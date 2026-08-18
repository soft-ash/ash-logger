<aside>

All notable changes to **logger_barta** are documented here. This project follows Semantic Versioning.

</aside>

---

## [0.1.2] — Latest

###  Bug Fixes

- **JSON String Formatting** — Fixed an issue in `JsonColorizer` where raw JSON strings passed to `requestBody` or `responseBody` were escaped into a single line. They are now properly decoded, pretty-printed, and syntax-highlighted.
- **README Updates** — Expanded documentation to showcase all available fields for network logging.

---

## [0.1.1]

###  Bug Fixes

- **README rendering fix** — Replaced HTML `<img>` tags with standard Markdown image tags in `README.md` to ensure screenshots render correctly on pub.dev.

---

## [0.1.0] — Initial Release

###  Features

**Core Logging**

- `BartaLog.debug` — Debug-level messages with optional tag
- `BartaLog.success` — Success confirmations with green output
- `BartaLog.error` — Error messages with stack trace support
- `BartaLog.trace` — Granular trace-level output
- `BartaLog.fatal` — Fatal error logging

**Network Inspection**

- `BartaLog.network` — Fully optional GET/POST/etc. request + response logging with Postman-style bordered output
- `BartaLog.curl` — Standalone cURL command formatter

**WebSocket Logging**

- `BartaLog.socketOn` — Inbound socket event logger
- `BartaLog.socketEmit` — Outbound socket event logger

**Configuration & Control**

- `BartaLevel` — Runtime verbosity control: `trace` / `debug` / `info` / `warning` / `error` / `fatal` / `off`
- Pluggable `BartaLogFilter` — Custom rules to include or suppress log entries
- Pluggable `BartaLogOutput` — Route logs to console, streams, or external services
- `BartaLogTheme` — Themeable console output colors

**Storage & Performance**

- In-memory circular-buffer log storage — prevents memory leaks in long-running sessions
- **Zero-cost in release mode** — no-op by default unless explicitly enabled

**UI**

- `BartaLogViewer` widget — Optional in-app log viewer with vertical/horizontal layout support