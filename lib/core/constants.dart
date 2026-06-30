/// SafeRD — Core constants and configuration
class AppConstants {
  // App
  static const appName = 'SafeRD';
  static const appVersion = '1.0.0';
  static const appUrl = 'https://github.com/benzanmontage-hue/safe-rd';

  // Location defaults (Santo Domingo)
  static const double defaultLat = 18.4861;
  static const double defaultLng = -69.9312;
  static const double defaultZoom = 14.0;

  // Incident
  static const int incidentExpiryHours = 4;
  static const double defaultRadiusKm = 10.0;
  static const int maxNearbyIncidents = 50;

  // SOS
  static const int sosCountdownSeconds = 3;
  static const String sosMessage = '¡Emergencia! Necesito ayuda. Enviado desde SafeRD.';
  static const String emergencyNumber = '911';

  // Offline
  static const String offlineBoxName = 'saferd_cache';
  static const int maxCachedIncidents = 100;
  static const Duration syncInterval = Duration(minutes: 5);

  // Firebase
  static const String incidentsCollection = 'incidents';
  static const String usersCollection = 'users';
  static const String notificationsTopic = 'incident_alerts';

  // API
  static const Duration networkTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;
}
