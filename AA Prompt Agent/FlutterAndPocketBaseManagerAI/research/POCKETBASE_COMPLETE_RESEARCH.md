# PocketBase v0.23+: Agent Implementation Reference

> **Purpose**: Directive reference for AI coding agents building backends with PocketBase. Every pattern is copy-ready. All syntax targets v0.23+ (the `$app` API, NOT legacy `dao`).

---

## 1. Architecture Overview

### 1.1 What PocketBase Is

A **single executable** bundling: SQLite database + REST API + Realtime (SSE) + Auth + File Storage + Admin UI. No external dependencies. No Docker required. No separate DB server.

- **Language**: Go 1.23+ with embedded SQLite in WAL mode
- **Concurrency**: Multiple simultaneous readers, one serialized writer. Writes are fast (no network hop to DB).
- **Deploy**: Copy binary + `pb_data/` folder. That's the entire backend.

### 1.2 PocketBase vs Supabase — When to Use Each

| Factor | PocketBase | Supabase |
|--------|-----------|----------|
| Database | Embedded SQLite (single file) | PostgreSQL (client-server) |
| Architecture | Monolithic (single process) | Microservices (containerized) |
| Scaling | Vertical (bigger CPU/RAM) | Horizontal (read replicas, sharding) |
| Extensibility | JavaScript hooks (Goja) / Go hooks | SQL stored procedures / Edge Functions |
| Deployment | Copy file to VPS | Docker orchestration required |
| Realtime | Native SSE (Server-Sent Events) | Elixir-based Realtime Engine |
| Best for | Self-hosted, simple apps, MVPs, offline-first | Complex SQL, PostGIS, enterprise horizontal scaling |

---

## 2. Directory Structure (Strict Contract)

```
project/
├── pocketbase          # The executable binary
├── pb_data/            # THE STATE — entire database + uploaded files
│   ├── data.db         # SQLite database (this IS the database)
│   └── storage/        # Uploaded files (if using local storage)
├── pb_migrations/      # Schema version control (JS or Go files)
├── pb_hooks/           # Server-side business logic (JS files)
└── pb_public/          # Static file serving (SPA build artifacts)
```

**Critical rules:**
- `pb_data/` is everything. Backup = copy this folder. Lose it = lose everything.
- `pb_migrations/` files auto-run on startup (checks `_migrations` table, skips already-applied).
- `pb_hooks/` hot-reloads on Linux/macOS. **Does NOT hot-reload on Windows** — restart required.
- `pb_public/` serves `index.html` at root `/` — deploy SPA builds here for full-stack single-binary apps.

---

## 3. Collections (Data Modeling)

### 3.1 Three Collection Types

| Type | Purpose | Special Fields |
|------|---------|---------------|
| **Base** | Standard data (posts, products, tasks) | `id`, `created`, `updated` (auto-generated, reserved) |
| **Auth** | Entities that log in (users, drivers, admins) | All Base fields + `email`, `emailVisibility`, `verified`, `password` (hashed) |
| **View** | Read-only SQL projection (aggregations, joins) | Defined by SQL query, exposed via standard REST API |

**Design pattern**: Create separate Auth collections for distinct user types (e.g., `customers` vs `staff`). They get completely isolated auth scopes, permissions, and OAuth providers.

### 3.2 Field Types

| Field Type | SQLite Storage | Agent Notes |
|-----------|---------------|-------------|
| `text` | TEXT | Min/max length, regex pattern validation |
| `number` | REAL | Min/max value, supports integer or float |
| `bool` | INTEGER | Stored as 0/1 |
| `email` | TEXT | Enforces email format, optional unique constraint |
| `url` | TEXT | Enforces URL format |
| `date` | TEXT | **Stored as UTC ISO8601 string** — normalize all dates to UTC before saving |
| `select` | TEXT (JSON) | Single (string) or Multiple (JSON array). Predefined options list |
| `file` | TEXT (JSON) | Stores filenames. Configure max size, MIME types, max file count |
| `relation` | TEXT (JSON) | Stores record ID(s). Single or Multiple. Configure cascade delete |
| `json` | TEXT | Raw JSON blob. Filtering on JSON attributes is slower than native fields |

### 3.3 Relations and Expand

```javascript
// BAD: N+1 queries (fetch comments, then fetch user for each)
const comments = await pb.collection('comments').getList();
for (const c of comments) {
  c.user = await pb.collection('users').getOne(c.user_id); // N extra requests!
}

// GOOD: Use expand — single request, PocketBase handles the join
const comments = await pb.collection('comments').getList(1, 50, {
  expand: 'user,post.author'  // Nested expansion supported
});
// Access: comments.items[0].expand.user.name
```

