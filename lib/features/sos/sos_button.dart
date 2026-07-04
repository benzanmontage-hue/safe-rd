import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/location_service.dart';

/// SafeRD — SOS Button (200×200dp, hold-to-activate).
///
/// Large, centered emergency button with pulse animation.
/// User must hold for [AppConstants.sosCountdownSeconds] seconds.
/// Releasing early cancels. Haptic feedback on each second.
class SOSButton extends StatefulWidget {
  final LocationService? locationService;

  const SOSButton({super.key, this.locationService});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  bool _holding = false;
  int _count = AppConstants.sosCountdownSeconds;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _ringController;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _ringController = AnimationController(
      vsync: this,
      duration: Duration(seconds: AppConstants.sosCountdownSeconds),
    );
    _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _startHold() {
    HapticFeedback.mediumImpact();
    setState(() {
      _holding = true;
      _count = AppConstants.sosCountdownSeconds;
    });
    _ringController.forward(from: 0.0);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count <= 1) {
        t.cancel();
        _activate();
        return;
      }
      HapticFeedback.heavyImpact();
      setState(() => _count--);
    });
  }

  void _cancelHold() {
    _timer?.cancel();
    _ringController.stop();
    _ringController.reset();
    HapticFeedback.lightImpact();
    setState(() => _holding = false);
  }

  Future<void> _activate() async {
    setState(() => _holding = false);
    _pulseController.stop();
    _ringController.reset();

    HapticFeedback.heavyImpact();
    HapticFeedback.heavyImpact();

    // Get location
    String locationPart = '';
    try {
      final pos = await widget.locationService?.getCurrentPosition();
      if (pos != null && pos['lat'] != null && pos['lng'] != null) {
        locationPart =
            '\n📍 Ubicación: https://maps.google.com/?q=${pos['lat']},${pos['lng']}';
      }
    } catch (_) {}

    final msg = '🚨 EMERGENCIA 🚨\n'
        '${AppConstants.sosMessage}$locationPart\n'
        '⏰ ${DateTime.now().toIso8601String()}\n'
        'Enviado desde SafeRD';

    final encoded = Uri.encodeComponent(msg);

    if (mounted) {
      _showActivatedSheet(encoded, msg);
    }
  }

  void _showActivatedSheet(String encodedMsg, String rawMsg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textDim.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppTheme.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '🚨 ¡Alerta Activada!',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Elige cómo enviar la alerta',
                style: TextStyle(color: AppTheme.textDim, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _channelButton(
                icon: Icons.chat_rounded,
                color: const Color(0xFF25D366),
                label: 'WhatsApp',
                onTap: () async {
                  Navigator.pop(ctx);
                  await launchUrl(
                    Uri.parse('https://wa.me/?text=$encodedMsg'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              const SizedBox(height: 10),
              _channelButton(
                icon: Icons.sms_rounded,
                color: const Color(0xFF00897B),
                label: 'SMS',
                onTap: () async {
                  Navigator.pop(ctx);
                  await launchUrl(Uri.parse('sms:?body=$encodedMsg'));
                },
              ),
              const SizedBox(height: 10),
              _channelButton(
                icon: Icons.phone_rounded,
                color: AppTheme.danger,
                label: 'Llamar ${AppConstants.emergencyNumber}',
                onTap: () async {
                  Navigator.pop(ctx);
                  await launchUrl(
                    Uri.parse('tel:${AppConstants.emergencyNumber}'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppTheme.textDim),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _channelButton({
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
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
            Icon(Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonSize = size.width * 0.48; // ~200dp on most phones

    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _holding ? _cancelHold() : null,
      onTapCancel: () => _holding ? _cancelHold() : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _ringController]),
        builder: (ctx, child) {
          return SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse ring (always visible, larger when holding)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _holding ? buttonSize * 1.35 : buttonSize * 1.2,
                  height: _holding ? buttonSize * 1.35 : buttonSize * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.danger.withValues(
                        alpha: _holding ? 0.5 : 0.2,
                      ),
                      width: _holding ? 3 : 2,
                    ),
                  ),
                ),

                // Countdown ring (only when holding)
                if (_holding)
                  SizedBox(
                    width: buttonSize * 1.2,
                    height: buttonSize * 1.2,
                    child: CircularProgressIndicator(
                      value: _ringAnim.value,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.warning,
                      ),
                    ),
                  ),

                // Main button
                Transform.scale(
                  scale: _holding ? 1.0 : _pulseAnim.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _holding ? AppTheme.danger : AppTheme.danger,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.danger.withValues(alpha: 0.4),
                          blurRadius: _holding ? 40 : 25,
                          spreadRadius: _holding ? 8 : 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _holding ? '$_count' : 'SOS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _holding ? 'Suelta para cancelar' : 'Mantén 3 seg',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
