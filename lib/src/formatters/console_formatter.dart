import '../config/ash_log_theme.dart';
import '../core/ansi.dart';
import '../core/ash_level.dart';
import '../core/ash_log_type.dart';
import '../domain/ash_log_entry.dart';
import 'json_colorizer.dart';

/// Builds the printed string for one [AshLogEntry].
///
/// Layout mirrors a Postman/Swagger console: a colored top border, a
/// header line (icon + type + optional title), then only the sections
/// that actually have data — endpoint, curl, request body, response
/// body — each separated by a divider, closed with a bottom border.
/// Nothing is ever printed for a field that's null, so a bare
/// `AshLog.network(endpoint: '/x')` prints a two-line box, while a full
/// call with everything filled in prints the whole thing.
class ConsoleFormatter {
  ConsoleFormatter(this.theme) : _json = JsonColorizer(theme);

  final AshLogTheme theme;
  final JsonColorizer _json;

  String format(AshLogEntry e) {
    if (theme.style == AshLogStyle.minimal) return _formatMinimal(e);
    return _formatBoxed(e);
  }

  // ─── Boxed (default) ────────────────────────────────────────────────

  String _formatBoxed(AshLogEntry e) {
    final color = _colorFor(e);
    final line = theme.borderChar * theme.boxWidth;
    final buf = StringBuffer();

    buf.writeln('$color${Ansi.bold}┌$line┐${Ansi.reset}');
    buf.writeln('$color│${Ansi.reset}  ${_icon(e)} ${Ansi.bold}$color${_headline(e)}${Ansi.reset}');

    final subLines = _subHeaderLines(e);
    for (final s in subLines) {
      buf.writeln('$color│${Ansi.reset}  ${Ansi.dim}$s${Ansi.reset}');
    }

    final sections = _bodySections(e);
    for (var i = 0; i < sections.length; i++) {
      final (label, body) = sections[i];
      buf.writeln('$color├$line┤${Ansi.reset}');
      buf.writeln('$color│${Ansi.reset}  $label');
      buf.writeln(_indent(body, color));
    }

    buf.write('$color└$line┘${Ansi.reset}');
    return buf.toString();
  }

  String _indent(String text, String color) => text
      .split('\n')
      .map((l) => '$color│${Ansi.reset}    $l')
      .join('\n');

  // ─── Minimal (compact, no borders) ──────────────────────────────────

  String _formatMinimal(AshLogEntry e) {
    final color = _colorFor(e);
    final buf = StringBuffer();
    buf.writeln('$color${_icon(e)} ${Ansi.bold}${_headline(e)}${Ansi.reset}');
    for (final s in _subHeaderLines(e)) {
      buf.writeln('  ${Ansi.dim}$s${Ansi.reset}');
    }
    for (final (label, body) in _bodySections(e)) {
      buf.writeln('  $label');
      buf.writeln(body.split('\n').map((l) => '    $l').join('\n'));
    }
    return buf.toString();
  }

  // ─── Shared field builders ───────────────────────────────────────────

  String _colorFor(AshLogEntry e) {
    switch (e.type) {
      case AshLogType.debug:
        return theme.debugColor;
      case AshLogType.success:
        return theme.successColor;
      case AshLogType.error:
        return theme.errorColor;
      case AshLogType.network:
        final ok = e.success ?? ((e.statusCode ?? 200) < 400);
        return ok ? theme.successColor : theme.errorColor;
      case AshLogType.socketIn:
        return theme.socketInColor;
      case AshLogType.socketOut:
        return theme.socketOutColor;
    }
  }

  String _icon(AshLogEntry e) {
    switch (e.type) {
      case AshLogType.debug:
        return '◆';
      case AshLogType.success:
        return '●';
      case AshLogType.error:
        return '✕';
      case AshLogType.network:
        final ok = e.success ?? ((e.statusCode ?? 200) < 400);
        return ok ? '●' : '✕';
      case AshLogType.socketIn:
        return '▼';
      case AshLogType.socketOut:
        return '▲';
    }
  }

  String _headline(AshLogEntry e) {
    switch (e.type) {
      case AshLogType.debug:
        return e.tag ?? 'DEBUG';
      case AshLogType.success:
        return e.title != null ? 'SUCCESS [${e.title}]' : 'SUCCESS';
      case AshLogType.error:
        final prefix = e.level == AshLevel.fatal ? 'FATAL' : 'ERROR';
        return e.title != null ? '$prefix [${e.title}]' : prefix;
      case AshLogType.network:
        final m = e.method?.toUpperCase();
        final status = e.statusCode != null ? ' · ${e.statusCode}' : '';
        final head = [
          if (m != null) '[$m]',
          e.title ?? 'NETWORK',
        ].join(' ');
        return '$head$status';
      case AshLogType.socketIn:
        return e.title ?? 'SOCKET IN';
      case AshLogType.socketOut:
        return e.title ?? 'SOCKET OUT';
    }
  }

  List<String> _subHeaderLines(AshLogEntry e) {
    final lines = <String>[];
    if (e.endpoint != null) lines.add(e.endpoint!);
    if (e.tag != null && e.type != AshLogType.debug) lines.add('#${e.tag}');
    return lines;
  }

  /// Returns (label, renderedBody) pairs for every non-null field,
  /// in the order Postman/Swagger typically shows them.
  List<(String, String)> _bodySections(AshLogEntry e) {
    final sections = <(String, String)>[];

    if (e.curl != null) {
      sections.add(('${Ansi.bold}cURL${Ansi.reset}', e.curl!));
    }
    if (e.requestBody != null) {
      sections.add(('${Ansi.bold}Request Body${Ansi.reset}', _json.render(e.requestBody)));
    }
    if (e.responseBody != null) {
      sections.add(('${Ansi.bold}Response Body${Ansi.reset}', _json.render(e.responseBody)));
    }
    if (e.data != null) {
      sections.add(('${Ansi.bold}Data${Ansi.reset}', _json.render(e.data)));
    }
    if (e.message != null) {
      sections.add(('${Ansi.bold}Message${Ansi.reset}', e.message!));
    }
    if (e.errorObject != null) {
      sections.add(('${Ansi.bold}Error${Ansi.reset}', e.errorObject.toString()));
    }
    if (e.stackTrace != null) {
      sections.add(('${Ansi.bold}Stack Trace${Ansi.reset}', e.stackTrace.toString()));
    }

    return sections;
  }
}
