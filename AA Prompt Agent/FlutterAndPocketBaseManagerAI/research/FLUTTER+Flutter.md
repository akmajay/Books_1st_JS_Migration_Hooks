# Flutter + PocketBase: Agent Implementation Reference

> **Purpose**: Directive reference for AI coding agents building production Flutter apps with PocketBase backend. Every pattern is copy-ready. Follow these conventions exactly.

---

## 1. Dart Language Essentials

### 1.1 Null Safety Rules

- Every type is **non-nullable by default**. `String` cannot hold `null`. Use `String?` for nullable.
- Use `late` when a non-nullable variable is initialized in lifecycle methods (e.g., `initState`).
- Use `late` for lazy initialization — value is computed on first access, not at declaration.
- Use `!` (bang operator) only when you are 100% certain the value is non-null.

### 1.2 Variable Modifiers

| Modifier | When to Use | Memory |
|----------|------------|--------|
| `var` | Local scope, type is obvious | Stack/Heap |
| `final` | Single assignment at runtime (API responses, DB records) | Heap |
| `const` | Compile-time constant (widget config, keys, enums) | Canonicalized (shared memory) |
| `late` | Deferred init, lifecycle-dependent state | Heap |
| `dynamic` | Heterogeneous JSON parsing only (avoid otherwise) | Boxed |

> **Performance**: Use `const` constructors on widgets. Flutter skips rebuilding `const` widgets during tree diffing — they share a single memory address.

### 1.3 Async Model

Dart is **single-threaded** with an event loop (like JavaScript).

```dart
// Future — single async value
final data = await pb.collection('posts').getList();

// Stream — continuous async events (SSE, WebSocket, sensors)
pb.collection('posts').subscribe('*', (e) {
  print(e.action); // create, update, delete
});
```

- `async/await` transforms asynchronous code into a state machine internally.
- **Never** perform blocking operations on the main isolate — causes frame drops (jank).
- Use `try-catch` with `await` for error handling. Exceptions bubble up naturally.

### 1.4 Enhanced Enums

Enums can hold state and methods. Use them to encapsulate display logic:

```dart
enum ConnectionStatus {
  connected(Colors.green, 'Online'),
  disconnected(Colors.red, 'Offline'),
  connecting(Colors.yellow, 'Connecting...');

  final Color color;
  final String label;
  const ConnectionStatus(this.color, this.label);
}
```

### 1.5 Collection Operators

```dart
// Spread
final combined = [...listA, ...listB];

// Null-aware spread (no crash if list is null)
final safe = [...?nullableList];

// Collection-if (conditional widget inclusion)
Column(children: [
  Text('Always visible'),
  if (isAdmin) AdminPanel(),
])

// Collection-for
ListView(children: [
  for (var item in items) ListTile(title: Text(item.name)),
])
```

---

## 2. Flutter Framework Core

### 2.1 Three-Tree Architecture

| Tree | Role | Weight |
|------|------|--------|
| **Widget** | Immutable UI configuration (blueprint) | Lightweight |
| **Element** | Mutable lifecycle manager (glue layer) | Medium |
| **RenderObject** | Actual sizing, layout, painting | Heavyweight |

When `setState` is called:
1. Element is marked dirty
2. Framework diffs new Widget config against existing Element
3. If type + key match → Element updates RenderObject properties (no recreation)
4. This diffing enables 60/120 FPS performance

### 2.2 Widget Lifecycle (StatefulWidget)

| Method | When | Use For |
|--------|------|---------|
| `createState()` | Widget inflation | Return new State instance |
| `initState()` | Element mounted (once) | Init controllers, subscribe streams, load data |
| `didChangeDependencies()` | InheritedWidget changes | Respond to theme/locale changes |
| `build()` | Element dirty | Describe UI — keep pure, no side effects |
| `didUpdateWidget()` | Parent passes new config | Update state to match new widget properties |
| `dispose()` | Element removed permanently | **Unsubscribe streams, dispose controllers, close connections** |

### 2.3 Layout Algorithm

**Rule**: Constraints go down → Sizes go up → Parent sets position.

| Widget | Behavior |
|--------|----------|
| `Expanded` | Forces child to fill ALL remaining flex space (tight constraints) |
| `Flexible` | Allows child to use UP TO remaining space (loose constraints) |
| `Spacer` | Empty `Expanded` — creates adjustable gaps |

