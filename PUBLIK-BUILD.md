# publik build of BetterCast

This repository is a fork of [StephenLovino/BetterCast](https://github.com/StephenLovino/BetterCast).
publik (https://publikhq.com) makes the build that this fork releases.
**publik signs this build. The author of BetterCast does not make it and does not sign it.**

Date of the changes: 2026-11-06 (`v24-publik.1`) and 2026-11-11 (`v24-publik.2`).

## What this fork changes

The base is the upstream tag `v24` (commit `768de0c01575ad56435ddec911f597a955fe6bbc`).
The app version (24.0, build 24) and the bundle identifier (`com.bettercast.sender`) are the same as upstream.

1. **Sign in with publik.** The Mac app opens with "Sign in with publik". The BetterCast window shows
   this screen first. "Welcome to BetterCast" (the Screen Recording and Accessibility steps) and the
   main window come only after you sign in. Click **Sign in with publik**: the sign-in page opens in
   your browser, and the app continues when you are signed in. If publik is not reachable, the app
   says so and shows **Retry**. BetterCast does not use AI and does not use the publik API, so there
   is no plan screen and no key step.
   - Code: `Sources/BetterCastSender/Publik.swift` is the publik module
     (https://publikhq.com/sdk/publik.swift.md) with three values set (`appSlug = "bettercast"`,
     `appVersion = "24.0"`, `usesAI = false`) and one addition: it also reads the app token from the
     Info.plist key `PublikAppToken`. `Sources/BetterCastSender/PublikGate.swift` draws the screens in
     the BetterCast window. `BetterCastSenderApp.init` starts the gate before any window opens.
   - To sign in, the app registers this Mac with publik one time (`POST /api/v1/installs`). That
     request holds the publik app token of this build, the app name and version, the operating
     system, the CPU type, a random install ID and the name of this Mac (System Settings > General >
     Sharing). publik answers with an install key. The app keeps the key in
     `~/Library/Application Support/publik/apps/bettercast.json` (mode 0600). Then the app asks
     `GET /api/v1/wallet` whether this install is signed in.
2. **Usage counts.** After the sign-in, the same module sends two events to
   `https://publikhq.com/api/v1/telemetry`: `app_opened` (one for each launch) and `active_session`
   (every 30 minutes while the app runs). An event holds the app name, the app version, the operating
   system, the CPU type and a random install ID (`~/Library/Application Support/publik/telemetry.json`),
   and it carries the install key, so publik counts the user by publik account. It holds no screen
   content, no sound and no device names. The module replaces the telemetry v1 client of
   `v24-publik.1` (`PublikTelemetry.swift` is removed); the app has one publik client.
3. **One sentence in the donation prompt.** The upstream text says that BetterCast "does not track you".
   With usage counts, that is not correct for this build. The fork removes those words from the
   English text and from the 5 translations. The rest of the prompt and the donation link of the
   author are not changed.
4. **Build.** `.github/workflows/publik-build.yml` compiles the Mac app on GitHub Actions. It writes
   the publik app token (the repository secret `PUBLIK_APP_TOKEN`) into the Info.plist of the app with
   `scripts/publik-app-token.sh`; `make_app.sh` does the same when `PUBLIK_APP_TOKEN` is set. The token
   is not in the source. The workflow then runs the built app against a fake publik on the build
   computer: the self-test (`PUBLIK_SELF_TEST=1`, for arm64 and x86_64), the gate, the usage counts
   and the opt-out. It does not sign and it does not publish.
5. **Documents.** `README.md` has a section "Sign in with publik and usage counts (publik build)".
   `.github/SECURITY.md` has one sentence about this build. This file is new.

Nothing else is changed. The receivers for iOS, Android, Windows and Linux are not built from this fork.
They have no sign-in and no usage counts.

## How to turn the usage counts off

One of these is sufficient:

- `DO_NOT_TRACK=1` in the environment of the app (for example `launchctl setenv DO_NOT_TRACK 1`, then
  start the app again).
- `PUBLIK_TELEMETRY=0` in the environment of the app.
- `{"usage": false}` in `~/Library/Application Support/publik/consent.json`.

The opt-out stops the usage counts only. The app still opens with Sign in with publik.

Details: https://publikhq.com/skills/telemetry.md

## Self-test

`PUBLIK_SELF_TEST=1 /Applications/BetterCast.app/Contents/MacOS/BetterCastSender` registers the
install, asks `GET /api/v1/wallet`, prints `publik self-test: ok bettercast 24.0` and exits. No window
opens. It sends no usage count.

## Signature

The Mac app and the disk image of this build are signed and notarized with the Developer ID of publik:
`Developer ID Application: Mann Bellani (R5R3ZS54LV)`. The upstream build is signed by its author
(team `TQ8F92XYBL`). macOS ties the Screen Recording, Accessibility, Camera and Microphone permissions
to the signer. If you change from one build to the other, macOS asks for these permissions again.

## Updates

The in-app updater (Sparkle) is not changed. It reads the update feed of the upstream author, and the
author signs each update. When upstream releases a version after v24, the updater installs the build of
the author. That build has no Sign in with publik and no usage counts, and the author signs it.

## Source and license

BetterCast is licensed under the GNU General Public License v3.0 (see [LICENSE](LICENSE)). This fork has
the same license. The complete source of this build is in this fork:
https://github.com/Blueturboguy07/BetterCast (branch `main`, release tag `v24-publik.2`).
The source of `v24-publik.1` is the tag `v24-publik.1` (branch `telemetry/v1`).

Upstream: https://github.com/StephenLovino/BetterCast
