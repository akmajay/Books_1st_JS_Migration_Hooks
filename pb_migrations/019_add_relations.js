// pb_migrations/019_add_relations.js
/// @ts-check
//
// Adds ALL 24 relation fields across 11 collections.
// Runs after migrations 001–018 (all collections exist).
//

migrate((app) => {
    // Helper: resolve collection ID by name
    const id = (name) => app.findCollectionByNameOrId(name).id;

    // ─────────────────────────────────────────────────────────
    // 1. USERS — 2 relations (school, referred_by)
    // ─────────────────────────────────────────────────────────
    const users = app.findCollectionByNameOrId("users");

    users.fields.add(new RelationField({
        name: "school",
        collectionId: id("schools"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    users.fields.add(new RelationField({
        name: "referred_by",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    app.save(users);

    // ─────────────────────────────────────────────────────────
    // 2. BOOKS — 2 relations (seller, school)
    // ─────────────────────────────────────────────────────────
    const books = app.findCollectionByNameOrId("books");

    books.fields.add(new RelationField({
        name: "seller",
        required: true,
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    books.fields.add(new RelationField({
        name: "school",
        collectionId: id("schools"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    app.save(books);

    // ─────────────────────────────────────────────────────────
    // 3. BUNDLE_ITEMS — 1 relation (bundle → books, cascade)
    // ─────────────────────────────────────────────────────────
    const bundleItems = app.findCollectionByNameOrId("bundle_items");

    bundleItems.fields.add(new RelationField({
        name: "bundle",
        collectionId: id("books"),
        cascadeDelete: true,
        maxSelect: 1,
    }));

    app.save(bundleItems);

    // ─────────────────────────────────────────────────────────
    // 4. CHATS — 3 relations (buyer, seller, book)
    // ─────────────────────────────────────────────────────────
    const chats = app.findCollectionByNameOrId("chats");

    chats.fields.add(new RelationField({
        name: "buyer",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    chats.fields.add(new RelationField({
        name: "seller",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    chats.fields.add(new RelationField({
        name: "book",
        collectionId: id("books"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    chats.fields.add(new RelationField({
        name: "last_sender",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    app.save(chats);

    // ─────────────────────────────────────────────────────────
    // 5. MESSAGES — 2 relations (chat → cascade, sender)
    // ─────────────────────────────────────────────────────────
    const messages = app.findCollectionByNameOrId("messages");

    messages.fields.add(new RelationField({
        name: "chat",
        collectionId: id("chats"),
        cascadeDelete: true,
        maxSelect: 1,
    }));

    messages.fields.add(new RelationField({
        name: "sender",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    messages.fields.add(new RelationField({
        name: "receiver",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    app.save(messages);

    // ─────────────────────────────────────────────────────────
    // 6. TRANSACTIONS — 3 relations (book, buyer, seller)
    // ─────────────────────────────────────────────────────────
    const transactions = app.findCollectionByNameOrId("transactions");

    transactions.fields.add(new RelationField({
        name: "book",
        collectionId: id("books"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    transactions.fields.add(new RelationField({
        name: "buyer",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    transactions.fields.add(new RelationField({
        name: "seller",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    app.save(transactions);

    // ─────────────────────────────────────────────────────────
    // 7. REVIEWS — 3 relations (transaction → cascade, reviewer, reviewee)
    // ─────────────────────────────────────────────────────────
    const reviews = app.findCollectionByNameOrId("reviews");

    reviews.fields.add(new RelationField({
        name: "transaction",
        collectionId: id("transactions"),
        cascadeDelete: true,
        maxSelect: 1,
    }));

    reviews.fields.add(new RelationField({
        name: "reviewer",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    reviews.fields.add(new RelationField({
        name: "reviewed_user",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    app.save(reviews);

    // ─────────────────────────────────────────────────────────
    // 8. WISHLISTS — 2 relations (user → cascade, book → cascade)
    // ─────────────────────────────────────────────────────────
    const wishlists = app.findCollectionByNameOrId("wishlists");

    wishlists.fields.add(new RelationField({
        name: "user",
        collectionId: id("users"),
        cascadeDelete: true,
        maxSelect: 1,
    }));

    wishlists.fields.add(new RelationField({
        name: "book",
        collectionId: id("books"),
        cascadeDelete: true,
        maxSelect: 1,
    }));

    app.save(wishlists);

    // ─────────────────────────────────────────────────────────
    // 9. REPORTS — 1 relation (reporter)
    // ─────────────────────────────────────────────────────────
    const reports = app.findCollectionByNameOrId("reports");

    reports.fields.add(new RelationField({
        name: "reporter",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    app.save(reports);

    // ─────────────────────────────────────────────────────────
    // 10. SEARCH_HISTORY — 1 relation (user → cascade)
    // ─────────────────────────────────────────────────────────
    const searchHistory = app.findCollectionByNameOrId("search_history");

    searchHistory.fields.add(new RelationField({
        name: "user",
        collectionId: id("users"),
        cascadeDelete: true,
        maxSelect: 1,
    }));

    app.save(searchHistory);

    // ─────────────────────────────────────────────────────────
    // 11. NOTIFICATIONS — 1 relation (user → cascade)
    // ─────────────────────────────────────────────────────────
    const notifications = app.findCollectionByNameOrId("notifications");

    notifications.fields.add(new RelationField({
        name: "user",
        collectionId: id("users"),
        cascadeDelete: true,
        maxSelect: 1,
    }));

    app.save(notifications);

    // ─────────────────────────────────────────────────────────
    // 12. REFERRALS — 2 relations (referrer, referee)
    // ─────────────────────────────────────────────────────────
    const referrals = app.findCollectionByNameOrId("referrals");

    referrals.fields.add(new RelationField({
        name: "referrer",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    referrals.fields.add(new RelationField({
        name: "referee",
        collectionId: id("users"),
        cascadeDelete: false,
        maxSelect: 1,
    }));

    app.save(referrals);

    // ─────────────────────────────────────────────────────────
    // 13. BLOCKED_USERS — 2 relations (blocker → cascade, blocked → cascade)
    // ─────────────────────────────────────────────────────────
    const blockedUsers = app.findCollectionByNameOrId("blocked_users");

    blockedUsers.fields.add(new RelationField({
        name: "blocker",
        collectionId: id("users"),
        cascadeDelete: true,
        maxSelect: 1,
    }));

    blockedUsers.fields.add(new RelationField({
        name: "blocked",
        collectionId: id("users"),
        cascadeDelete: true,
        maxSelect: 1,
    }));

    app.save(blockedUsers);

}, (app) => {
    // ─── REVERT: Remove all 24 relation fields ───────────────

    const removeField = (collectionName, fieldName) => {
        const col = app.findCollectionByNameOrId(collectionName);
        const field = col.fields.getByName(fieldName);
        if (field) {
            col.fields.removeById(field.getId());
            app.save(col);
        }
    };

    // blocked_users
    removeField("blocked_users", "blocked");
    removeField("blocked_users", "blocker");

    // referrals
    removeField("referrals", "referee");
    removeField("referrals", "referrer");

    // notifications
    removeField("notifications", "user");

    // search_history
    removeField("search_history", "user");

    // reports
    removeField("reports", "reporter");

    // wishlists
    removeField("wishlists", "book");
    removeField("wishlists", "user");

    // reviews
    removeField("reviews", "reviewed_user");
    removeField("reviews", "reviewer");
    removeField("reviews", "transaction");

    // transactions
    removeField("transactions", "seller");
    removeField("transactions", "buyer");
    removeField("transactions", "book");

    // messages
    removeField("messages", "receiver");
    removeField("messages", "sender");
    removeField("messages", "chat");

    // chats
    removeField("chats", "last_sender");
    removeField("chats", "book");
    removeField("chats", "seller");
    removeField("chats", "buyer");

    // bundle_items
    removeField("bundle_items", "bundle");

    // books
    removeField("books", "school");
    removeField("books", "seller");

    // users
    removeField("users", "referred_by");
    removeField("users", "school");
});
