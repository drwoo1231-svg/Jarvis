#!/usr/bin/env python3
"""
Rebuilds the open-licensed PNG + font assets in ../A_Piece_Of_Cake/data/.

Sources (all downloaded from public package registries):
  * Microsoft Fluent Emoji 3D (MIT)      -> npm  @lobehub/fluent-emoji-3d
  * Hubble eXtreme Deep Field (NASA, PD) -> PyPI scikit-image (bundled sample)
  * Bangers / Black Ops One / Orbitron (SIL OFL 1.1) -> npm @expo-google-fonts/*

The Rick sprites are NOT made here - they are drawn by
tools/RickPartsGenerator (run it in Processing).

Usage:  pip install pillow numpy  &&  python3 prepare_assets.py
"""
import io
import json
import os
import shutil
import tarfile
import urllib.request
import zipfile

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "..", "A_Piece_Of_Cake", "data")
CACHE = os.path.join(HERE, ".cache")


def fetch(url, name):
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        print("downloading", url)
        with urllib.request.urlopen(url) as r, open(path, "wb") as f:
            shutil.copyfileobj(r, f)
    return path


def npm_tarball(pkg):
    meta = json.load(urllib.request.urlopen("https://registry.npmjs.org/" + pkg))
    ver = meta["dist-tags"]["latest"]
    return fetch(meta["versions"][ver]["dist"]["tarball"], pkg.replace("/", "_") + ".tgz")


def from_tgz(tgz, member):
    with tarfile.open(tgz) as t:
        return t.extractfile(member).read()


# ---------------------------------------------------------------- helpers
def rgb_to_hsv(a):
    """a: float array (...,3) in 0..1 -> h (0..360), s, v"""
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    mx = a.max(-1)
    mn = a.min(-1)
    d = mx - mn
    h = np.zeros_like(mx)
    m = d > 1e-6
    rm = m & (mx == r)
    gm = m & (mx == g) & ~rm
    bm = m & ~rm & ~gm
    h[rm] = (60 * ((g[rm] - b[rm]) / d[rm])) % 360
    h[gm] = 60 * ((b[gm] - r[gm]) / d[gm]) + 120
    h[bm] = 60 * ((r[bm] - g[bm]) / d[bm]) + 240
    s = np.where(mx > 1e-6, d / np.maximum(mx, 1e-6), 0)
    return h, s, mx


def hsv_to_rgb(h, s, v):
    h = (h % 360) / 60.0
    i = np.floor(h).astype(int) % 6
    f = h - np.floor(h)
    p = v * (1 - s)
    q = v * (1 - s * f)
    t = v * (1 - s * (1 - f))
    out = np.zeros(h.shape + (3,))
    for k, (rr, gg, bb) in enumerate([(v, t, p), (q, v, p), (p, v, t),
                                       (p, q, v), (t, p, v), (v, p, q)]):
        m = i == k
        out[m, 0], out[m, 1], out[m, 2] = rr[m], gg[m], bb[m]
    return out


def to_arr(img):
    return np.asarray(img.convert("RGBA")).astype(np.float64) / 255.0


