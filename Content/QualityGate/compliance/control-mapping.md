---
layout: BlogPostLayout
series: quality-gate
title: "ControlMapping: Who Audits the Audit Map?"
tags: quality-gate, compliance, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-13 09:06
lastModified: 2026-08-13
published: true
---

# ControlMapping

**The compliance report is only as honest as the table underneath it. This checker audits the table.**

---

The [compliance report](/QualityGate/compliance/coverage-not-a-badge) rests on one artifact: a mapping from gate rules to framework control IDs. `security.insecure-transport` satisfies HIPAA §164.312(e), SOC 2 CC6.6, ISO 27001 A.5.14. Write the rule once, claim the control three times.

That mapping is a hand-maintained data file, and hand-maintained data files drift against the things they reference. When this one drifts, the failure mode is *inflated coverage* — a report claiming controls that nothing enforces, delivered to whoever asked for it, in the format they expect.

`control-mapping` checks the map against both of its endpoints.

## Four findings

**Phantom rule (error).** A mapping references `security.insecure-transport`, and no checker emits that id. Perhaps it was renamed; perhaps it was removed; perhaps it was aspirational. Whatever happened, the report is now claiming CC6.6 on the strength of a rule that never runs. The message says it plainly: *no such checker/rule emits it*.

**Phantom control (error).** The other direction — a mapping cites `A.8.24`, and no catalog defines it. Now the report claims a control that doesn't exist in the framework as catalogued, which is worse than an unmapped rule: it's a citation an auditor will look up and not find.

**Superseded catalog (error).** [Standards-watch](/QualityGate/compliance/standards-watch) notices when an upstream standard moves and marks the catalog superseded. That flag is not advisory. A catalog known to have drifted from the standard it describes cannot underwrite claims about that standard, so mapping integrity fails until someone reconciles it. This is the one that keeps drift detection from becoming a notification nobody acts on.

**Stale catalog (warning).** Reviewed longer ago than the freshness horizon. No drift has been detected — but nobody has *checked* in a while, and the finding says how long: *last reviewed 2025-11-02 (284 days ago, horizon 180)*.

The severity split is the argument in miniature. A phantom reference is a claim that is currently false, and blocks. A stale catalog is a claim nobody has verified lately, and warns. Collapsing those into one level would either let a false claim through or make the gate cry wolf about an unread calendar.

## Determinism, because compliance output is evidence

The validation function takes `today` as a parameter — an ISO string, injected — rather than reading the wall clock.

That's not fastidiousness. Staleness is a temporal fact, and a checker that reads `Date()` internally produces a different verdict on Tuesday than on Monday from identical inputs, which makes its output untestable and its history unreproducible. Push the clock read to the boundary and the engine becomes pure over its inputs: the same mapping, catalogs, and date always yield the same diagnostics. A compliance artifact you can't reproduce isn't evidence.

The same reasoning runs through the [hermeticity contract](/QualityGate/mirror/the-corpus) — a checker declares whether it is `.hermetic`, `.temporal`, or `.external`, and this one is honest about being temporal rather than pretending its answer is timeless.

## What it does not do

It does not check that a rule *adequately* satisfies a control. Whether `keychain-secrets` genuinely discharges CC6.1 is a judgment about the strength of a safeguard, and it belongs to a human who can read both the rule and the standard.

What this checker guarantees is narrower and worth having on its own: **every rule named in the map exists, every control cited is defined, and no claim rests on a catalog known to be out of date.** The map is checkable even when the mapping judgment isn't — and an unchecked map is how a report starts overstating without anyone deciding to overstate.

## Try it

```bash
quality-gate --check control-mapping
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
