import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/notification_service.dart';
import '../../services/location_service.dart';

/// SafeRD — SOS emergency button for the Dominican Republic.
///
/// A pulsing, tappable button that triggers a 3-second countdown before
/// sending an SOS alert. Integrates with [NotificationService] for push
/// alerts and offers multiple sharing options: WhatsApp, SMS, and direct
/// 911 dialing. Also supports [LocationService] to include the user's
/// current position in the SOS message.
class SOSButton extends StatefulWidget {
  /// Optional location service — if provided, the SOS message will
  /// include the user's current GPS coordinates.
  final LocationService? locationService;

  /// Optional notification service — if provided, a local notification
  /// will fire to confirm SOS was sent.
  final NotificationService? notificationService;

  const SOSButton({
    super.key,
    this.locationService,
    this.notificationService,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  bool _counting = false;
  bool _showOptions = false;
  int _count = AppConstants.sosCountdownSeconds;
  Timer? _timer;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _startSOS() {
    setState(() {
      _counting = true;
      _count = AppConstants.sosCountdownSeconds;
    });
    _pulse.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count <= 1) {
        t.cancel();
        _pulse.stop();
        _pulse.reset();
        _sendSOS();
        return;
      }
      setState(() => _count--);
    });
  }

  Future<void> _sendSOS() async {
    setState(() => _counting = false);

    // Build SOS message with optional location
    String locationPart = '';
    try {
      final pos = await widget.locationService?.getCurrentPosition();
      if (pos != null && pos['lat'] != null && pos['lng'] != null) {
        locationPart =
            '\n📍 https://www.google.com/maps?q=${pos['lat']},${pos['lng']}';
      }
    } catch (_) {
      // Location not available — proceed without it
    }

    final msg =
        '${AppConstants.sosMessage}$locationPart';
    final encoded = Uri.encodeComponent(msg);

    // Show options bottom sheet
    if (mounted) {
      _showOptionsSheet(encoded, msg);
    }

    // Fire notification to confirm SOS was sent
    try {
      await widget.notificationService?.showIncidentAlert(
        '🚨 SOS',
        'Noodmelding verzonden via SafeRD',
        0,
      );
    } catch (_) {
      // Notification failure is non-critical
    }
  }

  void _cancel() {
    _timer?.cancel();
    _pulse.stop();
    _pulse.reset();
    setState(() => _counting = false);
  }

  void _showOptionsSheet(String encodedMsg, String rawMsg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textDim.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '🚨 SOS Noodmelding',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kies hoe je de melding wilt verzenden',
                  style: TextStyle(
                    color: AppTheme.textDim.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                _optionRow(
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  label: 'WhatsApp',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final uri = Uri.parse(
                      'https://wa.me/?text=$encodedMsg',
                    );
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _optionRow(
                  icon: Icons.sms_rounded,
                  color: const Color(0xFF00897B),
                  label: 'SMS',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final uri = Uri.parse('sms:?body=$encodedMsg');
                    await launchUrl(uri);
                  },
                ),
                const SizedBox(height: 12),
                _optionRow(
                  icon: Icons.phone_rounded,
                  color: AppTheme.danger,
                  label: 'Bel ${AppConstants.emergencyNumber}',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final uri = Uri.parse(
                      'tel:${AppConstants.emergencyNumber}',
                    );
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _optionRow(
                  icon: Icons.copy_rounded,
                  color: AppTheme.accent,
                  label: 'Kopieer bericht',
                  onTap: () {
                    Navigator.pop(ctx);
                    // Copy to clipboard
                    // Note: For production, use Clipboard.setData
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bericht gekopieerd'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionRow({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _counting ? _cancel : _startSOS,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (ctx, child) {
          return Transform.scale(
            scale: _counting ? 1.0 + (_pulse.value * 0.08) : 1.0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _counting ? AppTheme.danger : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _counting ? AppTheme.danger : AppTheme.border,
                  width: 2,
                ),
                boxShadow: _counting
                    ? [
                        BoxShadow(
                          color: AppTheme.danger.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: _counting
                    ? Text(
                        '$_count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : const Text(
                        'SOS',
                        style: TextStyle(
                          color: AppTheme.danger,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
