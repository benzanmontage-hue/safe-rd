# SafeRD — Database Schema (Hive)

## Boxes

| Box Name | Type | Purpose |
|----------|------|---------|
| `contacts` | `Box<EmergencyContact>` | Trusted contacts list |
| `alertLogs` | `Box<AlertLog>` | SOS alert history |
| `settings` | `Box<dynamic>` | Key-value user preferences |
| `alertQueue` | `Box<QueuedAlert>` | Offline alert queue |

## Models

### EmergencyContact (typeId: 0)
```dart
@HiveType(typeId: 0)
class EmergencyContact extends HiveObject {
  @HiveField(0) String id;           // UUID
  @HiveField(1) String name;         // Display name
  @HiveField(2) String phoneNumber;  // +18091234567
  @HiveField(3) bool notifyWhatsApp; // Send via WA?
  @HiveField(4) bool notifySMS;      // Send via SMS?
  @HiveField(5) bool notifyPush;     // Send via FCM?
  @HiveField(6) String group;        // family | friends | work
  @HiveField(7) bool isActive;       // Soft delete
  @HiveField(8) DateTime createdAt;
}
```

### AlertLog (typeId: 1)
```dart
@HiveType(typeId: 1)
class AlertLog extends HiveObject {
  @HiveField(0) String id;                    // UUID
  @HiveField(1) DateTime timestamp;
  @HiveField(2) double latitude;
  @HiveField(3) double longitude;
  @HiveField(4) List<String> contactsNotified; // Contact IDs
  @HiveField(5) int status;           // 0=sent, 1=queued, 2=failed
  @HiveField(6) int retryCount;
  @HiveField(7) bool isTest;          // Test alert?
}
```

### QueuedAlert (typeId: 2)
```dart
@HiveType(typeId: 2)
class QueuedAlert extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) DateTime timestamp;
  @HiveField(2) double latitude;
  @HiveField(3) double longitude;
  @HiveField(4) List<String> contactIds;
  @HiveField(5) int retryCount;
  @HiveField(6) DateTime nextRetryAt;
}
```

### Settings (key-value, no type adapter)
```dart
// Keys stored in settings box:
'user_name'
'user_phone'
'user_blood_type'
'user_medical_notes'
'custom_sos_message'
'language'          // 'es' | 'en' | 'nl'
'dark_mode'         // true | false
'shake_to_sos'      // true | false
'onboarding_done'   // true | false
```
