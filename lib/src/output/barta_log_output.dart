import 'dart:async';
import 'dart:developer' as dev;

import '../domain/barta_log_entry.dart';

/// Destination for a formatted log line. [BartaLog] sends the same
/// formatted string (plus the raw entry) to every registered output,
/// so you can log to the console *and* forward errors elsewhere at
/// the same time.
///
/// Ships with [ConsoleBartaLogOutput] (default) and [BartaLogStreamOutput].
/// Write your own (a file sink, a remote log service) by implementing
/// this and passing it to `BartaLog.init(outputs: [...])`.
abstract class BartaLogOutput {
  void output(String formatted, BartaLogEntry entry);
}

/// Prints via `dart:developer`'s `log()`, same as the original
/// hand-rolled logger — plays nicely with DevTools and IDE consoles.
class ConsoleBartaLogOutput implements BartaLogOutput {
  const ConsoleBartaLogOutput();

  @override
  void output(String formatted, BartaLogEntry entry) {
    dev.log(formatted, name: entry.title ?? entry.tag ?? entry.type.name);
  }
}

/// Broadcasts every entry on a stream instead of (or alongside)
/// printing it. Listen to forward logs into Crashlytics, Sentry, a
/// remote logging service, or a custom UI:
///
/// ```dart
/// final streamOutput = BartaLogStreamOutput();
/// BartaLog.init(outputs: [const ConsoleBartaLogOutput(), streamOutput]);
/// streamOutput.stream.where((e) => e.level == BartaLevel.error).listen((e) {
///   // report to your crash service
/// });
/// ```
class BartaLogStreamOutput implements BartaLogOutput {
  BartaLogStreamOutput()
      : _controller = StreamController<BartaLogEntry>.broadcast();

  final StreamController<BartaLogEntry> _controller;

  Stream<BartaLogEntry> get stream => _controller.stream;

  @override
  void output(String formatted, BartaLogEntry entry) {
    _controller.add(entry);
  }

  void dispose() => _controller.close();
}
