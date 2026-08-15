## 0.1.1

* Fix: Replace HTML `<img>` tags with standard Markdown image tags in `README.md` to ensure screenshots render correctly on pub.dev.

## 0.1.0

* Initial release.
* `BartaLog.debug`, `BartaLog.success`, `BartaLog.error`, `BartaLog.trace`, `BartaLog.fatal`.
* `BartaLog.network` — fully optional GET/POST/etc. request+response logging.
* `BartaLog.curl` — standalone cURL command formatter.
* `BartaLog.socketOn` / `BartaLog.socketEmit`.
* `BartaLevel` (trace/debug/info/warning/error/fatal/off) for runtime verbosity filtering.
* Pluggable `BartaLogFilter` and `BartaLogOutput`.
* Themeable via `BartaLogTheme`.
* In-memory circular-buffer log storage.
* Optional `BartaLogViewer` widget (vertical/horizontal in-app log list).
* No-op in release mode unless explicitly enabled.
