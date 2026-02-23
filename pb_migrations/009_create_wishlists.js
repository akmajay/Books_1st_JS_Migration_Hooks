// pb_migrations/009_create_wishlists.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "wishlists",
        fields: [
            { name: "price_at_save", type: "number" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("wishlists");
    app.delete(collection);
});