**Cascade Delete**: Off by default. If enabled, deleting parent auto-deletes children. If off, child keeps a dangling reference.

---

## 4. API Security Rules

### 4.1 Rule System

Rules are **declarative expressions** (not middleware code) set per collection. They evaluate to `true` (allow) or `false` (deny).

| Rule | Controls |
|------|----------|
| `listRule` | Who can list/search records |
| `viewRule` | Who can view a single record |
| `createRule` | Who can create records |
| `updateRule` | Who can update records |
| `deleteRule` | Who can delete records |

**Defaults:**
- `null` = **Locked** — only superusers can access
- `""` (empty string) = **Public** — anyone including guests

### 4.2 Key Variables

| Variable | Meaning |
|----------|---------|
| `@request.auth.id` | Current logged-in user's ID (empty if guest) |
| `@request.auth.collectionName` | Which auth collection the user belongs to |
| `@request.body.fieldName` | Data being submitted (create/update rules) |
| `@request.headers.x_custom` | HTTP request headers |

### 4.3 Common Security Patterns

```
# "Own Data" — users see only their own records
listRule:   user = @request.auth.id
viewRule:   user = @request.auth.id
updateRule: user = @request.auth.id
deleteRule: user = @request.auth.id

# "Public Read, Auth Write, Owner Edit"
listRule:   ""
viewRule:   ""
createRule: @request.auth.id != ""
updateRule: author = @request.auth.id
deleteRule: author = @request.auth.id

# "Team Access" — users see records from their team
listRule:   @request.auth.team_id = team_id
viewRule:   @request.auth.team_id = team_id

# "Prevent field tampering" — block users from setting role field
createRule: @request.body.role:isset = false
```

### 4.4 Relational Rule Traversal

Rules can traverse relationships: `project.owner.id = @request.auth.id` — allows access if the project's owner matches the current user.

---

## 5. Authentication

### 5.1 Methods

| Method | Flow | Use Case |
|--------|------|----------|
| **Email/Password** | Client sends credentials → Server validates bcrypt hash → Returns JWT | Standard login |
| **OAuth2** | SDK opens popup → User auths with Google/GitHub/Apple → PocketBase creates/updates user → Returns JWT | Social login |
| **OTP** | `requestOTP(email)` sends code → `authWithOTP(id, code)` validates → Returns JWT | Magic link / passwordless |
| **MFA** | Login returns `401` with `mfaId` → Client sends second factor → Returns JWT | Two-step verification |

> **MFA handling**: Agent MUST handle the `401` intermediate state. Login does NOT always return a token immediately when MFA is enabled.

### 5.2 Token System (Stateless JWT)

- **No server sessions** — validity checked via token signature only
- **Default expiry**: 14 days (configurable)
- **Revoke all sessions**: Change user's `tokenKey` field → invalidates ALL existing tokens
- **Refresh**: `pb.collection('users').authRefresh()` — issues new token if current is valid

### 5.3 Superusers (v0.23+)

Admins are now records in the `_superusers` system auth collection (no longer a separate entity type). They:
- Bypass ALL collection API rules
- Cannot use OAuth2
- Managed via CLI: `./pocketbase superuser create email@example.com password`
- Managed via CLI: `./pocketbase superuser upsert email@example.com password` (create or update)

---

## 6. Client SDK — JavaScript

### 6.1 Setup

```javascript
import PocketBase from 'pocketbase';
const pb = new PocketBase('https://your-server.com');
```

**React Native** — localStorage doesn't exist, use AsyncAuthStore:

```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';
import PocketBase, { AsyncAuthStore } from 'pocketbase';

const store = new AsyncAuthStore({
  save:    async (serialized) => AsyncStorage.setItem('pb_auth', serialized),
  initial: AsyncStorage.getItem('pb_auth'),
});
const pb = new PocketBase('https://your-server.com', store);
```

### 6.2 CRUD Operations

```javascript
// CREATE
const record = await pb.collection('posts').create({
  title: 'Hello World',
  author: pb.authStore.record.id,
});

// READ — paginated
const result = await pb.collection('posts').getList(1, 20, {
  filter: 'created > "2024-01-01"',
  sort: '-created',
  expand: 'author',
});

// READ — single record
const post = await pb.collection('posts').getOne('RECORD_ID');

// UPDATE
await pb.collection('posts').update('RECORD_ID', { title: 'Updated' });

// DELETE
await pb.collection('posts').delete('RECORD_ID');
```

