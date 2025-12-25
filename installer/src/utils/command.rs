use std::process::{Command, Stdio};
use anyhow::{Context, Result};

pub fn run_script_function(function_name: &str) -> Result<()> {
    let script_path = std::env::current_dir()?
        .parent()
        .ok_or_else(|| anyhow::anyhow!("Could not find parent directory"))?
        .join("install-functions.sh");

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

pub fn check_yay() -> bool {
    Command::new("which")
        .arg("yay")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}
