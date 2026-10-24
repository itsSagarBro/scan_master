# Scan Master

An offline-first, privacy-focused, and high-performance QR code and barcode
scanner and generator built with Flutter.

Scan Master decodes 1D/2D symbologies in real time, automatically resolves
complex payload types (Wi-Fi, UPI, vCard, URLs), provides high-resolution custom
code generation, and manages local history entirely on-device with zero
telemetry or network trackers.

---

## Key Features

- **High-Speed Vision Scanning:** Real-time camera viewfinder decoding powered
  by [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) with Google
  Play Services unbundled ML Kit integration (~15 MB download footprint).
- **Intelligent Payload Resolution:** Built-in heuristics accurately detect and
  resolve complex payload types (Wi-Fi credentials, UPI payment links, vCards,
  SMS, emails, phone dialers, and web URLs), even when ML Kit returns generic
  text tokens.
- **Contextual One-Tap Actions:**
  - Connect directly to secured Wi-Fi networks (WPA/WEP/Open) via
    [`wifi_iot`](https://pub.dev/packages/wifi_iot).
  - Launch UPI payments across installed payment apps.
  - Open web links, trigger native dialers, dispatch SMS/emails, or copy text to
    the clipboard.
- **Custom QR & Barcode Generator:**
  - Supports 2D formats (QR Code, Aztec) and 1D formats (Code 128, EAN-13,
    UPC-A) via [`barcode_widget`](https://pub.dev/packages/barcode_widget) and
    [`pretty_qr_code`](https://pub.dev/packages/pretty_qr_code).
  - Embed custom center logos from the gallery with squircle or circular
    masking.
  - Configure matrix curvature, frame corner radiuses, and color palettes.
- **Gallery Image Extraction:** Pick images directly from the device photo
  library to decode barcodes without pointing the camera.
- **Zero-Cloud Privacy & Retention:**
  - All scans, custom creations, and starred favorites are persisted locally
    using [`Hive`](https://pub.dev/packages/hive).
  - Automated history retention with 7-day, 30-day, or indefinite intervals.
    Starred records are permanently exempt from automatic deletion.
- **Export & Share Pipeline:** Render high-resolution PNG snapshots using
  [`screenshot`](https://pub.dev/packages/screenshot) and export them to native
  device galleries via [`gal`](https://pub.dev/packages/gal) or share them
  through system share sheets via
  [`share_plus`](https://pub.dev/packages/share_plus).
- **Material 3 Design:** Frosted-glass interfaces, smooth ambient mesh glows,
  animated laser HUD overlays, and responsive dark/light theme switching.

## Tech Stack & Core Libraries

| Layer / Domain         | Package / Tool                                                                                                            | Purpose                                                                         |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| **Framework**          | [Flutter](https://flutter.dev/) (Stable channel)                                                                          | Cross-platform UI toolkit                                                       |
| **State Architecture** | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc)                                                                   | Reactive BLoC pattern for scanner, results, history, and settings               |
| **Routing**            | [`go_router`](https://pub.dev/packages/go_router)                                                                         | Declarative route hierarchy and parameter passing                               |
| **Local Persistence**  | [`hive_flutter`](https://pub.dev/packages/hive_flutter)                                                                   | Lightweight on-device NoSQL store; encryption requires additional configuration |
| **Vision & Scanner**   | [`mobile_scanner`](https://pub.dev/packages/mobile_scanner)                                                               | CameraX hardware bridge and Google ML Kit barcode vision                        |
| **Network Utility**    | [`wifi_iot`](https://pub.dev/packages/wifi_iot)                                                                           | Wi-Fi profile parsing and device connection                                     |
| **Image & Storage**    | [`gal`](https://pub.dev/packages/gal) / [`image_picker`](https://pub.dev/packages/image_picker)                           | Scoped gallery storage operations and media picker                              |
| **Export Engine**      | [`screenshot`](https://pub.dev/packages/screenshot) / [`share_plus`](https://pub.dev/packages/share_plus)                 | Offscreen widget rasterization and native system sharing                        |
| **Barcodes & QR**      | [`barcode_widget`](https://pub.dev/packages/barcode_widget) / [`pretty_qr_code`](https://pub.dev/packages/pretty_qr_code) | Multi-format 1D/2D barcode generation and styling                               |

## Architecture Overview

```text
lib/
├── bloc/
│   ├── history_bloc/             # Local Hive history CRUD, filters, and retention cleanup
│   ├── qr_scanner_bloc/          # Camera controller binding, torch toggles, and throttled detection
│   ├── scanned_result_bloc/      # Contextual actions (UPI, Wi-Fi, URL, gallery export)
│   └── settings_bloc/            # Retention policies, auto-copy/open flags, and theme modes
├── models/
│   └── history_model.dart        # ScannedModel schema and heuristic type resolver
├── screens/
│   ├── home_screen.dart          # Live camera viewfinder, animated laser HUD, docked navigation
│   ├── scanned_screen.dart       # Result dashboard, barcode card, and contextual actions
│   ├── history_screen.dart       # Chronological history, type filters, and batch operations
│   ├── favorites_screen.dart     # Starred records feed
│   ├── create_qr_screen.dart     # QR/barcode generator with logo and radius controls
│   └── settings_screen.dart      # Auto-action configuration and retention scheduler
└── utils/
    ├── resolve_barcode_type.dart # Payload classifier (Wi-Fi, UPI, vCard, URLs)
    ├── qr_scanner_overlay.dart   # Custom cut-out with animated corner brackets
    ├── get_lauch_url.dart        # Platform intent URI resolver
    ├── router.dart               # Deep-link and route declarations
    └── text_styles.dart          # Centralized typography system
```

## Build Optimizations & Footprint Control

To reduce APK size by avoiding bundled ML Kit models across CPU architectures,
Scan Master uses **unbundled ML Kit**.

### 1. Unbundled Play Services Model

In `android/gradle.properties`:

```ini
dev.steenbakker.mobile_scanner.useUnbundled=true
```

### 2. Google Play Dynamic Model Download

In `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="barcode" />
```

Google Play Services can download and update barcode vision models when needed.
Actual app download size varies by build configuration, architecture,
dependencies, and store delivery; verify the final AAB/APK size from your
release build.

## Getting Started

### Prerequisites

- Flutter SDK `>=3.3.0`
- Android Studio or VS Code with the Flutter extension
- Android SDK 34+
- Java JDK 17

### Installation & Run

1. **Clone the repository:**

   ```bash
   git clone https://github.com/itssagarbro/scan_master.git
   cd scan_master
   ```

2. **Fetch packages:**

   ```bash
   flutter pub get
   ```

3. **Run on a connected device:**

   ```bash
   flutter run
   ```

## Building for Production

### Android Keystore Setup

Configure `android/key.properties` with your signing details:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=upload-keystore.jks
```

Place `upload-keystore.jks` in the `android/` directory. Keep signing
credentials and keystore files private; do not commit them to version control.

### Generate an Android App Bundle

```bash
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

### Generate Standalone APKs per Architecture

```bash
flutter build apk --release --split-per-abi
```

## Permissions and Platform Configuration

### Android

Add the permissions required by your enabled features to
`android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Camera-based barcode scanning -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Wi-Fi actions; requirements vary by Android version and implementation -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />

<!-- Legacy external storage write access (Android 9 and below) -->
<uses-permission
    android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
```

Review the current requirements of `mobile_scanner`, `wifi_iot`, and your target
Android versions. Runtime permission behavior and Wi-Fi connection restrictions
vary by Android version; request only permissions needed by your implementation.

### iOS

Add the following usage descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Scan Master requires camera access to scan QR codes and barcodes.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Scan Master needs permission to save generated barcode images to your photo gallery.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Scan Master requires photo library access to pick images for barcode decoding and logo embedding.</string>
```

## Privacy

Scan history and generated items are designed to remain on-device. The app
description states that Scan Master uses no telemetry or network trackers.
Ensure this remains true for all dependencies and integrations, and disclose any
data handling accurately in the app's privacy policy and store listing.

## License

Distributed under the MIT License. See the repository's
[`LICENSE`](https://github.com/itssagarbro/scan_master/blob/main/LICENSE) file
for details.
