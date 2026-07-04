import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:saferd/core/theme.dart';
import 'package:saferd/core/constants.dart';
import 'package:saferd/models/contact.dart';
import 'package:saferd/services/offline_service.dart';
import 'package:saferd/services/location_service.dart';
import 'package:saferd/services/firebase_service.dart';
import 'package:saferd/services/notification_service.dart';
import 'package:saferd/features/home/sos_home_screen.dart';
import 'package:saferd/features/settings_screen.dart';
import 'package:saferd/features/history_screen.dart';
import 'package:saferd/features/contacts_screen.dart';
import 'package:saferd/features/sos/sos_button.dart';

Widget wrapWithProviders(Widget child, {OfflineService? offline}) {
  return MultiProvider(
    providers: [
      Provider<FirebaseService>.value(value: FirebaseService()),
      Provider<LocationService>.value(value: LocationService()),
      Provider<OfflineService>.value(value: offline ?? OfflineService()),
      Provider<NotificationService>.value(value: NotificationService()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: child,
    ),
  );
}

void main() {
  // ── SPEC 2.1: SOS Button ─────────────────────────────────
  group('SPEC 2.1 — SOS Button', () {
    testWidgets('SOS button renders', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const SOSButton()));
      // pump a few frames — don't use pumpAndSettle (animation loops forever)
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SOSButton), findsOneWidget);
    });
  });

  // ── SPEC 2.2: Contacts Model ─────────────────────────────
  group('SPEC 2.2 — Contact Model', () {
    test('serializes to/from map', () {
      final contact = EmergencyContact(
        id: 'test-1', name: 'Wilmer', phoneNumber: '+316****5678',
        notifyWhatsApp: true, notifySMS: true,
      );
      final map = contact.toMap();
      expect(map['name'], 'Wilmer');
      expect(map['phoneNumber'], '+316****5678');
      expect(map['notifyWhatsApp'], true);

      final restored = EmergencyContact.fromMap('test-1', map);
      expect(restored.name, 'Wilmer');
    });

    test('initial is first letter uppercase', () {
      expect(EmergencyContact(id: 'x', name: 'Wilmer', phoneNumber: '').initial, 'W');
      expect(EmergencyContact(id: 'x', name: 'maria', phoneNumber: '').initial, 'M');
    });

    test('channelsLabel without channels shows fallback', () {
      final c = EmergencyContact(id: 'x', name: 'T', phoneNumber: '',
          notifyWhatsApp: false, notifySMS: false);
      expect(c.channelsLabel, 'Sin canales');
    });

    test('channelsLabel with both channels', () {
      final c = EmergencyContact(id: 'x', name: 'T', phoneNumber: '',
          notifyWhatsApp: true, notifySMS: true);
      expect(c.channelsLabel, 'WhatsApp, SMS');
    });

    test('copyWith preserves id', () {
      final original = EmergencyContact(id: 'abc', name: 'Old', phoneNumber: '123');
      final updated = original.copyWith(name: 'New');
      expect(updated.id, 'abc');
      expect(updated.name, 'New');
      expect(updated.phoneNumber, '123');
    });
  });

  // ── SPEC 2.4: Offline Mode ───────────────────────────────
  group('SPEC 2.4 — OfflineService', () {
    // Note: full init() requires Hive which needs Flutter binding.
    // These are basic state tests.
  });

  // ── SPEC 2.5: Theme & Constants ──────────────────────────
  group('SPEC 2.5 — Theme', () {
    test('dark theme is default', () {
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.dark.scaffoldBackgroundColor, AppTheme.bg);
    });

    test('SOS colors match SPEC', () {
      expect(AppTheme.danger, const Color(0xFFE53935));
      expect(AppTheme.warning, const Color(0xFFFFC107));
      expect(AppTheme.safe, const Color(0xFF4CAF50));
      expect(AppTheme.accent, const Color(0xFFFF6A00));
    });
  });

  group('SPEC 2.5 — Constants', () {
    test('SOS countdown is 3 seconds', () => expect(AppConstants.sosCountdownSeconds, 3));
    test('emergency number is 911', () => expect(AppConstants.emergencyNumber, '911'));
    test('offline expiry is 4 hours', () => expect(AppConstants.incidentExpiryHours, 4));
    test('max retries is 3', () => expect(AppConstants.maxRetries, 3));
  });
}
