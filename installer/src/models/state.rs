use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InstallState {
    pub installed_packages: Vec<String>,
    pub deployed_configs: bool,
    pub enabled_services: Vec<String>,
    pub last_update: DateTime<Utc>,
    pub backups: Vec<BackupInfo>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BackupInfo {
    pub path: String,
    pub timestamp: DateTime<Utc>,
    pub size_bytes: u64,
}

impl Default for InstallState {
    fn default() -> Self {
        Self {
            installed_packages: Vec::new(),
            deployed_configs: false,
            enabled_services: Vec::new(),
            last_update: Utc::now(),
            backups: Vec::new(),
        }
    }
}

impl InstallState {
    pub fn load() -> anyhow::Result<Self> {
        let state_path = dirs::config_dir()
            .ok_or_else(|| anyhow::anyhow!("Could not find config directory"))?
            .join(".dotfiles-install-state.json");

        if !state_path.exists() {
            return Ok(Self::default());
        }

        let content = std::fs::read_to_string(&state_path)?;
        let state: InstallState = serde_json::from_str(&content)?;
        Ok(state)
    }

    pub fn save(&self) -> anyhow::Result<()> {
        let state_path = dirs::config_dir()
            .ok_or_else(|| anyhow::anyhow!("Could not find config directory"))?
            .join(".dotfiles-install-state.json");

        let content = serde_json::to_string_pretty(self)?;
        std::fs::write(&state_path, content)?;
        Ok(())
    }

    pub fn add_package(&mut self, package: String) {
        if !self.installed_packages.contains(&package) {
            self.installed_packages.push(package);
        }
        self.last_update = Utc::now();
    }

    pub fn add_service(&mut self, service: String) {
        if !self.enabled_services.contains(&service) {
            self.enabled_services.push(service);
        }
        self.last_update = Utc::now();
    }

    pub fn add_backup(&mut self, backup: BackupInfo) {
        self.backups.push(backup);
        self.last_update = Utc::now();
    }
}
