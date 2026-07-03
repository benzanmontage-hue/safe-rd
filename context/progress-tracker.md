# SafeRD — Progress Tracker

Last updated: 3 July 2026

## MVP Progress

### Core
- ✅ Project scaffold (Flutter clean architecture)
- ✅ Hive setup + adapters
- ✅ Riverpod providers
- ✅ Dark theme (Material 3)

### SOS Engine
- ✅ SOS button UI with pulsing animation
- ✅ 3-second countdown with cancel
- ✅ GPS location fetch
- ✅ Haptic feedback
- ⬜ Shake-to-SOS trigger
- ⬜ Lock screen widget

### Alert Channels
- ✅ WhatsApp (url_launcher)
- ✅ SMS (telephony)
- ✅ Phone call (911 auto-dial)
- ⬜ FCM push notifications
- ⬜ Offline alert queue
- ⬜ Retry strategy

### Trusted Contacts
- ✅ Contact CRUD
- ✅ Add from phonebook
- ⬜ Groups (Family, Friends, Work)
- ⬜ Per-channel toggle (WA/SMS/Push)

### Settings
- ✅ Dark theme toggle
- ⬜ User profile (name, blood type, notes)
- ⬜ Language (ES/EN/NL)
- ⬜ Custom SOS message

### Other
- ⬜ Alert history screen
- ⬜ Test alert mode
- ⬜ Offline map tiles
- ⬜ App icon and splash screen
- ⬜ Release build (APK)

## Blocked
- FCM push: needs Firebase project setup
- Offline maps: pending tile download strategy

## Next Sprint
1. Shake-to-SOS trigger
2. Alert history screen
3. Offline queue implementation
4. Lock screen widget

## Tech Debt
- [ ] Widget tests for SOS button
- [ ] Integration test for full SOS flow
- [ ] ProGuard rules for release
- [ ] Google Play Store listing assets
