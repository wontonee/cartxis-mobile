<p align="center">
  <img src="assets/transparent_logo.png" width="160" alt="Cartxis Logo" />
</p>̌

<h1 align="center">Cartxis Mobile App</h1>

<p align="center">
  Open Source Flutter eCommerce App for iOS &amp; Android
</p>

<p align="center">
  <a href="https://cartxis.com">cartxis.com</a> •
  <a href="https://github.com/wontonee/cartxis">Backend Repository</a> •
  Demo v1.0.0
</p>

---

## Overview

**Cartxis** is a free, open source mobile shopping app built ̌̌with Flutter. It connects to the [Cartxis web backend](https://github.com/wontonee/cartxis) which provides all the API, admin panel, product management, orders, and payment processing.

> ⚠️ **The mobile app requires the Cartxis web backend to be running first.**
> All data — products, users, orders, payments, settings — comes from the API.
> Set up the backend before running the mobile app.

---

## Requirements

### Mobile App

| Tool | Version |
|------|------|
| Flutter SDK | 3.x |
| Dart | 3.x |
| Xcode | 15+ (iOS builds) |
| Android Studio | Latest (Android builds) |
| Android SDK | API 24+ |
| CocoaPods | Latest (iOS dependencies) |

### Backend Server

| Requirement | Version |
|-------------|--------|
| PHP | 8.2+ |
| Composer | 2.x |
| Node.js | 18.x+ |
| NPM | 9.x+ |
| MySQL | 8.0+ |

---

## Step 1 — Set Up the Backend

Everything depends on the Cartxis web backend. Set it up first.

**Backend Repository:** [https://github.com/wontonee/cartxis](https://github.com/wontonee/cartxis)

### Option A — Quick Install (Recommended)

The fastest way to get a production-ready store:

```bash
composer create-project cartxis/cartxis my-store
cd my-store
php artisan cartxis:install
```

The interactive installer handles database setup, admin account creation, migrations, seeders, and asset publishing automatically.

### Option B — Development Install (Git Clone)

Use this method if you want to contribute to the backend or customise it.

```bash
# 1. Clone the repository
git clone https://github.com/wontonee/cartxis.git
cd cartxis

# 2. Install PHP dependencies
composer install

# 3. Install Node.js dependencies
npm install

# 4. Set up your environment file
cp .env.example .env
php artisan key:generate

# 5. Create a MySQL database, then update .env:
#    DB_DATABASE, DB_USERNAME, DB_PASSWORD

# 6. Run the Cartxis installer (migrations, seeders, admin setup)
php artisan cartxis:install

# 7. Build frontend assets
npm run build

# 8. Start the development server
php artisan serve
```

Once the backend is running, note your API base URL (e.g. `https://yourdomain.com`).

### Payment Gateway Configuration

All four payment gateways are configured from the **Admin Panel → Settings → Payment Methods**. No `.env` changes are needed for payment keys — enter them directly in the admin panel.

| Gateway | Admin Panel Setting |
|---------|---------------------|
| Stripe | Settings → Payment Methods → Stripe |
| Razorpay | Settings → Payment Methods → Razorpay |
| PhonePe | Settings → Payment Methods → PhonePe |
| PayPal | Settings → Payment Methods → PayPal |

### Production Deployment Checklist

Before going live, run the following on your server:

```bash
# Set production environment in .env
APP_ENV=production
APP_DEBUG=false

# Optimise Laravel
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan storage:link
```

- Set up a **queue worker** (Supervisor recommended) — required for email and async jobs
- Add the **scheduler cron** to run every minute:
  ```
  * * * * * cd /path/to/your-project && php artisan schedule:run >> /dev/null 2>&1
  ```
- Point your web server (Nginx/Apache) document root to the `public/` directory

---

## Step 2 — Set Up the Mobile App

### Clone the repository

```bash
git clone https://github.com/wontonee/cartxis-mobile.git
cd cartxis-mobile
```

### Install dependencies

```bash
flutter pub get
```

### Configure the API URL

Open [`lib/core/config/api_config.dart`](lib/core/config/api_config.dart) and update the base URLs:

```dart
// For development
static const String _iosBaseUrl     = 'https://your-local-domain.test';
static const String _androidBaseUrl = 'https://10.0.2.2'; // Android emulator host gateway

// For production
static const String productionBaseUrl = 'https://yourdomain.com';

// Set to true for production
static const bool isProduction = true;
```

> **iOS Simulator:** Add your local domain to `/etc/hosts` on your Mac and use it directly.
> **Android Emulator:** Use `10.0.2.2` as the IP (maps to your Mac/PC localhost). The app automatically passes the correct `Host` header for nginx vhost routing.

### Install iOS pods

```bash
cd ios && pod install && cd ..
```

### Run the app

```bash
# Development
flutter run

# Release mode
flutter run --release
```

---

## Payment Gateways

Cartxis supports **4 payment gateways** — all configured from the backend admin panel. No changes are needed in the mobile app code.

| Gateway | Status | Supported Methods |
|---------|--------|-------------------|
| **Stripe** | ✅ Supported | Credit / Debit Cards, Apple Pay (iOS) |
| **Razorpay** | ✅ Supported | UPI, Cards, Net Banking, Wallets |
| **PhonePe** | ✅ Supported | UPI Payments |
| **PayPal** | ✅ Supported | PayPal Checkout (WebView) |

Configure your gateway API keys in the backend admin panel under **Settings → Payment Methods**. The mobile app fetches the active configuration automatically at checkout.

---

## Features

### 🛍️ Shopping
- Browse products by category with featured, new arrivals, and on-sale sections
- Product search and filtering
- Product detail with image gallery, variants, and stock status

### 🛒 Cart & Checkout
- Add/remove items, update quantities
- Full address management with multiple saved addresses
- Choose from available payment gateways at checkout
- Order summary with shipping calculation

### 👤 Account & Profile
- Register, Login, Forgot Password with email reset
- Profile management with avatar upload
- Order history and detailed order tracking
- Wishlist — save and manage favourite products
- Dark mode support
- Secure account deletion (password-confirmed)

### ⚙️ Admin-Driven Configuration
- Login screen logo loaded from backend settings (`/api/v1/app/settings`)
- Payment methods enabled or disabled from admin panel — no app update needed
- All product data, pricing, inventory and banners managed from the backend

---

## Project Structure

```
lib/
├── core/
│   ├── config/          # API config, environment settings
│   ├── constants/       # Colours, strings, sizes, text styles
│   ├── network/         # HTTP client, API exception handling
│   ├── services/        # Heartbeat, connectivity
│   └── theme/           # App theme
├── data/
│   ├── models/          # User, Product, Order, Cart, Wishlist models
│   └── services/        # Auth, Product, Cart, Order, Wishlist, Payment, AppSettings
├── presentation/
│   └── screens/
│       ├── auth/        # Login, Register, Forgot Password
│       ├── home/        # Home, Featured, Categories
│       ├── product/     # Product listing, detail
│       ├── cart/        # Cart, Checkout
│       ├── orders/      # Order history, Order detail
│       ├── wishlist/    # Wishlist
│       ├── profile/     # Profile, Settings, Delete Account
│       └── main/        # Bottom navigation shell
└── routes/              # Named route definitions
```

---

## API Connectivity

The app uses a heartbeat system to stay in sync with the backend:

| Endpoint | Purpose |
|----------|---------|
| `POST /api/v1/system/api-sync/heartbeat` | Sent on app start and resume |
| `GET /api/v1/app/settings` | Admin-configured logo and settings |
| `DELETE /api/v1/auth/account` | Authenticated account deletion |

All authenticated endpoints use a Bearer token stored securely in SharedPreferences.

---

## Building for Release

### Android — Google Play Store

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

Upload the `.aab` to the Google Play Console.

**Application ID:** `com.cartxis.app`

The signing keystore credentials are stored in the `important/` folder (git-ignored — keep a secure backup).

### iOS — App Store

```bash
flutter build ipa --release
```

Open `ios/Runner.xcworkspace` in Xcode to archive and upload to App Store Connect.

---

## Play Store / App Store — Account Deletion URL

Google Play and Apple App Store require apps that allow account creation to provide an account deletion option. The Cartxis backend includes a dedicated account deletion page that satisfies this requirement.

**Account Deletion URL:** `https://yourdomain.com/account-deletion`

Use this URL in:
- **Google Play Console** → App content → Data safety → Account deletion
- **App Store Connect** → App Privacy → Account deletion URL

The mobile app also provides in-app account deletion under **Profile → Delete Account**, which requires password confirmation.

---

## Development Notes

- Set `isProduction = false` in [`api_config.dart`](lib/core/config/api_config.dart) for local development
- Self-signed SSL certificates are bypassed automatically in development mode
- Android emulator connectivity uses `10.0.2.2` + `Host` header for nginx vhost routing
- All debug `print()` statements have been removed from production code

---

## License

This project is open source under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Support

- **Website:** [https://cartxis.com](https://cartxis.com)
- **Email:** [dev@wontonee.com](mailto:dev@wontonee.com)
- **Backend Repo:** [https://github.com/wontonee/cartxis](https://github.com/wontonee/cartxis)

---

<p align="center">
  Built with ❤️ — <a href="https://cartxis.com">cartxis.com</a>
</p>

