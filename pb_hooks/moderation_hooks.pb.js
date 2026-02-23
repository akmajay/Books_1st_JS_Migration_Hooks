/// moderation_hooks.pb.js
/// Auto-moderation: auto-hide books after 3 reports, auto-restrict users after 5.
/// Ban cascade: hide/restore listings when admin bans/unbans a user.

// Helper: send push notification
function sendModPush(app, userId, title, body, dataObj) {
    try {
        const user = app.findRecordById("users", userId);
        const token = user.getString("fcm_token");
        if (!token) return;

        // Create in-app notification record
        const notifCollection = app.findCollectionByNameOrId("notifications");
        const notif = new Record(notifCollection);
        notif.set("user", userId);
        notif.set("title", title);
        notif.set("body", body);
        notif.set("type", dataObj.type || "moderation");
        notif.set("data", JSON.stringify(dataObj));
        notif.set("is_read", false);
        app.save(notif);
    } catch (err) {
        console.log("Mod push error:", err);
    }
}

// ── After Report Created ────────────────────────────────
onRecordAfterCreateSuccess((e) => {
    const report = e.record;
    const targetType = report.getString("target_type");
    const targetId = report.getString("target_id");

    // ── Auto-hide book after 3 reports ──
    if (targetType === "book") {
        try {
            const reports = $app.findRecordsByFilter(
                "reports",
                'target_type = "book" && target_id = "' + targetId + '" && status != "dismissed"',
                "", 0, 100
            );
            if (reports.length >= 3) {
                const book = $app.findRecordById("books", targetId);
                if (book.getString("status") !== "hidden") {
                    book.set("status", "hidden");
                    book.set("hidden_reason", "auto_moderation");
                    $app.save(book);

                    sendModPush($app, book.getString("seller"),
                        "⚠️ Listing Hidden",
                        'Your listing "' + book.getString("title") + '" has been temporarily hidden due to reports. Our team will review it.',
                        { type: "listing_hidden", bookId: targetId }
                    );
                }
            }
        } catch (err) {
            console.log("Auto-hide error:", err);
        }
    }

    // ── Auto-restrict user after 5 reports ──
    if (targetType === "user") {
        try {
            const reports = $app.findRecordsByFilter(
                "reports",
                'target_type = "user" && target_id = "' + targetId + '" && status != "dismissed"',
                "", 0, 100
            );
            if (reports.length >= 5) {
                const user = $app.findRecordById("users", targetId);
                if (!user.getBool("is_restricted")) {
                    user.set("is_restricted", true);
                    user.set("restricted_reason", "Multiple reports received");
                    $app.save(user);

                    sendModPush($app, targetId,
                        "⚠️ Account Restricted",
                        "Your account has been temporarily restricted due to multiple reports. Contact support to appeal.",
                        { type: "account_restricted" }
                    );
                }
            }
        } catch (err) {
            console.log("Auto-restrict error:", err);
        }
    }
}, "reports");

// ── Ban / Unban Cascade ─────────────────────────────────
onRecordAfterUpdateSuccess((e) => {
    const user = e.record;
    const wasBanned = e.record.original().getBool("is_banned");
    const isBanned = user.getBool("is_banned");

    // ── User was just BANNED ──
    if (!wasBanned && isBanned) {
        try {
            // Hide all active listings
            const books = $app.findRecordsByFilter(
                "books",
                'seller = "' + user.id + '" && status = "available"',
                "", 0, 500
            );
            for (const book of books) {
                book.set("status", "hidden");
                book.set("hidden_reason", "user_banned");
                $app.save(book);
            }

            sendModPush($app, user.id,
                "🚫 Account Banned",
                "Your account has been banned for violating our community guidelines.",
                { type: "account_banned" }
            );
        } catch (err) {
            console.log("Ban cascade error:", err);
        }
    }

    // ── User was UNBANNED ──
    if (wasBanned && !isBanned) {
        try {
            const books = $app.findRecordsByFilter(
                "books",
                'seller = "' + user.id + '" && hidden_reason = "user_banned"',
                "", 0, 500
            );
            for (const book of books) {
                book.set("status", "available");
                book.set("hidden_reason", "");
                $app.save(book);
            }
        } catch (err) {
            console.log("Unban restore error:", err);
        }
    }
}, "users");
