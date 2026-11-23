# AndroWish engine mods (for the Decent APK)

Patches to the **AndroWish** engine, generated against `charwliu/androwish`
commit **`f73cb8be`**. Apply from the androwish tree root with `patch -p1 < NN-*.patch`
(see `../BUILD.md`). These change the *engine*, not de1app — you only need them
when rebuilding the native libs.

| File | What | Why |
|------|------|-----|
| `01-arm64-only.patch` | `jni/Application64.mk`: `APP_ABI := arm64-v8a` (drop x86_64) | Decent tablets are arm64; halves `lib/` size |
| `02-blt-faster-graph-redraw.patch` | `jni/blt/src/blt{Graph,GrAxis}.{c,h}`: `cacheLabels` + `bufferChrome` | faster live-chart redraws (BLT-faster) |
| `03-zipfs-raise-archive-cap.patch` | `jni/tcl/generic/zipfs.c`: 128 MB → 1.5 GB `zipmax` | large APK can self-mount its own zipfs |
| `04-sdl2tk-dirty-rect-upload.patch` | `jni/sdl2tk/sdl/SdlTkGfx.c`: per-rect texture upload on Android | ~25–40 % less per-frame upload during a shot |
| `05-androidx-migration.patch` | `src/tk/tcl/wish/AndroWish.java`: `android.support.v4` → `androidx.core` | builds against modern SDK 35 |
| `06-prune-unused-tcl-packages.sh` | removes ~1,795 files of unused AndroWish "batteries" from `assets/` | keeps only the 19 Tcl packages de1app `package require`s |
| `07-gnss-guard-and-updater-icon.patch` | `AndroWish.java`: guard the legacy `addGpsStatusListener`/`addNmeaListener` calls; new `DecentUpdater.java` | Android 12+ devices without the legacy GNSS HAL throw there and crash-loop the app at launch (issue #358); the new activity gives `appupdate.tcl` its own launcher icon |
| `08-ble-scan-securityexception.patch` + `08-rebuild-ble-jar.sh` | `ble/src/.../BLEClient.java`: catch `SecurityException` in `onLeScan`; rebuild `libs/ble.jar` | Android 12+ without BLUETOOTH_CONNECT crashed on Search |
| `09-file-uri-to-content-uri.patch` | `AndroWish.java`: `buildIntent` turns a `file://` URI under files/ or cache/ into a FileProvider `content://` URI (authority `<package>.fileprovider`) and grants read access | since Android 7 a `file://` intent throws FileUriExposedException, so `apk_install` (de1app's Decaid installer) could not hand a downloaded APK to the installer. Needs the `<provider>`, `REQUEST_INSTALL_PACKAGES` and `<queries>` entries in `overlay/AndroidManifest*.xml` plus `overlay/res/xml/de1app_file_paths.xml` |

Also published standalone at `johnbuckman/androwish-android-improvements`.
