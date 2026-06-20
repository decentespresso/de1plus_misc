#!/bin/bash
# de1app-on-iOS app icon — thin wrapper that delegates to the iwish submodule's
# generic icon pipeline (iwish/scripts/build-icon.sh: source image -> opaque 1024
# -> actool -> Assets.car + AppIcon*.png). de1app keeps ONLY its icon config (the
# source image), not a copy of the pipeline.
#
#   usage: build-icon.sh [source-image] [app.app]
#     source-image  default /d/img/de1plus_white.jpg
#                   (other candidates: /d/img/de1plus.ico[4] = 256x256;
#                    de1_plus_app_icon.psd = 96x96)
#     app.app       optional; if given, the icon is installed into that bundle
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${1:-/d/img/de1plus_white.jpg}"
exec bash "$HERE/iwish/scripts/build-icon.sh" "$SRC" "${2:-}"
