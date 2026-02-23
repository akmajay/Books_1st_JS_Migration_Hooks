// pb_hooks/transaction_hooks.pb.js

// 1. Generate handover token when transaction moves to handover_pending
onRecordAfterUpdateSuccess((e) => {
    const txn = e.record;

    // Only trigger if status is handover_pending and token isn't already set
    if (txn.get("status") === "handover_pending" && !txn.get("handover_token")) {
        const token = $security.randomString(32);
        txn.set("handover_token", token);

        // Expires in 24 hours
        const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
        txn.set("token_expires_at", expiresAt);

        e.app.save(txn);

        console.log(`Generated handover token for transaction ${txn.id}`);
    }
}, "transactions");

// 2. Custom API to verify QR handover
routerAdd("POST", "/api/transactions/{id}/verify-handover", (e) => {
    const txnId = e.request.pathValue("id");
    const data = $apis.requestInfo(e).data;
    const token = data.token;

    if (!token) {
        return e.json(400, { error: "Handover token is required" });
    }

    const txn = e.app.findRecordById("transactions", txnId);
    if (!txn) {
        return e.json(404, { error: "Transaction not found" });
    }

    // Role check: Only the buyer can scan/verify
    const authRecord = e.get("authRecord");
    if (!authRecord || authRecord.id !== txn.get("buyer")) {
        return e.json(403, { error: "Unauthorized. Only the buyer can confirm handover." });
    }

    // Status check
    if (txn.get("status") !== "handover_pending") {
        return e.json(400, { error: "Transaction is not in handover_pending state" });
    }

    // Token validation
    if (txn.get("handover_token") !== token) {
        return e.json(400, { error: "Invalid handover code" });
    }

    // Expiry check
    const expiresAt = new Date(txn.get("token_expires_at"));
    if (expiresAt < new Date()) {
        return e.json(400, { error: "Handover code has expired. Please ask the seller to regenerate." });
    }

    // success!
    txn.set("status", "completed");
    txn.set("completed_at", new Date().toISOString());
    txn.set("handover_token", ""); // Clear token for security
    e.app.save(txn);

    // Mark book as sold
    try {
        const book = e.app.findRecordById("books", txn.get("book"));
        if (book) {
            book.set("status", "sold");
            book.set("sold_at", new Date().toISOString());
            e.app.save(book);
        }
    } catch (err) {
        console.log("Error marking book as sold: " + err);
    }

    return e.json(200, { message: "Handover verified successfully!" });
});

// 3. After a review is created, update the seller's trust score
onRecordAfterCreateSuccess((e) => {
    const review = e.record;
    const sellerId = review.get("reviewed_user");
    const txnId = review.get("transaction");

    try {
        // Fetch all reviews for this seller
        const reviews = e.app.findAllRecords("reviews", $expr.eq("reviewed_user", sellerId));

        let totalRating = 0;
        reviews.forEach((r) => {
            totalRating += r.get("rating");
        });

        const avgRating = totalRating / reviews.length;
        const roundedRating = Math.round(avgRating * 10) / 10;

        // Update seller user
        const seller = e.app.findRecordById("users", sellerId);
        seller.set("trust_score", roundedRating);
        seller.set("total_reviews", reviews.length);
        e.app.save(seller);

        // Update transaction status to terminal state
        const txn = e.app.findRecordById("transactions", txnId);
        if (txn && txn.get("status") === "completed") {
            txn.set("status", "reviewed");
            e.app.save(txn);
        }

    } catch (err) {
        console.log("Error updating trust score: " + err);
    }
}, "reviews");
