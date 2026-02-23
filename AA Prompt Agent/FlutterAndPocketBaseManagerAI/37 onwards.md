# PROMPT 37 of 70
Phase: UI Polish (PHASE_11)
Task: Splash & Onboarding Animations (Lottie) + Onboarding Completion logic
Type: 📱 FRONTEND (Instructions Only)

═══════════════════════════════════════════════════════════

### 📊 BACKEND SCHEMA
**Collection:** `users`
| Field | Type | Note |
|-------|------|------|
| `onboarding_complete` | bool | Flag to skip onboarding for returning users |

*Created in: Prompt 2 (Collections) & Prompt 4 (API Rules)*

═══════════════════════════════════════════════════════════

### 📋 INSTRUCTION
Enhance the onboarding experience with high-quality Lottie animations. Implement a seamless transition from the Splash Screen to either the Onboarding Flow (new users) or the Home Screen (returning users) based on the `onboarding_complete` flag in PocketBase.

### 📝 REQUIREMENTS

**1. Dependency Setup:**
- Add `lottie: ^3.1.2` to `pubspec.yaml`.

**2. Splash Screen (`lib/screens/splash/splash_screen.dart`):**
- Display a full-screen Lottie animation (`assets/animations/splash_anim.json`).
- On animation completion:
    - If user is NOT logged in → Navigate to Auth Gate (Prompt 6).
    - If user IS logged in:
        - Fetch the latest `users` record.
        - If `onboarding_complete == true` → Navigate to Home.
        - Else → Navigate to Onboarding.

**3. Onboarding Flow (`lib/screens/auth/onboarding_screen.dart`):**
- Create a PageView with 3 slides:
    - **Slide 1:** "Buy Used Books Nearby" + `onboarding_1.json` + description.
    - **Slide 2:** "Sell Your Old Books Fast" + `onboarding_2.json` + description.
    - **Slide 3:** "Connect with Students Directly" + `onboarding_3.json` + description.
- Implement smooth dot indicator (e.g., `smooth_page_indicator`).
- "Next" button transition between slides.
- Last Slide: "Get Started" button.

**4. Completion Logic:**
- When "Get Started" is pressed:
    - Show loading overlay.
    - Call: `pb.collection('users').update(pb.authStore.record!.id, {'onboarding_complete': true})`.
    - Handle success/error.
    - On success: Navigate to Home and clear the navigation stack.

**5. Styling:**
- Use the theme defined in `lib/config/theme.dart`.
- Animations should be centered with a responsive scale (use `ResponsiveBuilder` from Prompt 36).

### ⛔ DO NOT:
- Do NOT hardcode animation paths; use the assets folder properly.
- Do NOT skip the backend update of `onboarding_complete`.
- Do NOT allow the user to go back to the splash screen from onboarding.

### 👤 USER MANUAL STEPS:
1. Create a folder: `assets/animations/`.
2. Download 4 Lottie JSON files (LottieFiles.com) and rename them to:
   - `splash_anim.json`
   - `onboarding_1.json`
   - `onboarding_2.json`
   - `onboarding_3.json`
3. Add the animations to `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/animations/
   ```

### ✅ SELF-CHECK:
1. `lottie` package added and `pub pub get` runs.
2. Splash animation plays 100% and then triggers navigation.
3. Logged-in user with `onboarding_complete: true` skips onboarding.
4. "Get Started" button correctly updates the PocketBase user record.
5. Navigation stack is cleared after onboarding (user cannot "back" into onboarding).
6. `flutter analyze` returns 0 issues.

### 💬 CONFIRM IN CHAT:
"Prompt 37 complete. Splash and Onboarding implemented with Lottie animations. Onboarding completion logic synced with PocketBase `onboarding_complete` flag. Navigation flow: Splash → [Auth/Home/Onboarding]. zero errors."

═══════════════════════════════════════════════════════════

# PROMPT 38 of 70
Phase: Notifications (PHASE_12)
Task: Push Notifications (FCM) — Frontend Registration + Permission Flow
Type: 📱 FRONTEND (Instructions Only)