---

## 3. Clean Architecture

### 3.1 Folder Structure

```
lib/
├── domain/                    # Core business logic (NO Flutter imports)
│   ├── entities/              # Plain Dart objects (User, Todo, Post)
│   ├── repositories/          # Abstract interfaces (contracts)
│   └── usecases/              # Business rules (LoginUser, GetTasks)
├── data/                      # Adapter layer
│   ├── models/                # Entity extensions with fromJson/toJson
│   ├── datasources/           # PocketBase SDK calls, local storage
│   └── repositories/          # Concrete implementations of domain repos
├── presentation/              # UI layer
│   ├── providers/             # ChangeNotifiers / state holders
│   ├── screens/               # Full-page Scaffold widgets
│   └── widgets/               # Reusable UI components
└── main.dart
```

**Dependency Rule**: `presentation → domain ← data`. Presentation and Data both depend on Domain. Domain depends on nothing.

### 3.2 Data Model Pattern

```dart
class TodoModel {
  final String id;
  final String title;
  final bool completed;
  final DateTime created;

  TodoModel({required this.id, required this.title, required this.completed, required this.created});

  factory TodoModel.fromRecord(RecordModel record) => TodoModel(
    id: record.id,
    title: record.getStringValue('title'),
    completed: record.getBoolValue('completed'),
    created: DateTime.parse(record.getStringValue('created')),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'completed': completed,
  };
}
```

### 3.3 Assets Configuration

In `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/animations/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

Resolution-aware images: `assets/images/logo.png` (1x), `assets/images/2.0x/logo.png` (2x), `assets/images/3.0x/logo.png` (3x). Flutter auto-selects by device density.

---

## 4. State Management (Provider)

### 4.1 Core Pattern

```dart
class TodoProvider extends ChangeNotifier {
  List<TodoModel> _todos = [];
  bool _isLoading = false;

  List<TodoModel> get todos => _todos;
  bool get isLoading => _isLoading;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    final result = await pb.collection('todos').getList();
    _todos = result.items.map((r) => TodoModel.fromRecord(r)).toList();

    _isLoading = false;
    notifyListeners();
  }
}
```

### 4.2 Provider Setup (main.dart)

```dart
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProxyProvider<AuthProvider, TodoProvider>(
        create: (_) => TodoProvider(),
        update: (_, auth, todo) => todo!..userId = auth.userId,
      ),
    ],
    child: const MyApp(),
  ),
);
```

### 4.3 Consumption Rules

| Method | Rebuilds? | Use Where |
|--------|-----------|-----------|
| `context.watch<T>()` | ✅ Yes | Inside `build()` — reactive UI updates |
| `context.read<T>()` | ❌ No | Inside callbacks (`onPressed`) — fire-and-forget |
| `Consumer<T>` | ✅ Yes (scoped) | Isolate rebuild to specific subtree only |

**Never** use `context.watch` inside callbacks. **Never** use `context.read` inside `build`.

---

## 5. PocketBase Integration

### 5.1 Authentication Persistence

```dart
final prefs = await SharedPreferences.getInstance();
final store = AsyncAuthStore(
  save: (String data) async => prefs.setString('pb_auth', data),
  initial: prefs.getString('pb_auth'),
);
final pb = PocketBase('https://your-server.com', authStore: store);
```

- `AsyncAuthStore` persists auth token across app restarts.
- The SDK auto-refreshes tokens on API calls when possible.
- Check auth status: `pb.authStore.isValid`

### 5.2 CRUD Operations

```dart
// CREATE
final record = await pb.collection('posts').create(body: {
  'title': 'Hello World',
  'content': 'Post body here',
  'author': pb.authStore.record!.id,
});

// READ (paginated)
final result = await pb.collection('posts').getList(
  page: 1,
  perPage: 20,
  filter: 'author = "${userId}"',
  sort: '-created',
  expand: 'author,comments',
);

// UPDATE
await pb.collection('posts').update(record.id, body: {'title': 'Updated'});

// DELETE
await pb.collection('posts').delete(record.id);
```

### 5.3 Realtime Subscriptions

```dart
// Subscribe to all changes in a collection
pb.collection('messages').subscribe('*', (e) {
  if (e.action == 'create') {
    _messages.add(MessageModel.fromRecord(e.record!));
    notifyListeners();
  }
});

