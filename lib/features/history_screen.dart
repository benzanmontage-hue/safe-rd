import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/offline_service.dart';

/// SafeRD — Alert history screen.
///
/// Shows a chronological log of all past SOS alerts.
/// Data comes from Hive local storage via [OfflineService].
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final offline = context.read<OfflineService>();
    final history = offline.getAlertHistory();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: AppTheme.bg,
        actions: history.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.textDim, size: 20),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.surface,
                        title: const Text('Borrar historial',
                            style: TextStyle(color: AppTheme.text)),
                        content: const Text(
                            '¿Eliminar todas las alertas?',
                            style: TextStyle(color: AppTheme.textDim)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar',
                                style: TextStyle(color: AppTheme.textDim)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Borrar',
                                style: TextStyle(color: AppTheme.danger)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await offline.clearAlerts();
                      setState(() {});
                    }
                  },
                ),
              ]
            : null,
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: AppTheme.accent,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin alertas',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu historial de alertas aparecerá aquí',
                    style: TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (ctx, i) {
                final alert = history[i];
                final status = alert['status'] as String? ?? 'unknown';
                final ts = alert['timestamp'] as String? ?? '';
                final lat = alert['lat'] as double? ?? 0;
                final lng = alert['lng'] as double? ?? 0;

                final time = _formatTimestamp(ts);
                final icon = _statusIcon(status);
                final color = _statusColor(status);
                final label = _statusLabel(status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              time,
                              style: const TextStyle(
                                color: AppTheme.textDim,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (lat != 0 && lng != 0)
                        Text(
                          '📍 ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                          style: TextStyle(
                            color: AppTheme.textDim.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Ahora';
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'sent':
        return Icons.check_circle_rounded;
      case 'queued':
        return Icons.schedule_rounded;
      case 'failed':
        return Icons.error_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'sent':
        return AppTheme.safe;
      case 'queued':
        return AppTheme.warning;
      case 'failed':
        return AppTheme.danger;
      default:
        return AppTheme.textDim;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'sent':
        return 'Alerta enviada';
      case 'queued':
        return 'En cola (sin conexión)';
      case 'failed':
        return 'Error al enviar';
      default:
        return status;
    }
  }
}