### 6.3 Filtering & Sorting

```javascript
// ALWAYS use parameterized filters for user input — prevents injection
const result = await pb.collection('posts').getList(1, 20, {
  filter: pb.filter('title ~ {:search} && status = {:status}', {
    search: userInput,
    status: 'published',
  }),
  sort: '-created,+title',  // Descending created, ascending title
});
```

**Filter operators:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Equals | `status = "active"` |
| `!=` | Not equals | `status != "draft"` |
| `>`, `>=`, `<`, `<=` | Comparison | `created > "2024-01-01"` |
| `~` | Contains (case-insensitive) | `title ~ "report"` |
| `!~` | Not contains | `title !~ "draft"` |
| `?=` | Any equal (multi-relation/array) | `tags ?= "urgent"` |

**Field modifiers** (for API rules):

| Modifier | Meaning | Example |
|----------|---------|---------|
| `:isset` | Field present in payload | `@request.body.role:isset = false` |
| `:changed` | Value differs from DB | `@request.body.status:changed = true` |
| `:length` | Array length | `@request.body.tags:length <= 3` |
| `:each` | Every element matches | `@request.body.tags:each ~ "valid_"` |

**Temporal macros**: `@now`, `@todayStart`, `@todayEnd`, `@yesterday`, `@tomorrow`

### 6.4 Realtime (SSE)

```javascript
// Subscribe to all changes in a collection
pb.collection('messages').subscribe('*', (e) => {
  console.log(e.action, e.record);  // action: 'create' | 'update' | 'delete'
});

// Subscribe to specific record
pb.collection('messages').subscribe('RECORD_ID', (e) => { ... });

// CRITICAL: Unsubscribe when done
pb.collection('messages').unsubscribe('*');
pb.collection('messages').unsubscribe();  // Unsubscribe from everything
```

**Access control**: Realtime events respect API rules. If user can't `view` a record, they won't receive push events for it.

### 6.5 File Upload

```javascript
// Browser — standard FormData
const formData = new FormData();
formData.append('title', 'My Post');
formData.append('image', fileInput.files[0]);
const record = await pb.collection('posts').create(formData);

// React Native — MUST use { uri, type, name } object
formData.append('image', {
  uri: uriFromImagePicker,
  type: 'image/jpeg',
  name: 'photo.jpg',
});

// Get file URL
const url = pb.files.getURL(record, record.image);

// Protected file (requires token)
const token = await pb.files.getToken();
const url = pb.files.getURL(record, 'document.pdf', { token, thumb: '100x100' });
```

**Thumbnail modes**: `100x100` (crop), `100x100f` (fit), `0x100` (height-only, preserve aspect), `100x0` (width-only).

### 6.6 Error Handling

```javascript
try {
  await pb.collection('users').create(data);
} catch (err) {
  if (err.status === 400) {
    // Field-specific validation errors
    console.log(err.data.email?.message);  // "Must be a valid email address."
  }
}
```

Error shape:
```json
{
  "code": 400,
  "message": "Failed to create record.",
  "data": {
    "email": { "code": "validation_invalid_email", "message": "Must be a valid email." }
  }
}
```

---

## 7. Client SDK — Dart (Flutter)

### 7.1 Setup with Persistent Auth

```dart
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();
final store = AsyncAuthStore(
  save:    (String data) async => prefs.setString('pb_auth', data),
  initial: prefs.getString('pb_auth'),
);
final pb = PocketBase('https://your-server.com', authStore: store);
```

### 7.2 CRUD (Dart)

```dart
// CREATE
final record = await pb.collection('posts').create(body: {
  'title': 'Hello World',
  'author': pb.authStore.record!.id,
});

// READ
final result = await pb.collection('posts').getList(
  page: 1, perPage: 20,
  filter: 'author = "${userId}"',
  sort: '-created',
  expand: 'author',
);

// UPDATE
await pb.collection('posts').update(record.id, body: {'title': 'Updated'});

// DELETE
await pb.collection('posts').delete(record.id);
```

### 7.3 Type-Safe Data Access

```dart
// RecordModel helper methods
record.getStringValue('field_name');           // String
record.getListValue<String>('tags');           // List<String>
record.getBoolValue('active');                 // bool
record.getIntValue('count');                   // int
```

### 7.4 Error Handling (Dart)

```dart
try {
  await pb.collection('users').create(body: data);
} catch (e) {
  if (e is ClientException) {
    final errMap = e.response['data'];
    if (errMap.containsKey('email')) {
      print(errMap['email']['message']);
    }
  }
}
```