// CRITICAL: Unsubscribe in dispose()
@override
void dispose() {
  pb.collection('messages').unsubscribe('*');
  super.dispose();
}
```

### 5.4 File Upload

```dart
final record = await pb.collection('posts').create(
  body: {'title': 'With image'},
  files: [
    http.MultipartFile.fromBytes('image', imageBytes, filename: 'photo.jpg'),
  ],
);

// Get file URL
final url = pb.files.getUrl(record, record.getStringValue('image'));
```

---

## 6. Navigation (GoRouter)

### 6.1 Route Configuration

```dart
final router = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthProvider>().isAuthenticated;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginRoute) return '/login';
    if (isLoggedIn && isLoginRoute) return '/home';
    return null; // no redirect
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, __, navigationShell) => MainShell(shell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ]),
      ],
    ),
  ],
);
```

### 6.2 Key Concepts

- **`StatefulShellRoute`**: Maintains separate navigation stacks per tab (scroll position preserved).
- **`redirect`**: Centralized auth guard — runs on every navigation event.
- **`GoRoute` with params**: `path: '/post/:id'` → access via `state.pathParameters['id']`.
- **`context.go('/path')`**: Replaces current stack. **`context.push('/path')`**: Pushes on top.

---

## 7. UI Components & Theming

### 7.1 Material 3 Theming

```dart
MaterialApp.router(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  ),
  routerConfig: router,
)
```

Access anywhere: `Theme.of(context).colorScheme.primary`

### 7.2 Performance Lists

```dart
// ALWAYS use .builder for dynamic lists — lazy instantiation
ListView.builder(
  controller: _scrollController, // For infinite scroll detection
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index].title)),
)

// Infinite scroll pattern
_scrollController.addListener(() {
  if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
    context.read<PostProvider>().loadNextPage();
  }
});

// Pull-to-refresh
RefreshIndicator(
  onRefresh: () => context.read<PostProvider>().refresh(),
  child: ListView.builder(...),
)
```

**Never** use `ListView(children: [...])` for dynamic data — it builds ALL items at once.

### 7.3 Forms

```dart
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();

Form(
  key: _formKey,
  child: Column(children: [
    TextFormField(
      controller: _emailController,
      validator: (v) => v!.contains('@') ? null : 'Invalid email',
      textInputAction: TextInputAction.next, // Shows "Next" on keyboard
    ),
    ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Submit form
        }
      },
      child: const Text('Submit'),
    ),
  ]),
)
```

### 7.4 Image Caching

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (_, __) => const CircularProgressIndicator(),
  errorWidget: (_, __, ___) => const Icon(Icons.error),
)
```

Use `cached_network_image` package — auto-caches downloaded images locally.

---

## 8. Animation System

### 8.1 Decision Matrix — Pick the Right Strategy

| Need | Strategy | Widget/Class |
|------|----------|-------------|
| Simple property change (size, color, padding) | **Implicit** | `AnimatedContainer`, `AnimatedOpacity` |
| Custom property not covered by built-in widgets | **Implicit Custom** | `TweenAnimationBuilder` |
| Repeating, reversing, or user-controlled animation | **Explicit** | `AnimationController` + `AnimatedBuilder` |
| Screen-to-screen shared element transition | **Hero** | `Hero` widget with matching tags |
| Designer-created complex animation (After Effects) | **Lottie** | `Lottie.asset()` with optional controller |
| Multiple coordinated/cascading animations | **Staggered** | `Interval` + single `AnimationController` |
| Physics-based (spring, friction) | **Simulation** | `AnimationController.animateWith(SpringSimulation(...))` |

### 8.2 Implicit Animations (Simple — No Controller Needed)

```dart
// Changes to ANY property animate automatically
AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeInOut,
  width: _isExpanded ? 300 : 100,
  height: _isExpanded ? 300 : 100,
  decoration: BoxDecoration(
    color: _isExpanded ? Colors.blue : Colors.red,
    borderRadius: BorderRadius.circular(_isExpanded ? 50 : 10),
  ),
)
```

**Available implicit widgets**: `AnimatedContainer`, `AnimatedOpacity`, `AnimatedPadding`, `AnimatedPositioned`, `AnimatedAlign`, `AnimatedSwitcher`, `AnimatedDefaultTextStyle`, `AnimatedCrossFade`.

### 8.3 Explicit Animations (Full Control)

