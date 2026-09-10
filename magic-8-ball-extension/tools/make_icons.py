#!/usr/bin/env python3
"""Render the Magic 8 Ball toolbar icons.

Pure stdlib (zlib + struct) so it runs anywhere: a shaded sphere is sampled at
4x and box-filtered down, which gives clean edges without an imaging library.

    python3 tools/make_icons.py
"""
import math
import os
import struct
import zlib

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "icons")
SIZES = (16, 32, 48, 128)
SS = 4  # supersample factor

LIGHT = (-0.42, -0.58, 0.70)  # normalized below; from the upper left


def _norm(v):
    m = math.sqrt(sum(c * c for c in v))
    return tuple(c / m for c in v)


def shade(nx, ny, nz):
    """Lambert + specular on a matte-black billiard ball."""
    lx, ly, lz = _norm(LIGHT)
    diffuse = max(0.0, nx * lx + ny * ly + nz * lz)
    spec = diffuse ** 34
    rim = max(0.0, 1.0 - nz) ** 3 * 0.10  # faint bounce light at the edge
    value = 14 + 96 * diffuse ** 1.6 + 210 * spec + 70 * rim
    return min(255, value)


def sample(x, y, size):
    """RGBA for one supersampled point, in the unit square scaled to `size`."""
    c = size / 2.0
    r = size * 0.485
    dx, dy = x - c, y - c
    d = math.hypot(dx, dy)
    if d > r:
        return (0, 0, 0, 0)

    nx, ny = dx / r, dy / r
    nz = math.sqrt(max(0.0, 1.0 - nx * nx - ny * ny))
    v = shade(nx, ny, nz)

    # The white window with the "8", flattened onto the front of the ball.
    disc = r * 0.44
    if d <= disc:
        # Two rings stacked into an 8, sized so it survives the 16px downscale.
        top_c, top_out, top_in = -disc * 0.30, disc * 0.34, disc * 0.15
        bot_c, bot_out, bot_in = disc * 0.32, disc * 0.42, disc * 0.19
        dt = math.hypot(dx, dy - top_c)
        db = math.hypot(dx, dy - bot_c)
        on_eight = (top_in <= dt <= top_out) or (bot_in <= db <= bot_out)
        if on_eight:
            v = 18 + 26 * (v / 255.0)
        else:
            # keep a little of the sphere's shading in the white so it reads round
            v = 226 + 29 * (v / 255.0)

    g = int(round(v))
    # a hint of cool tint in the shadows
    b = min(255, g + (10 if g < 120 else 0))
    return (g, g, b, 255)


def render(size):
    S = size * SS
    rows = []
    for py in range(size):
        row = bytearray()
        for px in range(size):
            r = g = b = a = 0
            for sy in range(SS):
                for sx in range(SS):
                    pr, pg, pb, pa = sample(
                        (px * SS + sx + 0.5) / SS, (py * SS + sy + 0.5) / SS, size
                    )
                    # premultiply so transparent samples don't lighten the edge
                    r += pr * pa
                    g += pg * pa
                    b += pb * pa
                    a += pa
            n = SS * SS
            if a == 0:
                row += bytes((0, 0, 0, 0))
            else:
                row += bytes(
                    (
                        int(round(r / a)),
                        int(round(g / a)),
                        int(round(b / a)),
                        int(round(a / n)),
                    )
                )
        rows.append(bytes(row))
    return rows


def write_png(path, rows, size):
    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    raw = b"".join(b"\x00" + row for row in rows)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )
    with open(path, "wb") as fh:
        fh.write(png)


def main():
    os.makedirs(OUT, exist_ok=True)
    for size in SIZES:
        path = os.path.join(OUT, "icon%d.png" % size)
        write_png(path, render(size), size)
        print("wrote", os.path.relpath(path, os.getcwd()), "(%dx%d)" % (size, size))


if __name__ == "__main__":
    main()
