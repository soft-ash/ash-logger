import '../core/ansi.dart';
import '../core/barta_level.dart';

/// How much visual detail a printed block should have.
/// Extend this enum later (e.g. `compactSingleLine`) without touching
/// anything that already depends on [BartaLogTheme].
enum BartaLogStyle {
  /// Full Postman/Swagger-style bordered box (default).
  boxed,

  /// One line per field, no borders — friendlier for small consoles/CI logs.
  minimal,
}

/// Every visual knob of the package lives here so a user can hand you
/// their own instance and change colors, borders, or the print style
/// without touching package internals.
class BartaLogTheme {
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

  final BartaLogStyle style;
  final int boxWidth;
  final String borderChar;

  const BartaLogTheme({
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
    this.style = BartaLogStyle.boxed,
    this.boxWidth = 72,
    this.borderChar = '─',
  });

  BartaLogTheme copyWith({
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
    BartaLogStyle? style,
    int? boxWidth,
    String? borderChar,
  }) {
    return BartaLogTheme(
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

/// Global behavioural switches — separate from [BartaLogTheme] because
/// these affect *whether/where* something is logged, not how it looks.
class BartaLogConfig {
  final bool enableConsoleLogging;
  final bool enableInMemoryLogging;
  final bool logInReleaseMode;
  final int maxInMemoryLogs;

  /// Minimum severity that gets through. `BartaLevel.trace` (default)
  /// logs everything; e.g. `BartaLevel.warning` mutes debug/info/network
  /// success traces and only shows warning/error/fatal. Change at
  /// runtime with `BartaLog.level = BartaLevel.warning`.
  final BartaLevel level;

  final BartaLogTheme theme;

  const BartaLogConfig({
    this.enableConsoleLogging = true,
    this.enableInMemoryLogging = true,
    this.logInReleaseMode = false,
    this.maxInMemoryLogs = 200,
    this.level = BartaLevel.trace,
    this.theme = const BartaLogTheme(),
  });

  BartaLogConfig copyWith({
    bool? enableConsoleLogging,
    bool? enableInMemoryLogging,
    bool? logInReleaseMode,
    int? maxInMemoryLogs,
    BartaLevel? level,
    BartaLogTheme? theme,
  }) {
    return BartaLogConfig(
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