```dart
class _MyWidgetState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(); // Start animation
  }

  @override
  void dispose() {
    _controller.dispose(); // CRITICAL: prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: MyContent());
  }
}
```

**Built-in transition widgets**: `FadeTransition`, `SlideTransition`, `ScaleTransition`, `RotationTransition`, `SizeTransition`, `DecoratedBoxTransition`.

### 8.4 Curves Reference

| Curve | Effect | Use For |
|-------|--------|---------|
| `Curves.easeIn` | Slow start, fast end | Elements entering viewport |
| `Curves.easeOut` | Fast start, slow end | Elements settling into position |
| `Curves.easeInOut` | Slow start and end | General-purpose (default choice) |
| `Curves.bounceOut` | Bounce at end | Playful UI elements |
| `Curves.elasticOut` | Spring overshoot | Attention-grabbing effects |

### 8.5 Hero Transitions

```dart
// Source screen
Hero(
  tag: 'product-${product.id}',  // MUST be unique per route
  child: Image.network(product.thumbnailUrl),
)

// Destination screen — same tag
Hero(
  tag: 'product-${product.id}',
  child: Image.network(product.fullImageUrl),
)
```

### 8.6 Lottie (After Effects JSON Animations)

```dart
// From asset (5-50KB vs megabytes for GIFs)
Lottie.asset('assets/animations/loading.json')

// With controller for interactive control
Lottie.asset(
  'assets/animations/like_button.json',
  controller: _controller,
  onLoaded: (composition) {
    _controller.duration = composition.duration;
  },
)
```

### 8.7 Staggered Animations (Cascading Sequences)

```dart
// Single controller, multiple intervals
final opacity = Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
);
final slideY = Tween<double>(begin: 50, end: 0).animate(
  CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6)),
);
final scale = Tween<double>(begin: 0.5, end: 1.0).animate(
  CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
);
```

### 8.8 Performance

- Wrap animated elements in `RepaintBoundary` to prevent repainting parent subtree.
- **Impeller engine** (default on iOS, stable on Android) pre-compiles shaders at build time → no first-frame jank, targets 120fps.

---

## 9. Testing Strategy

### 9.1 Testing Pyramid

| Level | Environment | Speed | Confidence | Mock Strategy |
|-------|-------------|-------|------------|---------------|
| **Unit** | Dart VM | Milliseconds | Logic only | Full mocking |
| **Widget** | Headless Flutter | Seconds | UI + interaction | Partial mocking |
| **Integration** | Real device/emulator | Minutes | Full system | Minimal mocking |

### 9.2 Unit Testing with Mockito

```dart
// 1. Annotate test file
@GenerateMocks([TodoRepository])
void main() {
  late MockTodoRepository mockRepo;

  setUp(() {
    mockRepo = MockTodoRepository();
  });

  test('loadTodos returns list', () async {
    // 2. Stub behavior
    when(mockRepo.getTodos()).thenAnswer((_) async => [Todo(id: '1', title: 'Test')]);

    // 3. Execute
    final result = await mockRepo.getTodos();

    // 4. Verify
    expect(result.length, 1);
    verify(mockRepo.getTodos()).called(1);
  });
}
```

Run `dart run build_runner build` to generate `.mocks.dart` files.

### 9.3 Widget Testing

```dart
testWidgets('tap counter increments', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());

  expect(find.text('0'), findsOneWidget);

  await tester.tap(find.byIcon(Icons.add));
  await tester.pump(); // Trigger single frame rebuild

  expect(find.text('1'), findsOneWidget);
});
```

- `tester.pump()` — triggers one frame (assert state immediately after change).
- `tester.pumpAndSettle()` — pumps until all animations complete.
- **Finders**: `find.text()`, `find.byIcon()`, `find.byKey()`, `find.byType()`.

### 9.4 Integration Testing

```dart
// integration_test/app_test.dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full login flow', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'password');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
  });
}
```

Run: `flutter test integration_test/app_test.dart`

---

## 10. Global Error Handling

### 10.1 Complete Setup Pattern

