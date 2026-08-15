/// Standard ANSI escape codes used across the package.
/// Kept in one place so a custom [AshLogTheme] can override any of them.
class Ansi {
  const Ansi._();

  static const reset = '\x1B[0m';
  static const bold = '\x1B[1m';
  static const dim = '\x1B[2m';

  static const cyan = '\x1B[96m';
  static const green = '\x1B[92m';
  static const red = '\x1B[91m';
  static const yellow = '\x1B[93m';
  static const magenta = '\x1B[95m';
  static const white = '\x1B[97m';
  static const gray = '\x1B[90m';
}
