---
layout: BlogPostLayout
series: quality-gate
title: "MCPReadinessAuditor: When the Tool Schema and the Code Disagree"
tags: quality-gate, specialty, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-09-04 09:00
lastModified: 2026-09-04
published: true
---

# MCPReadinessAuditor

**Model Context Protocol servers describe their tools in a schema and implement them in code. When the two drift apart, the model calls a tool that isn't there.**

---

An MCP server exposes tools to a language model: each tool has a declared schema — its name, its parameters, their types — and a corresponding implementation. The schema is a contract the model reads. If the schema advertises a parameter the implementation doesn't handle, or the implementation expects an argument the schema never declares, the model calls the tool the way the schema promised and the call fails in a way that's maddening to debug, because the *description* and the *behavior* disagree.

`MCPReadinessAuditor` cross-references the tool schema against the implementation and flags the mismatches:

- A schema parameter with no corresponding handling in the implementation
- An implementation reading an argument the schema never declares
- Type mismatches between the declared schema and the code that consumes it

## Why a checker for this

As more of a codebase exists to be *called by a model* rather than by a human, the schema-implementation contract becomes load-bearing — and it's exactly the kind of thing that drifts silently, because nothing forces the two to stay in sync. A human reviewer reads the schema or the code, rarely both side by side. The auditor reads both, every commit, and flags the moment they diverge — before a model discovers the gap the hard way. It's a small, forward-looking checker for a workflow that's increasingly common.

## Try it

```bash
quality-gate --check mcp-readiness
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
