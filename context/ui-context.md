# SafeRD — UI Context

## Design System
**Theme:** Dark mode by default (safety app → used at night)
**Framework:** Material 3

## Colors
| Token | Hex | Usage |
|-------|-----|-------|
| Emergency Red | `#E53935` | SOS button, alerts |
| Alert Orange | `#FF9800` | Warnings, countdown |
| Safe Green | `#4CAF50` | Connected status |
| Dark Background | `#121212` | App background |
| Dark Surface | `#1E1E1E` | Cards, sheets |
| Text Primary | `#FFFFFF` | Headlines, body |
| Text Secondary | `#B0B0B0` | Subtitles, hints |

## Typography
- **Headlines:** Roboto Bold
- **Body:** Roboto Regular
- **SOS Text:** Roboto Black, uppercase, letter-spacing 4px

## SOS UX — Critical Path
```
Tap SOS → 3-second countdown (vibrate + animation)
  ├─ Cancel option (large X button)
  └─ Timer reaches 0 → alert fires
       ├─ Vibration pattern: long-long-short
       ├─ Flash screen red
       └─ Show "Alert Sent" confirmation
```

## Components
| Component | Spec |
|-----------|------|
| SOS Button | 200×200dp, red `#E53935`, pulsing animation, shadow |
| Countdown | Large white text (72sp), ring animation |
| Contact Card | 72dp height, avatar + name + channels |
| Status Bar | Top of home screen, green "Connected" / orange "Offline" |

## Accessibility
- SOS button: minimum 48×48dp touch target (actual: 200dp)
- All text: minimum 14sp
- Contrast ratio: minimum 4.5:1
- Screen reader labels on all buttons
