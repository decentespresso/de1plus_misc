#!/bin/sh
# Stage an OFFLINE-usable de1plus seed into the AndroWish app-bundle convention
# (assets/app/) for the self-contained de1app.apk. Mirrors the OSX minimal-seed
# logic in make_osx_universal_signed.sh, but keeps enough to boot WITHOUT a
# network self-update (sideload.flag, not google_play.flag).
set -e

SRC_DE1PLUS="${SRC_DE1PLUS:-/d/admin/code/de1app/de1plus}"
DST="${DST:-$HOME/de1app-android}"
APPDIR="$DST/assets/app"
SEED="$APPDIR/de1plus"

# POPULAR-SKINS seed (John 2026-07-10): ship only the "most popular skins"
# (machine.tcl:439 most_popular_skins = Insight MimojaCafe Metric DSx SWDark4 DSx2
# MiniMetric) + the "default" fallback image dir (dui uses it, dui.tcl:362), at the
# 2560x1600 rescale base only (dui rescales to any display), plus ALL fonts -- so the
# common skins work fully OFFLINE with no first-run download. All other (decorative)
# skins self-update on demand when picked. Keep this list in sync with machine.tcl:439.
#   SEED_SKINS=ALL      -> keep every skin (else a |-list of skin names)
#   SEED_SKIN_RES       -> |-list of resolution subdirs to keep
#   SEED_FONTS=ALL      -> keep every font (else a |-list of font filenames)
SEED_SKINS="${SEED_SKINS:-default|Insight|MimojaCafe|Metric|DSx|SWDark4|DSx2|MiniMetric}"
SEED_SKIN_RES="${SEED_SKIN_RES:-2560x1600}"
SEED_FONTS="${SEED_FONTS:-ALL}"

echo "Staging de1plus MINIMAL seed -> $SEED"
rm -rf "$APPDIR"
mkdir -p "$SEED"
# Copy code + small runtime data; drop user data + heavy non-boot dirs (the
# in-app updater fetches the rest later).
rsync -aL \
    --exclude 'CVS' --exclude '.git' --exclude '.gitignore' --exclude '.DS_Store' \
    --exclude 'history' --exclude 'history_v2' --exclude 'historybk' \
    --exclude 'history2' --exclude 'history3' --exclude 'history_v2b' \
    --exclude 'history_fake' \
    --exclude 'apk' --exclude 'doc' --exclude 'saver' --exclude 'builds' \
    --exclude 'shothistory.zip' \
    --exclude 'tmp' --exclude 'log.txt' --exclude 'log2.txt' --exclude '*.log' \
    "$SRC_DE1PLUS/" "$SEED/"

# Prune skins: keep the seed set, trim each to the two seed resolutions.
if [ -d "$SEED/skins" ]; then
    pruned=0; trimmed=0
    for d in "$SEED/skins"/*/; do
        name="$(basename "$d")"
        keep=0
        if [ "$SEED_SKINS" = "ALL" ]; then
            keep=1
        else
            # Case-INSENSITIVE match: some skin dirs are stored lowercase on disk
            # (e.g. the "metric" submodule) while the list / app use title case
            # (the app itself matches with `string toupper`, vars.tcl). A case-
            # sensitive compare silently dropped Metric.
            _lname=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')
            _llist=$(printf '%s' "$SEED_SKINS" | tr '[:upper:]' '[:lower:]')
            case "|$_llist|" in *"|$_lname|"*) keep=1 ;; esac
        fi
        if [ "$keep" = 1 ]; then
            for sub in "$d"*/; do
                [ -d "$sub" ] || continue
                subn="$(basename "$sub")"
                case "$subn" in
                    [0-9]*x[0-9]*)
                        case "|$SEED_SKIN_RES|" in
                            *"|$subn|"*) : ;;
                            *) rm -rf "$sub"; trimmed=$((trimmed+1)) ;;
                        esac ;;
                esac
            done
        else
            rm -rf "$d"; pruned=$((pruned+1))
        fi
    done
    echo "  skins: kept [$SEED_SKINS] at [$SEED_SKIN_RES]; pruned $pruned skins, $trimmed extra-res dirs."
fi

# Prune fonts to the boot-loaded set (skipped entirely when SEED_FONTS=ALL).
if [ -d "$SEED/fonts" ] && [ "$SEED_FONTS" != "ALL" ]; then
    pruned=0
    for f in "$SEED/fonts"/*; do
        [ -f "$f" ] || continue
        name="$(basename "$f")"
        case "|$SEED_FONTS|" in
            *"|$name|"*) : ;;
            *) rm -f "$f"; pruned=$((pruned+1)) ;;
        esac
    done
    echo "  fonts: kept boot set; pruned $pruned others."
elif [ -d "$SEED/fonts" ]; then
    echo "  fonts: kept ALL ($(ls "$SEED/fonts" | wc -l | tr -d ' ') files)."
fi

# Marker: offline sideload build (google_play_store.tcl redirects to
# ~/Documents/de1app but does NOT force a network self-update).
: > "$SEED/sideload.flag"

# AndroWish auto-run entry (tkZipMain.c runs /assets/app/main.tcl).
cat > "$APPDIR/main.tcl" <<'TCL'
# Bundled de1app entry point for AndroWish.
# AndroWish auto-runs /assets/app/main.tcl. The de1plus tree is bundled
# read-only at /assets/app/de1plus; de1plus.tcl -> de1app.tcl ->
# google_play_store.tcl sees sideload.flag and copies the tree to a writable
# ~/Documents/de1app, cd's there, and runs from that copy (settings/history/
# profiles persist; self-update optional). cd uses no trailing slash so it
# works from the read-only zipfs mount.
cd /assets/app/de1plus
source de1plus.tcl
TCL

echo "Seed staged. Size:"
du -sh "$APPDIR"
echo "  de1plus: $(du -sh "$SEED" | cut -f1)   skins: $(du -sh "$SEED/skins" 2>/dev/null | cut -f1)   fonts: $(du -sh "$SEED/fonts" 2>/dev/null | cut -f1)"
