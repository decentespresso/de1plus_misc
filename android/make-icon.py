#!/usr/bin/env python3
"""Regenerate the Decent Android launcher icon from the product render.

Produces an adaptive icon (machine on a white tile) + legacy fallbacks:
  res/mipmap-anydpi-v26/ic_launcher.xml        (hand-written, not touched here)
  res/mipmap-<d>/ic_launcher_foreground.png    machine on transparent, safe-zone sized
  res/mipmap-<d>/ic_launcher.png               machine on white (pre-API-26 fallback)
  res/values/colors.xml                        ic_launcher_background = #FFFFFF (not touched)

The machine is flood-filled out of its white photographic background (so the
transparent-corner areas show the tile, not white), then centred. The adaptive
foreground is scaled to 0.62 of the 108dp canvas: the launcher crops to the
central 72dp "safe zone" and zooms ~1.5x, so 0.62 fills the visible tile without
the portafilter handle / drip tray overflowing the mask.

Usage:  python3 make-icon.py /d/img/de1plus_white.jpg <res-dir>
Requires: Pillow, numpy, scipy.
"""
import sys, os
from PIL import Image, ImageChops, ImageFilter
import numpy as np
from scipy import ndimage

FG_FRAC = 0.62   # adaptive foreground (transparent bg)
LEG_FRAC = 0.84  # legacy square (white bg)
FG_SIZES  = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324}
LEG_SIZES = {"mdpi": 48,  "hdpi": 72,  "xhdpi": 96,  "xxhdpi": 144}


def load_machine(src):
    """Crop the machine from its white photo and flood-fill the bg to transparent."""
    im = Image.open(src).convert("RGB")
    bg = Image.new("RGB", im.size, (255, 255, 255))
    diff = ImageChops.difference(im, bg).convert("L").point(lambda p: 255 if p > 12 else 0)
    crop = im.crop(diff.getbbox())
    arr = np.asarray(crop).astype(np.int16)
    white = (arr[:, :, 0] > 234) & (arr[:, :, 1] > 234) & (arr[:, :, 2] > 234)
    lbl, _ = ndimage.label(white)
    border = set(lbl[0, :]) | set(lbl[-1, :]) | set(lbl[:, 0]) | set(lbl[:, -1])
    border.discard(0)
    alpha = np.where(np.isin(lbl, list(border)), 0, 255).astype("uint8")
    m = crop.convert("RGBA")
    m.putalpha(Image.fromarray(alpha).filter(ImageFilter.GaussianBlur(0.8)))
    return m


def place(machine, px, frac, bg):
    mw, mh = machine.size
    cv = Image.new("RGBA", (px, px), bg)
    s = (px * frac) / max(mw, mh)
    r = machine.resize((max(1, int(mw * s)), max(1, int(mh * s))), Image.LANCZOS)
    cv.alpha_composite(r, ((px - r.size[0]) // 2, (px - r.size[1]) // 2))
    return cv


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src, res = sys.argv[1], sys.argv[2]
    machine = load_machine(src)
    for d, px in FG_SIZES.items():
        os.makedirs(f"{res}/mipmap-{d}", exist_ok=True)
        place(machine, px, FG_FRAC, (0, 0, 0, 0)).save(f"{res}/mipmap-{d}/ic_launcher_foreground.png")
    for d, px in LEG_SIZES.items():
        place(machine, px, LEG_FRAC, (255, 255, 255, 255)).convert("RGB").save(f"{res}/mipmap-{d}/ic_launcher.png")
    print(f"icon regenerated into {res}/mipmap-* (fg={FG_FRAC}, legacy={LEG_FRAC})")


if __name__ == "__main__":
    main()
