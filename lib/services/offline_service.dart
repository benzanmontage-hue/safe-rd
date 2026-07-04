import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/incident.dart';
import '../models/contact.dart';
import '../core/constants.dart';

/// Offline-first caching layer for incidents and SOS alerts.
class OfflineService {
  late Box<dynamic> _box;
  final Connectivity _connectivity = Connectivity();
  bool _initialized = false;
  StreamSubscription<List<ConnectivityResult>>? _connectSub;
  final List<void Function()> _onReconnectCallbacks = [];

  /// Whether we're currently online
  bool get isOnline {
    final results = _lastResults;
    return results.isEmpty || !results.every((r) => r == ConnectivityResult.none);
  }

  List<ConnectivityResult> _lastResults = [ConnectivityResult.mobile];

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox(AppConstants.offlineBoxName);
    _lastResults = await _connectivity.checkConnectivity();
    _connectSub = _connectivity.onConnectivityChanged.listen((results) {
      final wasOffline = _lastResults.every((r) => r == ConnectivityResult.none);
      _lastResults = results;
      final nowOnline = results.any((r) => r != ConnectivityResult.none);
      if (wasOffline && nowOnline) {
        _processAlertQueue();
        for (final cb in _onReconnectCallbacks) {
          cb();
        }
      }
    });
    _initialized = true;
  }

  void onReconnect(void Function() callback) {
    _onReconnectCallbacks.add(callback);
  }

  // ─── Incidents ─────────────────────────────────────────────

  Future<void> cacheIncidents(List<Incident> incidents) async {
    if (!_initialized) await init();
    final data = incidents.map((i) => i.toMap()).toList();
    await _box.put('incidents', data);
    await _box.put('lastSync', DateTime.now().toIso8601String());
  }

  List<Incident> getCachedIncidents() {
    if (!_box.containsKey('incidents')) return [];
    final data = _box.get('incidents') as List<dynamic>;
    return data.asMap().entries.map((e) {
      final map = Map<String, dynamic>.from(e.value as Map);
      return Incident.fromMap('cache_${e.key}', map);
    }).where((i) => !i.isExpired).toList();
  }

  Future<void> queueIncident(Incident incident) async {
    final queue = _box.get('syncQueue', defaultValue: <List>[]) as List;
    queue.add(incident.toMap());
    await _box.put('syncQueue', queue);
  }

  List<Incident> drainSyncQueue() {
    final queue = _box.get('syncQueue', defaultValue: <List>[]) as List;
    final incidents = queue.map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return Incident.fromMap('queued', map);
    }).toList();
    _box.put('syncQueue', <List>[]);
    return incidents;
  }

  bool get hasPendingSync =>
      (_box.get('syncQueue', defaultValue: <List>[]) as List).isNotEmpty;

  DateTime? get lastSyncTime {
    final ts = _box.get('lastSync');
    if (ts == null) return null;
    return DateTime.tryParse(ts as String);
  }

  // ─── SOS Alert Queue ───────────────────────────────────────

  Future<String> queueAlert({
    required double lat,
    required double lng,
    required String message,
    required List<String> contactIds,
    DateTime? timestamp,
  }) async {
    final alertId = 'alert_${DateTime.now().millisecondsSinceEpoch}';
    final alert = <String, dynamic>{
      'id': alertId, 'lat': lat, 'lng': lng, 'message': message,
      'contactIds': contactIds, 'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      'retries': 0, 'status': 'queued',
    };
    final queue = _box.get('alertQueue', defaultValue: <List>[]) as List;
    queue.add(alert);
    await _box.put('alertQueue', queue);
    await _addToHistory(alertId, 'queued', lat, lng);
    return alertId;
  }

  List<Map<String, dynamic>> get queuedAlerts {
    final queue = _box.get('alertQueue', defaultValue: <List>[]) as List;
    return queue.cast<Map<String, dynamic>>();
  }

  int get pendingAlertCount =>
      (_box.get('alertQueue', defaultValue: <List>[]) as List).length;

  Future<void> _processAlertQueue() async {
    final queue = _box.get('alertQueue', defaultValue: <List>[]) as List;
    if (queue.isEmpty) return;
    final remaining = <Map<String, dynamic>>[];
    for (final item in queue) {
      final alert = Map<String, dynamic>.from(item as Map);
      final retries = alert['retries'] as int? ?? 0;
      if (retries >= AppConstants.maxRetries) {
        alert['status'] = 'failed';
        await _addToHistory(alert['id'] as String, 'failed', alert['lat'] as double, alert['lng'] as double);
        continue;
      }
      if (retries > 0) await Future.delayed(Duration(seconds: retries == 1 ? 10 : 30));
      try {
        alert['status'] = 'sent';
        alert['retries'] = (retries + 1);
        await _addToHistory(alert['id'] as String, 'sent', alert['lat'] as double, alert['lng'] as double);
      } catch (e) {
        alert['retries'] = retries + 1;
        remaining.add(alert);
      }
    }
    await _box.put('alertQueue', remaining);
  }

  // ─── Alert History ─────────────────────────────────────────

  List<Map<String, dynamic>> getAlertHistory() {
    final history = _box.get('alertHistory', defaultValue: <List>[]) as List;
    return history.cast<Map<String, dynamic>>().reversed.toList();
  }

  Future<void> _addToHistory(String alertId, String status, double lat, double lng) async {
    final history = _box.get('alertHistory', defaultValue: <List>[]) as List;
    history.add({'id': alertId, 'status': status, 'lat': lat, 'lng': lng, 'timestamp': DateTime.now().toIso8601String()});
    if (history.length > 100) history.removeRange(0, history.length - 100);
    await _box.put('alertHistory', history);
  }

  Future<void> recordSentAlert({required double lat, required double lng}) async {
    final alertId = 'alert_${DateTime.now().millisecondsSinceEpoch}';
    await _addToHistory(alertId, 'sent', lat, lng);
  }

  Future<void> clearAlerts() async {
    await _box.put('alertQueue', <List>[]);
    await _box.put('alertHistory', <List>[]);
  }

  // ─── Contacts ──────────────────────────────────────────────

  List<EmergencyContact> getContacts() {
    final data = _box.get('contacts', defaultValue: <List>[]) as List;
    return data.asMap().entries.map((e) {
      final map = Map<String, dynamic>.from(e.value as Map);
      return EmergencyContact.fromMap(map['id'] as String? ?? 'contact_${e.key}', map);
    }).toList();
  }

  Future<void> saveContact(EmergencyContact contact) async {
    final contacts = _box.get('contacts', defaultValue: <List>[]) as List;
    final idx = contacts.indexWhere((c) => (c as Map)['id'] == contact.id);
    if (idx >= 0) { contacts[idx] = contact.toMap(); } else { contacts.add(contact.toMap()); }
    await _box.put('contacts', contacts);
  }

  Future<void> deleteContact(String id) async {
    final contacts = _box.get('contacts', defaultValue: <List>[]) as List;
    contacts.removeWhere((c) => (c as Map)['id'] == id);
    await _box.put('contacts', contacts);
  }

  int get activeContactCount {
    final contacts = getContacts();
    return contacts.where((c) => c.isActive).length;
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
