## 0.2.0

- `AshLevel` (trace/debug/info/warning/error/fatal/off) — set a runtime
  floor with `AshLog.level = AshLevel.warning` to mute noisy levels
  without removing log calls.
- Pluggable `AshLogFilter` (`DefaultAshLogFilter` ships as default) —
  override `AshLog.init(filter: ...)` for custom rules (sampling,
  muting a tag, etc).
- Pluggable `AshLogOutput` — logs can go to more than just the console.
  Ships `ConsoleAshLogOutput` (default) and `AshLogStreamOutput` for
  piping entries to Crashlytics/Sentry/your own listener.
- `AshLog.trace` and `AshLog.fatal` added alongside `debug`/`error`.
- `AshLog.error` / `AshLog.fatal` now accept `error` and `stackTrace`,
  printed as their own sections.

## 0.1.0

- Initial release.
- `AshLog.debug`, `AshLog.success`, `AshLog.error`.
- `AshLog.network` — fully optional GET/POST/etc. request+response logging.
- `AshLog.curl` — standalone cURL command formatter.
- `AshLog.socketOn` / `AshLog.socketEmit`.
- Themeable via `AshLogTheme` (colors, box width, boxed/minimal style).
- In-memory circular-buffer log storage (`AshLogRepository` is swappable).
- Optional `AshLogViewer` widget (vertical/horizontal in-app log list).
- No-op in release mode unless explicitly enabled.