---

## 8. Batch API (Atomic Transactions)

Multiple mutations in a single HTTP request. **All-or-nothing** — if any operation fails, entire batch rolls back.

### 8.1 JavaScript

```javascript
const batch = pb.createBatch();

batch.collection('users').create({
  username: 'jdoe',
  email: 'jdoe@example.com',
  password: 'secure123',
  passwordConfirm: 'secure123',
});

batch.collection('departments').update('dep_123', {
  'head_count+': 1,  // Atomic increment
});

batch.collection('invites').delete('inv_987');

const result = await batch.send();  // Single atomic transaction
```

### 8.2 Dart

```dart
final batch = pb.createBatch();

batch.collection('users').create(body: {
  'username': 'jdoe',
  'email': 'jdoe@example.com',
  'password': 'secure123',
  'passwordConfirm': 'secure123',
});

batch.collection('departments').update('dep_123', body: {
  'head_count+': 1,
});

final result = await batch.send();
```

### 8.3 Limitations & Workaround

**Problem**: Cannot reference auto-generated ID from Step 1 in Step 2 (ID only exists after commit).

**Workaround**: Generate ID client-side (15-char random string), assign it in the create body, reference that known ID in subsequent operations.

### 8.4 Server Limits (Configurable)

| Setting | Default | Purpose |
|---------|---------|---------|
| `batch.maxRequests` | 50 | Max operations per batch |
| `batch.timeout` | 3s | Max execution time |
| `batch.maxBodySize` | ~128MB | Max JSON payload size |

---

## 9. Server-Side Hooks (pb_hooks/)

### 9.1 Runtime Environment

- Engine: **Goja** (ECMAScript 5.1 + some ES6). This is **NOT Node.js**.
- **No** `npm` packages. **No** `fs` module. **No** `crypto` module.
- Bridge objects: `$app`, `$os`, `$http`, `$security`

### 9.2 Event Hooks

```javascript
// pb_hooks/main.pb.js

// BEFORE create — validate/sanitize data. Throw error to abort.
onRecordCreate((e) => {
  if (e.record.get("title").length < 3) {
    throw new BadRequestError("Title too short");
  }
  e.next();  // Must call to continue chain
}, "posts");

// AFTER create — side effects (emails, counters, external API calls)
onRecordAfterCreate((e) => {
  // Record is already saved. Do side effects here.
  e.next();
}, "posts");
```

### 9.3 Custom API Routes

```javascript
routerAdd("GET", "/api/trending", (c) => {
  const records = $app.findRecordsByFilter("posts", "views > 100", "-views", 10);
  return c.json(200, { items: records });
}, $apis.requireAuth());  // Middleware: requires login
```

### 9.4 External HTTP Requests

```javascript
// No fetch() available — use $http.send (synchronous/blocking)
const res = $http.send({
  url: "https://api.stripe.com/v1/charges",
  method: "POST",
  headers: { "Authorization": "Bearer sk_live_..." },
  body: JSON.stringify({ amount: 1000 }),
});
```

### 9.5 Scheduled Tasks (Cron)

```javascript
cronAdd("0 0 * * *", () => {
  // Runs nightly at midnight
  $app.createBackup();
});
```

### 9.6 Email Hook Interception

```javascript
onMailerRecordPasswordResetSend((e) => {
  e.message.subject = `Password Reset for ${e.record.getString("name")}`;
  e.next();
});
```

**Email placeholders**: `{APP_NAME}`, `{APP_URL}`, `{TOKEN}`, `{OTP}`, `{OTP_ID}`, `{RECORD:fieldName}`

---

## 10. Migrations (Schema Version Control)

### 10.1 v0.23+ Syntax

```javascript
// pb_migrations/1710000000_add_sku_to_products.js
migrate((app) => {
  // UP
  const collection = app.findCollectionByNameOrId("products");

  collection.fields.add({
    type: "text",
    name: "sku_code",
    required: true,
    options: { min: 8, max: 12, pattern: "^[A-Z0-9]+$" },
  });

  app.save(collection);
}, (app) => {
  // DOWN (rollback)
  const collection = app.findCollectionByNameOrId("products");
  collection.fields.removeByName("sku_code");
  app.save(collection);
});
```

### 10.2 v0.22 → v0.23 Upgrade Protocol

1. **Backup** `pb_data/` from production to local dev
2. **Run** v0.23 binary against the data: `./pocketbase serve` (auto-upgrades internal schema)
3. **Delete** all old migration files in `pb_migrations/`
4. **Generate** new snapshot: `./pocketbase migrate collections`
5. **Sync** history: `./pocketbase migrate history-sync` (resets `_migrations` table)
6. **Deploy** new binary + new migration snapshot to production
7. **Run** `history-sync` on production

