---
layout: BlogPostLayout
series: quality-gate
title: "DocLinter: Catching DocC Errors Before They Break the Build"
tags: quality-gate, documentation, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:19
lastModified: 2026-08-13
published: true
---

# DocLinter

**Documentation that doesn't build is worse than none — it fails at the least convenient moment. This checker builds the DocC and fails at commit time instead.**

---

DocC is wonderful right up until a symbol link goes stale, a code fence is malformed, or a renamed type leaves a dangling reference. You usually find out when the documentation build breaks in CI, or when a reader clicks a link that goes nowhere. `DocLinter` moves that discovery to commit time: it builds the DocC and surfaces the errors as gate findings.

## What it catches

- Broken symbol links (a `` `SomeType` `` that no longer resolves)
- Malformed directives and code fences
- Dangling references after a rename or a move
- The structural problems that only appear when DocC actually compiles the catalog

Because it *builds* the documentation rather than pattern-matching it, the findings are DocC's own. There is no heuristic guessing at the format.

That sentence used to end differently, and the correction is the most useful thing in this post.

## Two ways a checker can lie to you

For most of its life this checker was wrong in two ways at once, and both were invisible because the output looked exactly like success.

**It examined one module out of a hundred and sixteen.** The command it ran was `swift package generate-documentation --target X`, where `X` was the first target of the first library product — or whatever `docTarget` named in the config. Every other module was never handed to DocC at all. So the green checkmark was not a claim about the package. It was a claim about 0.9% of it, and nothing in the output said so.

That is not degraded coverage. It is *absent* coverage, printed in the same shape as a clean run.

The fix was small — `--target` is repeatable, so full coverage costs one invocation rather than thirty-one. Pointed at every module owning a catalog, it went from 1 target to 31 and immediately surfaced **19 real defects** that had been sitting there: fifteen cross-module symbol references that DocC cannot resolve, three nested code spans it was reading as symbol links, and one parameter documented by its external label instead of its internal name.

**And it invented the addresses of what it did find.** Modern DocC puts the message on one line and the location on the next:

```
warning: Parameter 'seed' is missing documentation
   --> ../Portfolio/PortfolioUtilities.swift:103:54-103:54
```

The parser recognised two older shapes and neither of them was this one, so it dropped the location entirely — and then *recovered* it by collecting every function in the package with a parameter of that name and pairing them to the warnings **by position**. The first warning got the first match, the second the second, and so on, from two orderings that have nothing to do with each other.

With one such parameter in a package, that guess lands by luck. With eight, every guess missed. Three separate investigations went to files whose documentation was perfectly correct, and the natural reading of "the checker is flagging correct documentation" is *the checker is broken* — which was precisely backwards. The findings were right. Only the addresses were wrong.

A wrong location is not a milder version of a missing one. It spends your attention in the wrong place, and it does so most confidently when there are many candidates — which is exactly when your codebase is largest. The rule now is that ambiguity produces *no* location at all.

## The property worth stealing

Both bugs are the same bug wearing different clothes:

> **A checker that examined nothing must not print what a checker that found nothing prints.**

A sibling checker in the same suite, `doc-generated`, has reported its own coverage on every run since the day it was written — `regions: 10 found · 10 regenerated · 0 unknown` — pass or fail, including when the answer is zero. It has never had this class of failure, because the failure is unsayable in its output.

`doc-lint` now does the same: every run states how many targets it examined, and examining zero is an *error* rather than a pass. If your linter can't tell you what it looked at, you don't know what its silence means.

## A note on cross-module references

One hard-won detail worth passing on: in DocC, cross-module symbol references use *single* backticks, not double. Double backticks resolve against the symbol graph of the module being documented, and a type from another module simply isn't in it.

It's the kind of rule you learn once by breaking the build. Fifteen of the nineteen defects above were exactly this — including several in code written by someone who already knew the rule. That's the case for the checker in one line: knowing a rule and obeying it under deadline are different skills, and only one of them can be automated.

`doc-lint` is slower than most checkers, because it builds. Run it before a push rather than on every save. Right tool, right cadence.

## Try it

```bash
quality-gate --check doc-lint
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
