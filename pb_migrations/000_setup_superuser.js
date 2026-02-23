// pb_migrations/024_setup_superuser.js
migrate((app) => {
    const email = "life.jay.com@gmail.com";
    const password = "Akhilesh@2026";

    try {
        // Try to find the existing superuser
        const existing = app.findAuthRecordByEmail("_superusers", email);
        existing.setPassword(password);
        app.save(existing);
    } catch (e) {
        // If not found, create a new superuser record
        const collection = app.findCollectionByNameOrId("_superusers");
        const record = new Record(collection);
        record.set("email", email);
        record.setPassword(password);
        app.save(record);
    }
}, (app) => {
    // No-op for revert to avoid accidental deletion of admins
});
