#!/usr/bin/env python3
"""Generate JARVIS PWA icons (arc-reactor emblem) with Pillow."""
import math
import os
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(__file__), "..", "public", "icons")
os.makedirs(OUT, exist_ok=True)

CYAN = (56, 225, 255)
CYAN_SOFT = (111, 240, 255)
WHITE = (234, 252, 255)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def render(size, maskable=False):
    ss = 4  # supersample for crisp anti-aliasing
    S = size * ss
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = cy = S / 2

    # Background (radial-ish) with rounded corners.
    radius = int(S * 0.22) if not maskable else 0
    bg = Image.new("RGBA", (S, S), (1, 4, 9, 255))
    bd = ImageDraw.Draw(bg)
    # simple vertical-ish radial glow
    for r in range(int(S * 0.55), 0, -2):
        t = r / (S * 0.55)
        col = lerp((1, 4, 9), (6, 35, 56), 1 - t)
        bd.ellipse([cx - r, cy - r * 0.9, cx + r, cy + r * 0.9], fill=col + (255,))
    if radius:
        mask = Image.new("L", (S, S), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, S, S], radius=radius, fill=255)
        img.paste(bg, (0, 0), mask)
    else:
        img.paste(bg, (0, 0))
    d = ImageDraw.Draw(img)

    scale = 0.78 if maskable else 1.0  # keep safe zone for maskable

    def ring(rr, width, color, alpha):
        r = rr * scale
        d.ellipse([cx - r, cy - r, cx + r, cy + r],
                  outline=color + (alpha,), width=max(1, int(width)))

    R = S * 0.34
    # concentric rings
    ring(R * 1.02, S * 0.012, CYAN, 210)
    ring(R * 0.82, S * 0.006, CYAN, 140)
    ring(R * 0.62, S * 0.016, CYAN, 235)

    # rotating arc segments
    def arc(rr, start, end, width, color, alpha):
        r = rr * scale
        d.arc([cx - r, cy - r, cx + r, cy + r], start, end,
              fill=color + (alpha,), width=max(1, int(width)))

    arc(R * 0.92, -20, 120, S * 0.014, CYAN, 220)
    arc(R * 0.92, 160, 300, S * 0.014, CYAN, 220)

    # tick marks
    for i in range(60):
        a = math.radians(i * 6)
        r1 = R * 1.12 * scale
        r2 = R * 1.18 * scale
        x1, y1 = cx + math.cos(a) * r1, cy + math.sin(a) * r1
        x2, y2 = cx + math.cos(a) * r2, cy + math.sin(a) * r2
        d.line([x1, y1, x2, y2], fill=CYAN + (90,), width=max(1, int(S * 0.004)))

    # glowing core (layered discs for a soft glow)
    core = R * 0.40 * scale
    for i in range(int(core), 0, -1):
        t = i / core
        col = lerp(WHITE, (10, 166, 207), t)
        alpha = int(255 * (1 - t) ** 0.5)
        d.ellipse([cx - i, cy - i, cx + i, cy + i], fill=col + (alpha,))
    hot = core * 0.5
    d.ellipse([cx - hot, cy - hot, cx + hot, cy + hot], fill=WHITE + (235,))

    return img.resize((size, size), Image.LANCZOS)


def main():
    specs = [
        ("icon-192.png", 192, False),
        ("icon-512.png", 512, False),
        ("maskable-512.png", 512, True),
        ("apple-touch-icon.png", 180, False),
        ("favicon-32.png", 32, False),
    ]
    for name, size, maskable in specs:
        img = render(size, maskable)
        img.save(os.path.join(OUT, name))
        print("wrote", name, size)


if __name__ == "__main__":
    main()
