---
layout: BlogPostLayout
tags: project, swift, basic, apple, interpreter, apple-ii
image:
imageDescription:
title: Happy Birthday, Apple
link: https://github.com/jpurnell/ApplesoftBASIC
date: 2026-04-01 12:00
lastModified: 2026-04-01
published: true
---

I first used an Apple IIe in an afterschool program when I was seven. I learned the rudiments of BASIC and wrote a bunch of spaghetti GOTOs. The computer sat in the library with a bright orange carpet, the monitor glowed green, and I was absolutely certain that I was a hacker.

I woke up this morning — April 1, 2026, Apple's 50th birthday — and thought it'd be nice to write a little "happy birthday" BASIC program and throw it up on social media. Quick, easy, fun.

```basic
10 REM *** HAPPY BIRTHDAY APPLE ***
20 PRINT "HAPPY BIRTHDAY TO YOU..."
30 PRINT "HAPPY BIRTHDAY TO YOU..."
40 PRINT "HAPPY BIRTHDAY DEAR APPLE..."
50 PRINT "HAPPY BIRTHDAY TO YOU!"
60 END
```

Then I wanted to verify that it worked. But I didn't want to do it with a GUI program — I needed to see it in green on black. So I got a little more ambitious, and decided I'd make a BASIC interpreter. In Swift. Apple's own language, running Apple's original language. As a birthday present.

## What I Built

[ApplesoftBASIC](https://github.com/jpurnell/ApplesoftBASIC) is a full Applesoft BASIC interpreter written in Swift 6. It runs `.bas` files from the command line and has an interactive REPL, just like the real thing. The architecture is a classic three-stage pipeline: a lexer tokenizes the source, a parser builds an abstract syntax tree, and an interpreter walks the tree and executes the program.

It supports the real Applesoft BASIC feature set:

- **PRINT**, **LET**, **GOTO**, **IF/THEN**, **FOR/NEXT** — the basics
- **GOSUB/RETURN** — subroutines
- **INPUT** and **GET** — user interaction
- **DATA/READ/RESTORE** — inline data tables
- **DIM** — arrays (1D and 2D)
- **ON...GOTO/GOSUB** — computed branching
- **AND/OR/NOT** — logical operators
- String functions: **LEFT$**, **RIGHT$**, **MID$**, **LEN**, **CHR$**, **ASC**, **STR$**, **VAL**
- Math: **SIN**, **COS**, **TAN**, **ATN**, **SQR**, **LOG**, **EXP**, **INT**, **ABS**, **SGN**, **RND**
- Screen: **HOME**, **HTAB/VTAB**, **TAB**, **SPC**
- **DEF FN** — user-defined functions

127 tests. Zero warnings. No force unwraps. I followed my own [development guidelines](https://justinpurnell.com/projects/development-guidelines) — Design-First TDD, the whole process. The irony of applying rigorous modern software engineering practices to a language famous for GOTO spaghetti is not lost on me.

## Steve Jobs' Horoscope

The best sample program isn't mine. In the summer of 1975 — a year before Apple existed — a twenty-year-old Steve Jobs was working at Atari and moonlighting under the name "All-One Farm Design." He wrote a program called Astrochart that computed planetary positions for astrological natal charts. He used the fraction 71/4068 as his degree-to-radian conversion factor because it could be computed with integer division. The program used the B1950 astronomical epoch and included a correction for lunar evection. Jobs' own birth data — February 24, 1955, 7:15 PM, San Francisco — was hardcoded as the default.


Earlier this year, [Adafruit recreated the program](https://blog.adafruit.com/2026/01/06/we-recreated-steve-jobss-1975-atari-horoscope-program-and-you-can-run-it/) from Jobs' original handwritten equations, which had been [auctioned at RR Auction](https://www.rrauction.com/auctions/lot-detail/347697406735003-steve-jobs-hand-annotated-atari-horoscope-program-archive/). Their recreation is 210 lines of Applesoft BASIC, and it runs on our interpreter:

```text
ASTROCHART RESULTS
DATE: 2/24/1955
TIME: 19:15
LAT:37.77 LONG:-122.42
BODY     LONG  SIGN DEG
ASC      162 VIR 12'1
MC       258 SAG 18'55
SUN     273  CAP 3'3
MOON    124  LEO 4'26
MERCURY 64   GEM 4'48
VENUS   111  CAN 21'6
MARS    167  VIR 17'50
JUPITER 12   ARI 12'51
SATURN  236  SCO 26'37
ERROR: +/- 2-3 DEG
'BECAUSE IT IS.' -1975
```

Steve Jobs' 1975 Atari program, running in a Swift interpreter, on Apple's 50th birthday. That feels right.

## The Other Samples

I wrote four more programs to exercise the full feature set:

**Guess the Number** — the classic. RND picks a secret number, you try to find it in seven guesses or fewer. Every kid who ever touched a BASIC prompt wrote some version of this.

**Fibonacci & Primes** — the math nerd's hello world. Computes the Fibonacci sequence, approximates the golden ratio, finds all primes under 100 using trial division, and prints a table of trig functions.

**Sine Wave Art** — ASCII graphics. A scrolling sine wave, a dual-wave interference pattern (you can see them cross), and a bar chart of hypothetical Apple sales in 1977.

**Cupertino Quest** — a text adventure. The year is 1976. You're in a garage in Los Altos. Your mission: collect a circuit board, a 6502 processor, a power supply, a keyboard, and a BASIC ROM (from Woz at the Homebrew Computer Club) to build the Apple I. Five rooms, five items, GOSUB-driven room dispatch. It's no Zork, but it has heart.

## For My Kid

The project includes a [tutorial](https://github.com/jpurnell/ApplesoftBASIC) — ten lessons, starting from PRINT and working up through variables, loops, IF/THEN, GOSUB, and finally a complete number guessing game. I wrote it for my seven-year-old. The same age I was when I sat down at that Apple IIe.

The last line of the tutorial reads: "The language you're learning is the same one millions of kids learned on Apple II computers in schools all across America in the 1980s. Your dad was one of them!"

## Try It

```bash
git clone https://github.com/jpurnell/ApplesoftBASIC.git
cd ApplesoftBASIC
swift run applesoft birthday.bas
swift run applesoft samples/astrochart.bas
swift run applesoft
```

I recommend using the [Apple II font](https://www.kreativekorp.com/software/fonts/apple2/) to keep it real.

Happy birthday, Apple. Here's to the next fifty.
