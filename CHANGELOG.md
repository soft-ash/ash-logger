## 0.1.1

* Fix: Replace HTML `<img>` tags with standard Markdown image tags in `README.md` to ensure screenshots render correctly on pub.dev.

## 0.1.0

* Initial release.
* `AshLog.debug`, `AshLog.success`, `AshLog.error`, `AshLog.trace`, `AshLog.fatal`.
* `AshLog.network` — fully optional GET/POST/etc. request+response logging.
* `AshLog.curl` — standalone cURL command formatter.
* `AshLog.socketOn` / `AshLog.socketEmit`.
* `AshLevel` (trace/debug/info/warning/error/fatal/off) for runtime verbosity filtering.
* Pluggable `AshLogFilter` and `AshLogOutput`.
* Themeable via `AshLogTheme`.
* In-memory circular-buffer log storage.
* Optional `AshLogViewer` widget (vertical/horizontal in-app log list).
* No-op in release mode unless explicitly enabled.
