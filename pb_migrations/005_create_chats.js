// pb_migrations/005_create_chats.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "chats",
        fields: [
            { name: "last_message", type: "text" },
            { name: "last_message_at", type: "date" },
            { name: "last_sender", type: "relation", options: { collectionId: "users", maxSelect: 1 } },
            { name: "unread_count", type: "number", min: 0 },
            { name: "is_active", type: "bool" },
            { name: "is_deleted_by_buyer", type: "bool" },
            { name: "is_deleted_by_seller", type: "bool" },
            { name: "agreed_price", type: "number", min: 0 },
            { name: "offer_amount", type: "number" }, // Legacy/Prompt 14 overlap
            {
                name: "offer_status",
                type: "select",
                values: ["none", "pending", "accepted", "declined", "expired"],
            },
            { name: "offer_expires_at", type: "date" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("chats");
    app.delete(collection);
});
