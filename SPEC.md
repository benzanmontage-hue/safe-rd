# SafeRD — Product Specification Document v1.0

**Status:** Draft  
**Author:** Wilmer Benzan Villegas  
**Last Updated:** 3 July 2026  
**License:** MIT  
**Repository:** github.com/benzanmontage-hue/safe-rd

---

## 1. Executive Summary

SafeRD is a personal safety application for residents and visitors in the Dominican Republic. It provides one-tap emergency alerts (SOS), real-time location sharing with trusted contacts, and offline functionality — critical in a country where mobile connectivity is unreliable outside urban centers.

### Problem
- DR has high crime rates and unreliable emergency response (911 inconsistent)
- Tourists and residents lack a fast, reliable way to alert help
- Most safety apps require constant internet — useless in remote areas

### Solution
SafeRD offers:
- **One-tap SOS** that sends GPS location via WhatsApp, SMS, and FCM push notification simultaneously
- **Offline-first architecture** — works without internet, syncs when back online
- **Trusted contacts** — pre-configured emergency network
- **911 integration** — auto-dial with location readout

---

## 2. Core Features

### 2.1 SOS Emergency Alert (P0)
| Feature | Description |
|---------|-------------|
| Trigger | Tap SOS button or shake device 3× |
| Actions | 1. Send WhatsApp message with GPS link |
| | 2. Send SMS with coordinates |
| | 3. Push notification (FCM) to trusted contacts |
| | 4. Auto-dial 911 with TTS location readout |
| Latency | < 3 seconds from tap to alert sent |
| Offline | Queue alerts, send when connectivity restores |

### 2.2 Trusted Contacts Management (P0)
| Feature | Description |
|---------|-------------|
| Add contacts | From phonebook or manual entry |
| Contact types | WhatsApp, SMS, FCM push |
| Groups | Family, Friends, Work |
| Permissions | Per-contact toggle for alert channels |

### 2.3 Real-Time Location (P1)
| Feature | Description |
|---------|-------------|
| Live sharing | Share real-time location with contacts for N minutes |
| Map view | OpenStreetMap (offline tiles via Hive cache) |
| History | Last known locations stored locally |

### 2.4 Offline Mode (P0)
| Feature | Description |
|---------|-------------|
| Cache | Hive DB for all emergency contacts and settings |
| Queue | Failed alert attempts retry on connectivity |
| Sync | Background sync when internet returns |
| Data | Offline map tiles for Santo Domingo, Punta Cana, Santiago |

### 2.5 User Profile & Settings (P1)
| Feature | Description |
|---------|-------------|
| Profile | Name, blood type, medical notes (for first responders) |
| Preferences | Dark theme (default), language (ES/EN/NL) |
| Test mode | Send test alert to verify setup |
| Quick dial | Pre-configured emergency numbers (911, tourism police, embassy) |

---

## 3. Technical Architecture

