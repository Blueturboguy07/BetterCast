# publik build of BetterCast

This repository is a fork of [StephenLovino/BetterCast](https://github.com/StephenLovino/BetterCast).
publik (https://publikhq.com) makes the build that this fork releases.
**publik signs this build. The author of BetterCast does not make it and does not sign it.**

Date of the changes: 2026-11-06.

## What this fork changes

The base is the upstream tag `v24` (commit `768de0c01575ad56435ddec911f597a955fe6bbc`).
The app version (24.0, build 24) and the bundle identifier (`com.bettercast.sender`) are the same as upstream.

1. **Usage telemetry v1.** `Sources/BetterCastSender/PublikTelemetry.swift` is the publik reference client, not changed.
   `BetterCastSenderApp.init` calls it one time. The Mac app then sends two events to
   `https://publikhq.com/api/v1/telemetry`: `app_opened` (one for each launch) and `active_session`
   (every 30 minutes while the app runs). An event holds the app name, the app version, the operating
   system, the CPU type and a random install ID. It holds no screen content, no sound and no device names.
   If this computer has a publik API key for BetterCast (`PUBLIK_API_KEY` or
   `~/Library/Application Support/publik/apps/bettercast.json`), the event also carries that key and
   publik counts the user by publik account. BetterCast itself does not use the publik API.
2. **One sentence in the donation prompt.** The upstream text says that BetterCast "does not track you".
   With usage counts, that is not correct for this build. The fork removes those words from the
   English text and from the 5 translations. The rest of the prompt and the donation link of the
   author are not changed.
3. **Build workflow.** `.github/workflows/publik-build.yml` compiles the Mac app on GitHub Actions.
   It does not sign and it does not publish.
4. **Documents.** `README.md` has a new section "Usage counts (publik build)". This file is new.

Nothing else is changed. The receivers for iOS, Android, Windows and Linux are not built from this fork
and have no usage counts.

## How to turn the usage counts off

One of these is sufficient:

- `DO_NOT_TRACK=1` in the environment of the app (for example `launchctl setenv DO_NOT_TRACK 1`, then
  start the app again).
- `PUBLIK_TELEMETRY=0` in the environment of the app.
- `{"usage": false}` in `~/Library/Application Support/publik/consent.json`.

Details: https://publikhq.com/skills/telemetry.md

## Signature

The Mac app and the disk image of this build are signed and notarized with the Developer ID of publik:
`Developer ID Application: Mann Bellani (R5R3ZS54LV)`. The upstream build is signed by its author
(team `TQ8F92XYBL`). macOS ties the Screen Recording, Accessibility, Camera and Microphone permissions
to the signer. If you change from one build to the other, macOS asks for these permissions again.

## Updates

The in-app updater (Sparkle) is not changed. It reads the update feed of the upstream author, and the
author signs each update. When upstream releases a version after v24, the updater installs the build of
the author. That build has no publik usage counts and the author signs it.

## Source and license

BetterCast is licensed under the GNU General Public License v3.0 (see [LICENSE](LICENSE)). This fork has
the same license. The complete source of this build is in this fork:
https://github.com/Blueturboguy07/BetterCast (branch `telemetry/v1`, release tag `v24-publik.1`).

Upstream: https://github.com/StephenLovino/BetterCast
