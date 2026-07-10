# Decent de1app — self-contained Android APK (AndroWish-bundled)

A single sideloadable APK that bundles **de1app** + the **improved AndroWish**
engine (BLT-faster + AndroidX/SDK-35). One `adb install`, no separate code push.

- Package id: `com.decentespresso.de1app`  ·  label: **Decent**  ·  ABIs: arm64-v8a + x86_64
- Output: `~/de1app-android/Decent-de1app-release.apk` (~867 MB), signed with
  `~/iwish/androwish-release.jks` (alias `androwish`).
- Skins: **all skins at all resolutions + full fonts**, matching the iOS de1app
  bundle (`~/iwish/dist/IwishDE1dev.app`). (For a small APK, set
  `SEED_SKINS`/`SEED_SKIN_RES`/`SEED_FONTS` and restore the prune in the staging
  script — an earlier 6-skin build was ~98 MB.)

## How it works

1. This tree is a clone of AndroWish with the `androwish-android-improvements`
   patch set applied (BLT-faster + AndroidX/SDK modernization + **the zipfs
   archive-size-cap bump**, which is REQUIRED here: the all-skins APK is ~867 MB
   and AndroWish's default 128 MB zipfs cap would make the wish fail to mount its
   own APK / find `init.tcl`).
2. `build-de1app-seed.sh` stages the de1plus payload into `assets/app/de1plus/`
   (AndroWish's "wrap your own app" convention — it auto-runs `assets/app/main.tcl`
   from the read-only APK zipfs, per `jni/sdl2tk/generic/tkZipMain.c`). It ships
   **all skins at all resolutions + full fonts + splash + code/plugins/profiles/
   certs** (matching the iOS de1app bundle), dropping only junk
   (history*/doc/saver/apk/builds/shothistory.zip). ~884 MB.
3. `assets/app/main.tcl` does `cd /assets/app/de1plus; source de1plus.tcl`.
4. de1app boots: `de1plus.tcl → de1app.tcl → google_play_store.tcl`. The
   `sideload.flag` marker makes it copy the read-only seed to a writable
   `~/Documents/de1app` (app-internal storage), `cd` there, and run from the
   copy — so settings/history/profiles persist and the APK is never written to.
   Unlike `google_play.flag`, `sideload.flag` does **not** force a network
   self-update, so first launch works fully offline. (User can update in-app.)
5. `defaultConfig.applicationId = com.decentespresso.de1app` (namespace stays
   `tk.tcl.wish`), so it coexists with the plain AndroWish APK. App label
   "Decent" (`res/values/strings.xml`), launcher icon from `/d/img/de1plus_white.jpg`.

## de1app-side changes (in /d/admin/code/de1app, UNCOMMITTED — for review)

- `de1plus/de1plus.tcl` + `de1plus/de1app.tcl`: `cd "[file dirname [info script]]/"`
  → drop the trailing slash. Tcl's zipfs rejects a trailing-slash `cd` (real
  filesystems accept both), so this is required to run de1app from the read-only
  APK mount and is safe on desktop/tablet/iOS.
- `de1plus/google_play_store.tcl`: recognize a `sideload.flag` marker (sibling of
  `google_play.flag`) = copy-to-Documents + redirect, but skip the forced
  first-run network self-update.

## Rebuild

```sh
cd ~/de1app-android
sh build-de1app-seed.sh                 # re-stage seed from /d/admin/code/de1app/de1plus
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/27.3.13750724
./gradlew --no-daemon assembleRelease
cp build/outputs/apk/release/AndroWish-release.apk Decent-de1app-release.apk
```

## Verified

Installed + booted on a headless arm64 Android-34 emulator: seed copied to the
writable dir, de1app rendered the full Streamline UI (espresso page, BLT chart,
shot table). BLE (DE1 connection) needs real hardware — test on the tablet.
