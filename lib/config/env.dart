import 'dart:io';

class EnvConfig {
  static String? _baseUrl;

  static String get baseUrl {
    if (_baseUrl != null) return _baseUrl!;
    
    // Default production fallback
    _baseUrl = 'https://clubsetu-backend.onrender.com/api';
    
    try {
      final file = File('.env');
      if (file.existsSync()) {
        final lines = file.readAsLinesSync();
        for (var line in lines) {
          line = line.trim();
          if (line.isEmpty || line.startsWith('#')) continue;
          final parts = line.split('=');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join('=').trim();
            if (key == 'BASE_URL') {
              _baseUrl = value;
              break;
            }
          }
        }
      }
    } catch (_) {
      // Catch file errors or running in a web/non-file context
    }
    
    return _baseUrl!;
  }
}