```dart
void main() {
  // 1. Zone guard — catches unhandled async errors
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Framework errors — catches build/layout errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      // Send to Sentry/Crashlytics
      CrashService.recordFlutterError(details);
    };

    // 3. Platform errors — catches platform channel failures
    PlatformDispatcher.instance.onError = (error, stack) {
      CrashService.recordError(error, stack);
      return true;
    };

    // 4. Friendly error screen (instead of grey screen in release)
    ErrorWidget.builder = (details) => const Center(
      child: Text('Something went wrong'),
    );

    runApp(const MyApp());
  }, (error, stack) {
    CrashService.recordError(error, stack);
  });
}
```

**Error flow**: Async errors → `runZonedGuarded`. Build errors → `FlutterError.onError`. Platform channel errors → `PlatformDispatcher.instance.onError`.

---

## 11. Internationalization (i18n)

### 11.1 Setup

Create `l10n.yaml` in project root:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

### 11.2 ARB Files

`lib/l10n/app_en.arb`:
```json
{
  "appTitle": "My App",
  "welcomeMessage": "Welcome back, {userName}!",
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}"
}
```

### 11.3 Usage

```dart
// In MaterialApp
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
)

// In widgets
Text(AppLocalizations.of(context)!.welcomeMessage('Alice'))
Text(AppLocalizations.of(context)!.itemCount(5)) // "5 items"
```

Run `flutter pub get` → auto-generates `AppLocalizations` class from ARB files.

---

## 12. Platform Channels

### 12.1 Channel Types

| Type | Use Case | Pattern |
|------|----------|---------|
| `MethodChannel` | Call native function, get result | Command-response (getBatteryLevel) |
| `EventChannel` | Stream from native (sensors, connectivity) | Producer-consumer |
| `BasicMessageChannel` | High-frequency lightweight messages | Continuous messaging |

### 12.2 MethodChannel Implementation

**Dart side:**
```dart
static const platform = MethodChannel('com.example.app/battery');

Future<int> getBatteryLevel() async {
  try {
    return await platform.invokeMethod('getBatteryLevel');
  } on PlatformException catch (e) {
    throw Exception('Native error: ${e.message}');
  }
}
```

**Android side (Kotlin):**
```kotlin
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/battery")
    .setMethodCallHandler { call, result ->
        if (call.method == "getBatteryLevel") {
            val level = getBatteryLevel()
            if (level != -1) result.success(level)
            else result.error("UNAVAILABLE", "Battery unavailable", null)
        } else {
            result.notImplemented()
        }
    }
```

### 12.3 Type Mapping

| Dart | Android (Kotlin) | iOS (Swift) |
|------|------------------|-------------|
| `null` | `null` | `nil` |
| `bool` | `Boolean` | `NSNumber` |
| `int` | `Int` / `Long` | `NSNumber` |
| `String` | `String` | `NSString` |
| `List` | `ArrayList` | `NSArray` |
| `Map` | `HashMap` | `NSDictionary` |

---

## 13. Dependency Injection (GetIt)

### 13.1 Registration

```dart
final getIt = GetIt.instance;

void setupDI() {
  // Singleton — one instance forever (DB, HTTP client)
  getIt.registerLazySingleton<PocketBase>(() => PocketBase('https://api.example.com'));

  // Factory — new instance every time (ViewModels, Blocs)
  getIt.registerFactory<TodoProvider>(() => TodoProvider(getIt<PocketBase>()));
}
```

### 13.2 Usage

```dart
// Anywhere in code — no BuildContext needed
final pb = getIt<PocketBase>();
```

### 13.3 Injectable (Code Generation)

```dart
@lazySingleton
class ApiService { ... }

@injectable
class UserRepository {
  final ApiService api;
  UserRepository(this.api); // Auto-resolved by generated code
}
```

Run `dart run build_runner build` → generates `injection.config.dart`.

### 13.4 GetIt vs Provider — When to Use Each

| | GetIt | Provider |
|---|-------|---------|
| **Scope** | Global (anywhere) | Widget tree only (needs `context`) |
| **Use for** | Services, Repos, HTTP clients | UI state (ViewModels, Blocs) |
| **Disposal** | Manual | Automatic when widget removed |

**Recommendation**: Use BOTH — GetIt for global services, Provider for UI state.

---

## 14. App Flavors & Environments

### 14.1 Android (`android/app/build.gradle`)

```gradle
flavorDimensions "default"
productFlavors {
    dev {
        dimension "default"
        applicationIdSuffix ".dev"
        resValue "string", "app_name", "App Dev"
    }
    prod {
        dimension "default"
        resValue "string", "app_name", "App"
    }
}
```

### 14.2 iOS

