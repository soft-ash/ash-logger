import '../core/ash_level.dart';
import '../core/ash_log_type.dart';

/// A single log entry. Only [type] and [level] are mandatory — callers
/// pass just the fields relevant to what they're logging.
///
/// This is the shape stored in memory (for `AshLogViewer`), the shape
/// handed to the console formatter, and the shape sent to every
/// `AshLogOutput` — extending the package later (e.g. adding
/// `duration`) means adding one field here.
class AshLogEntry {
  final AshLogType type;
  final AshLevel level;
  final DateTime timestamp;

  final String? title;
  final String? tag;

  // Network-specific (all optional — GET needs none of requestBody,
  // POST can add it, curl/title/etc. are always opt-in).
  final String? method;
  final String? endpoint;
  final String? curl;
  final dynamic requestBody;
  final dynamic responseBody;
  final int? statusCode;
  final bool? success;

  // Generic / socket / debug payload.
  final dynamic data;
  final String? message;

  // Error details — separate from [data] so a formatter can label them
  // distinctly ("Error" / "Stack Trace" instead of "Data").
  final Object? errorObject;
  final StackTrace? stackTrace;

  AshLogEntry({
    required this.type,
    required this.level,
    this.title,
    this.tag,
    this.method,
    this.endpoint,
    this.curl,
    this.requestBody,
    this.responseBody,
    this.statusCode,
    this.success,
    this.data,
    this.message,
    this.errorObject,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
