import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/location_service.dart';
import '../../services/offline_service.dart';
import '../sos/sos_button.dart';
import '../contacts_screen.dart';

/// SafeRD — SOS-centric home screen.
///
/// Opens to the large SOS button immediately. Shows connection status,
/// quick actions (test alert, history), and a mini contact list.
class SOSHomeScreen extends StatelessWidget {
  const SOSHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offline = context.read<OfflineService>();
    final location = context.read<LocationService>();
    final online = offline.isOnline;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            _statusBar(online),
            const Spacer(flex: 2),

            // SOS Button — the hero
            SOSButton(locationService: location),
            const SizedBox(height: 8),
            Text(
              online ? 'Conectado • Alertas inmediatas' : 'Sin conexión • Se enviará al conectar',
              style: TextStyle(
                color: online ? AppTheme.safe : AppTheme.warning,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(flex: 2),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _quickAction(
                    icon: Icons.science_rounded,
                    label: 'Prueba',
                    color: AppTheme.warning,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Modo prueba — alerta enviada solo a ti'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.surface,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 32),
                  _quickAction(
                    icon: Icons.history_rounded,
                    label: 'Historial',
                    color: AppTheme.accent,
                    onTap: () {
                      // Will navigate to history tab
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mini contact list
            _contactPreview(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _statusBar(bool online) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online ? AppTheme.safe : AppTheme.warning,
              boxShadow: [
                BoxShadow(
                  color: (online ? AppTheme.safe : AppTheme.warning)
                      .withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            online ? 'Conectado' : 'Sin conexión',
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Text(
            'SafeRD',
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactPreview() {
    final offline = context.read<OfflineService>();
    final contacts = offline.getContacts().where((c) => c.isActive).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '👥 Contactos${contacts.isNotEmpty ? ' (${contacts.length})' : ''}',
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textDim, size: 18),
              ],
            ),
            if (contacts.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Añade contactos de confianza',
                style: TextStyle(
                  color: AppTheme.textDim.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ...contacts.take(3).map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _contactItem(c.name, c.channelsLabel),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _contactItem(String name, String channels) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              name[0],
              style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              channels,
              style: const TextStyle(
                color: AppTheme.textDim,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
