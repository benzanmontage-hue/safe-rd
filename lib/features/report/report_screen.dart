import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../services/firebase_service.dart';
import '../../services/location_service.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';

/// SafeRD — Incident report screen for the Dominican Republic.
///
/// Allows users to select an incident type from a grid and submit a report
/// with their current GPS position. Uses [FirebaseService] for upload and
/// [LocationService] for obtaining the user's coordinates.
class ReportScreen extends StatefulWidget {
  final FirebaseService firebase;
  final LocationService location;

  const ReportScreen({
    super.key,
    required this.firebase,
    required this.location,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedType;
  bool _reporting = false;

  Future<void> _report() async {
    if (_selectedType == null) return;
    setState(() => _reporting = true);

    try {
      final pos = await widget.location.getCurrentPosition();
      if (pos == null || pos['lat'] == null || pos['lng'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Locatie niet beschikbaar'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final incident = Incident(
        id: '',
        type: _selectedType!,
        lat: pos['lat'] ?? AppConstants.defaultLat,
        lng: pos['lng'] ?? AppConstants.defaultLng,
        reportedAt: DateTime.now(),
        severity: _getSeverity(_selectedType!),
      );

      final docId = await widget.firebase.reportIncident(incident);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              docId != null
                  ? '✅ ${incident.typeLabel} gerapporteerd'
                  : '📤 ${incident.typeLabel} in wachtrij (offline)',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reporting = false);
    }
  }

  int _getSeverity(String type) {
    switch (type) {
      case 'accident':
      case 'fire':
      case 'cables':
        return 5;
      case 'flood':
      case 'tree':
      case 'closed':
        return 4;
      case 'hole':
      case 'obstacle':
      case 'oil':
        return 3;
      case 'police':
      case 'animal':
      case 'semaphore':
        return 2;
      default:
        return 1;
    }
  }

  static const _quickTypes = [
    'accident',
    'hole',
    'police',
    'flood',
    'obstacle',
    'animal',
    'closed',
    'cables',
    'tree',
  ];

  IconData _iconFor(String type) {
    switch (type) {
      case 'accident':
        return Icons.car_crash_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'cables':
        return Icons.electrical_services_rounded;
      case 'flood':
        return Icons.water_damage_rounded;
      case 'tree':
        return Icons.nature_rounded;
      case 'closed':
        return Icons.block_rounded;
      case 'hole':
        return Icons.report_problem_rounded;
      case 'obstacle':
        return Icons.pan_tool_rounded;
      case 'oil':
        return Icons.oil_barrel_rounded;
      case 'police':
        return Icons.local_police_rounded;
      case 'animal':
        return Icons.pets_rounded;
      case 'semaphore':
        return Icons.traffic_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _colorForSeverity(String type) {
    final s = _getSeverity(type);
    if (s >= 5) return AppTheme.danger;
    if (s >= 4) return AppTheme.warning;
    return AppTheme.accent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Gevaar melden'),
        backgroundColor: AppTheme.bg,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.touch_app_rounded,
                    color: AppTheme.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Selecteer het type gevaar\ndat je wilt melden',
                    style: TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _quickTypes.length,
              itemBuilder: (ctx, i) {
                final type = _quickTypes[i];
                final labels = Incident.types;
                final label = labels[type] ?? type;
                final selected = _selectedType == type;
                final color = _colorForSeverity(type);

                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withOpacity(0.15)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? color : AppTheme.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _iconFor(type),
                          size: 28,
                          color: selected ? color : AppTheme.textDim,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: TextStyle(
                            color: selected ? color : AppTheme.textDim,
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType != null && !_reporting
                    ? AppTheme.danger
                    : AppTheme.surfaceLight,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.surfaceLight,
                disabledForegroundColor: AppTheme.textDim,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed:
                  (_selectedType != null && !_reporting) ? _report : null,
              icon: _reporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.warning_rounded, size: 28),
              label: Text(
                _reporting ? 'Melden...' : 'NU MELDEN',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