### 10.3 Method Mapping (v0.22 → v0.23)

| Operation | v0.22 (Legacy) | v0.23+ (Current) |
|-----------|---------------|-------------------|
| Context | `dao` from `db` | `app` passed directly |
| Find collection | `dao.findCollectionByNameOrId()` | `app.findCollectionByNameOrId()` |
| Save record | `dao.saveRecord()` | `app.save()` |
| Delete record | `dao.deleteRecord()` | `app.delete()` |
| Find admin | `dao.findAdminByEmail()` | `app.findAuthRecordByEmail("_superusers", ...)` |

---

## 11. Production Deployment

### 11.1 VPS (Recommended)

**Systemd service:**
```ini
[Unit]
Description=PocketBase
After=network.target

[Service]
ExecStart=/opt/pb/pocketbase serve --http=0.0.0.0:8090
WorkingDirectory=/opt/pb
Restart=always
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
```

**Reverse proxy** (Nginx or Caddy): Handle SSL termination, forward to port 8090. **Must** pass `X-Real-IP` headers.

### 11.2 Agent Deployment Workflow (SSH + SCP)

```bash
# 1. Upload migration and hook files
scp -r pb_migrations/* user@VPS_IP:/opt/pb/pb_migrations/
scp -r pb_hooks/* user@VPS_IP:/opt/pb/pb_hooks/

# 2. Restart to apply changes
ssh user@VPS_IP "systemctl restart pocketbase"
```

### 11.3 Docker

```dockerfile
FROM alpine:latest
RUN apk add --no-cache ca-certificates  # REQUIRED for $http.send (SSL)
COPY pocketbase /pb/pocketbase
EXPOSE 8090
VOLUME /pb/pb_data  # CRITICAL: Without this, ALL DATA LOST on restart
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8090"]
```

### 11.4 S3 Object Storage

Configure in Admin UI → Settings → Files Storage. Supports AWS S3, Cloudflare R2, MinIO, Wasabi. Keeps `pb_data/` lightweight (just the SQLite DB) — makes backups instant.

### 11.5 Backups

```javascript
// Automated nightly backup via hook
cronAdd("0 0 * * *", () => {
  $app.createBackup();  // Creates ZIP in pb_data/backups/
});
```

API: `POST /api/backups`. Backup ZIP contains `data.db` + uploaded files (if local storage). If using S3, contains only DB.

### 11.6 Security Hardening

- **Rate limiting**: Enabled by default (body limit 10MB, configurable)
- **CORS**: Configure allowed domains in Admin UI
- **Admin UI**: Disable or restrict `/_/` access via Nginx rules in high-security environments

### 11.7 Health Check

```
GET /api/health
→ { "status": 200, "message": "API is healthy.", "data": { "canBackup": true } }
```

`canBackup: true` = no active locks preventing backup.

---

## 12. SSR Integration (Next.js)

### 12.1 The Global Client Trap

```javascript
// ❌ NEVER DO THIS in SSR — creates shared state across requests
export const pb = new PocketBase('...');

// ✅ ALWAYS use a factory function — each request gets its own instance
export function createClient() {
  return new PocketBase(process.env.NEXT_PUBLIC_API_URL);
}
```

In SSR, a global singleton leaks auth state between different users' requests.

### 12.2 Middleware Pattern

Read cookie → load into temporary PB instance → validate → refresh if needed → set updated cookie.

---

## 13. Agent Anti-Patterns (Pitfalls to Avoid)

| Pattern | Bad | Good |
|---------|-----|------|
| **N+1 Trap** | Fetch list, then loop to fetch relation for each | Use `expand: 'user'` in single request |
| **Global SSR Client** | `export const pb = new PocketBase(...)` | Factory function per request |
| **Date Math** | SQL date functions in filter string | Calculate date in JS/Dart first, pass as ISO string |
| **React Native Upload** | Pass URI string directly | Use `{ uri, type, name }` object in FormData |
| **Full List** | `pb.collection('x').getFullList()` on large data | Use paginated `getList()` with `page` / `perPage` |
| **Missing Dispose** | Subscribe to realtime without unsubscribe | Always `unsubscribe()` in cleanup/dispose |

```javascript
// Date math — correct pattern
const sevenDaysAgo = new Date();
sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
const filter = `created < "${sevenDaysAgo.toISOString()}"`;
```
