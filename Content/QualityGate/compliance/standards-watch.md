---
layout: BlogPostLayout
series: quality-gate
title: "standards-watch: When the Regulation Itself Changes"
tags: quality-gate, compliance, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:25
lastModified: 2026-08-15
published: true
---

# standards-watch

**A control mapping is only as current as the standard it maps. `standards-watch` turns silent regulatory drift into a dated alert — by reading the law directly.**

---

Here's the problem with a compliance mapping: the standards move. HIPAA gets amended; SOC 2's criteria get revised; ISO publishes a new edition. If the mapping doesn't notice, it silently describes a world that no longer exists. `standards-watch` is the monitor that makes drift impossible to miss. It's **detect-and-alert only** — it never edits a catalog; a human reconciles and re-stamps.

## Reading the law

For HIPAA, it doesn't scrape a web page — it hits the federal **eCFR versioner API** for §164.312 of Title 45. The API normalizes the date out of the returned content, so the SHA-256 of the section text is stable day-to-day but **changes the moment the rule is actually amended.** That's exactly the drift signal. The catalog stores the last-observed hash; when today's fetch differs, the check reports `DRIFTED` and exits non-zero — so a scheduled job can alert.

It's armed and proven end-to-end: first run seeds the hash and reports `seeded`; the next run reports `unchanged`; and the tool's own hash matches `shasum -a 256` on the API body. If §164.312 is ever amended, you'll know the week it happens, not at your next audit.

## Early warning from the Federal Register

Even better: it reads the **Federal Register** for *proposed* rules touching 45 CFR 164 — filtered by CFR reference, not a noisy keyword search — and surfaces the latest one as an advisory. So a HIPAA rulemaking is on your radar *before* it takes effect. (Run live, it surfaced the January-2026 HIPAA Privacy Rule modification NPRM.)

## Honest about what it can't fetch

SOC 2 and ISO are copyrighted and not machine-readable, so they report `manual` — "re-verify against the cited source." The tool doesn't pretend to watch what it can't legally read. That's the same honesty as the [coverage report](/QualityGate/compliance/coverage-not-a-badge): automate detection where you can, be explicit where you can't, and never fake certainty. It ships with a weekly launchd job so the whole thing runs unattended.

## Try it

```bash
quality-gate standards-watch      # exits non-zero on drift; schedule it
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
