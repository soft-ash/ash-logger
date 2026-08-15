# Ash Logger

A beautiful, Postman/Swagger-style debug logger for Flutter.

`ash_logger` brings clarity to your console by printing API calls, socket events, and debug messages as clean, bordered boxes with syntax-highlighted JSON. 

Every field is **optional**: log just an endpoint for a quick trace, or include the method, cURL command, request body, and response for a full breakdown. Nothing runs in release builds unless explicitly enabled.

![Console Output](assets/console_screenshot.png)
<br/>
![UI Viewer](assets/ui_screenshot.png)

## Features

- **Rich Output**: `AshLog.trace` / `debug` / `success` / `error` / `fatal` with beautifully colored console logs.
- **API Inspector**: `AshLog.network` logs HTTP requests/responses like Postman.
- **cURL Generator**: `AshLog.curl` creates standalone, ready-to-use cURL commands.
- **Sockets**: `AshLog.socketOn` and `AshLog.socketEmit` for real-time traffic tracking.
- **Log Levels**: Control verbosity at runtime (`AshLog.level = AshLevel.warning`) to mute noise without removing code.
- **Pluggable Filters & Outputs**: Send logs to Crashlytics, Sentry, or custom files alongside the console using `AshLogFilter` and `AshLogOutput`.
- **In-App Viewer**: An optional `AshLogViewer` widget provides a searchable, in-app Swagger-style UI.
- **Performance First**: Bounded in-memory history (circular buffer) prevents memory leaks. Zero-cost in release mode.
- **Cross-Platform**: Works flawlessly on iOS, Android, Web, macOS, Windows, and Linux.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ash_logger: ^0.1.1
```

## Getting Started

Initialize the logger once in your `main.dart` before running your app. This step is optional but recommended if you want to use the in-app viewer or custom configurations.

```dart
import 'package:ash_logger/ash_logger.dart';

void main() {
  AshLog.init(); 
  runApp(const MyApp());
}
```

## Usage

### Basic Logging
```dart
AshLog.debug('User tapped checkout', tag: 'UI');
AshLog.success('Data loaded successfully');

// Errors with stack traces are separated cleanly
try {
  await api.submit();
} catch (e, st) {
  AshLog.error('Submit failed', title: 'Checkout', error: e, stackTrace: st);
}
```

### Network & API Calls
Nothing is mandatory. Provide as much or as little context as you want.

```dart
// Quick GET trace
AshLog.network(endpoint: '/users/42'); 

// Detailed API Log
AshLog.network(
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
AshLog.socketEmit(event: 'message:send', data: {'text': 'hi'});
AshLog.socketOn(event: 'message:received', data: {'text': 'hey'});
```

### Muting Logs (Levels)
You can change the minimum log level at runtime to mute noisy output while keeping the code intact.

```dart
// Mute everything below warning
AshLog.level = AshLevel.warning;

// Or configure it during initialization:
AshLog.init(config: const AshLogConfig(level: AshLevel.info));
```

### Advanced: Custom Filters & Crashlytics Integration
Send errors to external services by adding a custom `AshLogOutput`.

```dart
class MuteHealthCheck implements AshLogFilter {
  @override
  bool shouldLog(AshLogEntry entry) => entry.endpoint != '/health';
}

final streamOutput = AshLogStreamOutput();
AshLog.init(
  filter: MuteHealthCheck(),
  outputs: [const ConsoleAshLogOutput(), streamOutput],
);

// Listen to the stream and forward fatal errors
streamOutput.stream
    .where((e) => e.level == AshLevel.error || e.level == AshLevel.fatal)
    .listen((e) => MyCrashReporter.record(e.message, e.errorObject, e.stackTrace));
```

### In-App Log Viewer UI
Embed the `AshLogViewer` anywhere in your app to let testers or developers inspect logs without a computer.

```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const AshLogViewer(scrollDirection: Axis.vertical),
));
```

## Project Architecture

This package follows Clean Architecture principles, making it highly modular, testable, and easy to extend:

```text
lib/
├── ash_logger.dart         # Public API (AshLog)
└── src/
    ├── ash_log.dart        # Entry point and static methods
    ├── config/             # Theme and configuration models
    ├── core/               # Enums (AshLevel, AshLogType, ANSI colors)
    ├── data/               # Repositories (InMemoryAshLogRepository)
    ├── domain/             # Entities (AshLogEntry, AshLogRepository interface)
    ├── filter/             # Logging rules (AshLogFilter)
    ├── formatters/         # UI rendering (ConsoleFormatter, JsonColorizer)
    ├── output/             # Sinks (ConsoleAshLogOutput, AshLogStreamOutput)
    └── presentation/       # UI Widgets (AshLogViewer)
```

## Roadmap
Future planned features:
- File and remote log exports.
- A floating overlay bubble for the viewer.
- Built-in `Dio` and `http` interceptors.
- Advanced filtering and search inside the `AshLogViewer` UI.

## Contributing
Found a bug or have a feature request? Issues and pull requests are always welcome!
