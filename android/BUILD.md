# Building the Decent de1app Android APK

This directory contains **everything de1app-specific** needed to build the
self-contained `Decent` Android APK (`com.decentespresso.de1app`). The heavy
lifting — the Tcl/Tk/SDL2 runtime — comes from **AndroWish**, which is NOT
vendored here (it is ~545 MB of upstream C). Instead we pin an AndroWish commit
and carry only our overlay + patches.

```
misc/android/
├── BUILD.md                    ← this file
├── build-de1app-seed.sh        ← stages the de1plus seed into assets/app/
├── make-icon.py                ← regenerates the adaptive launcher icon
├── README-de1app-apk.md        ← design notes
├── overlay/                    ← files copied ONTO a pristine androwish checkout
│   ├── build.gradle            ← applicationId, SDK 35, androidx, keychain signing
│   ├── AndroidManifest64.xml   ← 64-bit build manifest (icon → @mipmap/ic_launcher)
│   ├── AndroidManifest.xml     ← 32-bit manifest (kept in sync)
│   ├── ant.properties.sample   ← signing config (NO password; see "Signing")
│   └── res/                    ← adaptive icon, colors.xml, strings.xml ("Decent")
└── mods/                       ← engine patches vs the pinned androwish base
    ├── 01-arm64-only.patch
    ├── 02-blt-faster-graph-redraw.patch
    ├── 03-zipfs-raise-archive-cap.patch
    ├── 04-sdl2tk-dirty-rect-upload.patch
    ├── 05-androidx-migration.patch
    └── 06-prune-unused-tcl-packages.sh
```

## Prerequisites (host: macOS)
- **AndroWish base**: `charwliu/androwish` at commit **`f73cb8be`** ("jni: fix to
  compile with new ndk"). All `mods/*.patch` are generated against this commit.
- **JDK 21** — Android Studio's bundled JBR:
  `/Applications/Android Studio.app/Contents/jbr/Contents/Home`
- **Android SDK** + **NDK r27d** (`ndk;27.3.13750724`), `platforms;android-35`.
- **Release keystore** in the macOS login keychain (see "Signing").

## Build steps
```sh
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/27.3.13750724
DE1=/d/admin/code/de1app/de1plus          # de1plus source (this repo)
M=/d/admin/code/de1app/misc/android

# 1) pristine engine
git clone https://github.com/charwliu/androwish AWtree && cd AWtree
git checkout f73cb8be

# 2) apply the engine mods
for p in "$M"/mods/0[1-5]*.patch; do patch -p1 < "$p"; done
sh "$M"/mods/06-prune-unused-tcl-packages.sh          # trim unused Tcl packages

# 3) overlay the de1app packaging (gradle, manifest, icon, strings, signing)
cp -R "$M"/overlay/. .
cp "$M"/overlay/ant.properties.sample ant.properties  # then edit for your keystore

# 4) stage the de1plus seed (popular skins @2560x1600 + all fonts)
SRC_DE1PLUS="$DE1" DST="$PWD" sh "$M"/build-de1app-seed.sh

# 5) (optional) regenerate the launcher icon from the product render
python3 "$M"/make-icon.py /d/img/de1plus_white.jpg res

# 6) build the signed release APK (arm64-only)
./gradlew --no-daemon assembleRelease
#   -> build/outputs/apk/release/AndroWish-release.apk  (~125 MB, "Decent")
```

## Signing (keychain, no secrets on disk)
`build.gradle` reads the keystore password at build time from the macOS login
keychain — nothing secret is committed. Seed the items once:
```sh
security add-generic-password -a store -s androwish-release-keystore -w '<pw>' -U
security add-generic-password -a key   -s androwish-release-keystore -w '<pw>' -U
```
`ant.properties` holds only the non-secret `key.store` path + `key.alias`.

## Notes
- **Bump `versionCode`** in `overlay/build.gradle` for every published build (the
  launcher caches the icon by versionCode).
- **Seed contents** are controlled by `build-de1app-seed.sh` env vars
  (`SEED_SKINS` / `SEED_SKIN_RES` / `SEED_FONTS`); default = the 7 "most popular"
  skins (machine.tcl:439) at 2560×1600 + all fonts, everything else self-updates.
- **Engine rebuild** (mods 01–05) needs the full androwish source + NDK. Day-to-day
  APK changes (skins, seed, icon, Tcl) do NOT — only steps 3–6.
- The engine patches are also published standalone at
  `johnbuckman/androwish-android-improvements`.
