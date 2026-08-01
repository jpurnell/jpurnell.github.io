---
layout: BlogPostLayout
series: quality-gate
title: "LoggingAuditor: No print(), No Silent Catches"
tags: quality-gate, hygiene, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-18 09:00
lastModified: 2026-08-18
published: true
---

# LoggingAuditor

**`print()` in production, errors swallowed in silence, and `os.Logger` calls that leak private data — the hygiene of knowing what your code did.**

---

Logging is how you find out what happened when you weren't watching. Bad logging hygiene means either no signal (a `print()` that vanishes in Release, an error caught and dropped) or too much (a logger call that prints a user's private data to the device console). `LoggingAuditor` catches both ends.

## What it catches

```swift
// ❌ logging.print-statement — print() in production; invisible in Release
print("loaded \(user.email)")

// ❌ logging.catch-without-logging — an error caught and silently dropped
do { try save() } catch { }

// ❌ logging.silent-try — try? with no explanation
let data = try? Data(contentsOf: url)
// ✅ // silent: an unreadable cache file is simply skipped
let data = try? Data(contentsOf: url)

// ❌ logging.missing-privacy — os.Logger interpolating data with no privacy annotation
logger.info("token: \(token)")            // leaks to the console
// ✅ logger.info("token: \(token, privacy: .private)")
```

Representative rule IDs: `logging.print-statement`, `logging.catch-without-logging`, `logging.silent-try`, `logging.missing-privacy`, `logging.no-os-logger-import`, `logging.bare-logger-init`.

The `try?` rule is one I meet constantly in my own first-pass code — three times this project's own gate caught me discarding an error without a `// silent:` reason, and each time the fix was to write down *why* the error was safe to drop. That's the rule working as intended: not "never use `try?`," but "never discard an error without saying why." Adjacency is strict and the comment is recorded — searchable, never silent.

## Try it

```bash
quality-gate --check logging
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
