---
layout: BlogPostLayout
series: quality-gate
title: "KeychainSecretsChecker: The Token You Left in UserDefaults"
tags: quality-gate, safety, compliance, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-14 09:00
lastModified: 2026-08-14
published: true
---

# KeychainSecretsChecker

**Credentials written to `UserDefaults` instead of the Keychain — a plaintext leak that's one line of code and one App Store review away from a breach.**

---

`UserDefaults` is a plaintext `.plist` inside the app container: unencrypted at rest, and swept into iTunes/iCloud device backups. It's the right tool for "has the user seen the tutorial." It's the wrong tool for an auth token. For a health or clinical app, a token in `UserDefaults` is a concrete breach surface. It's also an easy, invisible mistake — which is exactly what a static check is for.

## What it catches

```swift
// ❌ a secret written to UserDefaults
UserDefaults.standard.set(accessToken, forKey: "authToken")
defaults["refreshToken"] = token
UserDefaults.standard.setValue(apiKey, forKey: "clientSecret")

// ✅ store secrets in the Keychain
```

## How it stays precise — the AST earns its keep

A naïve version of this check cries wolf constantly. The real one is a two-pass SwiftSyntax analysis, and its precision guards are the whole point:

- **Receiver typing.** It first records which identifiers are actually bound to a `UserDefaults` instance, so a same-named `.set(...)` on some other object never fires.
- **The Bool/Int guard.** A stored `true` or `3` is not a credential — so `set(true, forKey: "hasSeenTokenTutorial")` stays quiet even though the key contains "token."
- **Word-aware matching.** `tokenizer` is not `token`; camelCase and acronyms are tokenized, so `apiKey` matches as a compound while `tokenizerConfig` does not.
- **Severity by confidence.** A string-literal secret key gates at `.error`; a match seen only in the stored value's identifier softens to `.warning`.

Both a config `allowKeys` list and an inline `// keychain:exempt` (recorded, never silent) suppress a site. **14 tests**; it validated end-to-end flagging a real `authToken` write while leaving the adjacent boolean line alone.

## It's also a compliance control

`keychain-secrets` is one of the technical-control checkers the [compliance mapping](/QualityGate/compliance/coverage-not-a-badge) ties to HIPAA §164.312(a)(2)(iv) (encryption), SOC 2 CC6.1, and ISO 27001 A.8.24 — a good example of a single AST rule doing double duty: catching a bug *and* producing audit evidence.

## Try it

```bash
quality-gate --check keychain-secrets
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
