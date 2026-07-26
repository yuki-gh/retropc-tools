#! /bin/bash

set -euC

cat Q10KJMF_NO[2-6]_[123][AB].bin > temp.bin
split -b 5120 temp.bin
rm temp.bin

i=0
for f in xa[a-p]
do
	python3 epson-qx-10-rom.py $f X$i.png --cut
	i=$((i+1))
done
rm xa[a-p]

split -b 3072 Q10KJMF_NO1_1A.bin
i=0
for f in xa[a-f]
do
	python3 epson-qx-10-rom.py $f J$i.png
	i=$((i+1))
done
rm xa[a-f]
