# SafeRD — Progress Tracker

Last updated: 4 July 2026

## Sprint 1 Complete ✅

### Core Redesign
- ✅ SOS home screen — grote rode knop (200×200dp), centraal
- ✅ Hold-to-activate UX — 3s countdown ring met pulse animatie
- ✅ Haptic feedback (medium → heavy → heavy-heavy)
- ✅ Status bar: "Conectado" / "Sin conexión"
- ✅ Bottom navigation — 4 tabs (Inicio, Mapa, Historial, Ajustes)

### SOS Engine
- ✅ SOS button UI with pulsing animation
- ✅ 3-second countdown with cancel
- ✅ GPS location fetch
- ✅ Haptic feedback
- ✅ WhatsApp + SMS + Phone channels
- ⬜ Shake-to-SOS trigger
- ⬜ Lock screen widget

### Alert Channels
- ✅ WhatsApp (url_launcher)
- ✅ SMS (telephony)
- ✅ Phone call (911 auto-dial)
- ⬜ FCM push notifications

### Offline
- ✅ Alert queue — queueert alerts zonder internet
- ✅ Auto-retry bij reconnect (0s, 10s, 30s, max 3)
- ✅ Alert history — lokale Hive log
- ✅ Connectivity listener met reconnect callbacks

### Trusted Contacts
- ✅ Contact model + CRUD
- ✅ Contacts screen met add/edit/delete dialogs
- ✅ Per-channel toggle (WhatsApp/SMS)
- ✅ Active/inactive toggle
- ✅ Home screen mini contact preview (tappable → full screen)

### Settings
- ✅ Dark theme toggle (stub)
- ✅ Language selector (stub, ES default)
- ✅ Shake-to-SOS toggle (stub)
- ✅ Profile fields: nombre, tipo sangre, notas médicas (stub)
- ⬜ User profile (real data binding)
- ⬜ Language (ES/EN/NL) real switching
- ⬜ Custom SOS message

### Other
- ✅ Alert history screen
- ⬜ Test alert mode
- ⬜ Offline map tiles
- ⬜ App icon and splash screen
- ⬜ Release build (APK)

## Next Sprint
1. Shake-to-SOS trigger
2. Test alert mode (orange button, sends only to self)
3. User profile with real data
4. Lock screen widget

## Tech Debt
- [ ] Widget tests for SOS button
- [ ] Integration test for full SOS flow
- [ ] ProGuard rules for release
- [ ] Google Play Store listing assets
- [ ] flutter_map migration (replace Google Maps)
