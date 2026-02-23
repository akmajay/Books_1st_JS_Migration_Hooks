// pb_migrations/016_create_blocked_users.js
/// @ts-check

// This collection will only have relation fields (added in Prompt 3)
// + system fields (id, created, updated).

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "blocked_users",
        fields: [],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("blocked_users");
    app.delete(collection);
});
