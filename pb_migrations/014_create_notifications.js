// pb_migrations/014_create_notifications.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "notifications",
        fields: [
            {
                name: "title",
                type: "text",
                required: true,
            },
            {
                name: "body",
                type: "text",
                required: true,
            },
            {
                name: "type",
                type: "select",
                required: true,
                values: [
                    "chat", "offer", "price_drop", "recommendation",
                    "referral", "system", "inactivity", "seller_reminder",
                ],
            },
            { name: "is_read", type: "bool" },
            { name: "data", type: "json" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("notifications");
    app.delete(collection);
});
