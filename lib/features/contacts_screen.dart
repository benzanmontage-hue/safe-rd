import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/contact.dart';
import '../../services/offline_service.dart';

/// SafeRD — Contacts management screen.
///
/// CRUD for trusted emergency contacts. Data stored in Hive via OfflineService.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    final offline = context.read<OfflineService>();
    final data = offline.getContacts();
    setState(() => _contacts = data);
  }

  Future<void> _addContact() async {
    final result = await showDialog<EmergencyContact>(
      context: context,
      builder: (ctx) => _ContactDialog(),
    );
    if (result != null) {
      final offline = context.read<OfflineService>();
      await offline.saveContact(result);
      _loadContacts();
    }
  }

  Future<void> _editContact(EmergencyContact contact) async {
    final result = await showDialog<EmergencyContact>(
      context: context,
      builder: (ctx) => _ContactDialog(contact: contact),
    );
    if (result != null) {
      final offline = context.read<OfflineService>();
      await offline.saveContact(result);
      _loadContacts();
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Eliminar contacto',
            style: TextStyle(color: AppTheme.text)),
        content: Text('¿Eliminar a ${contact.name}?',
            style: const TextStyle(color: AppTheme.textDim)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final offline = context.read<OfflineService>();
      await offline.deleteContact(contact.id);
      _loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Contactos'),
        backgroundColor: AppTheme.bg,
      ),
      body: _contacts.isEmpty
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
                      Icons.people_rounded,
                      color: AppTheme.accent,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin contactos',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Añade contactos de confianza\npara tus alertas SOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addContact,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Añadir contacto'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _contacts.length + 1, // +1 for add button
              itemBuilder: (ctx, i) {
                if (i == _contacts.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton.icon(
                      onPressed: _addContact,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Añadir contacto'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accent,
                        side: BorderSide(
                            color: AppTheme.accent.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  );
                }

                final contact = _contacts[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: ListTile(
                    onTap: () => _editContact(contact),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: contact.isActive
                            ? AppTheme.accent.withValues(alpha: 0.12)
                            : AppTheme.textDim.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          contact.initial,
                          style: TextStyle(
                            color: contact.isActive
                                ? AppTheme.accent
                                : AppTheme.textDim,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      contact.name,
                      style: TextStyle(
                        color: contact.isActive
                            ? AppTheme.text
                            : AppTheme.textDim,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      contact.phoneNumber.isNotEmpty
                          ? '${contact.phoneNumber}  •  ${contact.channelsLabel}'
                          : contact.channelsLabel,
                      style: const TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!contact.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.textDim.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Inactivo',
                              style: TextStyle(
                                  color: AppTheme.textDim, fontSize: 10),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppTheme.textDim, size: 18),
                          onPressed: () => _deleteContact(contact),
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  ),
                );
              },
            ),
    );
  }
}

/// Dialog for adding/editing a contact
class _ContactDialog extends StatefulWidget {
  final EmergencyContact? contact;
  const _ContactDialog({this.contact});

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late bool _whatsapp;
  late bool _sms;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _phoneCtrl = TextEditingController(text: c?.phoneNumber ?? '');
    _whatsapp = c?.notifyWhatsApp ?? true;
    _sms = c?.notifySMS ?? true;
    _active = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contact != null;

    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: Text(
        isEdit ? 'Editar contacto' : 'Nuevo contacto',
        style: const TextStyle(color: AppTheme.text, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppTheme.text),
              decoration: _inputDecoration('Nombre', Icons.person_rounded),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              style: const TextStyle(color: AppTheme.text),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('Teléfono', Icons.phone_rounded),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('WhatsApp',
                  style: TextStyle(color: AppTheme.text, fontSize: 13)),
              value: _whatsapp,
              onChanged: (v) => setState(() => _whatsapp = v),
              activeColor: const Color(0xFF25D366),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('SMS',
                  style: TextStyle(color: AppTheme.text, fontSize: 13)),
              value: _sms,
              onChanged: (v) => setState(() => _sms = v),
              activeColor: AppTheme.accent,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Activo',
                  style: TextStyle(color: AppTheme.text, fontSize: 13)),
              subtitle: const Text('Recibe alertas SOS',
                  style: TextStyle(color: AppTheme.textDim, fontSize: 11)),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              activeColor: AppTheme.safe,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: AppTheme.textDim)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty) return;
            final contact = EmergencyContact(
              id: widget.contact?.id ??
                  'contact_${DateTime.now().millisecondsSinceEpoch}',
              name: _nameCtrl.text.trim(),
              phoneNumber: _phoneCtrl.text.trim(),
              notifyWhatsApp: _whatsapp,
              notifySMS: _sms,
              isActive: _active,
            );
            Navigator.pop(context, contact);
          },
          child: Text(isEdit ? 'Guardar' : 'Añadir'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textDim, fontSize: 14),
      prefixIcon: Icon(icon, color: AppTheme.textDim, size: 18),
      filled: true,
      fillColor: AppTheme.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
