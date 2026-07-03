# SafeRD — API / Services

## Internal Services

| Service | Location | Description |
|---------|----------|-------------|
| `SosService` | features/sos/data/ | Orchestrates all alert channels |
| `GpsService` | features/sos/data/ | Location fetch with fallback |
| `ContactService` | features/contacts/data/ | CRUD for trusted contacts |
| `AlertLogService` | features/alerts/data/ | Alert history storage |
| `ConnectivityService` | core/network/ | Online/offline detection |
| `HiveService` | core/storage/ | Hive DB initialization + adapters |

## External Integrations

| Integration | Package | Method |
|-------------|---------|--------|
| WhatsApp | url_launcher | `launchUrl('whatsapp://send?phone=+123&text=...')` |
| SMS | telephony | `Telephony.sendSms(number, message)` |
| Phone | url_launcher | `launchUrl('tel://911')` |
| FCM | firebase_messaging | Push notification to trusted contacts |
| Maps | flutter_map | OpenStreetMap tiles |
| TTS | flutter_tts | `flutterTts.speak(emergencyMessage)` |

## Service Interfaces

```dart
abstract class SosService {
  Future<Result<void>> triggerAlert({
    required double lat,
    required double lng,
    required List<EmergencyContact> contacts,
  });
  
  Future<Result<void>> sendTestAlert();
  Future<Result<void>> cancelAlert();
}
```

```dart
abstract class GpsService {
  Future<Result<Location>> getCurrentLocation();
  Stream<Location> get locationStream;
}
```
