# SafeRD — Emergency Protocol

> **SOURCE OF TRUTH for all SOS-related code.**
> Every AI-generated SOS feature must follow this protocol exactly.

## Alert Channel Priority
When SOS is triggered, channels fire in this order:

| Priority | Channel | Latency | Fallback |
|----------|---------|---------|----------|
| 1 | WhatsApp | < 500ms | Skip if not installed |
| 2 | SMS | < 2s | Skip if no SIM |
| 3 | FCM Push | < 3s | Queue if offline |
| 4 | Phone Call (911) | < 5s | Skip if no SIM |

**Rule:** Channels fire simultaneously. No channel blocks another.

## Message Formats

### WhatsApp
```
🚨 EMERGENCIA 🚨
{USER_NAME} necesita ayuda AHORA
📍 Ubicación: https://maps.google.com/?q={LAT},{LNG}
📞 {USER_PHONE}
🩸 Sangre: {BLOOD_TYPE}
📝 {MEDICAL_NOTES}
⏰ {TIMESTAMP}
Enviado desde SafeRD
```

### SMS (160 char limit)
```
EMERGENCY:{NAME} at maps.app.goo.gl/{SHORT} Call 911/+{PHONE}.SafeRD
```

### FCM Push
```json
{
  "type": "sos_alert",
  "user_name": "{NAME}",
  "lat": {LAT},
  "lng": {LNG},
  "timestamp": "{ISO8601}",
  "blood_type": "{TYPE}",
  "medical_notes": "{NOTES}"
}
```

### Phone Call (TTS)
```
"Emergency. This is an automated message from SafeRD.
{USER_NAME} needs help.
Location: latitude {LAT_DEGREES}, longitude {LNG_DEGREES}.
Blood type: {BLOOD_TYPE}.
Medical: {MEDICAL}.
Repeat: {USER_NAME} at latitude {LAT}, longitude {LNG}.
End of message."
```

## GPS Fallback Strategy
| Priority | Source | Accuracy | Timeout |
|----------|--------|----------|---------|
| 1 | GPS | 5-10m | 5s |
| 2 | Network (cell towers) | 50-500m | 3s |
| 3 | Last known location (Hive) | variable | instant |

**Rule:** If GPS lock fails after 5 seconds, use network location. If both fail, use last known location with disclaimer: `⚠️ Ubicación aproximada (última conocida hace {MINUTES} min)`

## Offline Queue Design
```
State: OFFLINE
  → Save alert to Hive queue with all channel targets
  → Show "Alerta en cola — se enviará al recuperar conexión"
  → Listen for connectivity change

State: RECONNECTED
  → Process queue in FIFO order
  → Send WhatsApp first (lightest)
  → Then SMS
  → Then FCM
  → Max 3 retries per alert
  → After 3 failures: mark as FAILED, notify user
  → On success: remove from queue, log to history
```

## Retry Strategy
| Attempt | Delay | Action |
|---------|-------|--------|
| 1 | 0s | Immediate |
| 2 | 10s | Wait |
| 3 | 30s | Wait |
| Failed | — | Stop, notify user, log |

## Countdown UX
```
T+0.0s: User taps SOS
  → Haptic: medium vibration
  → UI: red screen overlay, countdown ring animation
  → Text: "SOLTAR PARA CANCELAR" (hold) or countdown number

T+0.0 to T+2.5s: Cancel window
  → User can: release button, tap X, swipe away
  → Vibration stops immediately on cancel

T+3.0s: Alert fires
  → Haptic: long-long-short pattern
  → UI: flash screen white, then green confirmation
  → Audio: system alert sound (if not silent)
  → All channels fire simultaneously
```

## Safety Rules
1. **No delay between channels** — fire all, let them race
2. **GPS data is never stored externally** — only in local Hive alert log
3. **Contact list is encrypted at rest** (flutter_secure_storage)
4. **Alert cannot be stopped after T+3.0s** — irreversible by design
5. **False alert handling:** Send follow-up WhatsApp "Falsa alarma — estoy bien" 
6. **Test mode:** Orange button instead of red, labeled "PRUEBA", sends only to self

## Error States
| Error | User Sees | System Does |
|-------|-----------|-------------|
| No GPS | "Usando ubicación aproximada" | Network → last known fallback |
| No SIM | "WhatsApp + FCM enviados. SMS no disponible." | Skip SMS, phone |
| No internet | "Alerta en cola — se enviará al conectar" | Queue all channels |
| WhatsApp not installed | "WhatsApp no instalado. SMS + FCM enviados." | Skip WhatsApp |
| All channels fail | "No se pudo enviar la alerta. Intente de nuevo." | Log failure, retry on connectivity |
