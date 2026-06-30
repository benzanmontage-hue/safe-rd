import 'package:flutter_tts/flutter_tts.dart';
import '../models/incident.dart';

class AudioService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  String? _lastSpoken;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('es-MX'); // Dominican Spanish
    await _tts.setSpeechRate(0.45); // Clear, not too fast
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    if (_lastSpoken == text) return; // Avoid repetition
    _lastSpoken = text;
    await _tts.speak(text);
  }

  Future<void> alertIncident(Incident incident, double distanceM) async {
    await init();
    final msg = 'Atención. ${incident.typeLabel} a ${distanceM.round()} metros. '
        'Reportado hace ${_timeAgo(incident.reportedAt)}.';
    await speak(msg);
  }

  Future<void> speakSOS() async {
    await init();
    await speak('Emergencia. Enviando tu ubicación a contactos de confianza.');
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'unos segundos';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutos';
    return '${diff.inHours} horas';
  }

  void dispose() => _tts.stop();
}
