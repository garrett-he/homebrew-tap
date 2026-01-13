---
name: homebrew-cookbook
description: Create, debug, validate, and submit Homebrew packaging scripts — formulae (Ruby .rb definitions that build software from source) and casks (Ruby .rb definitions that install prebuilt macOS apps, .pkg installers, and binaries) — in personal taps, homebrew-core, or homebrew-cask. Use when asked to write or fix a formula or cask, decide between the two, add software to a Homebrew tap, fix a failing brew install or audit, compute a release artifact checksum, generate a zap stanza, or bottle and publish a formula.
agent_created: true
---

# Homebrew Cookbook

## Overview

Homebrew packages are Ruby `.rb` definitions of two kinds:

- **Formula** — builds from source; for CLI tools and libraries.
- **Cask** — installs prebuilt artifacts; for `.app` bundles, `.pkg` installers, fonts, plugins, and standalone binaries.

This skill is an entry point. Decide which kind applies, then read only that workflow and follow its references. Do not load both workflows unless the task genuinely spans both.

## Decision tree (read first)

1. Is the deliverable a native macOS `.app`, a `.dmg`/`.pkg`, proprietary or binary-only software, or a self-updating distribution? → **Cask**. Read `references/cask-workflow.md`.
2. Is the software open source and distributed as source (or a CLI tool that can be built from source)? → **Formula**. Read `references/formula-workflow.md`.
3. Is the target a personal/team tap (for example `garrett-he/tap`)? → Either kind is allowed; apply rule 1 or 2 to choose, then pass `--tap=<user>/<repo>` to `brew create`.
4. Is the target `homebrew/core` or `homebrew/cask`? → Same choice by rule 1 or 2, then confirm the software meets the acceptance rules in `references/taps-and-ci.md` before proceeding.
5. Still unsure after reading both one-line definitions above? → Read the "Where to publish" table in `references/taps-and-ci.md`.

## Routing

| Task | Read |
|---|---|
| Write/fix a cask; GUI app, `.pkg`, prebuilt binary, zap, auto_updates, cask audit | `references/cask-workflow.md` |
| Write/fix a formula; source build, dependencies, `test do`, bottles, formula audit | `references/formula-workflow.md` |
| Choose a destination; tap layout, CI, autobump, commit/PR conventions | `references/taps-and-ci.md` |

## Shared resources

- `references/taps-and-ci.md` — destination rules, tap layout, CI, autobump, commit/PR conventions.
- `scripts/sha256_of_url.sh <url>` — download any URL and print a `sha256 "…"` line.
