import 'package:flutter/foundation.dart';

import 'config/ash_log_theme.dart';
import 'core/ash_level.dart';
import 'core/ash_log_type.dart';
import 'data/in_memory_ash_log_repository.dart';
import 'domain/ash_log_entry.dart';
import 'domain/ash_log_repository.dart';
import 'filter/ash_log_filter.dart';
import 'formatters/console_formatter.dart';
import 'output/ash_log_output.dart';

/// Public entry point of the package.
///
/// Everything is a static call so you never have to thread an instance
/// through your app — call [AshLog.init] once (optional; it has sane
/// defaults) and then just `AshLog.debug(...)`, `AshLog.network(...)`,
/// `AshLog.socketOn(...)` etc. from anywhere.
///
/// Design notes for future-you:
/// - All logging methods take only optional named params. Pass what you
///   have; unset fields simply don't print a section.
/// - Formatting lives in [ConsoleFormatter], storage in
///   [AshLogRepository], filtering in [AshLogFilter], and where a log
///   actually goes lives in [AshLogOutput] — swap any of these via
///   [init] without touching this class.
/// - Nothing runs in release mode unless [AshLogConfig.logInReleaseMode]
///   is explicitly turned on.
class AshLog {
  AshLog._();

  static AshLogConfig _config = const AshLogConfig();
  static AshLogRepository _repository =
      InMemoryAshLogRepository(maxLogs: _config.maxInMemoryLogs);
  static ConsoleFormatter _formatter = ConsoleFormatter(_config.theme);
  static AshLogFilter _filter = DefaultAshLogFilter(minLevel: _config.level);
  static List<AshLogOutput> _outputs = const [ConsoleAshLogOutput()];

  /// Call once in `main()` (before `runApp`) to customize theme, storage
  /// limits, filtering rules, or where logs actually go. Safe to skip —
  /// defaults (console output, no minimum level, in-memory history)
  /// work out of the box.
  static void init({
    AshLogConfig? config,
    AshLogRepository? repository,
    AshLogFilter? filter,
    List<AshLogOutput>? outputs,
  }) {
    if (config != null) {
      _config = config;
      _formatter = ConsoleFormatter(config.theme);
    }
    _repository =
        repository ?? InMemoryAshLogRepository(maxLogs: _config.maxInMemoryLogs);
    _filter = filter ?? DefaultAshLogFilter(minLevel: _config.level);
    _outputs = outputs ??
        (_config.enableConsoleLogging ? const [ConsoleAshLogOutput()] : const []);
  }

  /// Change the minimum severity at runtime without touching call
  /// sites, e.g. `AshLog.level = AshLevel.warning;` to mute
  /// debug/info/network-success noise while keeping errors visible.
  static set level(AshLevel level) {
    _config = _config.copyWith(level: level);
    _filter = DefaultAshLogFilter(minLevel: level);
  }

  static AshLevel get level => _config.level;

  /// All entries currently held in memory — feed this to your own UI,
  /// or use the bundled `AshLogViewer` widget.
  static List<AshLogEntry> get history => _repository.getAll();

  static void clearHistory() => _repository.clear();

  // ─── Debug / Trace ──────────────────────────────────────────────

  static void trace(dynamic message, {String? tag}) {
    _emit(AshLogEntry(
      type: AshLogType.debug,
      level: AshLevel.trace,
      tag: tag ?? 'TRACE',
      message: message?.toString(),
    ));
  }

  static void debug(dynamic message, {String? tag}) {
    _emit(AshLogEntry(
      type: AshLogType.debug,
      level: AshLevel.debug,
      tag: tag ?? 'DEBUG',
      message: message?.toString(),
    ));
  }

  // ─── Generic success / error (not tied to a network call) ─────────

  static void success(dynamic message, {String? title}) {
    _emit(AshLogEntry(
      type: AshLogType.success,
      level: AshLevel.info,
      title: title,
      message: message?.toString(),
    ));
  }

  static void error(
    dynamic message, {
    String? title,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(AshLogEntry(
      type: AshLogType.error,
      level: AshLevel.error,
      title: title,
      message: message?.toString(),
      errorObject: error,
      stackTrace: stackTrace,
    ));
  }

  /// Same as [error] but at [AshLevel.fatal] — use for crashes/unhandled
  /// exceptions you still want console history for.
  static void fatal(
    dynamic message, {
    String? title,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(AshLogEntry(
      type: AshLogType.error,
      level: AshLevel.fatal,
      title: title,
      message: message?.toString(),
      errorObject: error,
      stackTrace: stackTrace,
    ));
  }

  // ─── Network (GET/POST/... — every field optional) ─────────────────

  /// Log an API call. Nothing here is mandatory: log just an endpoint
  /// for a quick GET trace, or fill in method/curl/bodies/status for a
  /// full Postman-style breakdown. Level is derived from [success] /
  /// [statusCode] automatically (info if it looks like a 2xx, error
  /// otherwise) unless you don't pass either, in which case it's info.
  static void network({
    String? method,
    String? endpoint,
    dynamic requestBody,
    dynamic responseBody,
    String? curl,
    int? statusCode,
    bool? success,
    String? title,
  }) {
    final ok = success ?? ((statusCode ?? 200) < 400);
    _emit(AshLogEntry(
      type: AshLogType.network,
      level: ok ? AshLevel.info : AshLevel.error,
      method: method,
      endpoint: endpoint,
      requestBody: requestBody,
      responseBody: responseBody,
      curl: curl,
      statusCode: statusCode,
      success: success,
      title: title,
    ));
  }

  /// Convenience for building just the cURL section on its own — handy
  /// if you already log the response separately via [network].
  static void curl({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
  }) {
    final cmd = StringBuffer("curl -X '${method.toUpperCase()}' \\\n  '$endpoint'");
    headers?.forEach((k, v) => cmd.write(" \\\n  -H '$k: $v'"));
    if (body != null) {
      final bodyStr = body.toString();
      cmd.write(" \\\n  -d '${bodyStr.replaceAll("'", "'\\''")}'");
    }
    _emit(AshLogEntry(
      type: AshLogType.network,
      level: AshLevel.debug,
      method: method,
      endpoint: endpoint,
      curl: cmd.toString(),
      title: 'cURL',
    ));
  }

  // ─── Socket ──────────────────────────────────────────────────────

  static void socketOn({String? event, dynamic data}) {
    _emit(AshLogEntry(
      type: AshLogType.socketIn,
      level: AshLevel.debug,
      title: event,
      data: data,
    ));
  }

  static void socketEmit({String? event, dynamic data}) {
    _emit(AshLogEntry(
      type: AshLogType.socketOut,
      level: AshLevel.debug,
      title: event,
      data: data,
    ));
  }

  // ─── Internal ────────────────────────────────────────────────────

  static void _emit(AshLogEntry entry) {
    if (!kDebugMode && !_config.logInReleaseMode) return;
    if (!_filter.shouldLog(entry)) return;

    if (_config.enableInMemoryLogging) {
      _repository.save(entry);
    }

    final formatted = _formatter.format(entry);
    for (final output in _outputs) {
      output.output(formatted, entry);
    }
  }
}
