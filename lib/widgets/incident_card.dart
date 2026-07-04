import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../core/theme.dart';

/// SafeRD — Incident card widget for the Dominican Republic.
///
/// Displays a single incident with severity-colored border, emoji type
/// indicator, description, and confirm/deny action buttons for unconfirmed
/// incidents. Supports both active and pending-confirmation states.
class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onConfirm;
  final VoidCallback onDeny;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onConfirm,
    required this.onDeny,
  });

  Color get _severityColor {
    if (incident.severity >= 4) return AppTheme.danger;
    if (incident.severity >= 3) return AppTheme.warning;
    return AppTheme.safe;
  }

  IconData get _severityIcon {
    if (incident.severity >= 4) return Icons.dangerous_rounded;
    if (incident.severity >= 3) return Icons.warning_amber_rounded;
    return Icons.info_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (!incident.active) {
      return _buildUnconfirmed();
    }
    return _buildConfirmed();
  }

  Widget _buildUnconfirmed() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: AppTheme.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      incident.typeEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      incident.typeLabel,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Onbevestigd',
                      style: TextStyle(
                        color: AppTheme.warning.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  incident.description,
                  style: const TextStyle(
                    color: AppTheme.textDim,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _actionButton(
                      'Bevestigen',
                      AppTheme.safe,
                      onConfirm,
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      'Negeren',
                      AppTheme.danger,
                      onDeny,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmed() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _severityColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _severityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _severityIcon,
              color: _severityColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      incident.typeEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      incident.typeLabel,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _badge(
                      'Bevestigd ×${incident.confirmations}',
                      AppTheme.safe,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  incident.description,
                  style: const TextStyle(
                    color: AppTheme.textDim,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
