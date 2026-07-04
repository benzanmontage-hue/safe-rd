# SafeRD — Design & Sprint Plan v2

> **Hermes context:** Design review + implementation plan. Focus op visuele consistentie en gebruiker-first UX.

**Doel:** SafeRD ombouwen van incident-rapportage app naar complete persoonlijke veiligheidsapp voor DR — offline-first, SOS-first, Flitsmeister dark aesthetic.

**Laatste update:** 4 Juli 2026

---

## 1. VISUEEL DESIGN

### 1.1 Huidige staat

| Wat | Nu |
|-----|-----|
| Theme | Dark (✅) |
| Kleuren | Rood `#E53935`, Oranje `#FF6A00`, Groen `#4CAF50` |
| Stijl | Flitsmeister-achtig — minimalistisch, donker, amber accenten |
| Kaart | Google Maps (zwaar, API-key nodig) |
| SOS knop | Klein (FAB formaat), rechtsonder |

### 1.2 Gewenste staat

SafeRD moet een **SOS-first** app zijn. De gebruiker opent de app en ziet méteen de SOS knop — groot, centraal, onmiskenbaar.

```
┌─────────────────────────────┐
│ 🔴  Status: Conectado       │  ← Status bar (groen/rood)
│                             │
│                             │
│        ┌───────────┐        │
│        │           │        │
│        │   🚨 SOS  │        │  ← 200×200dp, rood, pulse animatie
│        │           │        │
│        │  Mantener  │        │
│        │  3 segundos│        │
│        └───────────┘        │
│                             │
│  [🧪 Test]  [📋 Historial]  │  ← Secundaire knoppen
│                             │
│  ┌─────────────────────┐    │
│  │ 👥 Contactos (3)    │    │  ← Bottom sheet (draggable)
│  │ Wilmer ✓            │    │
│  │ Maria ✓             │    │
│  │ Pedro (sin app)     │    │
│  └─────────────────────┘    │
│                             │
│  [🗺️ Mapa]  [⚙️ Ajustes]   │  ← Bottom nav
└─────────────────────────────┘
```

### 1.3 Design Tokens

```yaml
colors:
  bg:          '#121212'    # Achtergrond
  surface:     '#1E1E1E'    # Cards, sheets
  accent:      '#FF6A00'    # Amber accent (Flitsmeister style)
  danger:      '#E53935'    # SOS rood
  warning:     '#FFC107'    # Waarschuwingen
  safe:        '#4CAF50'    # Connected/online
  text:        '#F5F5F5'    # Primaire tekst
  dim:         '#9E9E9E'    # Secundaire tekst
  border:      '#333333'    # Card borders

typography:
  headlines:    Roboto Bold, 18-24sp
  body:         Roboto Regular, 14-16sp
  sos:          Roboto Black, 28sp, uppercase, letter-spacing 4px
  countdown:    72sp, Roboto Black, amber

components:
  cards:        16px radius, 1px border
  buttons:      12px radius, 14px padding
  sheets:       24px top radius
  inputs:       12px radius, 16px padding
```

---

## 2. NAVIGATIE (Bottom Nav)

```
🧭 Bottom Navigation Bar:
├── 🏠 Inicio    (SOS + contacten)
├── 🗺️ Mapa      (Live kaart + incidenten)
├── 📋 Historial (Alert log)
└── ⚙️ Ajustes   (Profiel + settings)
```

**Nu:** Alleen home screen met kaart + incident bottom sheet.
**Doel:** 4-tab bottom nav, SOS altijd bereikbaar via FAB of home screen.

---

## 3. FEATURE PRIORITEITEN

### 🔴 Sprint 1 — SOS Core (deze week)

| # | Feature | Impact | Effort |
|---|---------|--------|--------|
| 1 | **SOS home screen redesign** — grote SOS knop centraal | 🔥🔥🔥🔥🔥 | 2u |
| 2 | **SOS knoop UX** — hold-to-activate, 3s countdown ring | 🔥🔥🔥🔥🔥 | 3u |
| 3 | **Bottom navigation** — 4 tabs | 🔥🔥🔥🔥 | 1u |
| 4 | **Offline queue** — alerts queuen zonder internet | 🔥🔥🔥🔥 | 4u |
| 5 | **Alert history** — lokale log van alle alerts | 🔥🔥🔥🔥 | 2u |
| 6 | **Contacten scherm** — CRUD trusted contacts | 🔥🔥🔥🔥 | 3u |

### 🟠 Sprint 2 — Polish (volgende week)

| # | Feature | Impact | Effort |
|---|---------|--------|--------|
| 7 | **Shake-to-SOS** — 3× schudden = SOS trigger | 🔥🔥🔥 | 2u |
| 8 | **User profile** — naam, bloedtype, medische notities | 🔥🔥🔥 | 1.5u |
| 9 | **Test alert** — oranje testknop, stuurt alleen naar zelf | 🔥🔥🔥 | 2u |
| 10 | **Multi-language** — ES/EN/NL toggle | 🔥🔥 | 3u |
| 11 | **Custom SOS message** — gebruiker kan bericht aanpassen | 🔥🔥 | 1u |

### 🟢 Sprint 3 — Advanced

| # | Feature | Impact | Effort |
|---|---------|--------|--------|
| 12 | **Lock screen widget** — SOS vanaf lockscreen | 🔥🔥🔥 | 5u |
| 13 | **Offline tiles** — SDQ, Punta Cana, Santiago | 🔥🔥 | 4u |
| 14 | **FCM push** — Firebase notificaties naar contacts | 🔥🔥🔥 | 4u |
| 15 | **flutter_map migratie** — OSM ipv Google Maps | 🔥🔥 | 3u |

---

## 4. ARCHITECTUUR BESLISSINGEN

