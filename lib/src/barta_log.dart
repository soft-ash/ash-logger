import 'package:flutter/foundation.dart';

import 'config/barta_log_theme.dart';
import 'core/barta_level.dart';
import 'core/barta_log_type.dart';
import 'data/in_memory_barta_log_repository.dart';
import 'domain/barta_log_entry.dart';
import 'domain/barta_log_repository.dart';
import 'filter/barta_log_filter.dart';
import 'formatters/console_formatter.dart';
import 'output/barta_log_output.dart';

/// Public entry point of the package.
///
/// Everything is a static call so you never have to thread an instance
/// through your app — call [BartaLog.init] once (optional; it has sane
/// defaults) and then just `BartaLog.debug(...)`, `BartaLog.network(...)`,
/// `BartaLog.socketOn(...)` etc. from anywhere.
///
/// Design notes for future-you:
/// - All logging methods take only optional named params. Pass what you
///   have; unset fields simply don't print a section.
/// - Formatting lives in [ConsoleFormatter], storage in
///   [BartaLogRepository], filtering in [BartaLogFilter], and where a log
///   actually goes lives in [BartaLogOutput] — swap any of these via
///   [init] without touching this class.
/// - Nothing runs in release mode unless [BartaLogConfig.logInReleaseMode]
///   is explicitly turned on.
class BartaLog {
  BartaLog._();

  static BartaLogConfig _config = const BartaLogConfig();
  static BartaLogRepository _repository =
      InMemoryBartaLogRepository(maxLogs: _config.maxInMemoryLogs);
  static ConsoleFormatter _formatter = ConsoleFormatter(_config.theme);
  static BartaLogFilter _filter =
      DefaultBartaLogFilter(minLevel: _config.level);
  static List<BartaLogOutput> _outputs = const [ConsoleBartaLogOutput()];

  /// Call once in `main()` (before `runApp`) to customize theme, storage
  /// limits, filtering rules, or where logs actually go. Safe to skip —
  /// defaults (console output, no minimum level, in-memory history)
  /// work out of the box.
  static void init({
    BartaLogConfig? config,
    BartaLogRepository? repository,
    BartaLogFilter? filter,
    List<BartaLogOutput>? outputs,
  }) {
    if (config != null) {
      _config = config;
      _formatter = ConsoleFormatter(config.theme);
    }
    _repository = repository ??
        InMemoryBartaLogRepository(maxLogs: _config.maxInMemoryLogs);
    _filter = filter ?? DefaultBartaLogFilter(minLevel: _config.level);
    _outputs = outputs ??
        (_config.enableConsoleLogging
            ? const [ConsoleBartaLogOutput()]
            : const []);
  }

  /// Change the minimum severity at runtime without touching call
  /// sites, e.g. `BartaLog.level = BartaLevel.warning;` to mute
  /// debug/info/network-success noise while keeping errors visible.
  static set level(BartaLevel level) {
    _config = _config.copyWith(level: level);
    _filter = DefaultBartaLogFilter(minLevel: level);
  }

  static BartaLevel get level => _config.level;

  /// All entries currently held in memory — feed this to your own UI,
  /// or use the bundled `BartaLogViewer` widget.
  static List<BartaLogEntry> get history => _repository.getAll();

  static void clearHistory() => _repository.clear();

  // ─── Debug / Trace ──────────────────────────────────────────────

  static void trace(dynamic message, {String? tag}) {
    _emit(BartaLogEntry(
      type: BartaLogType.debug,
      level: BartaLevel.trace,
      tag: tag ?? 'TRACE',
      message: message?.toString(),
    ));
  }

  static void debug(dynamic message, {String? tag}) {
    _emit(BartaLogEntry(
      type: BartaLogType.debug,
      level: BartaLevel.debug,
      tag: tag ?? 'DEBUG',
      message: message?.toString(),
    ));
  }

  // ─── Generic success / error (not tied to a network call) ─────────

  static void success(dynamic message, {String? title}) {
    _emit(BartaLogEntry(
      type: BartaLogType.success,
      level: BartaLevel.info,
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
    _emit(BartaLogEntry(
      type: BartaLogType.error,
      level: BartaLevel.error,
      title: title,
      message: message?.toString(),
      errorObject: error,
      stackTrace: stackTrace,
    ));
  }

  /// Same as [error] but at [BartaLevel.fatal] — use for crashes/unhandled
  /// exceptions you still want console history for.
  static void fatal(
    dynamic message, {
    String? title,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(BartaLogEntry(
      type: BartaLogType.error,
      level: BartaLevel.fatal,
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
    _emit(BartaLogEntry(
      type: BartaLogType.network,
      level: ok ? BartaLevel.info : BartaLevel.error,
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
    final cmd =
        StringBuffer("curl -X '${method.toUpperCase()}' \\\n  '$endpoint'");
    headers?.forEach((k, v) => cmd.write(" \\\n  -H '$k: $v'"));
    if (body != null) {
      final bodyStr = body.toString();
      cmd.write(" \\\n  -d '${bodyStr.replaceAll("'", "'\\''")}'");
    }
    _emit(BartaLogEntry(
      type: BartaLogType.network,
      level: BartaLevel.debug,
      method: method,
      endpoint: endpoint,
      curl: cmd.toString(),
      title: 'cURL',
    ));
  }

  // ─── Socket ──────────────────────────────────────────────────────

  static void socketOn({String? event, dynamic data}) {
    _emit(BartaLogEntry(
      type: BartaLogType.socketIn,
      level: BartaLevel.debug,
      title: event,
      data: data,
    ));
  }

  static void socketEmit({String? event, dynamic data}) {
    _emit(BartaLogEntry(
      type: BartaLogType.socketOut,
      level: BartaLevel.debug,
      title: event,
      data: data,
    ));
  }

  // ─── Internal ────────────────────────────────────────────────────

  static void _emit(BartaLogEntry entry) {
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
