#!/usr/bin/env python3

import sys
from PIL import Image


def read_glyph(data):
    """
    32バイト → 16x16ビット配列
    1行2バイト(MSB→LSB)
    """
    glyph = []
    for y in range(16):
        row = []
        b0 = data[y * 2]
        b1 = data[y * 2 + 1]
        for bit in range(8):
            row.append((b0 >> (7 - bit)) & 1)
        for bit in range(8):
            row.append((b1 >> (7 - bit)) & 1)
        glyph.append(row)
    return glyph


def transform(glyph, cut):
    # 左右端16ドットを取得
    left = [glyph[y][0] for y in range(16)]
    right = [glyph[y][15] for y in range(16)]

    # 90度左回転（縦→横）
    left_rot = left
    right_rot = right

    # 下端へ追加（16→18行）
    glyph = [row[:] for row in glyph]
    glyph.append(left_rot)
    glyph.append(right_rot)

    # 上1行削除
    if cut:
        for x in range(16):
            glyph[0][x] = 0

    # 左右1列削除（18→	16列）
    glyph = [row[1:-1] for row in glyph]

    return glyph  # 18×14


def main():
    if not len(sys.argv) in (3, 4):
        print(f"Usage: {sys.argv[0]} BINFILE PNGFILE [--cut]")
        sys.exit(1)

    with open(sys.argv[1], "rb") as f:
        rom = f.read()

    glyphs = len(rom) // 32
    cols = glyphs // 16
    rows = 16
    cut = len(sys.argv) == 4

    GLYPH_W = 14
    GLYPH_H = 18

    img = Image.new("1", (cols * GLYPH_W, rows * GLYPH_H), 1)

    for i in range(glyphs):
        g = read_glyph(rom[i * 32:(i + 1) * 32])
        g = transform(g, cut)

        gx = (i // rows) * GLYPH_W
        gy = (i %  rows) * GLYPH_H

        for y in range(GLYPH_H):
            for x in range(GLYPH_W):
                img.putpixel((gx + x, gy + y), 0 if g[y][x] else 1)

    img.save(sys.argv[2])


if __name__ == "__main__":
    main()
