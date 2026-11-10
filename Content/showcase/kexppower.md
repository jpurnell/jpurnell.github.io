---
title: Spinner: I Power KEXP 90.3 FM, Everywhere
description: A personal Apple-platform listener for KEXP 90.3 FM, built around how I find music: the live playlist first, then everywhere I go, from iPhone and Apple Watch to the car, with Siri and Shortcuts.
date: 2026-11-10 15:37
lastModified: 2026-11-10
tags: showcase, project, kexppower, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: KEXPPower
published: true
settled: true
---

# Spinner: I Power KEXP 90.3 FM, Everywhere

> A personal Apple-platform listener for KEXP 90.3 FM, built around how I find music: the live playlist first, then everywhere I go, from iPhone and Apple Watch to the car, with Siri and Shortcuts.

## Motivation

I am a long-time and dedicated listener to Seattle's KEXP 90.3 FM. The DJs have broad an excellent taste, and it's where I find a great deal of my music. I wanted a way to listen that fits how I do it: see what is playing right now, hear it, keep the songs I want, and have all of that come with me, from the phone in my pocket to my wrist, my Mac, the living-room TV, the car, and, if I had one, the headset.

Spinner is that app. It starts from the live playlist and the song on now, then adds what I reach for: one-tap saving to a dedicated Apple Music playlist, a jump to the song in Apple Music, and playback from any point in KEXP's archive. It also answers when I ask. Through App Intents and Shortcuts I can ask what is playing, play live, pause, go back to live, rewind, add this song to my playlist (from the lock screen too, though not on the Mac), or play an archived show by name or date.

It is a personal project and open source, and it stands on other people's work. I built and review it to public-release standard, with privacy-first (anonymous) diagnostics data and a rigorous platform-by-platform testing approach.

## Approach

The app is native Swift, with one playback layer shared by every platform: iPhone, iPad, Mac, Apple Watch, Apple TV, Apple Vision Pro and CarPlay, including a CarPlay Archive tab. Siri, Shortcuts, widgets and Control Center all reach that same layer, so live, rewind and archive playback behave the same whichever way I start them.

The library underneath is the open-source KEXPPower package that also powers KEXP's own tvOS app. The repository's history begins in June 2019 with Dustin Bergman's commits; the tags `0.1.0` through `2.0.0` are his and `3.0.0` is Jay Kardong's. My commits begin in March 2022, and the recent 3.x releases are mine. I work from an in-repo fork of that library, port the upstream changes worth having by hand, and send nothing back to the package behind KEXP's app.

## Results

The history holds 309 commits from five people, across 25 tagged releases, the latest being `3.5.1`. The commit count by name would say eight, but several people appear under two spellings. Because the version numbers continue the library's timeline, the 3.x series is where my own work begins.

The app runs on iPhone, iPad, Mac, Apple Watch, Apple TV, Apple Vision Pro and CarPlay. The Siri and Shortcuts phrases above were the most recent addition.

## Decisions

**The live playlist is the first screen.** It is what I want in front of me when I listen, and the rest of the app follows from it.

**One playback layer for every platform.** The Watch, the TV and the car inherit archive and rewind from the same code instead of each getting their own player. The price is an abstraction that has to satisfy every platform's constraints at once.

**An in-repo fork instead of upstream pull requests.** Keeping the library in the repository lets me move at my own pace, at the cost of porting upstream changes by hand.

**Voice and automation as part of the design.** I wanted the app to be usable without looking at it, so Siri and Shortcuts reach the same playback layer as the screens.

## Where it stands

The tvOS target is new, built on 8 November 2026, and the Siri and Shortcuts surface arrived the day after. Both are young next to the rest of the app.
