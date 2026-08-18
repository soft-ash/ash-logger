import 'dart:convert';

import '../config/barta_log_theme.dart';
import '../core/ansi.dart';

/// Turns any encodable value into an indented, color-highlighted JSON
/// string (Postman/Swagger dark-theme style: white keys, green strings,
/// yellow numbers/booleans, gray null/punctuation).
class JsonColorizer {
  const JsonColorizer(this.theme);

  final BartaLogTheme theme;

  /// Pretty-prints + colorizes. Falls back to `toString()` for anything
  /// that isn't JSON-encodable (e.g. a custom class without toJson).
  String render(dynamic value) {
    if (value == null) return '${theme.nullColor}null${Ansi.reset}';
    
    var decodedValue = value;
    if (value is String) {
      try {
        decodedValue = jsonDecode(value);
      } catch (_) {
        // Not a valid JSON string, leave it as is
      }
    }

    try {
      final raw = const JsonEncoder.withIndent('  ').convert(decodedValue);
      return _colorize(raw);
    } catch (_) {
      return value.toString();
    }
  }

  String _colorize(String json) {
    final buffer = StringBuffer();
    int i = 0;

    while (i < json.length) {
      final ch = json[i];

      if (ch == '"') {
        final start = i;
        i++;
        while (i < json.length) {
          if (json[i] == '\\') {
            i += 2;
            continue;
          }
          if (json[i] == '"') {
            i++;
            break;
          }
          i++;
        }
        final raw = json.substring(start, i);
        int peek = i;
        while (peek < json.length && json[peek] == ' ') {
          peek++;
        }
        final isKey = peek < json.length && json[peek] == ':';
        buffer.write(isKey
            ? '${theme.keyColor}${Ansi.bold}$raw${Ansi.reset}'
            : '${theme.stringColor}$raw${Ansi.reset}');
        continue;
      }

      if (ch == '-' || (ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57)) {
        final start = i;
        while (i < json.length && '0123456789.eE+-'.contains(json[i])) {
          i++;
        }
        buffer.write(
            '${theme.numberColor}${json.substring(start, i)}${Ansi.reset}');
        continue;
      }

      if (json.startsWith('true', i)) {
        buffer.write('${theme.numberColor}${Ansi.bold}true${Ansi.reset}');
        i += 4;
        continue;
      }
      if (json.startsWith('false', i)) {
        buffer.write('${theme.numberColor}${Ansi.bold}false${Ansi.reset}');
        i += 5;
        continue;
      }
      if (json.startsWith('null', i)) {
        buffer.write('${theme.nullColor}${Ansi.bold}null${Ansi.reset}');
        i += 4;
        continue;
      }

      if ('{}[]'.contains(ch) || ch == ':' || ch == ',') {
        buffer.write('${theme.punctuationColor}$ch${Ansi.reset}');
        i++;
        continue;
      }

      buffer.write(ch);
      i++;
    }

    return buffer.toString();
  }
}
