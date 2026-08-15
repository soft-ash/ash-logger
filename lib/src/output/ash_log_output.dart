import 'dart:async';
import 'dart:developer' as dev;

import '../domain/ash_log_entry.dart';

/// Destination for a formatted log line. [AshLog] sends the same
/// formatted string (plus the raw entry) to every registered output,
/// so you can log to the console *and* forward errors elsewhere at
/// the same time.
///
/// Ships with [ConsoleAshLogOutput] (default) and [AshLogStreamOutput].
/// Write your own (a file sink, a remote log service) by implementing
/// this and passing it to `AshLog.init(outputs: [...])`.
abstract class AshLogOutput {
  void output(String formatted, AshLogEntry entry);
}

/// Prints via `dart:developer`'s `log()`, same as the original
/// hand-rolled logger — plays nicely with DevTools and IDE consoles.
class ConsoleAshLogOutput implements AshLogOutput {
  const ConsoleAshLogOutput();

  @override
  void output(String formatted, AshLogEntry entry) {
    dev.log(formatted, name: entry.title ?? entry.tag ?? entry.type.name);
  }
}

/// Broadcasts every entry on a stream instead of (or alongside)
/// printing it. Listen to forward logs into Crashlytics, Sentry, a
/// remote logging service, or a custom UI:
///
/// ```dart
/// final streamOutput = AshLogStreamOutput();
/// AshLog.init(outputs: [const ConsoleAshLogOutput(), streamOutput]);
/// streamOutput.stream.where((e) => e.level == AshLevel.error).listen((e) {
///   // report to your crash service
/// });
/// ```
class AshLogStreamOutput implements AshLogOutput {
  AshLogStreamOutput() : _controller = StreamController<AshLogEntry>.broadcast();

  final StreamController<AshLogEntry> _controller;

  Stream<AshLogEntry> get stream => _controller.stream;

  @override
  void output(String formatted, AshLogEntry entry) {
    _controller.add(entry);
  }

  void dispose() => _controller.close();
}
