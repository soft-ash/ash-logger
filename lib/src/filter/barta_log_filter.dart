import '../core/barta_level.dart';
import '../domain/barta_log_entry.dart';

/// Decides whether an [BartaLogEntry] actually gets logged. Swap this out
/// via `BartaLog.init(filter: ...)` for custom rules — e.g. silence a
/// noisy tag, sample 1-in-10 network logs, mute a specific endpoint.
abstract class BartaLogFilter {
  bool shouldLog(BartaLogEntry entry);
}

/// Default filter: log everything at or above [minLevel].
/// `BartaLevel.off` silences everything regardless of individual entries.
class DefaultBartaLogFilter implements BartaLogFilter {
  const DefaultBartaLogFilter({this.minLevel = BartaLevel.trace});

  final BartaLevel minLevel;

  @override
  bool shouldLog(BartaLogEntry entry) {
    if (minLevel == BartaLevel.off) return false;
    return entry.level.index >= minLevel.index;
  }
}
