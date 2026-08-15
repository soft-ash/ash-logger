import 'package:flutter/material.dart';

import '../ash_log.dart';
import '../core/ash_log_type.dart';
import '../domain/ash_log_entry.dart';

/// Optional in-app screen that renders [AshLog.history] as expandable
/// cards, newest first. Not required to use the logger at all — this
/// is purely for teams that want a Swagger-style in-app inspector.
///
/// Ships with a vertical (default) and horizontal layout; pass
/// [scrollDirection] to switch. This is intentionally a thin
/// presentation-only widget — it reads from [AshLog.history] and does
/// no formatting logic of its own, so it stays cheap to keep in sync
/// if the domain model grows.
class AshLogViewer extends StatefulWidget {
  const AshLogViewer({
    super.key,
    this.scrollDirection = Axis.vertical,
  });

  final Axis scrollDirection;

  @override
  State<AshLogViewer> createState() => _AshLogViewerState();
}

class _AshLogViewerState extends State<AshLogViewer> {
  late Axis _direction = widget.scrollDirection;

  @override
  Widget build(BuildContext context) {
    final logs = AshLog.history.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ash Logs'),
        actions: [
          IconButton(
            tooltip: 'Toggle layout',
            icon: Icon(_direction == Axis.vertical
                ? Icons.view_agenda_outlined
                : Icons.view_column_outlined),
            onPressed: () => setState(() {
              _direction =
                  _direction == Axis.vertical ? Axis.horizontal : Axis.vertical;
            }),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(AshLog.clearHistory),
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text('No logs yet'))
          : _direction == Axis.vertical
              ? ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (_, i) => _AshLogCard(entry: logs[i]),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: logs.length,
                  itemBuilder: (_, i) => SizedBox(
                    width: 320,
                    child: _AshLogCard(entry: logs[i]),
                  ),
                ),
    );
  }
}

class _AshLogCard extends StatelessWidget {
  const _AshLogCard({required this.entry});

  final AshLogEntry entry;

  Color get _color {
    switch (entry.type) {
      case AshLogType.debug:
        return Colors.amber;
      case AshLogType.success:
        return Colors.green;
      case AshLogType.error:
        return Colors.red;
      case AshLogType.network:
        final ok = entry.success ?? ((entry.statusCode ?? 200) < 400);
        return ok ? Colors.green : Colors.red;
      case AshLogType.socketIn:
        return Colors.purple;
      case AshLogType.socketOut:
        return Colors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = [
      if (entry.method != null) entry.method!.toUpperCase(),
      entry.title ?? entry.tag ?? entry.type.name,
      if (entry.statusCode != null) '· ${entry.statusCode}',
    ].join(' ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: _color, radius: 6),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          [
            if (entry.endpoint != null) entry.endpoint!,
            entry.timestamp.toIso8601String(),
          ].join(' · '),
          style: const TextStyle(fontSize: 11),
        ),
        children: [
          if (entry.requestBody != null) _field('Request', entry.requestBody),
          if (entry.responseBody != null) _field('Response', entry.responseBody),
          if (entry.data != null) _field('Data', entry.data),
          if (entry.curl != null) _field('cURL', entry.curl),
          if (entry.message != null) _field('Message', entry.message),
        ],
      ),
    );
  }

  Widget _field(String label, dynamic value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SelectableText('$label: $value'),
        ),
      );
}
