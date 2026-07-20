---
layout: BlogPostLayout
tags: project, operations, infrastructure, mcp, launchd, dns
image:
imageDescription:
title: The Server That Wasn't Listening
date: 2026-07-19 22:00
lastModified: 2026-07-19
published: true
---

# The Server That Wasn't Listening

**One MCP server dropped off the internet. The router was fine, the build was fine, the certs were fine — and the real fix was two layers deeper than the bug I set out to find.**

---

It started the way these things usually do — not with an alert, but with a sentence:

> "This doesn't seem to be deployed anymore — can you check what's going on?"

The thing in question was one of several small services I self-host: Swift tools I reach from Claude Code every day, each answering behind the same domain. One of them had simply stopped answering. The connection didn't time out or error — it was refused outright, the way a door is refused when there's no one behind it.

This is the story of finding out why, fixing it properly, and then realizing the bug I fixed wasn't the one that would bite me next.

## Ruling Out the Innocent

The instinct with a "not reachable" report is to start guessing. The discipline is to start eliminating. So I worked outside-in, and wrote down what each layer told me.

**The port.** From my laptop, the connection to the service was refused, but SSH to the box worked instantly. So: the host is up, the network path exists, and something specific to that one service is wrong.

**The neighbors.** On the server, `lsof -iTCP -sTCP:LISTEN` showed every *other* self-hosted service present and accounted for, and nothing at all on the port I cared about. So this wasn't a machine-wide failure. The siblings were happily listening. One was simply absent.

**The router.** The port-forward to the server was in place and correct. Ruled out.

**The build.** The binary existed on the server, freshly compiled. It ran. `--help` worked. Ruled out.

**The certificates.** TLS cert and key were present in the expected directory, valid and unexpired. Ruled out.

Every obvious suspect had an alibi. The router forwarded the port to a server that wasn't listening on it. The binary was built but not running. The certs were provisioned for a service that didn't exist.

That pattern — everything *around* the service is correct, but the service itself isn't there — points at exactly one thing.

## The Actual Cause

There was no `launchd` service.

Every other service on the box had a `LaunchAgent` plist: a small XML file that tells the system "run this program, keep it alive, restart it on failure, start it at boot." This one had a built binary, valid certs, a working port-forward, and *no plist*. It had been compiled and half-provisioned, and then the one step that actually starts a service — and keeps it started — was never done.

So nothing ever launched it. Nothing restarted it. A reboot, a crash, a stray `kill` — any of them would have left exactly this state, and it would have stayed that way silently forever, because "silently forever" is precisely what a missing service does.

The fix itself took a minute: write the plist, `launchctl bootstrap` it, watch the port come alive. From outside the network, an unauthenticated request now returned `HTTP 401` — which is the *healthy* answer. It means the server is up and enforcing auth, refusing to talk to a stranger. Connection-refused had become access-denied. That's the sound of a working service.

## Fixing It So It Stays Fixed

A one-off `launchctl` incantation typed over SSH is not a fix. It's the same fragility that caused the outage, wearing a different hat: undocumented state that lives only in one person's shell history. If the box gets rebuilt, or I forget the exact flags, I'm right back here.

So the real fix was to make the deployment *reproducible*. I added a small `deploy/` directory to the project:

- A **plist template** with placeholders, checked into the repo as the source of truth — no more hand-edited service files.
- A single **`deploy.sh`** that is idempotent by design: it builds the release binary, renders the template, reloads the service, and then *verifies* — it waits for the port to listen and probes the HTTPS endpoint, refusing to declare success until it actually sees the service answer.
- **`uninstall.sh`** and **`status.sh`** for clean rollback and health checks.
- A README documenting the whole topology so the next deploy is `git pull && ./deploy/deploy.sh`, not an archaeology expedition.

Then I re-ran it end-to-end and confirmed the running service was now the one rendered from the committed template, byte-for-byte. The gap that caused the outage — deployment as an oral tradition — was closed.

I could have stopped there. The ticket was, technically, resolved. But the diagnosis had surfaced something more uncomfortable than a missing plist.

## The Bug Under the Bug

Here's the thing about the machine: it sits on a connection with a **dynamic public IP** — the kind an ISP can change out from under you after an outage, a modem reboot, a lease expiry, a bad night. The address is not guaranteed to stay put. And the domain's DNS points an `A` record at whatever that public IP currently is.

