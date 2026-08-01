---
layout: BlogPostLayout
series: quality-gate
title: "SafetyAuditor: No Force Unwraps, and the OWASP Mobile Top 10"
tags: quality-gate, safety, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-13 09:00
lastModified: 2026-08-13
published: true
---

# SafetyAuditor

**The workhorse. It enforces the zero-tolerance safety rules — and a real slice of the OWASP Mobile Top 10.**

---

If quality-gate-swift has a flagship checker, it's this one. It enforces the rules that keep a shipping app from crashing on its users, and the security patterns that keep it from leaking them.

## The crash-safety rules

```swift
// ❌ force-unwrap — crashes on the one nil you didn't expect
let view = optionalView!
// ✅ guard let view = optionalView else { return }

// ❌ force-cast
let cell = item as! Cell
// ✅ guard let cell = item as? Cell else { return }

// ❌ force-try, and ❌ fatalError()/precondition() in production
let data = try! decode(payload)
```

The zero-tolerance rules — no `!`, no `as!`, no `try!`, no `fatalError()` in production — are the ones that show up in every "the app crashed" postmortem. Each has an escape hatch for the genuinely-safe case, and the escape hatch is a recorded `// SAFETY:` comment stating *why*: never silent.

## The security rules — OWASP Mobile Top 10

The same AST walk powers a set of security checks mapped to the OWASP Mobile Top 10:

```
security.hardcoded-secret     security.insecure-transport
security.insecure-keychain    security.tls-disabled
security.weak-crypto          security.command-injection
security.sql-injection        security.path-traversal
security.ssrf                 security.eval-js
```

Hardcoded credentials, HTTP where HTTPS is required, weak crypto (MD5/SHA-1/DES), disabled TLS validation, SQL built by string interpolation, path traversal, server-side request forgery from dynamic URLs. These aren't hypothetical: `security.insecure-transport` and `security.weak-crypto` are exactly the rules the [compliance mapping](/QualityGate/compliance/coverage-not-a-badge) later ties to HIPAA §164.312(e) and SOC 2 CC6.6.

A `// SECURITY:` comment exempts a validated case (a test fixture, a deliberately-allowlisted host) — recorded, with a reason, so an auditor can see every place a security rule was consciously relaxed.

## Try it

```bash
quality-gate --check safety
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
