# ecommerce_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Prerequisites

Before running the app, ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Git](https://git-scm.com/)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, macOS only)
- [Chrome](https://www.google.com/chrome/) (for web development)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ecommerce_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Verify Flutter installation:
```bash
flutter doctor
```

## Running the App

### Web

#### Using Chrome (Recommended)
```bash
flutter run -d chrome
```

#### Using Edge
```bash
flutter run -d edge
```

#### Using Firefox
```bash
flutter run -d firefox
```

#### Building for Web
```bash
flutter build web
```
The built files will be in the `build/web` directory.

### Android

#### Using Android Emulator
1. Open Android Studio
2. Go to **Tools > Device Manager**
3. Create a new virtual device or use an existing one
4. Start the emulator
5. Run the app:
```bash
flutter run -d emulator-5554
```
(Replace `emulator-5554` with your emulator device ID from `flutter devices`)

#### Using Real Android Device
1. Enable **Developer Options** on your Android device:
   - Go to **Settings > About Phone**
   - Tap **Build Number** 7 times
2. Enable **USB Debugging** in Developer Options
3. Connect your device via USB
4. Verify the device is connected:
```bash
flutter devices
```
5. Run the app:
```bash
flutter run
```

#### Building APK
```bash
flutter build apk
```
The APK will be in `build/app/outputs/flutter-apk/app-release.apk`.

#### Building App Bundle (for Play Store)
```bash
flutter build appbundle
```
The bundle will be in `build/app/outputs/bundle/release/app-release.aab`.

### iOS

#### Using iOS Simulator (macOS only)
1. Open Xcode
2. Go to **Xcode > Open Developer Tool > Simulator**
3. Choose a simulator device (e.g., iPhone 15)
4. Run the app:
```bash
flutter run -d iPhone
```
(Replace `iPhone` with your simulator device ID from `flutter devices`)

#### Using Real iOS Device (macOS only)
1. Open the iOS project in Xcode:
```bash
open ios/Runner.xcworkspace
```
2. Connect your iOS device via USB
3. In Xcode, select your device from the device dropdown
4. Sign the app with your Apple Developer account:
   - Go to **Signing & Capabilities**
   - Select your team
5. Run the app from Xcode or via command line:
```bash
flutter run
```

#### Building iOS App
```bash
flutter build ios
```
The built app will be in `build/ios/iphoneos/Runner.app`.

## Available Devices

To see all available devices to run the app on:
```bash
flutter devices
```

## Hot Reload

While the app is running, you can use hot reload to see changes instantly:
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

## Troubleshooting

### Android Issues
- Ensure Android SDK is installed and configured
- Run `flutter doctor --android-licenses` to accept licenses
- Check that `ANDROID_HOME` environment variable is set

### iOS Issues
- Ensure Xcode is installed and updated
- Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- Run `pod install` in the `ios` directory if you have CocoaPods issues

### Web Issues
- Ensure Chrome is installed
- Clear browser cache if you see stale content
- Check browser console for errors

### General Issues
- Run `flutter clean` and then `flutter pub get`
- Run `flutter doctor` to check for any missing dependencies
- Ensure you're on the latest Flutter version: `flutter upgrade`

## Project Structure

```
lib/
├── config/           # App configuration and routing
├── core/             # Core utilities, constants, and theme
├── data/             # Data models, repositories, and data sources
├── domain/           # Domain entities and use cases
└── presentation/     # UI screens, widgets, and BLoC state management
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
