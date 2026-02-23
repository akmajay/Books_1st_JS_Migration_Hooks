// pb_migrations/013_create_search_history.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "search_history",
        fields: [
            {
                name: "query",
                type: "text",
                required: true,
            },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("search_history");
    app.delete(collection);
});
