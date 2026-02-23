// Increment views_count when a book detail is viewed
// Use a custom API endpoint: GET /api/books/:id/view
routerAdd("GET", "/api/books/{id}/view", (e) => {
    const id = e.request.pathValue("id");

    try {
        // Find the book record
        const book = e.app.findRecordById("books", id);

        // Increment count
        const currentViews = book.getInt("views_count");
        book.set("views_count", currentViews + 1);

        e.app.save(book);

        return e.json(200, {
            "id": id,
            "views": book.getInt("views_count")
        });
    } catch (err) {
        return e.error(404, "Book not found", err);
    }
});