═══════════════════════════════════════════════════════════

### 📊 BACKEND SCHEMA
**Collection:** `users`
| Field | Type | Note |
|-------|------|------|
| `fcm_token` | text | Stores the device token for push notifications |

*Created in: Prompt 2 (Collections)*

═══════════════════════════════════════════════════════════

### 📋 INSTRUCTION
Implement Firebase Cloud Messaging (FCM) in the Flutter app to handle push notifications. This prompt focuses on the frontend registration, permission handling, and token management.

### 📝 REQUIREMENTS

**1. Dependency Setup:**
- Add these packages to `pubspec.yaml`:
    - `firebase_core: ^3.1.1`
    - `firebase_messaging: ^15.0.3`
    - `flutter_local_notifications: ^17.1.2`

**2. Initialization (`lib/main.dart`):**
- Initialize Firebase before `runApp()`.
- Set up a background message handler (top-level function).

**3. Notification Service (`lib/services/notification_service.dart`):**
- Create a singleton `NotificationService`.
- **initialize():**
    - Initialize `FlutterLocalNotificationsPlugin` for foreground notifications.
    - Setup Android Notification Channels (importance: max).
- **requestPermissions():**
    - Request FCM permissions (alert, badge, sound).
- **getToken():**
    - Fetch the FCM token.
    - **Update PocketBase:** If user is authenticated, update the `users` record with the new `fcm_token`.
- **listenMessages():**
    - Handle `onMessage` (foreground) by showing a local notification.
    - Handle `onMessageOpenedApp` (app opened from notification) → Use `GoRouter` to navigate to the correct screen based on `data` payload.

**4. App Integration:**
- Initialize `NotificationService` in the root widget (or `AuthGate`).
- Listen for auth state changes: when a user logs in, call `getToken()` to sync the token to PocketBase.

**5. Navigation Handling:**
- The notification `data` payload will contain `type` and `id` (e.g., `type: "chat", id: "chat_123"`).
- Programmatically navigate to the relevant screen using `router.push()`.

### ⛔ DO NOT:
- Do NOT hardcode the Firebase config in `main.dart` (use `DefaultFirebaseOptions` from `flutterfire configure`).
- Do NOT skip the background message handler.
- Do NOT update the FCM token in PocketBase if the user is not logged in.

