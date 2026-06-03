#[derive(Debug, schematic::Schematic, serde::Deserialize, serde::Serialize)]
#[serde(default, deny_unknown_fields, rename_all = "kebab-case")]
pub struct PluginConfig {
    pub dist_url: String,
}

impl Default for PluginConfig {
    fn default() -> Self {
        Self {
            dist_url: "https://example.com/releases/{version}/{platform}-{arch}.{ext}".into(),
        }
    }
}
