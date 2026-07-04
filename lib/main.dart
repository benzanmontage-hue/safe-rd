import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/firebase_service.dart';
import 'services/location_service.dart';
import 'services/offline_service.dart';
import 'services/notification_service.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'features/home/home_screen.dart';
import 'features/main_scaffold.dart';

/// SafeRD — Main application entry point for the Dominican Republic.
///
/// Initializes all core services in order:
/// 1. Hive (local storage)
/// 2. OfflineService (offline-first caching)
/// 3. NotificationService (FCM push)
/// 4. Firebase (core + offline persistence)
///
/// Uses [MultiProvider] to inject [FirebaseService], [LocationService],
/// [OfflineService], and [NotificationService] throughout the widget tree.
/// Shows a detailed error screen if Firebase initialization fails.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show errors as readable text instead of red screen
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'SafeRD Fout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  details.exceptionAsString(),
                  style: const TextStyle(
                    color: const Color(0xFFFF6A00),
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              if (details.stack != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Stack trace:',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    details.stack.toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  };

  // Initialize services
  final offlineService = OfflineService();
  final notificationService = NotificationService();
  final firebaseService = FirebaseService();

  try {
    // 1. Initialize Hive for local storage
    await Hive.initFlutter();
    debugPrint('SafeRD — Hive initialized');

    // 2. Initialize offline service
    await offlineService.init();
    debugPrint('SafeRD — OfflineService initialized');

    // 3. Initialize notifications
    await notificationService.init();
    debugPrint('SafeRD — NotificationService initialized');

    // 4. Initialize Firebase
    await Firebase.initializeApp();
    debugPrint(
      'SafeRD — Firebase initialized (${Firebase.apps.length} app(s))',
    );

    // 5. Enable Firestore offline persistence
    await firebaseService.enableOfflinePersistence();

    // 6. Wire FirebaseService to OfflineService
    firebaseService.setOfflineService(offlineService);

    // 7. Sync any queued incidents from offline storage
    final synced = await firebaseService.syncQueuedIncidents();
    if (synced > 0) {
      debugPrint('SafeRD — Synced $synced queued incidents');
    }
  } catch (e, stack) {
    debugPrint('SafeRD — Initialization error: $e');
    debugPrint('SafeRD — Stack: $stack');

    // Show error in UI instead of crashing
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Init mislukt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Controleer internetverbinding en Firebase-configuratie.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      '$e',
                      style: const TextStyle(
                        color: const Color(0xFFFF6A00),
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // Run the app with all services
  runApp(
    SafeRDApp(
      firebaseService: firebaseService,
      locationService: LocationService(),
      offlineService: offlineService,
      notificationService: notificationService,
    ),
  );
}

/// SafeRD root widget with MultiProvider setup.
///
/// Provides [FirebaseService], [LocationService], [OfflineService], and
/// [NotificationService] to the entire widget tree via Provider.
class SafeRDApp extends StatelessWidget {
  final FirebaseService firebaseService;
  final LocationService locationService;
  final OfflineService offlineService;
  final NotificationService notificationService;

  const SafeRDApp({
    super.key,
    required this.firebaseService,
    required this.locationService,
    required this.offlineService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>.value(value: firebaseService),
        Provider<LocationService>.value(value: locationService),
        Provider<OfflineService>.value(value: offlineService),
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainScaffold(),
      ),
    );
  }
}