### 3.1 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| State | Riverpod |
| Local DB | Hive (offline-first) |
| Push | Firebase Cloud Messaging (FCM) |
| SMS | telephony plugin |
| WhatsApp | url_launcher (whatsapp:// send) |
| Maps | flutter_map + OpenStreetMap tiles |
| Phone | url_launcher (tel://911) |
| TTS | flutter_tts (text-to-speech for 911 call) |
| Sensors | shake_detector |

### 3.2 Data Flow — SOS Alert

```
User taps SOS
  │
  ├─→ [GPS] Get current location (lat, lng, accuracy)
  ├─→ [Hive] Read trusted contacts
  │
  ├─→ [WhatsApp] Send "EMERGENCIA: https://maps.google.com/?q=LAT,LNG"
  ├─→ [SMS]    Send "EMERGENCY: LAT,LNG — Wilmer needs help"
  ├─→ [FCM]    Push to all contacts with app installed
  ├─→ [Phone]  Dial 911, TTS reads: "Emergency at LATITUDE X, LONGITUDE Y"
  │
  └─→ [Hive]   Log alert with timestamp + status
```

### 3.3 Offline Queue Design

```
Alert triggered OFFLINE:
  → Save to Hive queue: {id, timestamp, location, contacts, retries: 0}
  → Connectivity listener detects internet
  → Process queue FIFO, max 3 retries
  → On success: remove from queue, log
  → On fail after 3 retries: flag as failed, notify user
```

---

## 4. Data Models

### 4.1 Emergency Contact

```dart
@HiveType(typeId: 0)
class EmergencyContact {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String phoneNumber;
  @HiveField(3) bool notifyWhatsApp;
  @HiveField(4) bool notifySMS;
  @HiveField(5) bool notifyPush;
  @HiveField(6) String group; // family, friends, work
  @HiveField(7) bool isActive;
}
```

### 4.2 Alert Log

```dart
@HiveType(typeId: 1)
class AlertLog {
  @HiveField(0) String id;
  @HiveField(1) DateTime timestamp;
  @HiveField(2) double latitude;
  @HiveField(3) double longitude;
  @HiveField(4) List<String> contactsNotified;
  @HiveField(5) AlertStatus status; // sent, queued, failed
  @HiveField(6) int retryCount;
}
```

### 4.3 User Profile

```dart
@HiveType(typeId: 2)
class UserProfile {
  @HiveField(0) String fullName;
  @HiveField(1) String bloodType;
  @HiveField(2) String medicalNotes;
  @HiveField(3) String emergencyMessage; // custom SOS message
  @HiveField(4) String language; // es, en, nl
  @HiveField(5) bool darkMode;
  @HiveField(6) bool shakeToSOS;
}
```

---

## 5. Screens & Navigation

```
App
├── Home (SOS button — full screen, one tap)
│   ├── SOS Button (large, red, animated pulse)
│   ├── Quick Test Alert button
│   └── Status bar: "Connected" / "Offline — alerts will queue"
│
├── Contacts
│   ├── Contact List (grouped)
│   ├── Add Contact
│   └── Edit Contact
│
├── Map
│   ├── Current location marker
│   ├── Trusted contacts (if sharing)
│   └── Offline tile cache indicator
│
├── Settings
│   ├── Profile (name, blood type, notes)
│   ├── Alert Preferences (shake, custom message)
│   ├── Language (ES/EN/NL)
│   ├── Dark Theme toggle
│   └── About / Version
│
└── Alert History
    ├── Date, time, status
    └── Tap to see details
```

---

## 6. Edge Cases & Error Handling

| Scenario | Handling |
|----------|----------|
| No GPS signal | Use last known location + network location |
| No SIM card | WiFi-only alert via FCM + WhatsApp |
| WhatsApp not installed | Skip WhatsApp, send SMS + FCM |
| All channels fail | Show "Alert queued — will retry" + persistent notification |
| Phone locked | SOS from lock screen widget / notification |
| Accidental SOS | Cancel within 3-second countdown |
| Battery low | Reduce GPS polling, prioritize SMS over FCM |

---

## 7. Performance Requirements

| Metric | Target |
|--------|--------|
| Cold start | < 2 seconds |
| SOS trigger to alert sent | < 3 seconds (online) |
| GPS lock | < 5 seconds |
| App size | < 50 MB (APK) |
| Offline storage | < 10 MB for essential data + map tiles |
| Background sync | < 5% battery per day |

---

## 8. Security

| Concern | Mitigation |
|---------|-----------|
| Location data | Never leaves device except during active SOS |
| Contact list | Stored encrypted in Hive (Flutter Secure Storage) |
| FCM tokens | Rotated on app reinstall |
| SMS spoofing | N/A — SMS sent from user's own number |
| App tampering | ProGuard obfuscation for release builds |

---

## 9. Roadmap

### v1.0 — MVP (Current)
- [x] SOS button with 3-second countdown
- [x] WhatsApp + SMS + Phone channels
- [x] Trusted contacts CRUD
- [x] GPS location fetch
- [x] Dark theme
- [x] Offline Hive storage
- [ ] FCM push notifications
- [ ] Offline map tiles
- [ ] Shake-to-SOS

### v1.1 — Polish
- [ ] Lock screen widget
- [ ] Alert history screen
- [ ] Multi-language (ES/EN/NL)
- [ ] Test alert mode
- [ ] Custom SOS message

### v2.0 — Advanced
- [ ] Live location sharing
- [ ] Geofence alerts (arrive/leave safe zone)
- [ ] Emergency services directory (911, police, hospital by city)
- [ ] Voice-activated SOS ("Ayuda" keyword)
- [ ] Apple Watch / Wear OS companion

---

## 10. Competitor Analysis

| App | SafeRD Advantage |
|-----|-----------------|
| Noonlight | DR-specific, offline, WhatsApp integration |
| bSafe | Free, no subscription, MIT license |
| Life360 | Privacy-respecting — no persistent tracking |
| Local DR apps | Professional quality, Dutch engineering standards |

---

## 11. Appendix

### A. WhatsApp Message Format
```
🚨 EMERGENCIA 🚨
Wilmer necesita ayuda AHORA
📍 Ubicación: https://maps.google.com/?q=18.4861,-69.9312
📞 +31 6 XXXXXXXX
🩸 Sangre: O+
📝 Notas: Alergia a penicilina
Enviado desde SafeRD
```

### B. SMS Format (160 char limit)
```
EMERGENCY: Wilmer at https://maps.app.goo.gl/XXXXX. Call 911 or +316XXXX. SafeRD.
```

### C. TTS for 911 Call
```
"Emergency. Location: Latitude eighteen point four eight six one, Longitude minus sixty-nine point nine three one two. Caller: Wilmer Benzan. Blood type: O positive. Medical: allergic to penicillin."
```

---

*End of Specification*
