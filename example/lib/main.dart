import 'package:ash_logger/ash_logger.dart';
import 'package:flutter/material.dart';

void main() {
  // Optional — defaults work without calling this.
  AshLog.init(
    config: const AshLogConfig(
      maxInMemoryLogs: 150,
      theme: AshLogTheme(style: AshLogStyle.boxed),
    ),
  );
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ash Logger Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Ash Logger Demo')),
        body: Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: () => AshLog.debug('Hello from AshLog', tag: 'BOOT'),
                child: const Text('Debug'),
              ),
              ElevatedButton(
                onPressed: () => AshLog.network(
                  method: 'GET',
                  endpoint: '/users/42',
                  statusCode: 200,
                  responseBody: {'id': 42, 'name': 'Ash'},
                  title: 'Get User',
                ),
                child: const Text('GET success'),
              ),
              ElevatedButton(
                onPressed: () => AshLog.network(
                  method: 'POST',
                  endpoint: '/posts',
                  requestBody: {'title': 'Hello world'},
                  responseBody: {'error': 'Unauthorized'},
                  statusCode: 401,
                  curl: "curl -X 'POST' '/posts' -d '{\"title\":\"Hello world\"}'",
                  title: 'Create Post',
                ),
                child: const Text('POST error'),
              ),
              ElevatedButton(
                onPressed: () => AshLog.socketEmit(event: 'message:send', data: {'text': 'hi'}),
                child: const Text('Socket emit'),
              ),
              ElevatedButton(
                onPressed: () => AshLog.socketOn(event: 'message:received', data: {'text': 'hey'}),
                child: const Text('Socket on'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AshLogViewer()),
                ),
                child: const Text('Open log viewer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
