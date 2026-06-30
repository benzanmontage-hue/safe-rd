# SafeRD Architecture

SafeRD is a Flutter application built with a **feature-first** folder structure and **Provider** for dependency injection and state management. This document describes the high-level architecture, data flow, and key design decisions.

---

## 📁 Directory Structure

```
lib/
├── core/                        # Shared utilities & configuration
│   ├── constants.dart           # App-wide constants (defaults, timeouts, keys)
│   └── theme.dart               # Dark theme definition & color palette
├── features/                    # Feature modules (feature-first)
│   ├── home/
│   │   └── home_screen.dart     # Main map screen with incident list
│   ├── report/
│   │   └── report_screen.dart   # Incident type selection & submission
│   └── sos/
│       └── sos_button.dart      # SOS emergency button & sharing sheet
├── models/
│   └── incident.dart            # Incident data model with serialization
├── services/                    # Platform & backend services
│   ├── audio_service.dart       # Text-to-speech (Dominican Spanish)
│   ├── firebase_service.dart    # Firestore CRUD, offline sync, streams
│   ├── location_service.dart    # GPS tracking with fallback defaults
│   ├── notification_service.dart# FCM push + local notifications
│   └── offline_service.dart     # Hive-backed offline cache & sync queue
├── widgets/                     # Reusable UI components
│   └── incident_card.dart       # Incident display card with actions
└── main.dart                    # Entry point, service init, MultiProvider
```

---

## 🧱 Feature-First Structure

Each feature is a self-contained module in `lib/features/`. A feature owns its UI, business logic, and any feature-specific models or services.

| Feature | Responsibility |
|---|---|
| **home** | Google Maps rendering, incident marker display, draggable bottom sheet with nearby incidents |
| **report** | Incident type grid selector, GPS location capture, submission to Firebase (or offline queue) |
| **sos** | Pulsing SOS button with countdown, sharing options (WhatsApp, SMS, 911, clipboard) |

Shared widgets live in `lib/widgets/`, shared services in `lib/services/`, and shared constants/theme in `lib/core/`.

---

## 🗄 State Management: Provider

SafeRD uses **Provider** (via `package:provider`) for dependency injection and reactive state.

```
main.dart
  └── MultiProvider
       ├── Provider<FirebaseService>
       ├── Provider<LocationService>
       ├── Provider<OfflineService>
       └── Provider<NotificationService>
            └── MaterialApp
                 └── HomeScreen
                      ├── Consumer2<FirebaseService, LocationService>
                      ├── ReportScreen (receives services via constructor)
                      └── SOSButton (receives services via constructor)
```

- **Services are singletons** — instantiated once in `main.dart` and provided down the widget tree
- **Widgets consume services** via `Provider.of<T>()`, `context.watch<T>()`, or constructor injection
- **No global state store** — each service owns its data and exposes streams or getters

---

## ⚙️ Service Layer

### FirebaseService
- Manages `FirebaseFirestore` instance with offline persistence enabled
- Provides methods: `reportIncident`, `confirmIncident`, `denyIncident`, `getActiveIncidents`
- Checks connectivity via `connectivity_plus` before all writes
- Falls back to `OfflineService` queue when offline
- Merges online Firestore stream with offline cached stream using `StreamGroup.merge`

### LocationService
- Wraps `Geolocator` for GPS positioning
- Defaults to **Santo Domingo** (18.4861, -69.9312) when GPS is unavailable
- Provides a broadcast `positionStream` for real-time updates
- Distance/bearing calculations via the Haversine formula

### OfflineService
- Uses `Hive` for local persistence
- **Cache**: Stores the latest incident list for offline map viewing
- **Sync Queue**: Stores incidents submitted while offline; drained and synced when connectivity returns
- Tracks `lastSync` timestamp

### NotificationService
- Initializes Firebase Cloud Messaging (FCM)
- Subscribes to the `incident_alerts` topic
- Shows local notifications for foreground messages
- Provides `showIncidentAlert` for triggered alerts

### AudioService
- Uses `flutter_tts` for text-to-speech in Dominican Spanish (`es-MX`)
- Reads incident alerts aloud: type, distance, and time ago
- Avoids repeating the same message

---

## 🔄 Data Flow

```
User reports incident
       │
       ▼
ReportScreen ──► LocationService.getCurrentPosition()
       │
       ▼
FirebaseService.reportIncident(incident)
       │
       ├── Online? ──► Firestore ──► getActiveIncidents stream ──► HomeScreen map + list
       │                              │
       │                              ▼
       │                         NotificationService.push alert to nearby users
       │
       └── Offline? ──► OfflineService.queueIncident()
                            │
                            ▼
                       Hive syncQueue
                            │
                       (when online) ──► firebaseService.syncQueuedIncidents()
                                              │
                                              ▼
                                         Firestore
```

---

## 📡 Offline-First Strategy

1. **Firestore persistence** — Enabled via `FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true)`
2. **Hive cache** — Incident list snapshots are saved to Hive whenever the online stream emits data
3. **Sync queue** — Incidents reported while offline are queued in Hive with `OfflineService.queueIncident()`
4. **Reconnection sync** — On startup and periodically, `FirebaseService.syncQueuedIncidents()` drains the queue
5. **Graceful fallback** — When offline, the home screen shows cached incidents from Hive

---

## 🔔 Push Notification Flow

```
FCM server sends message to topic "incident_alerts"
       │
       ▼
FirebaseMessaging.onMessage (foreground)
       │
       ▼
NotificationService._showLocalNotification()
       │
       ▼
flutter_local_notifications display
       │
       ▼
User taps notification ──► onMessageOpened stream
                              │
                              ▼
                         App opens to incident detail
```

- Users are auto-subscribed to the `incident_alerts` topic on init
- FCM tokens are available on `NotificationService.fcmToken` for server-side targeting
- Local notifications use the `incident_alerts` channel with high importance

---

## 🛡 Error Handling

- **Graceful degradation** — Every widget that uses map, location, or network has a fallback UI
- **Custom error widget** — Replaces Flutter's red error screen with a dark-themed, readable error display
- **Try/catch everywhere** — All Firebase, GPS, and async operations are wrapped in try/catch with debug logging
- **No crash on init failure** — If Firebase or Hive fails to initialize, the app shows an error screen instead of crashing

---

## 🧪 Testing Strategy

- **Unit tests** — Incident model serialization, OfflineService queue logic, LocationService distance calculations
- **Widget tests** — IncidentCard rendering, SOSButton countdown behavior, ReportScreen type grid
- **Integration tests** — Full reporting flow with mocked Firebase and Location services

Tests live in `test/` following the same folder structure as `lib/`.
