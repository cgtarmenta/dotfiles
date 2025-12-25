use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Package {
    pub name: String,
    pub description: String,
    pub category: PackageCategory,
    pub required: bool,
    pub size_mb: Option<u32>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum PackageCategory {
    Core,
    Themes,
    Desktop,
    Development,
    Optional,
}

impl PackageCategory {
    pub fn as_str(&self) -> &str {
        match self {
            PackageCategory::Core => "Core Packages",
            PackageCategory::Themes => "Themes & Icons",
            PackageCategory::Desktop => "Desktop Applications",
            PackageCategory::Development => "Development Tools",
            PackageCategory::Optional => "Optional Programs",
        }
    }
}

impl Package {
    pub fn new(name: String, description: String, category: PackageCategory, required: bool) -> Self {
        Self {
            name,
            description,
            category,
            required,
            size_mb: None,
        }
    }
}
