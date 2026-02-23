# ⚡ PocketBase Coder Guide
> **For Coding Agents:** This is the **definitive technical reference** for PocketBase.
> **Scope:** Deep internals, schema rules, API logic, and Flutter integration patterns.
> **Anti-Pattern:** Do NOT hallucinate SQL commands. PocketBase uses a Go-based abstraction over SQLite.

---

## 1. PocketBase Internals (The Stuff You Must Know)

### 1.1 Architecture
- **Single Binary:** The entire backend is one executable (`pocketbase` or `pocketbase.exe`).
- **Database:** Standard SQLite (in WAL mode). Stored in `pb_data/`.
- **Realtime:** Server-Sent Events (SSE). NOT WebSockets.
- **File Storage:** Local filesystem by default (`pb_data/storage`). S3 compatible.

### 1.2 Collections (Tables)
Every "Table" is a **Collection**.
1.  **Base Collection:** Standard data (e.g., `projects`, `tasks`).
2.  **Auth Collection:** Has built-in auth logic (email, password, salt). Users collection is `auth`.
3.  **View Collection:** Read-only SQL view (combines data).

### 1.3 System Fields (Automatic)
Every record in every collection has these **unmodifiable** fields:
- `id`: 15-character Unique ID (e.g., `a9f87dsd7s8d7s`). string.
- `created`: Date string (UTC).
- `updated`: Date string (UTC).
- **Auth only:** `username`, `email`, `emailVisibility`, `verified`.

### 1.4 Critical Field Types
- **Relation:** Links to another collection.
    - `cascadeDelete`: If true, deleting parent deletes child.
    - `maxSelect`: 1 = Single relation. >1 = Multiple relation.
- **JSON:** Stores any unstructured JSON data. Good for settings/metadata.
- **File:** Stores file paths.
    - URL Pattern: `{host}/api/files/{collection_id_or_name}/{record_id}/{filename}`

### 1.5 Schema via Code (Migrations)
If you cannot use the Admin UI, you use **JS Migrations** (`pb_migrations/*.js`).
```javascript
migrate((db) => {
  const dao = new Dao(db);
  const collection = new Collection({
    name: "posts",
    type: "base",
    schema: [
      { name: "title", type: "text", required: true },
      { name: "author", type: "relation", collectionId: "_pb_users_auth_", maxSelect: 1 }
    ]
  });
  return dao.saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("posts");
  return dao.deleteCollection(collection);
})
```

---

## 2. API Rules (The Logic Gate)

PocketBase doesn't use SQL Policies. It uses **API Rules**.
- 5 Rules per collection: `List`, `View`, `Create`, `Update`, `Delete`.
- Rule evaluates to **Boolean**. True = Allow. False = Deny.

### Syntax Cheat Sheet
| Syntax | Meaning |
|--------|---------|
| `""` (Empty String) | **Public** (Anyone can access). |
| `null` (Null) | **Admin Only** (No API access). |
| `@request.auth.id != ""` | **Any Logged-in User**. |
| `user = @request.auth.id` | **Owner Only** (Field `user` matches current auth ID). |
| `status = "active"` | **Filter** (Only active records). |
| `created > "2023-01-01"` | **Date Filter**. |

### Advanced Logic
- **AND:** `status = "active" && public = true`
- **OR:** `user = @request.auth.id || public = true`
- **LIKE:** `title ~ "draft"` (Contains "draft")
- **RELATION LOOKUP:** `@collection.projects.user ?= @request.auth.id` (Is user in projects?)

---

## 3. Server-Side Logic (pb_hooks)

**CRITICAL:** PocketBase uses **Goja** (Go JavaScript runtime).
- ❌ **NO npm packages.** You cannot `npm install`.
- ❌ **NO `require()`** (except typically built-in modules).
- ❌ **NO Node.js APIs** (fs, process, crypto).
- ✅ **YES** `$app` global for database access.
- ✅ **YES** `$http` for external API calls.
- ✅ **YES** `$os`, `$security`, `$filesystem` utils.

### Hook Example (Validation)
```javascript
// pb_hooks/validate_product.pb.js

onRecordBeforeCreateRequest((e) => {
    const product = e.record;
    
    // Get field value
    const price = product.get("price");
    
    if (price < 0) {
        throw new BadRequestError("Price cannot be negative");
    }

    // Set field value
    // Note: To use Go libs, we use special $ helpers
    const slug = $slug(product.get("name"));
    product.set("slug", slug);

}, "products");
```

---

## 4. Flutter Integration (Client Patterns)

### 4.1 Dependency
```yaml
dependencies:
  pocketbase: ^0.19.0
  shared_preferences: ^2.2.0  # REQUIRED for auth persistence
```

### 4.2 Initialization (Singleton + Persistence)
**CRITICAL:** Default `AuthStore` forgets login on restart. Use `AsyncAuthStore`.

```dart
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PocketBaseService {
  static PocketBase? _pb;

  static Future<PocketBase> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    final store = AsyncAuthStore(
      save:    (String data) async => prefs.setString('pb_auth', data),
      initial: prefs.getString('pb_auth'),
    );

    _pb = PocketBase('https://{domain}', authStore: store);
    return _pb!;
  }

  static PocketBase get instance {
    if (_pb == null) throw Exception("PocketBase not initialized");
    return _pb!;
  }
}
```

### 4.3 Typed Models (Best Practice)
Wrap `RecordModel` to avoid untyped Map access.

```dart
class Task {
  final String id;
  final String title;
  final bool isCompleted;

  Task.fromRecord(RecordModel record)
      : id = record.id,
        title = record.data['title'] ?? '',
        isCompleted = record.data['isCompleted'] ?? false;
  
  // Helper for JSON serialization if needed
  Map<String, dynamic> toJson() => {
    'title': title,
    'isCompleted': isCompleted,
  };
}

// Usage
final records = await pb.collection('tasks').getFullList();
final tasks = records.map((r) => Task.fromRecord(r)).toList();
```

### 4.4 Relations (Expand)
To fetch related data (JOIN), use the `expand` parameter.

```dart
// Fetch 'posts' and expand the 'author' relation
final result = await pb.collection('posts').getList(
  page: 1,
  perPage: 20,
  expand: 'author',
);

for (var record in result.items) {
  final author = record.expand['author']?[0];
  print(author?.data['username']);
}
```

### 4.5 Realtime (SSE)
Dart SDK handles reconnection automatically.

```dart
// Subscribe
pb.collection('chats').subscribe('*', (e) {
  print("Action: ${e.action}"); // create, update, delete
  print("Record: ${e.record}");
});

// Unsubscribe
pb.collection('chats').unsubscribe('*');
```

---

## 5. Deployment Checklist
1.  **Binary:** `./pocketbase serve --http="0.0.0.0:8090"`
2.  **Reverse Proxy:** Nginx/Caddy in front (for HTTPS).
3.  **Domain:** Point A Record to VPS IP.
4.  **Service:** Systemd file to keep it running.
