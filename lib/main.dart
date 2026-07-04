import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/firebase_service.dart';
import 'services/location_service.dart';
import 'services/offline_service.dart';
import 'services/notification_service.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'features/main_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Show app immediately, init services in background
  runApp(const _SafeRDLoading());

  // Init services after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final result = await _initAll();
    if (result.error != null) {
      runApp(_SafeRDError(result.error!));
    } else {
      runApp(SafeRDApp(
        firebaseService: result.firebase!,
        locationService: result.location!,
        offlineService: result.offline!,
        notificationService: result.notification!,
      ));
    }
  });
}

class _InitResult {
  FirebaseService? firebase;
  LocationService? location;
  OfflineService? offline;
  NotificationService? notification;
  String? error;
}

Future<_InitResult> _initAll() async {
  final result = _InitResult();
  try {
    result.offline = OfflineService();
    await result.offline!.init();
    result.location = LocationService();
    result.notification = NotificationService();
    result.firebase = FirebaseService();
  } catch (e, stack) {
    result.error = '$e\n\n$stack';
  }
  return result;
}

/// Loading screen shown while services initialize
class _SafeRDLoading extends StatelessWidget {
  const _SafeRDLoading();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6A00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.shield_rounded,
                    color: Color(0xFFFF6A00), size: 44),
              ),
              const SizedBox(height: 24),
              const Text('SafeRD',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 32),
              const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6A00)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error screen shown if init fails
class _SafeRDError extends StatelessWidget {
  final String message;
  const _SafeRDError(this.message);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Error al iniciar',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Reinicia la aplicación',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(message,
                    style: const TextStyle(color: Color(0xFFFF6A00), fontSize: 12, fontFamily: 'monospace')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
