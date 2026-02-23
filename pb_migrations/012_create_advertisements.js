// pb_migrations/012_create_advertisements.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "advertisements",
        fields: [
            {
                name: "business_name",
                type: "text",
                required: true,
            },
            {
                name: "logo",
                type: "file",
                maxSelect: 1,
                maxSize: 524288,
                mimeTypes: ["image/jpeg", "image/png", "image/webp"],
            },
            { name: "tagline", type: "text", max: 100 },
            { name: "link", type: "url" },
            { name: "phone", type: "text" },
            { name: "is_active", type: "bool" },
            { name: "sort_order", type: "number" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("advertisements");
    app.delete(collection);
});
