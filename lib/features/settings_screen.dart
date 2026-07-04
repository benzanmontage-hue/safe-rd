import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// SafeRD — Settings screen.
///
/// User profile, language, dark mode toggle, about.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: AppTheme.bg,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          _sectionHeader('👤 Perfil'),
          const SizedBox(height: 8),
          _settingTile(
            icon: Icons.person_rounded,
            title: 'Nombre',
            subtitle: 'Sin configurar',
            onTap: () {},
          ),
          _settingTile(
            icon: Icons.bloodtype_rounded,
            title: 'Tipo de sangre',
            subtitle: 'Sin configurar',
            onTap: () {},
          ),
          _settingTile(
            icon: Icons.notes_rounded,
            title: 'Notas médicas',
            subtitle: 'Sin configurar',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Preferences section
          _sectionHeader('⚙️ Preferencias'),
          const SizedBox(height: 8),
          _settingTile(
            icon: Icons.language_rounded,
            title: 'Idioma',
            subtitle: 'Español',
            onTap: () {},
          ),
          _settingTile(
            icon: Icons.dark_mode_rounded,
            title: 'Modo oscuro',
            subtitle: 'Activado',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeColor: AppTheme.accent,
            ),
            onTap: null,
          ),
          _settingTile(
            icon: Icons.vibration_rounded,
            title: 'Agitar para SOS',
            subtitle: 'Desactivado',
            trailing: Switch(
              value: false,
              onChanged: (_) {},
              activeColor: AppTheme.accent,
            ),
            onTap: null,
          ),

          const SizedBox(height: 24),

          // About
          _sectionHeader('ℹ️ Acerca de'),
          const SizedBox(height: 8),
          _settingTile(
            icon: Icons.info_rounded,
            title: 'Versión',
            subtitle: '1.0.0 • MIT License',
            onTap: null,
          ),
          _settingTile(
            icon: Icons.code_rounded,
            title: 'Código fuente',
            subtitle: 'github.com/benzanmontage-hue/safe-rd',
            onTap: () {},
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'SafeRD — República Dominicana',
              style: TextStyle(
                color: AppTheme.textDim.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.accent,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accent, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textDim,
            fontSize: 12,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
