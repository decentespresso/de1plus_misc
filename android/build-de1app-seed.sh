#!/bin/sh
# Stage an OFFLINE-usable de1plus seed into the AndroWish app-bundle convention
# (assets/app/) for the self-contained de1app.apk.
#
# ALLOWLIST, not blocklist (John, 2026-08-12): the seed is built STRICTLY from the
# files listed in de1plus/misc.tcl (proc make_de1_dir) -- the canonical Decent
# distribution manifest ("if it's not in misc.tcl, don't distribute"). We reuse
# misc.tcl VERBATIM as the single source of truth: run its own list-building logic
# (the static list + every skin/plugin/profile_editor folder's filelist.txt) and
# copy ONLY those paths. This is why a bundled APK must never again ship the
# developer's runtime state -- e.g. the top-level settings.tdb that once made a
# build boot "already logged in as john@bookmooch.com", or a plugin settings.tdb
# holding a service credential: none of those are in misc.tcl, so they can't leak.
# (The earlier rsync-everything-minus-excludes approach silently shipped whatever
# the blocklist forgot.)
#
# On top of the manifest we apply the APK's size levers: only the popular skins,
# only the chosen resolution(s), and (by default) no screensaver -- the in-app
# updater fetches the rest on demand. Those are SUBSETS of the manifest; nothing
# outside it is ever added.
set -e

SRC_DE1PLUS="${SRC_DE1PLUS:-/d/admin/code/de1app/de1plus}"
DST="${DST:-$HOME/de1app-android}"
APPDIR="$DST/assets/app"
SEED="$APPDIR/de1plus"

# POPULAR-SKINS seed (machine.tcl most_popular_skins + Streamline/Streamline Dark
# + the "default" fallback image dir), at the 2560x1600 rescale base only (dui
# rescales to any display). SEED_SKINS=ALL keeps every skin in the manifest.
SEED_SKINS="${SEED_SKINS:-default|Insight|MimojaCafe|Metric|DSx|SWDark4|DSx2|MiniMetric|Streamline|Streamline Dark}"
SEED_SKIN_RES="${SEED_SKIN_RES:-2560x1600}"   # |-list of resolution subdirs to keep
SEED_SAVER="${SEED_SAVER:-0}"                 # 1 = include screensaver images (else updater fills)

echo "Staging de1plus seed (misc.tcl manifest allowlist) -> $SEED"
rm -rf "$APPDIR"
mkdir -p "$SEED"

# 1) The canonical distributable file list. Take misc.tcl up to (but not including)
#    its copy loop and just print $files -- reusing its exact static list + the
#    per-folder filelist.txt enumeration, with no duplication and no line-number
#    fragility (cut at the unique "set old_timestamp 0" marker).
TMPTCL="$(mktemp -t de1seedtcl).tcl"
awk '/set old_timestamp 0/{exit} {print}' "$SRC_DE1PLUS/misc.tcl" > "$TMPTCL"
cat >> "$TMPTCL" <<'TCL'
    foreach {f s} $files { puts $f }
}
make_de1_dir [lindex $argv 0] {}
TCL
MANIFEST="$(mktemp -t de1manifest).txt"
tclsh "$TMPTCL" "$SRC_DE1PLUS" 2>/dev/null \
    | grep -vE '^(Checking|Found|Files added)' | sort -u > "$MANIFEST"
rm -f "$TMPTCL"
[ -s "$MANIFEST" ] || { echo "ERROR: empty manifest from misc.tcl (tclsh present?)"; exit 1; }