### 4.1 Google Maps → flutter_map (Sprint 3)

**Nu:** Google Maps (`google_maps_flutter`) — vereist API key, zwaar, geen offline tiles.
**Doel:** `flutter_map` + OpenStreetMap — gratis, offline tiles mogelijk, lichter.

```yaml
# pubspec.yaml — nieuw
flutter_map: ^7.0.0
latlong2: ^0.9.0
```

### 4.2 Provider → Riverpod (Sprint 3)

**Nu:** Provider package.
**Doel:** Riverpod (betere testbaarheid, compile-time safety).

### 4.3 Data flow — Offline Queue (Sprint 1)

```
Alert triggered (OFFLINE):
  → Save to Hive queue: {id, timestamp, location, contacts, retries: 0}
  → UI: "Alerta en cola — se enviará al conectar"
  
Connectivity restored:
  → Process queue FIFO
  → WhatsApp → SMS → FCM (in parallel)
  → Max 3 retries (0s, 10s, 30s)
  → Success: remove from queue, save to history
  → 3 failures: mark FAILED, notify user
```

### 4.4 Bestandsstructuur (target)

```
lib/
├── core/
│   ├── theme.dart              # ✅ Bestaat
│   ├── constants.dart          # ✅ Bestaat
│   ├── routes.dart             # ⬜ Nieuw — navigatie
├── features/
│   ├── home/
│   │   └── home_screen.dart    # 🔄 Refactor — SOS-centric
│   ├── sos/
│   │   ├── sos_button.dart     # 🔄 Refactor — groter, hold UX
│   │   ├── sos_service.dart    # ⬜ Nieuw — coördinatie engine
│   │   └── offline_queue.dart  # ⬜ Nieuw
│   ├── contacts/
│   │   ├── contacts_screen.dart # ⬜ Nieuw
│   │   └── contact_card.dart   # ⬜ Nieuw
│   ├── history/
│   │   ├── history_screen.dart # ⬜ Nieuw
│   │   └── alert_log_card.dart # ⬜ Nieuw
│   ├── map/
│   │   └── map_screen.dart     # 🔄 Verplaats uit home
│   ├── settings/
│   │   └── settings_screen.dart # ⬜ Nieuw
│   ├── report/
│   │   └── report_screen.dart  # ✅ Bestaat
├── models/
│   ├── incident.dart           # ✅ Bestaat
│   ├── contact.dart            # ⬜ Nieuw
│   ├── alert_log.dart          # ⬜ Nieuw
│   └── user_profile.dart       # ⬜ Nieuw
├── services/
│   ├── firebase_service.dart   # ✅ Bestaat
│   ├── location_service.dart   # ✅ Bestaat
│   ├── offline_service.dart    # ✅ Bestaat — uitbreiden
│   ├── audio_service.dart      # ✅ Bestaat
│   └── notification_service.dart # ✅ Bestaat
└── main.dart                   # ✅ Bestaat — bottom nav toevoegen
```

---

## 5. WAT NIET TE DOEN

- ❌ **Nog geen FCM** — te complex voor nu, Firebase project nodig
- ❌ **Geen Google Maps dependency uitbreiden** — we gaan naar flutter_map
- ❌ **Geen feature creep** — focus op SOS flow, de rest is bijzaak
- ❌ **Geen login/registratie** — app is lokaal-first, geen accounts
- ❌ **Wilmer design filosofie:** "keep it simpel" — geen over-engineered animaties, geen onnodige schermen

---

## 6. EERSTE TASK: SOS Home Screen

### Wat moet er gebeuren?

De huidige `home_screen.dart` is een kaart met incidenten — dat moet het Map-tabblad worden. Een nieuw home screen moet:

1. **Grote SOS knop** (200×200dp) centraal op het scherm
2. **Hold-to-activate** UX — gebruiker moet 3 seconden vasthouden
3. **Pulse animatie** — rode ring die klopt
4. **Countdown ring** — amber ring die rondgaat tijdens hold
5. **Status indicator** — groen "Conectado" of oranje "Sin conexión"
6. **Snelle contacten** — mini-lijst onder de SOS knop (2-3 trusted contacts)

### Mockup

```
┌──────────────────────────┐
│ 🔴 Conectado        DR 🏳│  ← 16px padding
│                          │
│                          │
│       ╭─────────╮       │
│      ╱           ╲      │
│     │    🚨 SOS   │     │  ← Rode cirkel, 200dp
│     │             │     │     Pulse: ring expand/fade
│     │  Mantén 3s  │     │
│     │             │     │
│      ╲           ╱      │
│       ╰─────────╯       │
│                          │
│                          │
│   [🧪 Prueba] [📋 Log]  │  ← Kleine secundaire knoppen
│                          │
│ ┌──────────────────────┐ │
│ │ 👥 Contactos         │ │  ← Card
│ │  Wilmer     ✓ WA/SMS │ │
│ │  Maria      ✓ WA     │ │
│ └──────────────────────┘ │
│                          │
│ 🏠  🗺️  📋  ⚙️          │  ← Bottom nav
└──────────────────────────┘
```

---

## 7. PROJECT STATUS

| Area | Progress |
|------|----------|
| SOS core UI | 🔄 Needs redesign |
| Alert channels (WA/SMS/Phone) | ✅ Working |
| GPS location | ✅ Working |
| Offline storage (Hive) | ✅ Working |
| Firebase sync | ✅ Working |
| Incident reporting | ✅ Working |
| Bottom nav | ⬜ Not started |
| Contacts management | ⬜ Not started |
| Alert history | ⬜ Not started |
| Offline queue | ⬜ Not started |
| User profile | ⬜ Not started |
| Multi-language | ⬜ Not started |

---

*Plan ready for review. Wilmer: zeg welke feature eerst, of "start met Sprint 1".*
