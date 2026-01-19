# Cartxis Mobile App

Cartxis is a Flutter eCommerce mobile app for iOS and Android. It connects to the Cartxis web app backend API and provides a complete shopping experience on mobile.

## Prerequisites

You must have the Cartxis web app running because the mobile app depends on its API.

- Cartxis web app: https://github.com/wontonee/cartxis
- Flutter SDK 3.x
- Dart 3.x
- Xcode (for iOS builds)
- Android Studio + Android SDK (for Android builds)

## Get Started

1) Clone this repository.
2) Install dependencies:
	- Run `flutter pub get`
3) Configure the API base URL:
	- Update `testBaseUrl` in [lib/core/config/api_config.dart](lib/core/config/api_config.dart)
4) Run the app:
	- `flutter run`

## API Connectivity (Heartbeat)

The app sends a heartbeat to your backend on app start and whenever the app resumes from background using:

- POST `/api/v1/system/api-sync/heartbeat`

This lets your admin know the app is connected and syncing.

## Project Structure

- `lib/` contains the Flutter app code
- `lib/core/` core utilities, config, networking
- `lib/data/` models and services
- `lib/presentation/` UI screens and widgets
- `lib/routes/` navigation

## Notes

- If you use self-signed certificates in development, keep `isProduction = false` in [lib/core/config/api_config.dart](lib/core/config/api_config.dart)
- For production, set `isProduction = true` and update `productionBaseUrl`

## License

See LICENSE if provided by the repository.

---

Support: dev@wontonee.com

Website: https://wontonee.com

Made with ❤️ by the Wontonee Team

