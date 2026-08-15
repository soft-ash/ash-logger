import 'package:logger_barta/logger_barta.dart';
import 'package:flutter/material.dart';

void main() {
  // Optional — defaults work without calling this.
  BartaLog.init(
    config: const BartaLogConfig(
      maxInMemoryLogs: 150,
      theme: BartaLogTheme(style: BartaLogStyle.boxed),
    ),
  );
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barta Logger Demo',
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Barta Logger Demo')),
          body: Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      BartaLog.debug('Hello from BartaLog', tag: 'BOOT'),
                  child: const Text('Debug'),
                ),
                ElevatedButton(
                  onPressed: () => BartaLog.network(
                    method: 'GET',
                    endpoint: '/users/42',
                    statusCode: 200,
                    responseBody: {'id': 42, 'name': 'Barta'},
                    title: 'Get User',
                  ),
                  child: const Text('GET success'),
                ),
                ElevatedButton(
                  onPressed: () => BartaLog.network(
                    method: 'POST',
                    endpoint: '/posts',
                    requestBody: {'title': 'Hello world'},
                    responseBody: {'error': 'Unauthorized'},
                    statusCode: 401,
                    curl:
                        "curl -X 'POST' '/posts' -d '{\"title\":\"Hello world\"}'",
                    title: 'Create Post',
                  ),
                  child: const Text('POST error'),
                ),
                ElevatedButton(
                  onPressed: () => BartaLog.socketEmit(
                      event: 'message:send', data: {'text': 'hi'}),
                  child: const Text('Socket emit'),
                ),
                ElevatedButton(
                  onPressed: () => BartaLog.socketOn(
                      event: 'message:received', data: {'text': 'hey'}),
                  child: const Text('Socket on'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BartaLogViewer()),
                  ),
                  child: const Text('Open log viewer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
