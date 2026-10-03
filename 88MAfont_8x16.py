#! /usr/bin/env python3

import sys
import os
import subprocess

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} INPUTFILE")
    sys.exit(1)

infile = sys.argv[1]

with open(infile, "rb") as f:
    data = f.read()

if len(data) != 0x80000:
    raise ValueError(
        f"{infile}: expected size 0x80000 bytes, got 0x{len(data):x}"
    )

header = b"P4\n8 256\n"

for x in range(16):
    out = bytearray()

    for y in range(16):
        for r in range(8):
            out.append(data[0x50000 + x * 128 + y * 8 + r])
            out.append(data[0x40000 + x * 128 + y * 8 + r])

    with open(f"{x}.pbm", "wb") as f:
        f.write(header)
        f.write(out)

# ImageMagickが利用可能ならPNGを生成
try:
    subprocess.run(
        [
            "convert",
            "+append",
            *[f"{i}.pbm" for i in range(10)],
            *[f"{i}.pbm" for i in range(10, 16)],
            "8x16.png",
        ],
        check=True,
    )
except FileNotFoundError:
    print("ImageMagick 'convert' not found; PBM files were generated.")
except subprocess.CalledProcessError as e:
    print(f"convert failed: {e}")
