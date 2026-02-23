// pb_migrations/011_create_banners.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "banners",
        fields: [
            {
                name: "title",
                type: "text",
                required: true,
            },
            {
                name: "image",
                type: "file",
                required: true,
                maxSelect: 1,
                maxSize: 1048576,
                mimeTypes: ["image/jpeg", "image/png", "image/webp"],
            },
            { name: "link", type: "url" },
            { name: "start_date", type: "date", required: true },
            { name: "end_date", type: "date", required: true },
            { name: "is_active", type: "bool" },
            { name: "sort_order", type: "number" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("banners");
    app.delete(collection);
});
