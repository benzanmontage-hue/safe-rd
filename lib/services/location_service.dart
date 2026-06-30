import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../core/constants.dart';

/// SafeRD — Real-time location service for the Dominican Republic.
///
/// Uses [Geolocator] for GPS-based position tracking with automatic fallback
/// to Santo Domingo defaults when location is unavailable or permissions
/// are denied. Provides a stream-based API for continuous updates.
class LocationService {
  final StreamController<Map<String, double>> _controller =
      StreamController<Map<String, double>>.broadcast();

  StreamSubscription<Position>? _positionSub;
  Map<String, double> _lastKnown = {
    'lat': AppConstants.defaultLat,
    'lng': AppConstants.defaultLng,
  };
  bool _initialized = false;

  /// The last known position (lat/lng). Defaults to Santo Domingo.
  Map<String, double> get current => Map.unmodifiable(_lastKnown);

  /// A broadcast stream of position updates (lat/lng maps).
  Stream<Map<String, double>> get positionStream => _controller.stream;

  /// Initialize and request location permissions.
  /// Call this once before using [getCurrentPosition] or [startListening].
  Future<LocationServiceStatus> init() async {
    if (_initialized) return LocationServiceStatus.alreadyStarted;

    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _lastKnown = {
          'lat': AppConstants.defaultLat,
          'lng': AppConstants.defaultLng,
        };
        _initialized = true;
        return LocationServiceStatus.serviceNotEnabled;
      }

      // Check and request permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _lastKnown = {
            'lat': AppConstants.defaultLat,
            'lng': AppConstants.defaultLng,
          };
          _initialized = true;
          return LocationServiceStatus.permissionDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _lastKnown = {
          'lat': AppConstants.defaultLat,
          'lng': AppConstants.defaultLng,
        };
        _initialized = true;
        return LocationServiceStatus.permissionDeniedForever;
      }

      // Permission granted — get initial position
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      );

      _lastKnown = {
        'lat': pos.latitude,
        'lng': pos.longitude,
      };
      _initialized = true;
      return LocationServiceStatus.granted;
    } catch (e) {
      debugPrint('SafeRD — LocationService init error: $e');
      _lastKnown = {
        'lat': AppConstants.defaultLat,
        'lng': AppConstants.defaultLng,
      };
      _initialized = true;
      return LocationServiceStatus.error;
    }
  }

  /// Get the current position once.
  /// Returns null if position cannot be determined (falls back to defaults
  /// stored in [_lastKnown]).
  Future<Map<String, double>?> getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lastKnown = {'lat': pos.latitude, 'lng': pos.longitude};
      return _lastKnown;
    } catch (e) {
      debugPrint('SafeRD — getCurrentPosition failed: $e');
      // Return last known (defaults if never set)
      return _lastKnown;
    }
  }

  /// Start streaming location updates.
  /// Emits position maps on the [positionStream] whenever the user moves.
  void startListening() {
    _positionSub?.cancel();

    try {
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position pos) {
        _lastKnown = {'lat': pos.latitude, 'lng': pos.longitude};
        if (!_controller.isClosed) {
          _controller.add(_lastKnown);
        }
      });
    } catch (e) {
      debugPrint('SafeRD — startListening error: $e');
      // Still emit at least once so listeners get something
      if (!_controller.isClosed) {
        _controller.add(_lastKnown);
      }
    }
  }

  /// Stop location streaming.
  void stopListening() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  /// Alias for [startListening] — convenience for the callback-style API.
  void listen(void Function(Map<String, double>) callback) {
    // Add to stream and also call with current value immediately
    callback(_lastKnown);
    _controller.stream.listen(callback);
    startListening();
  }

  /// Calculate distance (in meters) between two lat/lng points
  /// using the Haversine formula.
  static double distanceBetween(
      double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  /// Calculate bearing between two points.
  static double bearingBetween(
      double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.bearingBetween(lat1, lng1, lat2, lng2);
  }

  /// Dispose of all resources.
  void dispose() {
    _positionSub?.cancel();
    _controller.close();
  }
}

/// Status returned by [LocationService.init].
enum LocationServiceStatus {
  granted,
  serviceNotEnabled,
  permissionDenied,
  permissionDeniedForever,
  error,
  alreadyStarted,
}