Follow that thread and the failure mode is obvious and ugly: **the day the IP changes, the DNS record goes stale, and every service behind that domain — not just the one — falls off the internet at once.** No crash. No error. No log line. The processes keep running perfectly, listening on their ports, serving no one, because the name that points to them now points somewhere else.

A flawless, reproducible deployment does not survive this. `KeepAlive` doesn't survive it. It's not a *service* failure at all — it's a *naming* failure one layer down, and it would look, from my laptop, exactly like the outage I'd just fixed. I'd go hunting for a dead service and find a set of perfectly healthy ones behind a dead address.

What we'd actually lost, during the window this all started in, was simply *knowing the correct public IP*. That's a data problem. And data problems have clean solutions.

## The Safety Net

So I built a second, tiny project — deliberately separate, because this is host infrastructure that serves every service on the box, not any one app. It does three things.

**1. It never loses the IP again.** A `launchd` job runs every fifteen minutes, detects the machine's true public IP (via consensus across a few independent providers, so one flaky endpoint can't lie to it), and writes it to a file in iCloud Drive:

```
current-ip.txt   →  the current public IP, one line, glanceable from any device
status.json      →  { wan_ip, dns_ip, in_sync, checked_at, changed_at }
changes.log      →  append-only history of every change
DRIFT.flag       →  present only while DNS is stale, with the fix command inside
```

Because it's in iCloud, the correct address is on my phone, my laptop, every device I own — *especially* useful mid-outage, when the box itself might be the thing I can't reach. The writes are atomic (write to a temp file, then rename) so iCloud never syncs a half-written file. Losing track of the IP is now structurally impossible.

**2. It detects drift.** Every run compares the live DNS `A` record against the real public IP. When they diverge, it says so — in the log, in the status file, and by dropping that `DRIFT.flag` where I'll see it.

**3. It can re-attach the name to the address.** A `reattach-dns.sh` script updates the Google Cloud DNS record to point back at the current IP. Wire it to the drift detector and you have full dynamic-DNS: the moment the IP moves, the name follows it, automatically, within minutes.

That last piece ships **disabled**, on purpose. Automatically rewriting production DNS is exactly the kind of power you want to arm deliberately, not by default. Until it's configured with real credentials, the re-attach script is *inert and fail-safe*: run it and it tells you precisely what's missing and exits without touching anything. Turning on true auto-repair is a one-line change once the credentials are in place — and there's a runbook for it. A safety net you can inspect before you trust it.

One small, satisfying detail: the current DNS record had a one-hour TTL. The re-attach writes it back at five minutes, so the *next* time the IP moves, recovery propagates in minutes instead of an hour. The tool doesn't just fix the drift; it shortens the blast radius of the next one.

## Two Details Worth Keeping

A couple of things from this that I'll carry forward:

**"Healthy" is not "silent."** The most dangerous failures in this whole exercise made *no noise*. A missing service logs nothing. A stale DNS record logs nothing. The processes are fine; the absence is the bug. Any monitoring worth having has to assert presence — "the thing I expect is here and answering" — not merely watch for errors, because the errors never come. That's why the deploy script probes the endpoint and the monitor asserts `in_sync`, rather than either of them waiting for something to complain.

**The box couldn't see itself.** When I had the server curl its own public hostname to health-check, it failed — because the router doesn't hairpin traffic back to its own WAN address. The service was completely healthy; the *self-test* was wrong. It's a good reminder that where you observe from changes what's true, and that a external-facing service has to be verified from somewhere external. The real confirmation always came from my laptop, off the LAN.

## The Lesson

I was asked to fix a server that wasn't listening. The listening was the easy part — a missing plist, a one-minute repair. The work that mattered was the two questions the outage *implied* but didn't ask:

*Why did this state even exist?* Because the deployment lived in my memory instead of in the repo. Fixed by making it reproducible.

*What would take everything down next?* A residential IP with no memory of itself and no way to reattach its own name. Fixed by giving it both.

The bug you're handed is rarely the most expensive bug in the building. It's just the one that happened to page you. The discipline is to fix the thing you were asked about — and then to keep pulling the thread until you find the thing that was actually going to hurt.

---

**Justin Purnell** builds Swift tooling and AI-augmented operational infrastructure. He writes about the systems he runs, the outages he causes, and the ones he prevents.
