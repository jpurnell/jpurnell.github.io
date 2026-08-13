---
layout: BlogPostLayout
series: quality-gate
title: "The Trust Service: Who Gets to Write the Memory"
tags: quality-gate, mirror, swift
link: https://github.com/jpurnell/org-judgement-system
date: 2026-07-31 09:16
lastModified: 2026-08-13
published: true
---

# The Trust Service

**Institutional memory is only worth trusting if you know who wrote each entry — and if the high-stakes ones required more than one person to agree.**

---

The [corpus](/QualityGate/mirror/the-corpus) is single-writer for a reason: hand-edited memory drifts from the schema and loses its provenance. But "single-writer" raises a question — *which* writer, and how do you know? The Trust Service answers it, and it's built demand-first: every piece improves the solo experience and costs nothing until a second writer actually appears.

## Verified identity

A `TokenStore` issues random bearer tokens (shown once at issuance, stored SHA-256-hashed) so a CI writer can prove who it is. An `IdentityEnvelope` binds a verified token to a CI identity to the claims it's asserting. So a corpus entry isn't just "someone wrote this" — it's "this verified actor wrote this, asserting these things," recorded. That's the provenance the whole system rests on.

## Getting in sync

For high-stakes writes, one person agreeing isn't enough. A `ReviewPolicy` (glob-matched rules) can require a second reviewer, and the `ReviewQueue` enforces it: a governed override holds as `pending-review`, and approving or rejecting it requires a **distinct second identity** — the submitter approving their own override is a *typed error*, not a policy someone might forget. Where a policy is absent, the behavior is exactly today's solo experience; the machinery only engages when the stakes call for it.

This is Bridgewater's "getting in sync" as code: a disagreement, or a consequential call, is resolved through a defined process with named participants — not by whoever has commit access and a deadline.

## Held, never lost

A governed write that goes to review persists its artifact byte-faithful in a spool until the review is decided. Approval applies the *original* operation; rejection discards it; and a spool failure downgrades a hold to a rejection — because accepting a write we couldn't preserve would be worse than refusing it. "Held, never lost" is a claim about the artifact, not just the record.

## The tripwire

A `WriterCensus` watches for the moment the organization stops being one person: two distinct verified persons writing within 30 days trips a standing "second-writer" warning in every gate run. The controls above don't force themselves on a solo developer — they *arrive* exactly when a team does. The system grows the governance it needs, when it needs it, and not before.

---

**Source:** [github.com/jpurnell/org-judgement-system](https://github.com/jpurnell/org-judgement-system)
