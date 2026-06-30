/// SafeRD — Incident model
class Incident {
  final String id;
  final String type; // 'hole', 'accident', 'police', 'flood', etc.
  final double lat;
  final double lng;
  final DateTime reportedAt;
  final int confirmations;
  final int denials;
  final String? reporterId;
  final int severity; // 1-5
  final bool active;
  final String description;

  Incident({
    required this.id,
    required this.type,
    required this.lat,
    required this.lng,
    required this.reportedAt,
    this.confirmations = 1,
    this.denials = 0,
    this.reporterId,
    this.severity = 1,
    this.active = true,
    this.description = '',
  });

  double get trustScore {
    final total = confirmations + denials;
    if (total == 0) return 0;
    return confirmations / total;
  }

  bool get isExpired =>
      DateTime.now().difference(reportedAt).inHours > 4;

  Map<String, dynamic> toMap() => {
        'type': type,
        'lat': lat,
        'lng': lng,
        'reportedAt': reportedAt.toIso8601String(),
        'confirmations': confirmations,
        'denials': denials,
        'reporterId': reporterId,
        'severity': severity,
        'active': active,
        'description': description,
      };

  factory Incident.fromMap(String id, Map<String, dynamic> map) => Incident(
        id: id,
        type: map['type'] ?? '',
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        reportedAt: DateTime.parse(map['reportedAt']),
        confirmations: map['confirmations'] ?? 1,
        denials: map['denials'] ?? 0,
        reporterId: map['reporterId'],
        severity: map['severity'] ?? 1,
        active: map['active'] ?? true,
        description: map['description'] ?? '',
      );

  static const types = {
    'hole': '🚧 Hoyos',
    'accident': '🚔 Accidente',
    'police': '🚨 Policía',
    'flood': '🌊 Inundación',
    'animal': '🐄 Animal',
    'obstacle': '🧱 Obstáculo',
    'closed': '🛑 Calle Cerrada',
    'tree': '🌳 Árbol Caído',
    'cables': '⚡ Cables Caídos',
    'semaphore': '🚦 Semáforo Dañado',
    'fire': '🔥 Incendio',
    'oil': '💧 Aceite',
    'visibility': '🌫 Baja Visibilidad',
  };

  String get typeLabel => types[type] ?? type;
  String get typeEmoji => types[type]?.split(' ').first ?? '⚠️';
}
