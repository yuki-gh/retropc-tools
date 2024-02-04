#! /bin/bash

# usage: $0 CGROM68.68 (or CGROM68.64)

dd if=$1 of=CGROM68_0.bin bs=4096 count=1
dd if=$1 of=CGROM68_1.bin bs=4096 count=1 skip=1
dd if=$1 of=CGROM68_2.bin bs=4096 count=1 skip=2
dd if=$1 of=CGROM68_3.bin bs=4096 count=1 skip=3
objcopy -F binary -i 16 -b 12 --interleave-width 4 CGROM68_0.bin hikanji0.bin
objcopy -F binary -i 16 -b  8 --interleave-width 8 CGROM68_1.bin hikanji1.bin
objcopy -F binary -i 16 -b 10 --interleave-width 2 CGROM68_2.bin katakana0.bin
objcopy -F binary -i 16 -b 12 --interleave-width 4 CGROM68_2.bin katakana1.bin
objcopy -F binary -i 16 -b 10 --interleave-width 2 CGROM68_3.bin hiragana0.bin
objcopy -F binary -i 16 -b 12 --interleave-width 4 CGROM68_3.bin hiragana1.bin
cat hikanji?.bin > hikanji.bin
cat katakana?.bin > katakana.bin
cat hiragana?.bin > hiragana.bin
rm CGROM68_?.bin hikanji?.bin katakana?.bin hiragana?.bin

