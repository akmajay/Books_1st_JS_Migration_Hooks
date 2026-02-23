// pb_migrations/020_set_api_rules.js
/// @ts-check
//
// Sets API rules for ALL 17 collections to enforce security.
// Runs after migrations 001–019.
//

migrate((app) => {
    // Helper: set rules for a collection
    const setRules = (name, rules) => {
        const collection = app.findCollectionByNameOrId(name);
        collection.listRule = rules.list;
        collection.viewRule = rules.view;
        collection.createRule = rules.create;
        collection.updateRule = rules.update;
        collection.deleteRule = rules.delete;
        app.save(collection);
    };

    // 1. users (Auth)
    setRules("users", {
        list: "", // Public
        view: "", // Public
        create: "", // Public
        update: "@request.auth.id = id", // Owner only
        delete: "@request.auth.id = id", // Owner only
    });

    // 2. schools
    setRules("schools", {
        list: "", // Public
        view: "", // Public
        create: null, // Admin only
        update: null, // Admin only
        delete: null, // Admin only
    });

    // 3. books
    setRules("books", {
        list: "", // Public
        view: "", // Public
        create: "@request.auth.id != ''", // Any logged-in user
        update: "@request.auth.id = seller", // Seller only
        delete: "@request.auth.id = seller", // Seller only
    });

    // 4. bundle_items
    setRules("bundle_items", {
        list: "", // Public
        view: "", // Public
        create: "@request.auth.id != ''", // Logged-in (ownership checked via hook)
        update: "@request.auth.id = bundle.seller", // Bundle seller only
        delete: "@request.auth.id = bundle.seller", // Bundle seller only
    });

    // 5. chats
    setRules("chats", {
        list: "@request.auth.id = buyer || @request.auth.id = seller", // Participants only
        view: "@request.auth.id = buyer || @request.auth.id = seller", // Participants only
        create: "@request.auth.id != ''", // Any logged-in user
        update: "@request.auth.id = buyer || @request.auth.id = seller", // Participants only
        delete: "@request.auth.id = buyer || @request.auth.id = seller", // Participants only
    });

    // 6. messages
    setRules("messages", {
        list: "@request.auth.id = chat.buyer || @request.auth.id = chat.seller", // Chat participants only
        view: "@request.auth.id = chat.buyer || @request.auth.id = chat.seller", // Chat participants only
        create: "@request.auth.id != '' && (@request.auth.id = chat.buyer || @request.auth.id = chat.seller)", // Must be participant
        update: "@request.auth.id = chat.buyer || @request.auth.id = chat.seller", // Participants only
        delete: null, // No deletion (audit trail)
    });

    // 7. transactions
    setRules("transactions", {
        list: "@request.auth.id = buyer || @request.auth.id = seller", // Parties only
        view: "@request.auth.id = buyer || @request.auth.id = seller", // Parties only
        create: "@request.auth.id != ''", // Any logged-in user
        update: "@request.auth.id = buyer || @request.auth.id = seller", // Parties only
        delete: null, // Never delete
    });

    // 8. reviews
    setRules("reviews", {
        list: "", // Public
        view: "", // Public
        create: "@request.auth.id != ''", // Any logged-in user
        update: "@request.auth.id = reviewer", // Reviewer only
        delete: null, // No deletion
    });

    // 9. wishlists
    setRules("wishlists", {
        list: "@request.auth.id = user", // Owner only
        view: "@request.auth.id = user", // Owner only
        create: "@request.auth.id != ''", // Any logged-in user
        update: null, // No updates
        delete: "@request.auth.id = user", // Owner only
    });

    // 10. reports
    setRules("reports", {
        list: null, // Admin only
        view: null, // Admin only
        create: "@request.auth.id != ''", // Any logged-in user
        update: null, // Admin only
        delete: null, // Admin only
    });

    // 11. banners
    setRules("banners", {
        list: "", // Public
        view: "", // Public
        create: null, // Admin only
        update: null, // Admin only
        delete: null, // Admin only
    });

    // 12. advertisements
    setRules("advertisements", {
        list: "", // Public
        view: "", // Public
        create: null, // Admin only
        update: null, // Admin only
        delete: null, // Admin only
    });

    // 13. search_history
    setRules("search_history", {
        list: "@request.auth.id = user", // Owner only
        view: "@request.auth.id = user", // Owner only
        create: "@request.auth.id != ''", // Logged-in users
        update: null, // No updates
        delete: "@request.auth.id = user", // Owner only
    });

    // 14. notifications
    setRules("notifications", {
        list: "@request.auth.id = user", // Owner only
        view: "@request.auth.id = user", // Owner only
        create: null, // Server/hooks only
        update: "@request.auth.id = user", // Owner only
        delete: "@request.auth.id = user", // Owner only
    });

    // 15. referrals
    setRules("referrals", {
        list: "@request.auth.id = referrer || @request.auth.id = referee", // Involved parties only
        view: "@request.auth.id = referrer || @request.auth.id = referee", // Involved parties only
        create: "@request.auth.id != ''", // Logged-in users
        update: null, // Server/hooks only
        delete: null, // Never delete
    });

    // 16. blocked_users
    setRules("blocked_users", {
        list: "@request.auth.id = blocker", // Blocker only
        view: "@request.auth.id = blocker", // Blocker only
        create: "@request.auth.id != ''", // Logged-in users
        update: null, // No updates
        delete: "@request.auth.id = blocker", // Blocker only
    });

    // 17. app_config
    setRules("app_config", {
        list: "", // Public
        view: "", // Public
        create: null, // Admin only
        update: null, // Admin only
        delete: null, // Admin only
    });

}, (app) => {
    // Revert: set all rules to null (locked)
    const collections = [
        "users", "schools", "books", "bundle_items", "chats", "messages",
        "transactions", "reviews", "wishlists", "reports", "banners",
        "advertisements", "search_history", "notifications", "referrals",
        "blocked_users", "app_config"
    ];

    for (const name of collections) {
        const collection = app.findCollectionByNameOrId(name);
        collection.listRule = null;
        collection.viewRule = null;
        collection.createRule = null;
        collection.updateRule = null;
        collection.deleteRule = null;
        app.save(collection);
    }
});
