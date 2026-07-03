# SafeRD — Security

## Data Protection

| Data | Storage | Encryption |
|------|---------|-----------|
| Contact list | Hive box | flutter_secure_storage (keys) |
| Alert history | Hive box | No (local only) |
| GPS data | Never stored externally | N/A |
| FCM tokens | Firebase | Firebase encryption |
| User profile | Hive box | flutter_secure_storage |
| SMS messages | Phone SMS app | OS-level |

## Threat Model

| Threat | Risk | Mitigation |
|--------|------|-----------|
| App reverse-engineered | Low | ProGuard obfuscation |
| Location leaked | Medium | Never sent except during SOS |
| FCM token stolen | Low | Rotate on reinstall |
| SMS intercepted | Low | SMS is inherently insecure — warn user |
| False SOS | Medium | 3s countdown + cancel option |
| App uninstalled during SOS | Low | SMS already sent by then |

## Privacy Principles

1. **GPS never tracked** — only accessed during SOS
2. **No analytics** — no Firebase Analytics, no Crashlytics
3. **No third-party data sharing** — contacts stay on device
4. **No background location** — app doesn't run GPS in background
5. **Data minimization** — only store what's needed for SOS

## Build Security

```gradle
// android/app/build.gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt')
    }
}
```

## Permissions (Android)

| Permission | Why | When |
|-----------|-----|------|
| ACCESS_FINE_LOCATION | GPS for SOS | On SOS trigger |
| SEND_SMS | SMS alerts | On SOS trigger |
| CALL_PHONE | 911 auto-dial | On SOS trigger |
| VIBRATE | Haptic feedback | Always |
| INTERNET | FCM, WhatsApp | Always |
| RECEIVE_BOOT_COMPLETED | Restart services | Always |
| FOREGROUND_SERVICE | SOS from background | Always |
