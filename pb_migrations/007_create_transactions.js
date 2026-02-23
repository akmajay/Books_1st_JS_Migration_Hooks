// pb_migrations/007_create_transactions.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "transactions",
        fields: [
            {
                name: "agreed_price",
                type: "number",
                required: true,
                min: 0,
            },
            {
                name: "status",
                type: "select",
                required: true,
                values: ["initiated", "confirmed", "handover_pending", "completed", "reviewed", "disputed"],
            },
            { name: "handover_token", type: "text" },
            { name: "token_expires_at", type: "date" },
            { name: "qr_token", type: "text" }, // Legacy/Prompt 15 overlap
            { name: "qr_generated_at", type: "date" },
            { name: "completed_at", type: "date" },
            { name: "is_offline_sync_pending", type: "bool" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("transactions");
    app.delete(collection);
});