# 2) Filter to the seed subset (popular skins, chosen resolution(s), optional
#    screensaver). Everything else in the manifest ships as-is.
FILTER="$(mktemp -t de1seedlist).txt"
awk -v skins="$SEED_SKINS" -v res="$SEED_SKIN_RES" -v saver="$SEED_SAVER" '
  BEGIN{ allskins=(skins=="ALL");
         n=split(skins,a,"|"); for(i=1;i<=n;i++) keepskin[tolower(a[i])]=1;
         m=split(res,b,"|");   for(i=1;i<=m;i++) keepres[b[i]]=1 }
  {
    if ($0 ~ /^skins\//) {
      p=$0; sub(/^skins\//,"",p); slash=index(p,"/"); name=(slash?substr(p,1,slash-1):p);
      if (!allskins && !(tolower(name) in keepskin)) next;         # non-popular skin
      rest=substr(p,slash+1);
      if (rest ~ /^[0-9]+x[0-9]+\//) { r=rest; sub(/\/.*/,"",r); if (!(r in keepres)) next }
      print; next
    }
    if (saver=="0" && $0 ~ /^saver\//) next                        # screensaver -> updater fills
    print
  }' "$MANIFEST" | sort -u > "$FILTER"

# 3) Copy exactly those files (strict allowlist). A stale filelist.txt can list a
#    file that has since been removed, so split into on-disk vs missing and rsync
#    only what exists -- a missing manifest entry must not abort the build (it just
#    means the updater will fetch it), and we report the count so it stays visible.
EXIST="$(mktemp -t de1seedok).txt"; : > "$EXIST"
missing=0
while IFS= read -r f; do
    if [ -e "$SRC_DE1PLUS/$f" ]; then
        printf '%s\n' "$f" >> "$EXIST"
    else
        missing=$((missing+1)); [ "$missing" -le 8 ] && echo "  MISSING (in manifest, not on disk): $f"
    fi
done < "$FILTER"
rsync -aL --files-from="$EXIST" "$SRC_DE1PLUS/" "$SEED/"
echo "  manifest: $(wc -l < "$MANIFEST" | tr -d ' ') files; seeded: $(wc -l < "$EXIST" | tr -d ' '); missing-on-disk: $missing"
rm -f "$MANIFEST" "$FILTER" "$EXIST"

# Marker: offline sideload build (google_play_store.tcl sees sideload.flag and
# copies the read-only tree to a writable ~/Documents/Decent, no forced update).
: > "$SEED/sideload.flag"

# Fresh build identity so the read-only redirect (de1app.tcl ::de1_redirect_data_root)
# REFRESHES an existing Documents/Decent copy on the next launch when this APK is newer.
# build-info.txt (shipped by every read-only build via the misc.tcl manifest) is the
# refresh trigger; regenerate it fresh here (the manifest copy may be stale) and drop an
# explicit build_id.txt too.
# DE1PLUS=$SEED so it stamps the SEED's version.tcl (the real X.Y.Z the app shows via
# `package version de1app`) AND writes the seed's build-info.txt — from git describe.
DE1APP_REPO="$(cd "$SRC_DE1PLUS/.." && pwd)"
if [ -x "$DE1APP_REPO/misc/create_build_info.sh" ]; then
    ( cd "$DE1APP_REPO" && DE1PLUS="$SEED" bash misc/create_build_info.sh "$SEED/build-info.txt" ) >/dev/null 2>&1 || true
fi
BID="$(awk -F'\t' '$1=="version_string"{print $2; exit}' "$SEED/build-info.txt" 2>/dev/null)"
printf '%s\n' "${BID:-apk-build}" > "$SEED/build_id.txt"
echo "  version.tcl: $(head -1 "$SEED/version.tcl" 2>/dev/null)   build_id: ${BID:-apk-build}"

# AndroWish auto-run entry (tkZipMain.c runs /assets/app/main.tcl).
cat > "$APPDIR/main.tcl" <<'TCL'
# Bundled de1app entry point for AndroWish.
# AndroWish auto-runs /assets/app/main.tcl. The de1plus tree is bundled
# read-only at /assets/app/de1plus; de1plus.tcl -> de1app.tcl ->
# google_play_store.tcl sees sideload.flag and copies the tree to a writable
# ~/Documents/Decent, cd's there, and runs from that copy (settings/history/
# profiles persist; self-update optional). cd uses no trailing slash so it
# works from the read-only zipfs mount.
cd /assets/app/de1plus
source de1plus.tcl
TCL

echo "Seed staged. Size:"
du -sh "$APPDIR"
echo "  de1plus: $(du -sh "$SEED" | cut -f1)   skins: $(du -sh "$SEED/skins" 2>/dev/null | cut -f1)   fonts: $(du -sh "$SEED/fonts" 2>/dev/null | cut -f1)"
