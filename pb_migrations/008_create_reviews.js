// pb_migrations/008_create_reviews.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "reviews",
        fields: [
            { name: "reviewer", type: "relation", options: { collectionId: "users", maxSelect: 1 } },
            { name: "reviewed_user", type: "relation", options: { collectionId: "users", maxSelect: 1 } },
            { name: "rating", type: "number", min: 1, max: 5 },
            { name: "comment", type: "text" },
            { name: "tags", type: "json" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("reviews");
    app.delete(collection);
});
