import 'dart:collection';

import '../domain/ash_log_entry.dart';
import '../domain/ash_log_repository.dart';

/// Fixed-size circular buffer. Once [maxLogs] is reached, the oldest
/// entry is dropped on every insert — bounded memory, no leaks, no
/// matter how long the app session runs.
class InMemoryAshLogRepository implements AshLogRepository {
  InMemoryAshLogRepository({this.maxLogs = 200});

  final int maxLogs;
  final Queue<AshLogEntry> _buffer = Queue<AshLogEntry>();

  @override
  void save(AshLogEntry entry) {
    if (_buffer.length >= maxLogs) {
      _buffer.removeFirst();
    }
    _buffer.add(entry);
  }

  @override
  List<AshLogEntry> getAll() => List.unmodifiable(_buffer);

  @override
  void clear() => _buffer.clear();
}
