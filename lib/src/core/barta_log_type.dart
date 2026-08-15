/// The kind of entry being logged.
/// Add new values here when you extend the package in the future —
/// everything downstream (formatter, repository, viewer) switches on this.
enum BartaLogType {
  debug,
  success,
  error,
  network,
  socketIn,
  socketOut,
}
