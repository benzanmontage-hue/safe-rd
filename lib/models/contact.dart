/// SafeRD — Emergency contact model.
///
/// Trusted contacts that receive SOS alerts via WhatsApp, SMS, or push.
/// Stored in Hive as raw Map for offline access.
class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final bool notifyWhatsApp;
  final bool notifySMS;
  final bool isActive;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.notifyWhatsApp = true,
    this.notifySMS = true,
    this.isActive = true,
  });

  /// Display initial (first letter of name)
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  /// Active channels as string
  String get channelsLabel {
    final c = <String>[];
    if (notifyWhatsApp) c.add('WhatsApp');
    if (notifySMS) c.add('SMS');
    return c.isEmpty ? 'Sin canales' : c.join(', ');
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'notifyWhatsApp': notifyWhatsApp,
        'notifySMS': notifySMS,
        'isActive': isActive,
      };

  factory EmergencyContact.fromMap(String id, Map<String, dynamic> map) {
    return EmergencyContact(
      id: id,
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      notifyWhatsApp: map['notifyWhatsApp'] as bool? ?? true,
      notifySMS: map['notifySMS'] as bool? ?? true,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  EmergencyContact copyWith({
    String? name,
    String? phoneNumber,
    bool? notifyWhatsApp,
    bool? notifySMS,
    bool? isActive,
  }) {
    return EmergencyContact(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notifyWhatsApp: notifyWhatsApp ?? this.notifyWhatsApp,
      notifySMS: notifySMS ?? this.notifySMS,
      isActive: isActive ?? this.isActive,
    );
  }
}
