// pb_migrations/017_create_app_config_singleton.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "app_config",
        fields: [
            { name: "min_app_version", type: "text", required: true },
            { name: "latest_app_version", type: "text", required: true },
            { name: "maintenance_mode", type: "bool" },
            { name: "maintenance_message", type: "text" },
            { name: "maintenance_eta", type: "text" },
            { name: "play_store_url", type: "text" },
            { name: "terms_url", type: "text" },
            { name: "privacy_url", type: "text" },
            { name: "support_email", type: "text" },
            { name: "announcement", type: "text" },
            { name: "announcement_type", type: "select", values: ["info", "warning", "critical"] },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("app_config");
    app.delete(collection);
});