def from_arr(a):
    return Image.fromarray((np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA")


def save(img, name, size=None):
    if size:
        img = img.resize((size, size), Image.LANCZOS)
    img.save(os.path.join(DATA, name), optimize=True)
    print("  wrote", name, img.size)


# ---------------------------------------------------------------- build
def main():
    os.makedirs(DATA, exist_ok=True)
    fluent = npm_tarball("@lobehub/fluent-emoji-3d")

    def emoji(code):
        return Image.open(io.BytesIO(from_tgz(fluent, "package/assets/%s.webp" % code))).convert("RGBA")

    # 1. straight conversions (webp -> png)
    plain = {
        "1f389": "party_popper.png", "2728": "sparkles.png", "1f31f": "star.png",
        "1f44f": "clap.png", "1f4a5": "boom.png", "1f6a8": "siren.png",
        "26a0-fe0f": "warning.png", "1f4a8": "puff.png", "1fa90": "planet_ringed.png",
        "1f30d": "earth.png", "1f319": "moon.png", "1f6f8": "ufo.png", "1f680": "rocket.png",
        "1f38a": "confetti_ball.png",
    }
    for code, name in plain.items():
        save(emoji(code), name)

    # 2. the cake: upscale, then delete the baked-in flames so the sketch can
    #    draw live flames that you can blow out.
    cake = emoji("1f382").resize((512, 512), Image.LANCZOS)
    a = to_arr(cake)
    h, s, v = rgb_to_hsv(a[..., :3])
    H, W = a.shape[:2]
    yy = np.arange(H)[:, None].repeat(W, 1)
    blue = (h > 170) & (h < 230) & (s > 0.25) & (a[..., 3] > 0.5)   # candle sticks
    flame = (yy < 0.215 * H) & ~blue          # everything above the candles that isn't candle
    a[flame, 3] = 0.0
    # candle tops (for placing the live flames) - scan blue columns
    cols = np.where(blue.any(0))[0]
    groups, start = [], cols[0]
    for p, c in zip(cols, cols[1:]):
        if c != p + 1:
            groups.append((start, p)); start = c
    groups.append((start, cols[-1]))
    tips = []
    for x0, x1 in groups:
        if x1 - x0 < 8:
            continue
        ys = np.where(blue[:, x0:x1 + 1].any(1))[0]
        tips.append(((x0 + x1) / 2 / W, ys.min() / H))
    print("  candle tips (fraction of cake.png):", [(round(x, 4), round(y, 4)) for x, y in tips])
    save(from_arr(a), "cake.png")

    # 3. the gift box: recolour (yellow box -> royal violet, red ribbon -> gold),
    #    then slice into lid and body so the lid can blow off.
    gift = emoji("1f381").resize((512, 512), Image.LANCZOS)
    a = to_arr(gift)
    h, s, v = rgb_to_hsv(a[..., :3])
    ribbon = ((h < 4) | (h > 290)) & (s > 0.15)     # red / magenta ribbon + bow
    box = (h >= 4) & (h < 100) & (s > 0.10)         # yellow-orange box
    nh, ns, nv = h.copy(), s.copy(), v.copy()
    nh[box] = 255 + (h[box] - 35) * 0.5
    ns[box] = np.clip(s[box] * 1.05, 0, 1)
    nv[box] = v[box] * 0.78
    nh[ribbon] = 44 + ((h[ribbon] + 60) % 360 - 60) * 0.15
    ns[ribbon] = np.clip(s[ribbon] * 0.9, 0, 1)
    nv[ribbon] = np.clip(v[ribbon] * 1.08, 0, 1)
    a[..., :3] = hsv_to_rgb(nh, ns, nv)
    # find the lid's bottom edge: the row where the opaque width drops (lid overhangs the body)
    widths = (a[..., 3] > 0.5).sum(1)
    body_w = np.median(widths[int(0.62 * H):int(0.85 * H)])
    cut = None
    for y in range(int(0.30 * H), int(0.62 * H)):
        if widths[y] > body_w + 12 and widths[y + 1] <= body_w + 12:
            cut = y + 1
    print("  gift lid/body cut row:", cut, "of", H)
    lid = a.copy(); lid[cut:, :, 3] = 0
    body = a.copy(); body[:cut, :, 3] = 0
    save(from_arr(lid), "gift_lid.png")
    save(from_arr(body), "gift_body.png")
    print("  gift cut fraction:", round(cut / H, 4))

    # 4. balloons in several colours (hue-shift only the red rubber)
    balloon = emoji("1f388")
    a = to_arr(balloon)
    h, s, v = rgb_to_hsv(a[..., :3])
    rubber = ((h < 40) | (h > 240)) & (s > 0.10)    # red rubber + its magenta shading (string is ~210)
    for name, hue in [("red", None), ("blue", 215), ("green", 110), ("yellow", 48),
                      ("purple", 275), ("pink", 325), ("orange", 26)]:
        b = a.copy()
        if hue is not None:
            nh = h.copy()
            nh[rubber] = hue + ((h[rubber] + 120) % 360 - 120) * 0.3
            nv = v.copy()
            if name == "yellow":
                nv[rubber] = np.clip(v[rubber] * 1.15, 0, 1)
            b[..., :3] = hsv_to_rgb(nh, s, nv)
        save(from_arr(b), "balloon_%s.png" % name)

    # 5. Hubble eXtreme Deep Field (public domain, NASA) from the scikit-image wheel
    meta = json.load(urllib.request.urlopen("https://pypi.org/pypi/scikit-image/json"))
    whl = next(u for u in meta["urls"] if u["filename"].endswith(".whl"))
    whl = fetch(whl["url"], whl["filename"])
    with zipfile.ZipFile(whl) as z:
        xdf = Image.open(io.BytesIO(z.read("skimage/data/hubble_deep_field.jpg"))).convert("RGB")
    xdf.save(os.path.join(DATA, "hubble_xdf.png"), optimize=True)
    print("  wrote hubble_xdf.png", xdf.size)

    # 6. fonts (SIL Open Font License)
    for pkg, member, out in [
        ("@expo-google-fonts/bangers", "package/400Regular/Bangers_400Regular.ttf", "Bangers.ttf"),
        ("@expo-google-fonts/black-ops-one", "package/400Regular/BlackOpsOne_400Regular.ttf", "BlackOpsOne.ttf"),
        ("@expo-google-fonts/orbitron", "package/700Bold/Orbitron_700Bold.ttf", "Orbitron-Bold.ttf"),
    ]:
        with open(os.path.join(DATA, out), "wb") as f:
            f.write(from_tgz(npm_tarball(pkg), member))
        print("  wrote", out)


if __name__ == "__main__":
    main()
