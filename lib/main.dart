import 'dart:ui';
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
import 'features/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch ALL errors including async/PlatformDispatcher errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('SafeRD — FATAL: $error\n$stack');
    return true; // handled
  };

  ErrorWidget.builder = (details) => _errorWidget(
    'Error en la UI',
    details.exceptionAsString(),
    details.stack?.toString(),
  );

  // Initialize services — each is optional
  final offlineService = OfflineService();
  final notificationService = NotificationService();
  final firebaseService = FirebaseService();

  await Hive.initFlutter();
  await offlineService.init();

  // Non-critical services
  await _tryInit('Notificaciones', () => notificationService.init());
  await _tryInit('Firebase', () async {
    await Firebase.initializeApp();
    await firebaseService.enableOfflinePersistence();
    firebaseService.setOfflineService(offlineService);
    await firebaseService.syncQueuedIncidents();
  });

  runApp(SafeRDApp(
    firebaseService: firebaseService,
    locationService: LocationService(),
    offlineService: offlineService,
    notificationService: notificationService,
  ));
}

Future<void> _tryInit(String name, Future<void> Function() fn) async {
  try {
    await fn();
    debugPrint('SafeRD — $name ✓');
  } catch (e) {
    debugPrint('SafeRD — $name ✗: $e');
  }
}

Widget _errorWidget(String title, String message, String? stack) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
                child: SelectableText(message, style: const TextStyle(color: Color(0xFFFF6A00), fontSize: 13, fontFamily: 'monospace')),
              ),
              if (stack != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
                  child: SelectableText(stack, style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

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
