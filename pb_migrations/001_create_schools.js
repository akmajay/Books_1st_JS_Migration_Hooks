// pb_migrations/001_create_schools.js
/// @ts-check

migrate((app) => {
  const collection = new Collection({
    type: "base",
    name: "schools",
    fields: [
      {
        name: "name",
        type: "text",
        required: true,
      },
      {
        name: "city",
        type: "text",
        required: true,
      },
      {
        name: "area",
        type: "text",
      },
      {
        name: "type",
        type: "select",
        required: true,
        values: ["school", "coaching", "college"],
      },
      {
        name: "board",
        type: "select",
        values: ["CBSE", "ICSE", "State Board", "IB", "Other"],
      },
      {
        name: "is_active",
        type: "bool",
      },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_schools_name ON schools (name)",
    ],
  });

  app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("schools");
  app.delete(collection);
});
