import 'dart:collection';

import '../domain/barta_log_entry.dart';
import '../domain/barta_log_repository.dart';

/// Fixed-size circular buffer. Once [maxLogs] is reached, the oldest
/// entry is dropped on every insert — bounded memory, no leaks, no
/// matter how long the app session runs.
class InMemoryBartaLogRepository implements BartaLogRepository {
  InMemoryBartaLogRepository({this.maxLogs = 200});

  final int maxLogs;
  final Queue<BartaLogEntry> _buffer = Queue<BartaLogEntry>();

  @override
  void save(BartaLogEntry entry) {
    if (_buffer.length >= maxLogs) {
      _buffer.removeFirst();
    }
    _buffer.add(entry);
  }

  @override
  List<BartaLogEntry> getAll() => List.unmodifiable(_buffer);

  @override
  void clear() => _buffer.clear();
}
