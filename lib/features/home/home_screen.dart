import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/incident.dart';
import '../../services/firebase_service.dart';
import '../../services/location_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/incident_card.dart';
import '../../features/sos/sos_button.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../report/report_screen.dart';

/// SafeRD — Home screen with live incident map and nearby alerts.
///
/// Displays a full-screen Google Map with incident markers, a draggable
/// bottom sheet listing nearby incidents, and quick-access buttons for
/// reporting and SOS. Integrates [AudioService] for voice alerts and
/// [LocationService] for real-time position tracking.
class HomeScreen extends StatefulWidget {
  final FirebaseService firebase;
  final LocationService location;

  const HomeScreen({super.key, required this.firebase, required this.location});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final AudioService _audio = AudioService();
  List<Incident> _incidents = [];
  LatLng? _currentPos;
  StreamSubscription? _incidentStream;
  bool _loading = true;
  bool _mapError = false;

  @override
  void initState() {
    super.initState();
    _audio.init();
    _initLocation();
  }

  Future<void> _initLocation() async {
    // Try to get current position
    try {
      final pos = await widget.location.getCurrentPosition();
      if (pos != null && mounted) {
        setState(() {
          _currentPos = LatLng(pos['lat']!, pos['lng']!);
        });
      }
    } catch (e) {
      debugPrint('SafeRD — Location init error: $e');
      // Fallback to Santo Domingo default
      if (mounted) {
        setState(() {
          _currentPos = LatLng(
            AppConstants.defaultLat,
            AppConstants.defaultLng,
          );
        });
      }
    }

    // Subscribe to incident stream
    try {
      _incidentStream = widget.firebase.getActiveIncidents().listen(
        (incidents) {
          if (mounted) {
            setState(() {
              _incidents = incidents;
              _loading = false;
            });
          }
        },
        onError: (e) {
          debugPrint('SafeRD — Incident stream error: $e');
          if (mounted) {
            setState(() => _loading = false);
          }
        },
      );
    } catch (e) {
      debugPrint('SafeRD — Stream subscription error: $e');
      if (mounted) setState(() => _loading = false);
    }

    // Listen for location updates
    try {
      widget.location.listen((pos) {
        if (mounted) {
          final np = LatLng(pos['lat']!, pos['lng']!);
          setState(() => _currentPos = np);
          _mapController
              ?.animateCamera(CameraUpdate.newLatLng(np));
        }
      });
    } catch (e) {
      debugPrint('SafeRD — Location listen error: $e');
    }
  }

  @override
  void dispose() {
    _incidentStream?.cancel();
    _audio.dispose();
    widget.location.dispose();
    super.dispose();
  }

  Widget _buildMap() {
    try {
      return GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
          zoom: AppConstants.defaultZoom,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          // Move to user position if available
          if (_currentPos != null) {
            controller.animateCamera(
              CameraUpdate.newLatLng(_currentPos!),
            );
          }
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        markers: _incidents
            .where((i) => i.active)
            .map((i) => Marker(
                  markerId: MarkerId(i.id),
                  position: LatLng(i.lat, i.lng),
                  icon: _markerIconForSeverity(i.severity),
                  infoWindow: InfoWindow(
                    title: i.typeLabel,
                    snippet: i.typeEmoji,
                  ),
                ))
            .toSet(),
      );
    } catch (e) {
      debugPrint('SafeRD — Map init error: $e');
      _mapError = true;
      return _mapFallback();
    }
  }

  BitmapDescriptor _markerIconForSeverity(int severity) {
    if (severity >= 4) return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    if (severity >= 3) return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
  }

  Widget _mapFallback() {
    return Container(
      color: AppTheme.bg,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map, size: 48, color: AppTheme.textDim),
            SizedBox(height: 12),
            Text(
              'Kaart niet beschikbaar',
              style: TextStyle(color: AppTheme.textDim),
            ),
            SizedBox(height: 8),
            Text(
              'Controleer Google Maps-installatie',
              style: TextStyle(color: AppTheme.textDim, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _currentPos == null) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_off_rounded,
                      size: 48,
                      color: AppTheme.textDim,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Locatie niet beschikbaar',
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initLocation,
                      child: const Text('Opnieuw proberen'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_mapError) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: AppTheme.textDim,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kaartfout',
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _mapError = false);
                      },
                      child: const Text('Opnieuw laden'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          _buildMap(),
          _topBar(),
          _reportFab(),
          const Positioned(
            bottom: 160,
            right: 16,
            child: SOSButton(),
          ),
          _bottomSheet(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                color: AppTheme.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            _pill(
              AppTheme.safe,
              Icons.circle,
              '${_incidents.where((i) => i.active).length}',
            ),
            const SizedBox(width: 10),
            _pill(
              AppTheme.warning,
              Icons.circle_outlined,
              '${_incidents.where((i) => !i.active).length}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(Color color, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportFab() {
    return Positioned(
      bottom: 120,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'report',
            backgroundColor: AppTheme.danger,
            elevation: 8,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportScreen(
                    firebase: widget.firebase,
                    location: widget.location,
                  ),
                ),
              );
            },
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'REPORTAR',
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: DraggableScrollableSheet(
        initialChildSize: 0.22,
        minChildSize: 0.12,
        maxChildSize: 0.45,
        builder: (ctx, scroll) {
          return Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textDim.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Incidentes cercanos',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_incidents.length}',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _incidents.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 40,
                                color: AppTheme.safe,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Todo seguro',
                                style: TextStyle(
                                  color: AppTheme.textDim,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'No hay peligros cercanos',
                                style: TextStyle(
                                  color: AppTheme.textDim,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scroll,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _incidents.length,
                          itemBuilder: (ctx2, i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: IncidentCard(
                                incident: _incidents[i],
                                onConfirm: () =>
                                    widget.firebase.confirmIncident(
                                        _incidents[i].id),
                                onDeny: () =>
                                    widget.firebase.denyIncident(
                                        _incidents[i].id),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
