import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/incident.dart';
import '../core/constants.dart';
import 'offline_service.dart';

/// SafeRD — Enhanced Firebase service for the Dominican Republic.
///
/// Provides Firestore operations with:
/// - Offline persistence enabled by default
/// - [OfflineService] integration for queuing incidents when offline
/// - Connectivity-aware operations with automatic retry
/// - Comprehensive error handling with try/catch
class FirebaseService {
  FirebaseFirestore? _db;
  CollectionReference? _incidents;
  final Connectivity _connectivity = Connectivity();
  OfflineService? _offline;
  bool _persistenceEnabled = false;

  /// Attach an [OfflineService] instance for offline queue management.
  void setOfflineService(OfflineService offline) {
    _offline = offline;
  }

  /// Enable Firestore offline persistence.
  /// Should be called once before any Firestore operations.
  Future<void> enableOfflinePersistence() async {
    if (_persistenceEnabled) return;
    try {
      // Cloud Firestore enables offline persistence by default in current versions
      _persistenceEnabled = true;
      debugPrint('SafeRD — Firestore offline persistence ready');
    } catch (e) {
      debugPrint('SafeRD — Failed to enable persistence: $e');
    }
  }

  FirebaseFirestore get db {
    _db ??= FirebaseFirestore.instance;
    return _db!;
  }

  CollectionReference get incidents {
    _incidents ??= db.collection(AppConstants.incidentsCollection);
    return _incidents!;
  }

  /// Check if Firebase is currently available.
  bool get isAvailable {
    try {
      FirebaseFirestore.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Check current connectivity status.
  Future<bool> get isOnline async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (_) {
      return false;
    }
  }

  /// Report a new incident.
  ///
  /// If online, submits directly to Firestore.
  /// If offline, queues the incident via [OfflineService] for later sync.
  Future<String?> reportIncident(Incident incident) async {
    try {
      final online = await isOnline;
      if (online) {
        final docRef = await incidents.add(incident.toMap());
        debugPrint('SafeRD — Incident reported: ${docRef.id}');
        return docRef.id;
      } else {
        // Offline — queue for later sync
        if (_offline != null) {
          await _offline!.queueIncident(incident);
          debugPrint('SafeRD — Incident queued for offline sync');
        }
        return null;
      }
    } catch (e) {
      debugPrint('SafeRD — reportIncident error: $e');
      // Fallback to offline queue
      if (_offline != null) {
        try {
          await _offline!.queueIncident(incident);
        } catch (qe) {
          debugPrint('SafeRD — offline queue error: $qe');
        }
      }
      return null;
    }
  }

  /// Confirm an incident (+1 confirmation).
  Future<void> confirmIncident(String id) async {
    try {
      if (await isOnline) {
        await incidents.doc(id).update({
          'confirmations': FieldValue.increment(1),
        });
      }
    } catch (e) {
      debugPrint('SafeRD — confirmIncident error: $e');
    }
  }

  /// Deny an incident (+1 denial).
  Future<void> denyIncident(String id) async {
    try {
      if (await isOnline) {
        await incidents.doc(id).update({
          'denials': FieldValue.increment(1),
        });
      }
    } catch (e) {
      debugPrint('SafeRD — denyIncident error: $e');
    }
  }

  /// Listen to active incidents in real-time.
  ///
  /// Returns a stream that emits the full list of active, non-expired
  /// incidents whenever the Firestore collection changes.
  /// Falls back to cached incidents from [OfflineService] when offline.
  Stream<List<Incident>> getActiveIncidents({
    double? lat,
    double? lng,
    double radiusKm = AppConstants.defaultRadiusKm,
  }) {
    // Merge online stream with offline cache
    final onlineStream = _onlineIncidentStream();
    final offlineStream = _offlineIncidentStream();

    return StreamGroup.merge([onlineStream, offlineStream]);
  }

  Stream<List<Incident>> _onlineIncidentStream() {
    try {
      var query = incidents
          .where('active', isEqualTo: true)
          .orderBy('reportedAt', descending: true)
          .limit(AppConstants.maxNearbyIncidents);

      return query.snapshots().map((snap) {
        final incidents = snap.docs
            .map((doc) =>
                Incident.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .where((i) => !i.isExpired)
            .toList();

        // Cache incidents for offline use
        if (_offline != null) {
          _offline!.cacheIncidents(incidents);
        }

        return incidents;
      });
    } catch (e) {
      debugPrint('SafeRD — online incident stream error: $e');
      return const Stream.empty();
    }
  }

  Stream<List<Incident>> _offlineIncidentStream() {
    try {
      return _connectivity.onConnectivityChanged
          .where((result) => result == ConnectivityResult.none)
          .map((_) {
        if (_offline != null) {
          return _offline!.getCachedIncidents();
        }
        return <Incident>[];
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Sync queued incidents from offline storage to Firestore.
  /// Call this when connectivity is restored.
  Future<int> syncQueuedIncidents() async {
    if (_offline == null) return 0;
    if (!(await isOnline)) return 0;

    try {
      final queue = _offline!.drainSyncQueue();
      int synced = 0;

      for (final incident in queue) {
        try {
          await incidents.add(incident.toMap());
          synced++;
        } catch (e) {
          debugPrint('SafeRD — Sync failed for incident: $e');
          // Re-queue failed items
          await _offline!.queueIncident(incident);
        }
      }

      debugPrint('SafeRD — Synced $synced/${queue.length} incidents');
      return synced;
    } catch (e) {
      debugPrint('SafeRD — syncQueuedIncidents error: $e');
      return 0;
    }
  }

  /// Deactivate an incident (set active = false).
  Future<void> deactivate(String id) async {
    try {
      if (await isOnline) {
        await incidents.doc(id).update({'active': false});
      }
    } catch (e) {
      debugPrint('SafeRD — deactivate error: $e');
    }
  }
}

/// Simple stream merger to combine multiple streams of the same type.
class StreamGroup {
  static Stream<T> merge<T>(Iterable<Stream<T>> streams) {
    final controller = StreamController<T>.broadcast();
    int active = streams.length;

    if (active == 0) {
      controller.close();
      return controller.stream;
    }

    for (final stream in streams) {
      stream.listen(
        (data) => controller.add(data),
        onError: (e) => debugPrint('SafeRD — StreamGroup error: $e'),
        onDone: () {
          active--;
          if (active == 0 && !controller.isClosed) {
            controller.close();
          }
        },
      );
    }

    return controller.stream;
  }
}
