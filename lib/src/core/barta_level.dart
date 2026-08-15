/// Severity levels, low → high. Mirrors common logging conventions so
/// the package feels familiar if you've used `package:logging` or
/// `package:logger` — trace < debug < info < warning < error < fatal.
///
/// Every [BartaLog] call picks a sensible default level (e.g. `error()`
/// is [BartaLevel.error]), but you can override it per-call, and you can
/// set a global floor with `BartaLog.level = BartaLevel.warning` to mute
/// noisier levels without removing the log calls from your code.
enum BartaLevel {
  trace,
  debug,
  info,
  warning,
  error,
  fatal,

  /// Set `BartaLogConfig(level: BartaLevel.off)` to silence everything.
  off;

  bool operator >=(BartaLevel other) => index >= other.index;
  bool operator <=(BartaLevel other) => index <= other.index;
  bool operator >(BartaLevel other) => index > other.index;
  bool operator <(BartaLevel other) => index < other.index;
}
