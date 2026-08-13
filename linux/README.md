# Building the Decent de1app Linux AppImage

Packages de1app as a self-contained **AppImage** (one file, no install) for
`x86_64` and `aarch64`. Like the Android APK, the payload is the `misc.tcl`
manifest seed (see `../android/build-de1app-seed.sh`); the runtime is
**undroidwish** (AndroWish's SDL2 Tk), bundled read-only inside the AppImage.

```
misc/linux/
├── README.md            ← this file
├── build-appimage.sh    ← assembles one AppImage (mksquashfs + type-2 runtime)
├── AppRun               ← entry point: seeds tree to ~/.local/share/Decent, runs
└── decent.desktop       ← desktop entry (icon = de1_icon_v2.png)
```

## How the AppImage runs
The mount is read-only, but de1app writes into its own tree (settings, history,
self-update). `AppRun` seeds the tree into a writable `~/.local/share/Decent` on
first launch (overwrite-refresh on version change, user data preserved), then runs
`undroidwish de1plus.tcl` there. Shell-side equivalent of `::de1_redirect_data_root`.

## Inputs
- **undroidwish** per arch: `x86_64` from the desktop-linux build (the same
  `undroidwish-linux64` shipped in `decent_linux_*.zip`); `aarch64` built natively
  from AndroWish (no arm64 undroidwish is shipped in the zip). See
  [[undroidwish_arm64_port]] / `johnbuckman/androwish-android-improvements`.
- **type-2 runtimes**: `runtime-x86_64`, `runtime-aarch64` from
  `github.com/AppImage/type2-runtime/releases/continuous/`.
- **payload src**: the `misc.tcl`-manifest-filtered `de1plus` tree, version stamped
  (`version.tcl`: `package ifneeded de1app <ver>`).
- host tool: `squashfs-tools` (`mksquashfs`). No appimagetool/FUSE needed to BUILD
  — `build-appimage.sh` = `mksquashfs AppDir out` then `cat runtime out > X.AppImage`.
  This is arch-agnostic, so an aarch64 host can build the x86_64 AppImage too.

## Build
```sh
# one AppImage:  build-appimage.sh <arch> <undroidwish-binary> <output.AppImage>
DE1_SRC=<manifest-seed-tree> build-appimage.sh x86_64  ./undroidwish-linux64      Decent-x86_64.AppImage
DE1_SRC=<manifest-seed-tree> build-appimage.sh aarch64 ./undroidwish-aarch64      Decent-aarch64.AppImage
```
Name the outputs exactly `Decent-x86_64.AppImage` / `Decent-aarch64.AppImage` —
those are the stable filenames the website links to.

## Publish
Upload both into the single rolling "latest" GitHub release (stable URLs never
change) from a `gh`-authenticated host:
```sh
sh ../publish-latest.sh Decent-x86_64.AppImage Decent-aarch64.AppImage
#  -> https://github.com/decentespresso/de1app/releases/latest/download/Decent-x86_64.AppImage
#  -> https://github.com/decentespresso/de1app/releases/latest/download/Decent-aarch64.AppImage
```
Do NOT use a per-platform `linux-latest` tag — everything shares the one `latest`
release so `…/releases/latest/download/<file>` works across all platforms.
