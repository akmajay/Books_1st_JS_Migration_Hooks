// pb_migrations/006_create_messages.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "messages",
        fields: [
            { name: "chat", type: "relation", options: { collectionId: "chats", maxSelect: 1 } },
            { name: "sender", type: "relation", options: { collectionId: "users", maxSelect: 1 } },
            { name: "receiver", type: "relation", options: { collectionId: "users", maxSelect: 1 } },
            { name: "content", type: "text" },
            {
                name: "type",
                type: "select",
                values: ["text", "image", "offer", "system"],
            },
            { name: "image", type: "file", options: { maxSelect: 1, maxSize: 5242880 } },
            { name: "offer_amount", type: "number" },
            { name: "is_read", type: "bool" },
            { name: "read_at", type: "date" },
            { name: "is_delivered", type: "bool" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("messages");
    app.delete(collection);
});