1. Duplicate "Runner" scheme → create "Runner-dev", "Runner-prod"
2. Duplicate Debug/Release configs → "Debug-dev", "Release-prod"
3. In Build Settings → User-Defined → set `APP_DISPLAY_NAME`, `BUNDLE_ID_SUFFIX` per config
4. In `Info.plist` → reference as `$(APP_DISPLAY_NAME)`

### 14.3 Dart Entry Points

```dart
// lib/main_dev.dart
void main() {
  AppConfig.init(environment: 'dev', apiUrl: 'https://dev-api.example.com');
  runApp(const MyApp());
}

// lib/main_prod.dart
void main() {
  AppConfig.init(environment: 'prod', apiUrl: 'https://api.example.com');
  runApp(const MyApp());
}
```

**Run command**: `flutter run --flavor dev -t lib/main_dev.dart`

---

## 15. Plugins & Native Capabilities

| Plugin | Purpose | Key Pattern |
|--------|---------|-------------|
| `flutter_secure_storage` | Encrypted token storage (Keychain/Keystore) | Use for auth tokens instead of SharedPreferences |
| `connectivity_plus` | Monitor WiFi/Cellular/None status | Stream-based — show offline UI, pause sync |
| `permission_handler` | Request camera, storage, location permissions | Handle `permanentlyDenied` → open app settings |
| `flutter_local_notifications` | Local push notifications | Configure Android channels + iOS permission |
| `cached_network_image` | Auto-cache network images locally | Reduces bandwidth, improves load speed |

---

## 16. Deployment

### 16.1 Android

```bash
flutter build appbundle  # AAB for Play Store (recommended)
flutter build apk        # APK for sideloading
```

- Sign with keystore (`.jks`) configured in `android/key.properties`
- R8 code shrinking enabled by default in release — removes unused code, obfuscates

### 16.2 iOS

- Requires Apple Developer Account ($99/year)
- Archive via Xcode → Distribution Certificate + Provisioning Profile required
- `Info.plist` must include ALL usage description strings (`NSCameraUsageDescription`, etc.) — missing = rejection

### 16.3 Web

```bash
flutter build web  # Compiles Dart to JavaScript
```

- **CanvasKit** renderer: pixel-perfect, larger download — use for high-fidelity apps
- **HTML** renderer: smaller, broader compatibility
- Configure CORS on PocketBase server to allow web domain

---

## 17. CI/CD

### 17.1 GitHub Actions Workflow

```yaml
name: Flutter CI
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build appbundle
```

### 17.2 Secrets Management

- **Never** commit keystores or API keys to repo
- GitHub Actions: store as Encrypted Secrets → decode during build
- Codemagic: upload signing files via UI → auto-injected into build

### 17.3 Tool Comparison

| | GitHub Actions | Codemagic |
|---|---------------|-----------|
| **Setup** | Manual (Flutter SDK, Java, CocoaPods) | Pre-installed Flutter + Xcode |
| **iOS builds** | Expensive (Mac runners) | Optimized, included |
| **Config** | YAML workflows | YAML or click-and-configure UI |
| **Best for** | Flexibility, existing GitHub projects | iOS-heavy, Flutter-specialized |

---

## 18. PocketBase Deployment (Agent Workflow)

The agent deploys PocketBase via SSH. User provides: **VPS IP, SSH key, domain (optional)**.

### 18.1 Install on VPS

```bash
ssh user@VPS_IP
wget https://github.com/pocketbase/pocketbase/releases/download/v0.23.x/pocketbase_0.23.x_linux_amd64.zip
unzip pocketbase_*.zip -d /opt/pb
```

### 18.2 Systemd Service

```bash
cat > /etc/systemd/system/pocketbase.service << EOF
[Unit]
Description=PocketBase
After=network.target

[Service]
ExecStart=/opt/pb/pocketbase serve --http=0.0.0.0:8090
WorkingDirectory=/opt/pb
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable pocketbase
systemctl start pocketbase
```

### 18.3 Deploy Migrations & Hooks

```bash
scp -r pb_migrations/* user@VPS_IP:/opt/pb/pb_migrations/
scp -r pb_hooks/* user@VPS_IP:/opt/pb/pb_hooks/
ssh user@VPS_IP "systemctl restart pocketbase"
```

Hooks hot-reload on Linux. Migrations auto-run on restart.
