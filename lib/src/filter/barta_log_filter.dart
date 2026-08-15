import '../core/ash_level.dart';
import '../domain/ash_log_entry.dart';

/// Decides whether an [AshLogEntry] actually gets logged. Swap this out
/// via `AshLog.init(filter: ...)` for custom rules — e.g. silence a
/// noisy tag, sample 1-in-10 network logs, mute a specific endpoint.
abstract class AshLogFilter {
  bool shouldLog(AshLogEntry entry);
}

/// Default filter: log everything at or above [minLevel].
/// `AshLevel.off` silences everything regardless of individual entries.
class DefaultAshLogFilter implements AshLogFilter {
  const DefaultAshLogFilter({this.minLevel = AshLevel.trace});

  final AshLevel minLevel;

  @override
  bool shouldLog(AshLogEntry entry) {
    if (minLevel == AshLevel.off) return false;
    return entry.level.index >= minLevel.index;
  }
}
