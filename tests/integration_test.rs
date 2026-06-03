#[cfg(feature = "wasm")]
use proto_pdk_test_utils::*;

#[cfg(feature = "wasm")]
mod plugin_tool {
    use super::*;

    #[tokio::test(flavor = "multi_thread")]
    async fn registers_metadata() {
        let sandbox = create_empty_proto_sandbox();
        let plugin = sandbox.create_plugin("plugin-test").await;

        let metadata = plugin.register_tool(RegisterToolInput::default()).await;

        assert_eq!(metadata.name, "TOOL_NAME");
        assert_eq!(metadata.self_upgrade_commands, vec!["upgrade"]);
        assert!(metadata.plugin_version.is_some());
    }
}
