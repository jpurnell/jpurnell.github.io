---
layout: BlogPostLayout
series: quality-gate
title: "DocRunAuditor: Compiling Isn't Running"
tags: quality-gate, documentation, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-13 09:03
lastModified: 2026-08-13
published: true
---

# DocRunAuditor

**An example that typechecks and then traps on line two is still a broken example. Rung 2 runs it.**

---

Rung 1 proves the types line up. It says nothing about what happens when someone actually executes the thing.

The gap is not exotic. A sample that force-unwraps an optional the API stopped guaranteeing, an index into an array the example didn't populate, a division by a value that's zero in the documented case — all compile perfectly, all fail on the first run, and all sit in documentation looking authoritative until a reader tries them.

`doc-run` executes the article top to bottom and reports the trap.

## A stronger convention than rung 1 asks for

This is worth being blunt about, because it's why the checker is opt-in and stays opt-in.

Rung 1 asks an article to be one *compilable* program. Rung 2 asks it to be one *runnable* program — top to bottom, no traps, side effects and all. That's a second convention, and a catalog that has adopted the first has not thereby adopted the second. It arrives red for anyone who hasn't, and the red is legitimate: those examples genuinely don't run.

The path to green is repairing the documentation, never relaxing the rule. That's the same path `doc-code` walked before it was promoted to run by default — and the bar was met rather than lowered.

## Why running is harder than compiling

Three things make execution a different problem:

**It has to terminate.** A documented example containing a `while` loop over user input, or an animation loop, will happily run forever. Execution is bounded, and a timeout is reported as a finding rather than hanging the gate.

**Side effects are real.** A rung-1 typecheck touches nothing. Running an example that writes a file, opens a socket, or shells out actually does those things. The article is executed in its own working directory for exactly this reason.

**Output becomes evidence.** Once you're running the program, you have its stdout — which is the raw material rung 3 needs, and the reason these two checkers are siblings rather than one checker with a flag.

## What it deliberately doesn't do

It doesn't check what the program *printed*. An article that runs cleanly and prints `0.847` where the prose promised `0.9` passes rung 2 and fails rung 3, and keeping those separate is what lets a project adopt one without the other.

## Try it

```bash
quality-gate --check doc-run
```

Opt-in. If your catalog has just reached green on `doc-code`, expect this one to have opinions — and treat the arrival as remediation work rather than a reason to switch it off.

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
