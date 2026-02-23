
// notification_hooks.pb.js

/**
 * Sends a push notification via FCM HTTP v1 API
 */
function sendPushNotification(app, recipientId, title, body, data) {
    try {
        const user = app.findRecordById("users", recipientId);
        const fcmToken = user.getString("fcm_token");

        if (!fcmToken) {
            console.log("No FCM token for user: " + recipientId);
            return;
        }

        // Check user preferences
        const prefs = user.get("notification_preferences") || {};
        const type = data.type;

        // Map data type to preference keys
        let prefKey = type;
        if (type === 'new_message') prefKey = 'new_message';
        if (type === 'new_offer') prefKey = 'new_offer';
        if (type === 'handover_ready' || type === 'transaction_complete') prefKey = 'transactions';
        if (type === 'price_drop') prefKey = 'price_drop';
        if (type === 'new_review') prefKey = 'new_review';

        if (prefs[prefKey] === false) {
            console.log("User opted out of " + prefKey + " notifications");
            return;
        }

        // 1. Create In-App Notification Record
        const notifCollection = app.findCollectionByNameOrId("notifications");
        const notif = new Record(notifCollection);
        notif.set("user", recipientId);
        notif.set("title", title);
        notif.set("body", body);
        notif.set("type", type);
        notif.set("data", JSON.stringify(data));
        notif.set("is_read", false);
        app.saveRecord(notif);

        // 2. Fetch Project ID from settings
        const settings = app.findFirstRecordByFilter("settings", "active = true");
        const projectId = settings ? settings.getString("firebase_project_id") : "jayganga-books-f4a42";

        // 3. Send Push via FCM
        // Note: Access token retrieval logic usually involves a service account.
        // For PB, we assume a helper or env var provides it.
        const accessToken = $os.getenv("FCM_ACCESS_TOKEN");

        if (accessToken) {
            $http.send({
                url: `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer " + accessToken
                },
                body: JSON.stringify({
                    message: {
                        token: fcmToken,
                        notification: { title, body },
                        data: data,
                        android: { priority: "high" }
                    }
                })
            });
        }
    } catch (e) {
        console.error("Error sending push notification: ", e);
    }
}

// triggers

// 1. New Message or Offer
onRecordAfterCreateSuccess((e) => {
    const msg = e.record;
    const chat = e.app.findRecordById("chats", msg.getString("chat"));
    const senderId = msg.getString("sender");
    const recipientId = senderId === chat.getString("buyer") ? chat.getString("seller") : chat.getString("buyer");
    const sender = e.app.findRecordById("users", senderId);
    const senderName = sender.getString("name");

    const type = msg.getString("type");

    if (type === 'text') {
        sendPushNotification(e.app, recipientId, senderName, msg.getString("content"), {
            type: "new_message",
            chatId: chat.id
        });
    } else if (type === 'offer') {
        const book = e.app.findRecordById("books", chat.getString("book"));
        sendPushNotification(e.app, chat.getString("seller"), "💰 New Offer!",
            `₹${msg.getInt("offer_amount")} offered for "${book.getString("title")}"`,
            { type: "new_offer", chatId: chat.id }
        );
    } else if (type === 'image') {
        sendPushNotification(e.app, recipientId, senderName, "📷 Sent a photo", {
            type: "new_message",
            chatId: chat.id
        });
    }
}, "messages");

// 2. Transaction Status
onRecordAfterUpdateSuccess((e) => {
    const txn = e.record;
    const oldStatus = e.record.originalCopy().getString("status");
    const newStatus = txn.getString("status");

    if (oldStatus === newStatus) return;

    const book = e.app.findRecordById("books", txn.getString("book"));
    const bookTitle = book.getString("title");

    if (newStatus === 'handover_pending') {
        sendPushNotification(e.app, txn.getString("buyer"), "📱 Handover Ready!",
            `Meet the seller and scan their QR for "${bookTitle}"`,
            { type: "handover_ready", txnId: txn.id }
        );
    } else if (newStatus === 'completed') {
        sendPushNotification(e.app, txn.getString("seller"), "✅ Deal Completed!",
            `"${bookTitle}" has been successfully handed over.`,
            { type: "transaction_complete", txnId: txn.id }
        );
        sendPushNotification(e.app, txn.getString("buyer"), "🌟 Review your purchase",
            `Please rate your experience with the seller for "${bookTitle}"`,
            { type: "transaction_complete", txnId: txn.id }
        );
    }
}, "transactions");

// 3. New Review
onRecordAfterCreateSuccess((e) => {
    const review = e.record;
    const reviewer = e.app.findRecordById("users", review.getString("reviewer"));
    const recipientId = review.getString("reviewed_user");

    sendPushNotification(e.app, recipientId, "⭐ New Review!",
        `${reviewer.getString("name")} gave you ${review.get("rating")} stars`,
        { type: "new_review", userId: recipientId }
    );
}, "reviews");

// 4. Price Drop
onRecordAfterUpdateSuccess((e) => {
    const book = e.record;
    const oldPrice = e.record.originalCopy().getInt("selling_price");
    const newPrice = book.getInt("selling_price");

    if (newPrice < oldPrice && oldPrice > 0) {
        const wishlists = e.app.findRecordsByFilter("wishlists", `book = "${book.id}"`);
        for (const wl of wishlists) {
            sendPushNotification(e.app, wl.getString("user"), "📉 Price Drop!",
                `"${book.getString("title")}" dropped to ₹${newPrice}!`,
                { type: "price_drop", bookId: book.id }
            );
        }
    }
}, "books");
