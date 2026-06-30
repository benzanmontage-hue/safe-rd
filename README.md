# SafeRD 🛡️

**Real-time road safety reporting for the Dominican Republic.**

[![CI](https://github.com/benzanmontage-hue/safe-rd/actions/workflows/ci.yml/badge.svg)](https://github.com/benzanmontage-hue/safe-rd/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

SafeRD empowers Dominican citizens to report road hazards, accidents, and safety incidents in real time. The app uses GPS location, Firebase, and offline-first caching to ensure reports are never lost — even in areas with poor connectivity.

---

## 📸 Screenshots

<!--
  TODO: Add screenshots here once the app is running on a device.
  Replace these placeholders with actual image URLs or paths.

  ![Home Map](screenshots/home_map.png)
  ![Report Incident](screenshots/report_incident.png)
  ![SOS Alert](screenshots/sos_alert.png)
  ![Incident List](screenshots/incident_list.png)
-->

| Home Map | Report Incident | SOS Alert | Incident List |
|---|---|---|---|
| *Coming soon* | *Coming soon* | *Coming soon* | *Coming soon* |

---

## ✨ Features

- 🚧 **Real-time incident reporting** — Report potholes, accidents, floods, fallen trees, downed cables, and more
- 🗺️ **Live hazard map** — Google Maps integration with color-coded markers by severity
- 🆘 **SOS button** — 3-second countdown then share your location via WhatsApp, SMS, or dial 911
- 📡 **Offline-first** — Incidents are cached locally and synced when connectivity returns
- 🔔 **Push notifications** — Firebase Cloud Messaging alerts for nearby incidents
- 🔊 **Voice alerts** — Text-to-speech announcements in Dominican Spanish for nearby hazards
- ✅ **Community verification** — Confirm or deny incidents reported by others
- 🔌 **Graceful degradation** — Full fallback UI when location, maps, or network are unavailable

---

## 🏗 Architecture

SafeRD follows a **feature-first** folder structure with **Provider** for state management.

```
lib/
├── core/           # Theme, constants, shared utilities
├── features/       # Business feature modules
│   ├── home/       # Map + incident list
│   ├── report/     # Incident reporting screen
│   └── sos/        # Emergency SOS button
├── models/         # Data models (Incident)
├── services/       # Backend & platform services
├── widgets/        # Shared UI components
└── main.dart       # Entry point & DI setup
```

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for a detailed overview.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x, channel stable)
- Dart 3.x (bundled with Flutter)
- A [Firebase project](https://console.firebase.google.com/) with:
  - Authentication (anonymous or email)
  - Cloud Firestore
  - Firebase Cloud Messaging
- Android: `minSdkVersion 21`

### Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/benzanmontage-hue/safe-rd.git
   cd safe-rd
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Download `google-services.json` from your Firebase project and place it in `android/app/`
   - (Optional) Download `GoogleService-Info.plist` for iOS and place it in `ios/Runner/`

4. **Set environment variables** (optional)

   Create a `.env` file in the project root:

   ```env
   # Defaults point to Santo Domingo — override as needed
   DEFAULT_LAT=18.4861
   DEFAULT_LNG=-69.9312
   INCIDENT_EXPIRY_HOURS=4
   ```

5. **Run the app**

   ```bash
   flutter run
   ```

### Build for Release

```bash
flutter build apk --release   # Android
flutter build ios --release   # iOS
```

---

## 📚 Documentation

| Document | Description |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Full architecture, data flow, and directory tree |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute, coding standards, PR process |

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Analyze code quality
dart analyze

# Check formatting
dart format --set-exit-if-changed .
```

---

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) before opening a pull request.

### Quick Start

1. Fork the repo
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Commit using [Conventional Commits](https://www.conventionalcommits.org/) (`feat: add amazing feature`)
4. Push and open a PR

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

---

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Powered by [Firebase](https://firebase.google.com/)
- Map data © [Google Maps](https://maps.google.com/)
- Icons from [Material Design](https://material.io/icons)
