// pb_migrations/003_create_books.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "books",
        fields: [
            {
                name: "title",
                type: "text",
                required: true,
                min: 2,
                max: 200,
            },
            {
                name: "author",
                type: "text",
                required: true,
            },
            { name: "edition", type: "text" },
            { name: "publisher", type: "text" },
            { name: "description", type: "text", max: 1000 },
            {
                name: "photos",
                type: "file",
                required: true,
                maxSelect: 3,
                maxSize: 524288,
                mimeTypes: ["image/jpeg", "image/png", "image/webp"],
            },
            { name: "mrp", type: "number", min: 0 },
            {
                name: "selling_price",
                type: "number",
                required: true,
                min: 0,
            },
            {
                name: "condition",
                type: "select",
                required: true,
                values: ["like_new", "good", "fair"],
            },
            {
                name: "condition_tags",
                type: "select",
                maxSelect: 6,
                values: [
                    "highlighted", "notes_margins", "missing_cover",
                    "all_pages_intact", "slight_yellowing", "water_damage",
                ],
            },
            {
                name: "category",
                type: "select",
                required: true,
                values: [
                    "school", "jee_engineering", "neet_medical",
                    "bank_ssc", "govt_upsc", "college", "other",
                ],
            },
            { name: "class_year", type: "text" },
            {
                name: "board",
                type: "select",
                values: ["CBSE", "ICSE", "State Board", "IB", "Other"],
            },
            {
                name: "stream",
                type: "select",
                values: ["Science", "Commerce", "Arts", "General"],
            },
            {
                name: "status",
                type: "select",
                required: true,
                values: ["active", "reserved", "sold", "archived", "draft"],
            },
            { name: "is_bundle", type: "bool" },
            { name: "bundle_name", type: "text" },
            { name: "bundle_total_mrp", type: "number" },
            { name: "handover_area", type: "text" },
            { name: "available_from", type: "date" },
            { name: "views_count", type: "number", min: 0 },
            { name: "wishlist_count", type: "number", min: 0 },
            { name: "location_lat", type: "number" },
            { name: "location_lon", type: "number" },
            { name: "is_priority", type: "bool" },
            { name: "auto_archive_date", type: "date" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("books");
    app.delete(collection);
});
