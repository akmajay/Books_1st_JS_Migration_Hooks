# JayGanga Books 📚

**JayGanga Books** is a hyperlocal, second-hand book marketplace built with Flutter and PocketBase. It enables users to buy, sell, and trade books within their local communities safely and efficiently.

## 🚀 Status: Production Ready
This project has undergone a comprehensive "Production Readiness" audit to meet high-quality standards:
- **Zero Analysis Issues**: Codebase is clean with 0 lints or errors.
- **Modern Dependencies**: Upgraded to latest major versions (GoRouter, SharePlus, PocketBase SDK).
- **Hardened Security**: Sensitive files (PEMs, keys) are secured and ignored via Git.
- **Robust Hooks**: Standardized PocketBase JS hooks for reliable transaction and referral logic.

## 🛠 Tech Stack
- **Frontend**: Flutter (Provider, GoRouter)
- **Backend**: PocketBase (JS Hooks, FCM Integration)
- **Security**: Local QR-code based handover verification.

## 📦 How to Run Locally

### Prerequisites
- Flutter SDK (latest stable)
- PocketBase Server (for backend)

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/akmajay/Books_1st_JS_Migration_Hooks.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## 🔐 Security Note
Sensitive files like PEM certificates and Keystores are not included in this repository. Ensure you place your own certificates in the root directory if needed for production builds; they will be ignored by Git as per the `.gitignore` policy.

---
*Built with ❤️ for a better book-trading experience.*
