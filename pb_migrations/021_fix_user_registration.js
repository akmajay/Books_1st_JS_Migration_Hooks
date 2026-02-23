// pb_migrations/021_fix_user_registration.js
/// @ts-check

migrate((app) => {
    const users = app.findCollectionByNameOrId("users");

    // Make phone and user_type optional for OAuth registration
    const phone = users.fields.getByName("phone");
    if (phone) {
        phone.required = false;
    }

    const userType = users.fields.getByName("user_type");
    if (userType) {
        userType.required = false;
    }

    app.save(users);

    // Ensure Public access is properly set (using null for true public access)
    const books = app.findCollectionByNameOrId("books");
    books.listRule = "";
    books.viewRule = "";
    app.save(books);

    const schools = app.findCollectionByNameOrId("schools");
    schools.listRule = "";
    schools.viewRule = "";
    app.save(schools);

}, (app) => {
    // Revert logic (not critical here)
});
