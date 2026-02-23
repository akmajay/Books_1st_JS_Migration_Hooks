// pb_migrations/002_create_users_custom_fields.js
/// @ts-check

// The `users` auth collection is auto-created by PocketBase.
// This migration ADDS custom fields to it.

migrate((app) => {
    const collection = app.findCollectionByNameOrId("users");

    // ── Profile Fields ────────────────────────────────────────
    collection.fields.add(new TextField({
        name: "phone",
        required: false,
        min: 10,
        max: 15,
    }));

    collection.fields.add(new SelectField({
        name: "user_type",
        required: false,
        values: ["school_student", "exam_aspirant", "college_student"],
    }));

    collection.fields.add(new TextField({ name: "class_year" }));

    collection.fields.add(new SelectField({
        name: "board",
        values: ["CBSE", "ICSE", "State Board", "IB", "Other"],
    }));

    collection.fields.add(new SelectField({
        name: "stream",
        values: ["Science", "Commerce", "Arts", "General"],
    }));

    collection.fields.add(new SelectField({
        name: "exam_type",
        values: ["JEE", "NEET", "Bank", "SSC", "UPSC", "State PSC", "Other"],
    }));

    collection.fields.add(new TextField({ name: "coaching_institute" }));
    collection.fields.add(new TextField({ name: "college_name" }));
    collection.fields.add(new TextField({ name: "college_branch" }));
    collection.fields.add(new TextField({ name: "college_semester" }));

    // ── Location Fields ───────────────────────────────────────
    collection.fields.add(new NumberField({ name: "location_lat" }));
    collection.fields.add(new NumberField({ name: "location_lon" }));
    collection.fields.add(new TextField({ name: "city" }));
    collection.fields.add(new TextField({ name: "area" }));

    // ── Bio & Social ──────────────────────────────────────────
    collection.fields.add(new TextField({ name: "bio", max: 500 }));
    collection.fields.add(new JSONField({ name: "badges" }));

    // ── Stats & Trust ─────────────────────────────────────────
    collection.fields.add(new NumberField({
        name: "trust_score",
        min: 0,
        max: 5,
    }));

    collection.fields.add(new NumberField({ name: "review_count", min: 0 }));
    collection.fields.add(new NumberField({ name: "total_sales", min: 0 }));
    collection.fields.add(new NumberField({ name: "total_purchases", min: 0 }));

    // ── Referral ──────────────────────────────────────────────
    collection.fields.add(new TextField({ name: "referral_code" }));

    // ── Push Notifications ────────────────────────────────────
    collection.fields.add(new TextField({ name: "fcm_token" }));

    // ── Moderation ────────────────────────────────────────────
    collection.fields.add(new BoolField({ name: "is_banned" }));
    collection.fields.add(new TextField({ name: "ban_reason" }));

    // ── Activity ──────────────────────────────────────────────
    collection.fields.add(new DateField({ name: "last_active" }));
    collection.fields.add(new BoolField({ name: "onboarding_complete" }));

    // ── Preferences ───────────────────────────────────────────
    collection.fields.add(new SelectField({
        name: "preferred_language",
        values: ["en", "hi"],
    }));

    collection.fields.add(new NumberField({
        name: "preferred_radius",
        min: 1,
        max: 10,
    }));

    collection.fields.add(new SelectField({
        name: "dark_mode",
        values: ["system", "light", "dark"],
    }));

    // ── Referral Reward ───────────────────────────────────────
    collection.fields.add(new DateField({ name: "priority_until" }));

    // ── Avatar ────────────────────────────────────────────────
    collection.fields.add(new FileField({
        name: "avatar",
        maxSelect: 1,
        maxSize: 524288,
        mimeTypes: ["image/jpeg", "image/png", "image/webp"],
    }));

    // ── Index ─────────────────────────────────────────────────
    collection.addIndex("idx_users_referral_code", true, "referral_code", "referral_code != ''");

    app.save(collection);
}, (app) => {
    // Revert: remove custom fields from users
    // Note: in practice, reverting this is complex. A fresh DB is simpler.
    const collection = app.findCollectionByNameOrId("users");

    const customFields = [
        "phone", "user_type", "class_year", "board", "stream", "exam_type",
        "coaching_institute", "college_name", "college_branch", "college_semester",
        "location_lat", "location_lon", "city", "area", "bio", "badges",
        "trust_score", "review_count", "total_sales", "total_purchases",
        "referral_code", "fcm_token", "is_banned", "ban_reason",
        "last_active", "onboarding_complete", "preferred_language",
        "preferred_radius", "dark_mode", "priority_until", "avatar",
    ];

    for (const fieldName of customFields) {
        const field = collection.fields.getByName(fieldName);
        if (field) {
            collection.fields.removeById(field.getId());
        }
    }

    app.save(collection);
});
