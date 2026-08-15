/// Severity levels, low → high. Mirrors common logging conventions so
/// the package feels familiar if you've used `package:logging` or
/// `package:logger` — trace < debug < info < warning < error < fatal.
///
/// Every [AshLog] call picks a sensible default level (e.g. `error()`
/// is [AshLevel.error]), but you can override it per-call, and you can
/// set a global floor with `AshLog.level = AshLevel.warning` to mute
/// noisier levels without removing the log calls from your code.
enum AshLevel {
  trace,
  debug,
  info,
  warning,
  error,
  fatal,

  /// Set `AshLogConfig(level: AshLevel.off)` to silence everything.
  off;

  bool operator >=(AshLevel other) => index >= other.index;
  bool operator <=(AshLevel other) => index <= other.index;
  bool operator >(AshLevel other) => index > other.index;
  bool operator <(AshLevel other) => index < other.index;
}
