use std::process::{Command, Stdio};
use anyhow::{Context, Result};

pub fn run_script_function(function_name: &str) -> Result<()> {
    // Get the repository root directory (where install-functions.sh is located)
    let repo_root = std::env::current_dir()?
        .ancestors()
        .find(|p| p.join("install-functions.sh").exists())
        .ok_or_else(|| anyhow::anyhow!("Could not find install-functions.sh"))?
        .to_path_buf();
    
    let script_path = repo_root.join("install-functions.sh");

    let output = Command::new("bash")
        .arg("-c")
        .arg(format!("cd {} && source {} && {}", 
            script_path.parent().unwrap().display(),
            script_path.display(), 
            function_name))
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .stdin(Stdio::inherit())
        .output()
        .context("Failed to execute install script")?;

    if !output.status.success() {
        anyhow::bail!("Installation step failed");
    }

    Ok(())
}

/// Shelly is CachyOS's package manager and the only one this repo drives:
/// repositories, the AUR, Flatpaks and AppImages through one tool, elevating
/// itself where it needs to.
pub fn check_shelly() -> bool {
    Command::new("which")
        .arg("shelly")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}
