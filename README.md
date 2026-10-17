# Scan Master

A fast, modern, and lightweight QR code and barcode scanner and generator built with Flutter.

## Features

- **High-speed scanning:** Real-time QR code and barcode recognition powered by [`mobile_scanner`](https://pub.dev/packages/mobile_scanner).
- **Format support:** Supports standard 1D and 2D formats, including QR Code, EAN-13, EAN-8, UPC-A, UPC-E, Code 128, Code 39, Code 93, Codabar, Data Matrix, Aztec, and PDF-417.
- **Smart actions:** Detects payload types and offers contextual actions, such as opening URLs, calling phone numbers, sending SMS messages or emails, and connecting to Wi-Fi networks.
- **Customizable auto-actions:** Optional automatic clipboard copying, opening web links, and saving QR code images.
- **Local history and favorites:** Stores scan history locally on-device using Hive, with configurable retention policies.
- **Image export and sharing:** Save and share generated or scanned QR codes directly to the gallery.
- **Theming:** Light, dark, and system theme modes using Material 3.

## Tech Stack

| Technology                                                                                                        | Purpose                              |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| [Flutter](https://flutter.dev/)                                                                                   | Cross-platform application framework |
| [BLoC / flutter_bloc](https://pub.dev/packages/flutter_bloc)                                                      | State management                     |
| [go_router](https://pub.dev/packages/go_router)                                                                   | Navigation and routing               |
| [Hive](https://pub.dev/packages/hive) / [hive_flutter](https://pub.dev/packages/hive_flutter)                     | Local storage                        |
| [mobile_scanner](https://pub.dev/packages/mobile_scanner)                                                         | Camera and barcode scanning          |
| [barcode_widget](https://pub.dev/packages/barcode_widget)                                                         | Barcode generation                   |
| [google_fonts](https://pub.dev/packages/google_fonts) / [auto_size_text](https://pub.dev/packages/auto_size_text) | Typography and responsive text       |

## Project Structure

```text
lib/
├── bloc/
│   ├── history_bloc/          # Scan history persistence and favorites
│   ├── qr_scanner_bloc/       # Camera lifecycle, flash, and scanner feed
│   ├── scanned_result_bloc/   # Actions on scanned payloads (copy, share, save)
│   └── settings_bloc/         # Theme mode and user preferences
├── models/
│   └── history_model.dart     # Scanned record data schema
├── screens/
│   ├── home_screen.dart       # Camera viewfinder and scanner view
│   ├── history_screen.dart    # Scan logs with swipe-to-delete/favorite
│   ├── favorites_screen.dart  # Starred records list
│   ├── scanned_screen.dart    # Scan result details and actions
│   ├── settings_screen.dart   # App preferences and retention policies
│   └── about_screen.dart      # App metadata and legal disclosures
└── utils/
    ├── router.dart            # go_router configuration
    ├── qr_scanner_overlay.dart # Custom viewfinder cut-out overlay
    ├── text_styles.dart       # App typography definitions
    └── themes/                # Light and dark theme configurations
```

## Getting Started

### Prerequisites

- Flutter SDK: `>=3.3.0 <4.0.0`
- Android NDK: `28.0.12433566` or newer (for 16 KB page-size alignment support)
- Android Gradle Plugin: `8.11.1` or higher
- Gradle wrapper: `8.11.1` or higher

### Installation

1. **Clone the repository:**

   Replace `your-username` with your GitHub username or use your repository URL.

   ```bash
   git clone https://github.com/your-username/scan_master.git
   cd scan_master
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the application:**

   ```bash
   flutter run
   ```

## Permissions

### Android

Ensure the required permissions are declared in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
```

> Add only the permissions your implementation actually uses. Android storage and Wi-Fi permissions may vary depending on the Android versions and APIs you support.

### iOS

Add the relevant usage descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Scan Master requires camera access to scan QR codes and barcodes.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Scan Master needs permission to save generated barcode images to your photo library.</string>
```

## Contributing

Contributions, bug reports, and feature suggestions are welcome.

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/my-new-feature`
3. Commit your changes: `git commit -m "Add some feature"`
4. Push your branch: `git push origin feature/my-new-feature`
5. Open a pull request.

## License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file for details.
