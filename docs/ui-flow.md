# SafeRD — UI Flow

## Navigation Structure

```
App Start
  │
  ├─→ First Launch → Onboarding (3 screens)
  │     ├─ Welcome
  │     ├─ Add Emergency Contacts
  │     └─ Enable Permissions (GPS, SMS, Notifications)
  │
  └─→ Home Screen
        │
        ├─ [SOS Button] → Countdown (3s) → Alert Fired → Confirmation
        │     └─ Cancel → Back to Home
        │
        ├─ Bottom Nav Bar
        │     ├─ 🏠 Home (SOS + status)
        │     ├─ 👥 Contacts
        │     ├─ 🗺️ Map
        │     └─ ⚙️ Settings
        │
        └─ Alert History (from Settings)
```

## Screen States

### Home Screen
| State | UI |
|-------|-----|
| Ready | Green status "Conectado", SOS button pulsing |
| Offline | Orange status "Sin conexión — alerta en cola" |
| Alerting | Full red screen, countdown, no navigation |
| Sent | Green checkmark, "Alerta enviada a {N} contactos" |
| Failed | Red error, "Error — intente de nuevo" |

### SOS Flow (Critical Path)
```
Tap SOS
  → Vibration starts (medium intensity)
  → Screen turns red with overlay
  → Countdown ring animation (3s)
  → Button shows "CANCELAR" (large text)
  
  IF user releases/cancels:
    → Screen fades back to home
    → Vibration stops
    → No alert sent
  
  IF countdown completes:
    → Long vibration burst
    → Screen flashes white → green
    → Alert channels fire
    → "Alerta enviada" text appears
    → Auto-return to home after 5s
```