### 👤 USER MANUAL STEPS:
1. Create a Firebase Project in the [Firebase Console](https://console.firebase.google.com/).
2. Add an Android app with package name: `com.jayganga.books`.
3. Download `google-services.json` and place it in `android/app/`.
4. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`.
5. Run: `flutterfire configure` in the project root to generate `lib/firebase_options.dart`.
6. (Optional) For testing, you can send a test message from the Firebase "Cloud Messaging" tab.

### ✅ SELF-CHECK:
1. `firebase_options.dart` generated and imported.
2. App requests notification permission on first launch (or after login).
3. FCM token is printed in console and successfully saved to the `users` collection in PocketBase.
4. Foreground notification appears as a heads-up banner (Android).
5. Tapping a notification with a `data` payload navigates the user to the correct screen.
6. `flutter analyze` returns 0 issues.

### 💬 CONFIRM IN CHAT:
"Prompt 38 complete. FCM initialized. Permission handling and token sync to PocketBase implemented. Deep linking from notification data handled via GoRouter. zero errors."

═══════════════════════════════════════════════════════════

# PROMPT 39 of 70
Phase: Notifications (PHASE_12)
Task: Push Notifications (FCM) — Backend Hook (Triggering Notifications)
Type: 🔧 BACKEND (Code Provided by Manager AI)

═══════════════════════════════════════════════════════════

### 📊 BACKEND SCHEMA
**Collection:** `messages` (Trigger)
**Collection:** `chats` (Context)
**Collection:** `users` (Token Source)
| Collection | Field Used | Purpose |
|------------|------------|---------|
| `messages` | `content`, `chat`, `sender` | Triggering event data |
| `chats` | `buyer`, `seller` | Identify receiver |
| `users` | `fcm_token` | Target device token |

═══════════════════════════════════════════════════════════

### 📋 INSTRUCTION
Create a PocketBase JavaScript hook to automatically send push notifications via FCM when a new message or offer is created. The Manager AI has written the **EXACT code** below.

### 📄 CREATE FILE: `pb_hooks/push_notifications.pb.js`

```javascript
// pb_hooks/push_notifications.pb.js

onRecordAfterCreateSuccess("messages", (e) => {
    const message = e.record;
    const chatId = message.get("chat");
    const senderId = message.get("sender");
    
    // 1. Fetch the Chat to find the receiver
    const chat = $app.findRecordById("chats", chatId);
    const buyerId = chat.get("buyer");
    const sellerId = chat.get("seller");
    
    // Receiver is the person who is NOT the sender
    const receiverId = (senderId === buyerId) ? sellerId : buyerId;
    
    // 2. Fetch the Receiver User record
    const receiver = $app.findRecordById("users", receiverId);
    const fbToken = receiver.get("fcm_token");
    
    if (!fbToken) {
        console.log("No FCM token for receiver: " + receiverId);
        return;
    }

    // 3. Prepare Notification Content
    let title = "New Message";
    let body = message.get("content") || "Sent an attachment";
    
    if (message.get("type") === "offer") {
        title = "New Offer Received 💰";
        body = "You received an offer of ₹" + message.get("offer_amount");
    }

    // 4. Send to FCM (HTTP v1)
    // Note: Replaces {PROJECT_ID} and uses the config for authorization
    try {
        const config = $app.findFirstRecordByFilter("app_config", "is_active = true");
        const projectId = config.get("fcm_project_id");
        const accessToken = config.get("fcm_access_token"); // Long-lived or rotated token

        if (!projectId || !accessToken) {
            console.log("FCM Config missing in app_config");
            return;
        }

        const url = "https://fcm.googleapis.com/v1/projects/" + projectId + "/messages:send";
        
        const res = $http.send({
            url: url,
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + accessToken
            },
            body: JSON.stringify({
                "message": {
                    "token": fbToken,
                    "notification": {
                        "title": title,
                        "body": body
                    },
                    "data": {
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                        "type": "chat",
                        "id": chatId
                    }
                }
            })
        });

        if (res.statusCode !== 200) {
            console.log("FCM Error: " + res.raw);
        } else {
            console.log("Notification sent successfully to: " + receiverId);
        }
    } catch (err) {
        console.log("Push Hook Error: " + err.message);
    }
});
```

### ⛔ DO NOT:
- Do NOT modify the JS code — it uses the $app API which is the current standard.
- Do NOT remove the try-catch block.
- Do NOT use the legacy FCM server key (deprecated).

### 🚀 DEPLOY:
[CLI]: `bash deploy.sh`

### 👤 USER MANUAL STEPS:
1. In PocketBase Admin UI, go to `app_config` collection.
2. Ensure you have fields: `fcm_project_id` (text) and `fcm_access_token` (text).
3. Fill in your **Firebase Project ID**.
4. To get a test **Access Token**:
   - Go to Google Cloud Console → IAM & Admin → Service Accounts.
   - Create a key (JSON) for "Firebase Cloud Messaging API (V1)".
   - Use a tool like [OAuth2 Playground](https://developers.google.com/oauthplayground/) or a local script to generate a token with scope `https://www.googleapis.com/auth/firebase.messaging`.
5. Update `app_config` with the token.

### ✅ SELF-CHECK:
1. `pb_hooks/push_notifications.pb.js` created and synced to VPS via `deploy.sh`.
2. PocketBase logs (`journalctl -u pocketbase`) show no syntax errors on restart.
3. Sending a message in the app triggers the hook (check logs: "Notification sent successfully").
4. Receiver device receives the push notification.

### 💬 CONFIRM IN CHAT:
"Prompt 39 complete. FCM Backend Hook implemented. Real-time notifications for messages and offers are active. Backend code provided exactly. zero errors."

═══════════════════════════════════════════════════════════
⏭️ NEXT: Prompt 40 — Offline Cache & Sync Logic (Hive + Repository Pattern)
