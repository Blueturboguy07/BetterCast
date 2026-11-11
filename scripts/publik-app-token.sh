#!/bin/bash
# publik build (see PUBLIK-BUILD.md): writes the publik app token into the Info.plist of the
# assembled BetterCast.app, as the key PublikAppToken. Publik.swift reads it at the
# Sign in with publik gate.
#
# usage: scripts/publik-app-token.sh <path to BetterCast.app/Contents/Info.plist>
#
# The token comes from the environment variable PUBLIK_APP_TOKEN (in CI: the repository secret
# of the same name). The script never prints it and never writes it to any other file.
# Without the variable it writes nothing: that build cannot sign in with publik, and the gate
# says "This build has no publik app token."
set -euo pipefail
PLIST="${1:?usage: scripts/publik-app-token.sh <path to Info.plist>}"
if [ -z "${PUBLIK_APP_TOKEN:-}" ]; then
  echo "publik app token: none (PUBLIK_APP_TOKEN is not set). This build cannot sign in with publik." >&2
  exit 0
fi
python3 -I - "$PLIST" <<'PY'
import os, plistlib, sys
path = sys.argv[1]
token = os.environ.get("PUBLIK_APP_TOKEN", "").strip()
if not token.startswith("pat_"):
    sys.exit("publik app token: the value of PUBLIK_APP_TOKEN is not an app token; nothing written")
with open(path, "rb") as f:
    info = plistlib.load(f)
info["PublikAppToken"] = token
with open(path, "wb") as f:
    plistlib.dump(info, f, sort_keys=False)
print("publik app token: written to Info.plist (key PublikAppToken)")
PY
