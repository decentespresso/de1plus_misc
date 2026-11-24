# Decent de1app — self-contained Android APK (AndroWish-bundled)

A single sideloadable APK that bundles **de1app** with an **improved AndroWish**
engine. One `adb install`, no separate code push. Published as `de1app.apk` on the
rolling `latest` release of `decentespresso/de1app`
(`https://github.com/decentespresso/de1app/releases/latest/download/de1app.apk`).

- Package id: `com.decentespresso.de1app` · label **Decent** (plus a second
  launcher icon, **Decent Updater**) · ABI: arm64-v8a only.
- Size: about 97 MB. Runs on 4 KB- and 16 KB-page Android (engine patch 10).
- Signed with `~/iwish/androwish-release.jks` (alias `androwish`); the passwords
  are in the macOS keychain (see `BUILD.md`, "Signing").
- Seed: only the files `de1plus/misc.tcl` lists, cut down to the popular skins at
  2560×1600 plus all fonts. Everything else self-updates in the app.

For clean-room build steps, publishing and signing see **`BUILD.md`**. For what each
engine patch does see **`mods/README.md`**.

## How it works

1. The build tree (`~/de1app-android`) is AndroWish `charwliu/androwish` at
   `f73cb8be` with `mods/` applied and `overlay/` copied on top. Key engine mods:
   the zipfs archive-size cap is raised (patch 03; AndroWish's 128 MB default
   cannot mount a larger APK, so the wish never finds `init.tcl`), AndroidX/SDK 35
   (05), the GNSS crash guard and updater icon (07), the BLE scan fix (08),
   FileProvider APK installs (09) and 16 KB-aligned native libs (10).
2. `build-de1app-seed.sh` stages de1plus into `assets/app/de1plus/` (AndroWish's
   "wrap your own app" convention: it auto-runs `assets/app/main.tcl` from the
   read-only APK zipfs, per `jni/sdl2tk/generic/tkZipMain.c`).
   - It copies **only** the files `misc.tcl` (`make_de1_dir`) lists, so developer
     state such as `settings.tdb` can never leak in.
   - It keeps the skins in `SEED_SKINS` at the resolutions in `SEED_SKIN_RES`, and
     drops the screensaver unless `SEED_SAVER=1`.
   - It stamps `version.tcl`, `build-info.txt` and `build_id.txt` from
     `git describe` of the checkout `SRC_DE1PLUS` sits in. Seed releases from a
     clean checkout so the version has no `-dirty`.
3. `assets/app/main.tcl` does `cd /assets/app/de1plus; source de1plus.tcl`.
4. de1app boots: `de1plus.tcl → de1app.tcl → google_play_store.tcl`. The
   `sideload.flag` marker makes it copy the read-only seed to a writable
   `~/Documents/Decent` (app-internal storage,
   `/data/data/com.decentespresso.de1app/files/Documents/Decent/`), `cd` there,
   and run from the copy, so settings, history and profiles persist and the APK is
   never written to. A newer `build-info.txt` in the APK refreshes that copy after
   an update. Unlike `google_play.flag`, `sideload.flag` does **not** force a
   network self-update, so first launch works offline (it takes about a minute
   while the seed is copied).
5. `applicationId = com.decentespresso.de1app` (namespace stays `tk.tcl.wish`), so it
   coexists with the plain AndroWish APK. The label comes from
   `res/values/strings.xml`; the launcher icon is made from
   `/d/img/de1plus_white.jpg` by `make-icon.py`.

## Rebuild (day to day: Tcl, seed, skins, icon)

No engine rebuild needed; about 25 s for the gradle step.

```sh
cd ~/de1app-android
# bump versionCode/versionName in ~/de1app-android/build.gradle (the launcher
# caches the icon by versionCode; overlay/build.gradle is only a template)
SRC_DE1PLUS=/path/to/clean/de1app/de1plus sh build-de1app-seed.sh
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$ANDROID_HOME/ndk/27.3.13750724:$PATH"   # preBuild runs ndk-build
./gradlew --no-daemon assembleRelease
cp build/outputs/apk/release/AndroWish-release.apk de1app.apk
```

A clean checkout for the seed: `git worktree add --detach <dir> origin/main`, then
`git submodule update --init --recursive` in it. Publish with
`sh /d/admin/code/de1app/misc/publish-latest.sh de1app.apk`.

## Testing

- Emulators: `awtablet` (16 KB pages) and `aw_tablet_api34` (4 KB), both 2560×1600.
  Test both: a lib that isn't 16 KB-aligned only fails on the first.
- Launch: `adb shell am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -n com.decentespresso.de1app/tk.tcl.wish.AndroWishLauncher`
- Logs: logcat tag `DE1` (release builds are not debuggable, so `run-as` gives nothing).
- Wipe app data: `adb shell pm clear com.decentespresso.de1app`.
- BLE (a real DE1 connection) needs real hardware: test on a tablet.
