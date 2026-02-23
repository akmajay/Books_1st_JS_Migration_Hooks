// pb_migrations/015_create_referrals.js
/// @ts-check

migrate((app) => {
    const collection = new Collection({
        type: "base",
        name: "referrals",
        fields: [
            {
                name: "referral_code",
                type: "text",
                required: true,
            },
            {
                name: "status",
                type: "select",
                required: true,
                values: ["invited", "registered", "completed"],
            },
            { name: "reward_granted", type: "bool" },
        ],
    });

    app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("referrals");
    app.delete(collection);
});
