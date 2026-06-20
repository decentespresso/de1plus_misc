# de1app on iOS

This directory holds everything specific to packaging **de1app as a complete iOS
app** ("de1app on iOS") — the launcher, `Info.plist`, app icon, entitlements, and
the build / sign / deploy scripts. It is checked into the de1app repo because it
is de1app-specific and is intended for **Apple App Store** distribution.

## iwish vs. de1app-on-iOS — the separation

There are two distinct projects, kept deliberately separate:

| | **iwish** ("AndroWish on iOS") | **de1app on iOS** (this dir) |
|---|---|---|
| What | The Tcl/Tk runtime: [AndroWish](https://www.androwish.org/)'s `undroidwish` (Tcl + Tk/SdlTk + SDL2 + AGG + FreeType) built for iOS, plus the iOS-native `borg`/`ble` command shims. | A custom build that bundles **de1app** on top of the iwish runtime into one signed, self-contained `.app`. |
| Repo | Open source, **`johnbuckman/iwish`** (GPL-3, like AndroWish). | Here, in **`decentespresso/de1app`** (`misc/ios/`). |
| App Store | **Not acceptable** to the App Store (it's a generic Tcl/Tk runtime / interpreter). Released for other developers to package *their own* Tcl/Tk apps. | The shippable product — a single coffee app, **App-Store-bound**. |

In short: **iwish is the engine; de1app-on-iOS is one car built with it.** Other
developers can use iwish to build and submit their own packaged Tcl/Tk apps.

## What's here

de1app-on-iOS is **just de1app's Tcl/Tk code riding on the iwish runtime**, so the
iwish runtime + its shared build/sign/icon scripts are pulled in as a git submodule
rather than copied here:

- `iwish/` — **git submodule → `johnbuckman/iwish`** (the engine + shared scripts:
  `scripts/build-device.sh`, `scripts/sign-and-install-device.sh` (generic),
  `scripts/build-icon.sh` (generic), `scripts/unix-commands.tcl`, the `src-ios`
  shims, and the androwish/SDL patches). Clone de1app with `--recursive`, or
  `git submodule update --init --recursive`. **Everything runtime-related lives
  here, not copied into de1app.**

Genuinely de1app-specific (the only non-submodule files here):

- `launcher.tcl` — the app's `main.tcl` inside the bundle. A thin bootstrap: sets
  `TCL_LIBRARY`/`TK_LIBRARY` + the native-extension `auto_path` (no env on iOS),
  then `cd`s into the bundled `de1plus` and `source`s `de1plus.tcl`.
- `Info.plist` — bundle id `com.decent.de1app`, landscape orientations,
  hidden status bar, `MinimumOSVersion 15.0`, icon keys (`AppIcon`).
- `de1app.entitlements` — signing entitlements (app-id `XD9V8H8S2N.com.decent.de1app`,
  get-task-allow, …); must match the provisioning profile's App ID.
- `build-icon.sh` — **thin wrapper** that calls `iwish/scripts/build-icon.sh` with
  de1app's icon source (`/d/img/de1plus_white.jpg`). Only the source image is
  de1app-specific; the pipeline lives in the submodule.
- `push-de1app.sh` — **dev iteration**: sync the de1app source into a built `.app`
  and onto the device, signing via `iwish/scripts/sign-and-install-device.sh`.
  de1app reads code from TWO places, so it syncs BOTH: the bundle (cwd — top-level
  `*.tcl`) and `~/Documents/Decent` (`[homedir]` — skins/plugins/profile_editors/
  translation), then reinstalls + relaunches.

The de1app **source** side of iOS support lives in the normal de1app tree, not
here: `de1plus/ios.tcl` (platform detection via `borg platform`; redirect the
writable data root to `~/Documents/Decent` and seed it) and the `::iwish`/`::ios`
hooks in `de1app.tcl`/`main.tcl`/`utils.tcl`/`updater.tcl`.

## Building de1app-on-iOS (outline)

1. **Build the iwish runtime** for `arm64-apple-ios` via the submodule
   (`iwish/scripts/build-device.sh` + `iwish/scripts/build-ext-dev.sh`):
   FreeType, SDL2, AndroWish Tcl, sdl2tk + `sdl2wish` (UTF6), plus the loadable
   extension stack (tkimg, tls, TclCurl, BLT, tksvg, sqlite3, itcl, thread, zint)
   and the `borg`/`ble` shims. This yields: the `sdl2wish` binary, `lib/tcl8.6` +
   `lib/tk8.6`, and a `lib-batteries/` of extension dylibs.
2. **Assemble the `.app`:**
   - `iWish` (= the `sdl2wish` binary, renamed)
   - `lib/tcl8.6`, `lib/tk8.6`
   - `lib-batteries/` (extension dylibs)
   - `libhardexit.dylib` (the clean-exit helper — build it from the iwish runtime's
     `src-ios/hardexit/hardexit.c`; loaded by de1app's `utils.tcl:ios_install_hardexit`)
   - the iwish runtime's `lib/tcl8.6/unix-commands.tcl` (pure-Tcl `ls`/`cat`/`cp`/…;
     iOS has no `exec`), with `lib/tcl8.6/init.tcl` sourcing it so the commands are
     available to all de1app Tcl, not just the console. A clean iwish runtime
     already ships this; `push-de1app.sh` self-heals it (step 1b) for older bundles.
   - `de1plus/` — a curated copy of the de1app tree (code + active skins/Streamline,
     fonts, splash, etc.; drop builds/history/apk and unused skin resolutions)
   - `main.tcl` (= `launcher.tcl`), `Info.plist`, the icon (`build-icon.sh` →
     `iwish/scripts/build-icon.sh`), `embedded.mobileprovision`
3. **Sign + install:** `iwish/scripts/sign-and-install-device.sh <app> <identity> <profile> <udid> [entitlements]`.
   Needs an Apple Development cert + a provisioning profile (device UDID +
   the device UDID) for `com.decent.de1app`. iWish-on-iOS uses a separate id
   (`com.decent.iWish`) so both apps can be installed side by side.
4. **Iterate:** after editing de1app source, `bash push-de1app.sh`.

> Note: this is currently a developer/sideload build. App Store submission needs a
> distribution profile + an Xcode archive/IPA step (TODO).
