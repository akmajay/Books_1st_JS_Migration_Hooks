// pb_migrations/004_create_bundle_items.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "bundle_items",
        fields: [
            {
                name: "item_title",
                type: "text",
                required: true,
            },
            { name: "item_author", type: "text" },
            {
                name: "item_condition",
                type: "select",
                values: ["like_new", "good", "fair"],
            },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("bundle_items");
    app.delete(collection);
});
