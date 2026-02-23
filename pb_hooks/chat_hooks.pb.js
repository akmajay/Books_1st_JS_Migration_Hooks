// pb_hooks/chat_hooks.pb.js

// When a message is created, update the chat's last_message fields
onRecordAfterCreateSuccess((e) => {
    const msg = e.record;
    const dao = e.app.dao();

    try {
        const chat = dao.findRecordById("chats", msg.get("chat"));

        let content = msg.get("content");
        if (msg.get("type") === "offer") content = "💰 Offer: ₹" + msg.get("offer_amount");
        if (msg.get("type") === "photo") content = "📷 Photo";

        chat.set("last_message", content);
        chat.set("last_message_at", msg.get("created"));
        chat.set("last_sender", msg.get("sender"));

        // Update unread count for receiver
        const unreadCount = dao.countRecords("messages", {
            "chat": chat.id,
            "receiver": msg.get("receiver"),
            "is_read": false
        });
        chat.set("unread_count", unreadCount);

        dao.saveRecord(chat);
    } catch (err) {
        console.log("Chat Hook Error (Create): " + err);
    }
}, "messages");

// When messages are marked as read, update unread count for the chat
onRecordAfterUpdateSuccess((e) => {
    const msg = e.record;
    const dao = e.app.dao();

    // Only trigger if is_read changed to true
    if (msg.get("is_read") && !e.originalRecord.get("is_read")) {
        try {
            const chat = dao.findRecordById("chats", msg.get("chat"));

            const unreadCount = dao.countRecords("messages", {
                "chat": chat.id,
                "receiver": msg.get("receiver"),
                "is_read": false
            });

            chat.set("unread_count", unreadCount);
            dao.saveRecord(chat);
        } catch (err) {
            console.log("Chat Hook Error (Update): " + err);
        }
    }
}, "messages");
