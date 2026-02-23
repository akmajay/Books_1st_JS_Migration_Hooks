
// referral_hooks.pb.js

// 1. Auto-Generate Referral Code on User Creation
onRecordAfterCreateSuccess((e) => {
    const user = e.record;
    if (!user.get("referral_code")) {
        let code;
        let exists = true;
        let attempts = 0;

        while (exists && attempts < 10) {
            code = $security.randomString(6).toUpperCase();
            try {
                // Check if code collision
                e.app.findFirstRecordByFilter("users", `referral_code = "${code}"`);
                attempts++;
            } catch (err) {
                exists = false; // No record found = Success
            }
        }

        if (code) {
            user.set("referral_code", code);
            e.app.saveRecord(user);
        }
    }
}, "users");

// 2. Referral Redemption on Profile Update (Referred By Code)
onRecordAfterUpdateSuccess((e) => {
    const user = e.record;
    const refCode = user.getString("referred_by_code");
    const oldRefCode = e.record.originalCopy().getString("referred_by_code");

    // Only proceed if code is being set for the first time
    if (refCode && !oldRefCode) {
        try {
            const referrer = e.app.findFirstRecordByFilter("users", `referral_code = "${refCode}"`);

            // Block self-referral
            if (referrer.id === user.id) {
                console.log("Self-referral blocked for user: " + user.id);
                return;
            }

            // Link referrer relation
            user.set("referred_by", referrer.id);
            e.app.saveRecord(user);

            // Create referral record entry
            const refCollection = e.app.findCollectionByNameOrId("referrals");
            const ref = new Record(refCollection);
            ref.set("referrer", referrer.id);
            ref.set("referred_user", user.id);
            ref.set("code_used", refCode);
            ref.set("status", "joined");
            e.app.saveRecord(ref);

            // Award "Connector" badge if this is their first referral
            const existingRefsResult = e.app.findRecordsByFilter("referrals", `referrer = "${referrer.id}"`, "-created", 2);
            if (existingRefsResult.length === 1) {
                try {
                    const badgeCollection = e.app.findCollectionByNameOrId("badges");
                    const badge = new Record(badgeCollection);
                    badge.set("user", referrer.id);
                    badge.set("type", "connector");
                    badge.set("title", "Connector");
                    badge.set("description", "Referred your first friend!");
                    e.app.saveRecord(badge);
                } catch (be) {
                    console.error("Error awarding connector badge: " + be);
                }
            }

            // Push Notification to Referrer
            // Note: sendPushNotification helper is expected to be global from notification_hooks.pb.js
            if (typeof sendPushNotification === 'function') {
                sendPushNotification(e.app, referrer.id,
                    "👥 New Referral!",
                    `${user.getString("name")} joined using your code. Both of you get rewards!`,
                    { type: "referral", userId: user.id }
                );
            }

        } catch (err) {
            console.log("Invalid referral code used: " + refCode);
        }
    }
}, "users");
