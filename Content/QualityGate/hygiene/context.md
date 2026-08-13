---
layout: BlogPostLayout
series: quality-gate
title: "ContextAuditor: Consent, Surveillance, and the Ethics of Code"
tags: quality-gate, hygiene, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:31
lastModified: 2026-08-20
published: true
---

# ContextAuditor

**If we can detect institutional patterns in override decisions, can we detect ethical patterns in the code itself? This is that checker.**

---

`ContextAuditor` came directly out of building the [Institutional Judgment System](/QualityGate/mirror/the-mirror). If the whole project is about making judgment visible, the obvious next question is whether the *code* encodes judgments about the people it touches — and whether those judgments are made deliberately or by omission.

## Four categories of ethical risk

- **Missing consent guards** — accessing location, contacts, camera, health data, calendar, or photos with no prior consent check in the enclosing function.
- **Unguarded analytics** — tracking user behavior with no opt-out guard.
- **Automated decisions without review** — an ML prediction feeding directly into a deny / block / suspend action with no human-review step.
- **Surveillance patterns** — background location tracking with no disclosure annotation.

```swift
// ❌ accessing health data with no consent check
let steps = try await healthStore.samples(for: .stepCount)
// ✅ // CONSENT: user opted in via Settings > Privacy
guard hasHealthConsent else { return }
let steps = try await healthStore.samples(for: .stepCount)
```

Each rule is suppressed with a *justification* annotation — `// CONSENT: User opted in via Settings > Privacy`. The requirement for justification text is deliberate: **silent suppression is not allowed.** An access that's genuinely consented is recorded as such; an access that isn't gets a finding.

## Earn your keep or get removed

`ContextAuditor` is a separate, easily-disableable module, and that's a design statement. If its findings are consistently ignored, the correct response is to *disable it* — not to force compliance. An ignored checker is worse than no checker, because it trains people to skip the gate's output. This is the "flag to understand, not forbid" philosophy in its sharpest form: an advisory ethical checker has to earn its place, every run, or it should be gone.

## Try it

```bash
quality-gate --check context
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
