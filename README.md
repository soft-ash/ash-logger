<aside>

**logger_barta** · A beautiful, Postman/Swagger-style debug logger for Flutter. Print API calls, socket events, and debug messages as clean, bordered boxes with syntax-highlighted JSON.

</aside>

## Features

- **Rich Output** — `BartaLog.trace` / `debug` / `success` / `error` / `fatal` with beautifully colored console logs
- **API Inspector** — `BartaLog.network` logs HTTP requests/responses like Postman
- **cURL Generator** — `BartaLog.curl` creates standalone, ready-to-use cURL commands
- **WebSockets** — `BartaLog.socketOn` and `BartaLog.socketEmit` for real-time traffic tracking
- **Log Levels** — Control verbosity at runtime (`BartaLog.level = BartaLevel.warning`) to mute noise without removing code
- **Pluggable Filters & Outputs** — Send logs to Crashlytics, Sentry, or custom files using `BartaLogFilter` and `BartaLogOutput`
- **In-App Viewer** — Optional `BartaLogViewer` widget provides a searchable, Swagger-style in-app UI
- **Performance First** — Bounded in-memory history (circular buffer) prevents memory leaks; zero-cost in release mode
- **Cross-Platform** — iOS, Android, Web, macOS, Windows, and Linux

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  logger_barta: ^0.1.2
```

---

## Getting Started

Initialize once in `main.dart` before running your app.

```dart
import 'package:logger_barta/logger_barta.dart';

void main() {
  BartaLog.init();
  runApp(const MyApp());
}
```

---

## Usage

### Basic Logging

```dart
BartaLog.debug('User tapped checkout', tag: 'UI');
BartaLog.success('Data loaded successfully');

try {
  await api.submit();
} catch (e, st) {
  BartaLog.error('Submit failed', title: 'Checkout', error: e, stackTrace: st);
}
```

### Network & API Calls

Every field is **optional** — log just an endpoint for a quick trace, or include the full breakdown.

```dart
// Quick GET trace
BartaLog.network(endpoint: '/users/42');

// Detailed API log
BartaLog.network(
  title: 'Create Post',
  method: 'POST',
  endpoint: '/posts',
  statusCode: 201,
  success: true,
  requestBody: '{"title": "Hello world"}',
  responseBody: {'id': 1},
  curl: "curl -X 'POST' '/posts' -d '{\"title\":\"Hello world\"}'",
);
```

**Console Output:**

<p align="center">

  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/screenshot_5_20_07.png" width="650" alt="Console Output">
  <br>
  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/screenshot_5_20_26.png" width="650" alt="Console Output">
  <br>
  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/screenshot_5_20_42.png" width="650" alt="Console Output">
  <br>
  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/screenshot_5_21_00.png" width="650" alt="Console Output">
  <br>
  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/screenshot_5_21_18.png" width="650" alt="Console Output">
</p>



### WebSockets

```dart
BartaLog.socketEmit(event: 'message:send', data: {'text': 'hi'});
BartaLog.socketOn(event: 'message:received', data: {'text': 'hey'});
```

### Muting Logs (Levels)

```dart
// Mute everything below warning
BartaLog.level = BartaLevel.warning;

// Or configure during initialization
BartaLog.init(config: const BartaLogConfig(level: BartaLevel.info));
```

### Advanced: Custom Filters & Crashlytics Integration

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

streamOutput.stream
    .where((e) => e.level == BartaLevel.error || e.level == BartaLevel.fatal)
    .listen((e) => MyCrashReporter.record(e.message, e.errorObject, e.stackTrace));
```

### In-App Log Viewer

<p align="center">
  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/ui_screenshot.png" width="300" alt="UI Screenshot">
</p>

```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const BartaLogViewer(scrollDirection: Axis.vertical),
));
```

---

## Contributing

Found a bug or have a feature request? Issues and pull requests are always welcome!

---

*Developed by dev_ash*.