// pb_migrations/018_seed_app_config_singleton.js
/// @ts-check

migrate((app) => {
    const collection = app.findCollectionByNameOrId("app_config");

    const record = new Record(collection);
    record.set("min_app_version", "1.0.0");
    record.set("latest_app_version", "1.0.0");
    record.set("maintenance_mode", false);
    record.set("maintenance_message", "We are performing maintenance.");
    record.set("maintenance_eta", "30 minutes");
    record.set("play_store_url", "https://play.google.com/store/apps/details?id=com.jayganga.books");
    record.set("terms_url", "https://api.jayganga.com/terms");
    record.set("privacy_url", "https://api.jayganga.com/privacy");
    record.set("support_email", "support@jayganga.com");
    record.set("announcement", "");
    record.set("announcement_type", "info");

    app.save(record);
}, (app) => {
    // No-op for seed rollback (or collection-wide delete if needed)
});
