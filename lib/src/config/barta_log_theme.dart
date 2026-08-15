import '../core/ansi.dart';
import '../core/ash_level.dart';

/// How much visual detail a printed block should have.
/// Extend this enum later (e.g. `compactSingleLine`) without touching
/// anything that already depends on [AshLogTheme].
enum AshLogStyle {
  /// Full Postman/Swagger-style bordered box (default).
  boxed,

  /// One line per field, no borders — friendlier for small consoles/CI logs.
  minimal,
}

/// Every visual knob of the package lives here so a user can hand you
/// their own instance and change colors, borders, or the print style
/// without touching package internals.
class AshLogTheme {
  final String debugColor;
  final String successColor;
  final String errorColor;
  final String networkColor;
  final String socketInColor;
  final String socketOutColor;

  final String keyColor;
  final String stringColor;
  final String numberColor;
  final String nullColor;
  final String punctuationColor;

  final AshLogStyle style;
  final int boxWidth;
  final String borderChar;

  const AshLogTheme({
    this.debugColor = Ansi.yellow,
    this.successColor = Ansi.green,
    this.errorColor = Ansi.red,
    this.networkColor = Ansi.cyan,
    this.socketInColor = Ansi.magenta,
    this.socketOutColor = Ansi.cyan,
    this.keyColor = Ansi.white,
    this.stringColor = Ansi.green,
    this.numberColor = Ansi.yellow,
    this.nullColor = Ansi.gray,
    this.punctuationColor = Ansi.gray,
    this.style = AshLogStyle.boxed,
    this.boxWidth = 72,
    this.borderChar = '─',
  });

  AshLogTheme copyWith({
    String? debugColor,
    String? successColor,
    String? errorColor,
    String? networkColor,
    String? socketInColor,
    String? socketOutColor,
    String? keyColor,
    String? stringColor,
    String? numberColor,
    String? nullColor,
    String? punctuationColor,
    AshLogStyle? style,
    int? boxWidth,
    String? borderChar,
  }) {
    return AshLogTheme(
      debugColor: debugColor ?? this.debugColor,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      networkColor: networkColor ?? this.networkColor,
      socketInColor: socketInColor ?? this.socketInColor,
      socketOutColor: socketOutColor ?? this.socketOutColor,
      keyColor: keyColor ?? this.keyColor,
      stringColor: stringColor ?? this.stringColor,
      numberColor: numberColor ?? this.numberColor,
      nullColor: nullColor ?? this.nullColor,
      punctuationColor: punctuationColor ?? this.punctuationColor,
      style: style ?? this.style,
      boxWidth: boxWidth ?? this.boxWidth,
      borderChar: borderChar ?? this.borderChar,
    );
  }
}

/// Global behavioural switches — separate from [AshLogTheme] because
/// these affect *whether/where* something is logged, not how it looks.
class AshLogConfig {
  final bool enableConsoleLogging;
  final bool enableInMemoryLogging;
  final bool logInReleaseMode;
  final int maxInMemoryLogs;

  /// Minimum severity that gets through. `AshLevel.trace` (default)
  /// logs everything; e.g. `AshLevel.warning` mutes debug/info/network
  /// success traces and only shows warning/error/fatal. Change at
  /// runtime with `AshLog.level = AshLevel.warning`.
  final AshLevel level;

  final AshLogTheme theme;

  const AshLogConfig({
    this.enableConsoleLogging = true,
    this.enableInMemoryLogging = true,
    this.logInReleaseMode = false,
    this.maxInMemoryLogs = 200,
    this.level = AshLevel.trace,
    this.theme = const AshLogTheme(),
  });

  AshLogConfig copyWith({
    bool? enableConsoleLogging,
    bool? enableInMemoryLogging,
    bool? logInReleaseMode,
    int? maxInMemoryLogs,
    AshLevel? level,
    AshLogTheme? theme,
  }) {
    return AshLogConfig(
      enableConsoleLogging: enableConsoleLogging ?? this.enableConsoleLogging,
      enableInMemoryLogging:
          enableInMemoryLogging ?? this.enableInMemoryLogging,
      logInReleaseMode: logInReleaseMode ?? this.logInReleaseMode,
      maxInMemoryLogs: maxInMemoryLogs ?? this.maxInMemoryLogs,
      level: level ?? this.level,
      theme: theme ?? this.theme,
    );
  }
}
