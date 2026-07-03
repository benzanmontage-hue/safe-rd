# SafeRD — Architecture Context

## Stack
- **Framework:** Flutter 3.x (Dart)
- **State Management:** Riverpod
- **Local DB:** Hive (offline-first)
- **Push:** Firebase Cloud Messaging
- **Maps:** flutter_map + OpenStreetMap
- **SMS:** telephony package
- **WhatsApp:** url_launcher (whatsapp://send)
- **Phone:** url_launcher (tel://)
- **TTS:** flutter_tts

## Architecture Pattern
Clean Architecture with feature-first structure:

```
lib/
├── core/
│   ├── di/              # Dependency injection
│   ├── network/         # Connectivity checker
│   ├── storage/         # Hive setup + adapters
│   └── utils/           # Constants, extensions
├── features/
│   ├── sos/             # SOS engine
│   ├── contacts/        # Trusted contacts
│   ├── alerts/          # Alert history
│   ├── map/             # Location + offline tiles
│   └── settings/        # Profile, preferences
└── main.dart
```

## Key Design Decisions
1. **Offline-first** — Hive is source of truth, network is enhancement
2. **No external API dependencies for SOS** — everything must work offline
3. **Riverpod over BLoC** — simpler for this app's state complexity
4. **OpenStreetMap over Google Maps** — no API key dependency, offline tiles
