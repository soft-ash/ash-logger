# Logger Barta

**logger_barta** is a structured logging and debugging package for Flutter.

It makes console logs easier to read and debug by providing clean output for **application logs, API requests/responses, WebSocket events, errors, cURL commands, and in-app log viewing**.

## Why Logger Barta?

Instead of dealing with unreadable `print()` output, Logger Barta gives you one consistent logging system for your Flutter application.

* Structured and readable console logs
* Postman-style API debugging
* WebSocket and Socket.IO monitoring
* Formatted JSON request/response data
* Error and stack trace logging
* Log levels and custom filters
* Custom log outputs
* In-app log viewer
* Bounded log storage for better memory usage

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  logger_barta: ^0.1.3
```

Then run:

```bash
flutter pub get
```

Import:

```dart
import 'package:logger_barta/logger_barta.dart';
```

## Quick Start

Basic logging works without initialization:

```dart
BartaLog.debug('User opened profile');

BartaLog.success('Profile loaded successfully');

BartaLog.error(
  'Failed to load profile',
  error: exception,
  stackTrace: stackTrace,
);
```

For custom configuration:

```dart
void main() {
  BartaLog.init();

  runApp(const MyApp());
}
```

## API Logging

Log HTTP requests, responses, status codes, JSON data, and cURL commands.

```dart
BartaLog.network(
  title: 'Create Post',
  method: 'POST',
  endpoint: '/posts',
  statusCode: 201,
  success: true,
  requestBody: {
    'title': 'Hello World',
  },
  responseBody: {
    'id': 1,
  },
  curl: "curl -X POST '/posts'",
);
```

All network fields are optional:

```text
title
method
endpoint
statusCode
success
requestBody
responseBody
curl
```

## WebSocket / Socket.IO

Track outgoing and incoming socket events:

```dart
BartaLog.socketEmit(
  event: 'message:send',
  data: {'text': 'Hello'},
);

BartaLog.socketOn(
  event: 'message:received',
  data: {'text': 'Hello back'},
);
```

Useful for chat, notifications, live feeds, WebRTC signaling, and other real-time features.

## Log Levels

Control which logs should be displayed:

```dart
BartaLog.level = BartaLevel.warning;
```

## Custom Filters

Exclude logs you do not need:

```dart
class MuteHealthCheck implements BartaLogFilter {
  @override
  bool shouldLog(BartaLogEntry entry) {
    return entry.endpoint != '/health';
  }
}

BartaLog.init(
  filter: MuteHealthCheck(),
);
```

## Custom Outputs

Send logs to your own monitoring or crash-reporting system:

```dart
final output = BartaLogStreamOutput();

BartaLog.init(
  outputs: [
    const ConsoleBartaLogOutput(),
    output,
  ],
);

output.stream.listen((entry) {
  // Send entry to your custom service.
});
```

## In-App Log Viewer

View captured logs directly inside your Flutter application:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const BartaLogViewer(
      scrollDirection: Axis.vertical,
    ),
  ),
);
```

This is useful for debugging physical devices and QA testing without connecting the device to a development machine.

## Screenshots

### Debug

<p align="center">
  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/screenshot_5_20_07.png" width="650" alt="Logger Barta Debug Log">
</p>

### Network

<p align="center">
  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/screenshot_5_20_42.png" width="650" alt="Logger Barta Network Log">
</p>

### Socket

<p align="center">
  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/screenshot_5_21_00.png" width="650" alt="Logger Barta Socket Log">
</p>

### In-App Viewer

<p align="center">
  <img src="https://raw.githubusercontent.com/soft-ash/ash-logger/main/assets/ui_screenshot.png" width="300" alt="Logger Barta In-App Log Viewer">
</p>

## Recommended For

Logger Barta is useful for Flutter applications that use:

* REST APIs
* WebSockets / Socket.IO
* Real-time communication
* Complex JSON payloads
* Custom error tracking
* Physical-device debugging
* QA testing

## Production Safety

Avoid logging sensitive information such as:

* Passwords
* Authentication tokens
* API secrets
* Payment information
* Private user data

Configure log levels, filters, and outputs appropriately for production builds.

## Contributing

Issues and pull requests are welcome.

When reporting a bug, please include your Flutter/Dart version, package version, platform, reproduction steps, and relevant logs.

## License

See the `LICENSE` file for licensing information.

## Author

Developed by **dev_ash**.

---

**Logger Barta** — structured logs for better Flutter debugging.
