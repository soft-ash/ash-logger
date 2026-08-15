import 'barta_log_entry.dart';

/// Storage contract for log entries. The default implementation is an
/// in-memory circular buffer, but this interface is what lets you swap
/// in e.g. a SQLite-backed repository later without touching [BartaLog]
/// or the viewer widget.
abstract class BartaLogRepository {
  void save(BartaLogEntry entry);
  List<BartaLogEntry> getAll();
  void clear();
}
