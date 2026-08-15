# Barta Logger

A beautiful, Postman/Swagger-style debug logger for Flutter.

`logger_barta` brings clarity to your console by printing API calls, socket events, and debug messages as clean, bordered boxes with syntax-highlighted JSON. 

Every field is **optional**: log just an endpoint for a quick trace, or include the method, cURL command, request body, and response for a full breakdown. Nothing runs in release builds unless explicitly enabled.

## Features

- **Rich Output**: `BartaLog.trace` / `debug` / `success` / `error` / `fatal` with beautifully colored console logs.
- **API Inspector**: `BartaLog.network` logs HTTP requests/responses like Postman.
- **cURL Generator**: `BartaLog.curl` creates standalone, ready-to-use cURL commands.
- **Sockets**: `BartaLog.socketOn` and `BartaLog.socketEmit` for real-time traffic tracking.
- **Log Levels**: Control verbosity at runtime (`BartaLog.level = BartaLevel.warning`) to mute noise without removing code.
- **Pluggable Filters & Outputs**: Send logs to Crashlytics, Sentry, or custom files alongside the console using `BartaLogFilter` and `BartaLogOutput`.
- **In-App Viewer**: An optional `BartaLogViewer` widget provides a searchable, in-app Swagger-style UI.
- **Performance First**: Bounded in-memory history (circular buffer) prevents memory leaks. Zero-cost in release mode.
- **Cross-Platform**: Works flawlessly on iOS, Android, Web, macOS, Windows, and Linux.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  logger_barta: ^0.1.1
```

## Getting Started

Initialize the logger once in your `main.dart` before running your app. This step is optional but recommended if you want to use the in-app viewer or custom configurations.

```dart
import 'package:logger_barta/logger_barta.dart';

void main() {
  BartaLog.init(); 
  runApp(const MyApp());
}
```

## Usage

### Basic Logging
```dart
BartaLog.debug('User tapped checkout', tag: 'UI');
BartaLog.success('Data loaded successfully');

// Errors with stack traces are separated cleanly
try {
  await api.submit();
} catch (e, st) {
  BartaLog.error('Submit failed', title: 'Checkout', error: e, stackTrace: st);
}
```

### Network & API Calls
Nothing is mandatory. Provide as much or as little context as you want.

```dart
// Quick GET trace
BartaLog.network(endpoint: '/users/42'); 

// Detailed API Log
BartaLog.network(
  method: 'POST',
  endpoint: '/posts',
  requestBody: {'title': 'Hello world'},
  responseBody: {'id': 1},
  statusCode: 201,
  curl: "curl -X 'POST' '/posts' -d '{\"title\":\"Hello world\"}'",
  title: 'Create Post',
);
```

### WebSockets
```dart
BartaLog.socketEmit(event: 'message:send', data: {'text': 'hi'});
BartaLog.socketOn(event: 'message:received', data: {'text': 'hey'});
```

### Muting Logs (Levels)
You can change the minimum log level at runtime to mute noisy output while keeping the code intact.

```dart
// Mute everything below warning
BartaLog.level = BartaLevel.warning;

// Or configure it during initialization:
BartaLog.init(config: const BartaLogConfig(level: BartaLevel.info));
```

### Advanced: Custom Filters & Crashlytics Integration
Send errors to external services by adding a custom `BartaLogOutput`.

```dart
class MuteHealthCheck implements BartaLogFilter {
  @override
  bool shouldLog(BartaLogEntry entry) => entry.endpoint != '/health';
}

final streamOutput = BartaLogStreamOutput();
BartaLog.init(
  filter: MuteHealthCheck(),
  outputs: [const ConsoleBartaLogOutput(), streamOutput],
);

// Listen to the stream and forward fatal errors
streamOutput.stream
    .where((e) => e.level == BartaLevel.error || e.level == BartaLevel.fatal)
    .listen((e) => MyCrashReporter.record(e.message, e.errorObject, e.stackTrace));
```

### In-App Log Viewer UI
Embed the `BartaLogViewer` anywhere in your app to let testers or developers inspect logs without a computer.

```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const BartaLogViewer(scrollDirection: Axis.vertical),
));
```

## Project Architecture

This package follows Clean Architecture principles, making it highly modular, testable, and easy to extend:

```text
lib/
├── logger_barta.dart         # Public API (BartaLog)
└── src/
    ├── barta_log.dart        # Entry point and static methods
    ├── config/             # Theme and configuration models
    ├── core/               # Enums (BartaLevel, BartaLogType, ANSI colors)
    ├── data/               # Repositories (InMemoryBartaLogRepository)
    ├── domain/             # Entities (BartaLogEntry, BartaLogRepository interface)
    ├── filter/             # Logging rules (BartaLogFilter)
    ├── formatters/         # UI rendering (ConsoleFormatter, JsonColorizer)
    ├── output/             # Sinks (ConsoleBartaLogOutput, BartaLogStreamOutput)
    └── presentation/       # UI Widgets (BartaLogViewer)
```

## Roadmap
Future planned features:
- File and remote log exports.
- A floating overlay bubble for the viewer.
- Built-in `Dio` and `http` interceptors.
- Advanced filtering and search inside the `BartaLogViewer` UI.

## Contributing
Found a bug or have a feature request? Issues and pull requests are always welcome!

---
Developed by Ash Soft.
