import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/incident.dart';
import '../core/constants.dart';

/// Offline-first caching layer for incidents.
/// Saves incidents locally via Hive, syncs with Firebase when online.
class OfflineService {
  late Box<Map<dynamic, dynamic>> _box;
  final Connectivity _connectivity = Connectivity();
  bool _initialized = false;

  /// Whether we're currently online
  bool get isOnline => _lastStatus != ConnectivityResult.none;
  ConnectivityResult _lastStatus = ConnectivityResult.mobile;

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(AppConstants.offlineBoxName);
    _lastStatus = await _connectivity.checkConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      _lastStatus = result;
    });
    _initialized = true;
  }

  /// Cache incidents locally (offline-first)
  Future<void> cacheIncidents(List<Incident> incidents) async {
    if (!_initialized) await init();
    final data = incidents.map((i) => i.toMap()).toList();
    await _box.put('incidents', data);
    await _box.put('lastSync', DateTime.now().toIso8601String());
  }

  /// Get cached incidents
  List<Incident> getCachedIncidents() {
    if (!_box.containsKey('incidents')) return [];
    final data = _box.get('incidents') as List<dynamic>;
    return data.asMap().entries.map((e) {
      final map = Map<String, dynamic>.from(e.value as Map);
      return Incident.fromMap('cache_${e.key}', map);
    }).where((i) => !i.isExpired).toList();
  }

  /// Queue an incident for sync when offline
  Future<void> queueIncident(Incident incident) async {
    final queue = _box.get('syncQueue', defaultValue: <List>[]) as List;
    queue.add(incident.toMap());
    await _box.put('syncQueue', queue);
  }

  /// Get and clear sync queue
  List<Incident> drainSyncQueue() {
    final queue = _box.get('syncQueue', defaultValue: <List>[]) as List;
    final incidents = queue.map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return Incident.fromMap('queued', map);
    }).toList();
    _box.put('syncQueue', <List>[]);
    return incidents;
  }

  /// Check if there are pending sync items
  bool get hasPendingSync =>
      (_box.get('syncQueue', defaultValue: <List>[]) as List).isNotEmpty;

  DateTime? get lastSyncTime {
    final ts = _box.get('lastSync');
    if (ts == null) return null;
    return DateTime.tryParse(ts as String);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
