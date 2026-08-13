#!/bin/sh
# publish-latest.sh -- upload built release asset(s) to the SINGLE rolling
# GitHub "latest" release of decentespresso/de1app (tag `latest`), replacing any
# existing asset of the same name.
#
# WHY one shared release: GitHub's stable URL
#   https://github.com/decentespresso/de1app/releases/latest/download/<file>
# always serves <file> from the ONE release GitHub marks "Latest" -- there is
# exactly one per repo. So every platform (Android apk, Linux AppImages, ...)
# publishes its current build INTO this release, each with a STABLE filename.
# The website links straight at those /releases/latest/download/ URLs, so they
# never change from release to release. (This replaces the old per-platform
# `android-latest` / `linux-latest` tag technique.)
#
# The asset is uploaded under its filename as-is, so name the file exactly what
# the download URL should be, e.g.:
#   de1app.apk               -> releases/latest/download/de1app.apk
#   Decent-x86_64.AppImage   -> releases/latest/download/Decent-x86_64.AppImage
#   Decent-aarch64.AppImage  -> releases/latest/download/Decent-aarch64.AppImage
#
# Usage:  sh publish-latest.sh <file> [file...]
# Requires: gh authenticated with write access to decentespresso/de1app.
set -e
REPO=decentespresso/de1app
TAG=latest

[ $# -ge 1 ] || { echo "usage: publish-latest.sh <file> [file...]" >&2; exit 1; }
for f; do [ -f "$f" ] || { echo "no such file: $f" >&2; exit 1; }; done

# Ensure the rolling release exists (first run creates it, marked as Latest).
if ! gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
    gh release create "$TAG" --repo "$REPO" \
        --title "de1app -- latest builds (all platforms)" \
        --notes "Current Decent de1app builds. Stable download URLs: /releases/latest/download/<file>." \
        --latest
fi

gh release upload "$TAG" "$@" --repo "$REPO" --clobber
echo "published to https://github.com/$REPO/releases/latest :"
for f; do echo "  https://github.com/$REPO/releases/latest/download/$(basename "$f")"; done
