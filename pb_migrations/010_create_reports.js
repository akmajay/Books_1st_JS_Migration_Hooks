// pb_migrations/010_create_reports.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "reports",
        fields: [
            {
                name: "type",
                type: "select",
                required: true,
                values: ["listing", "user", "bug"],
            },
            {
                name: "reason",
                type: "select",
                required: true,
                values: [
                    "fake_listing", "wrong_price", "inappropriate",
                    "spam", "harassment", "other",
                ],
            },
            { name: "description", type: "text", max: 500 },
            {
                name: "screenshot",
                type: "file",
                maxSelect: 1,
                maxSize: 1048576,
            },
            { name: "target_type", type: "text" },
            { name: "target_id", type: "text" },
            {
                name: "status",
                type: "select",
                values: ["pending", "reviewed", "actioned", "dismissed"],
            },
            { name: "admin_notes", type: "text" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("reports");
    app.delete(collection);
});
