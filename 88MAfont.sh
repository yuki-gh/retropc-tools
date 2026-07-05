#! /bin/bash

# dump font in PC-8801MA_16.rom from https://archive.org/details/pc-8801ma-rom-dump

set -eu
set -o pipefail

infile="$1"

# 8x8 ANK+GRPH

printf "P4\n8 128\n" > header.txt

for x in $(seq 0 15)
do
	rm -f out.bin
	for y in $(seq 0 15)
	do
		echo $x-$y
		for r in $(seq 0 3)
		do
			dd if="$1" bs=1 count=1 skip=$((0x50800+$x*64+$y*4+$r)) 2>/dev/null >> out.bin
			dd if="$1" bs=1 count=1 skip=$((0x40800+$x*64+$y*4+$r)) 2>/dev/null >> out.bin
		done
	done
	cat header.txt out.bin > $x.pbm
done
convert +append ?.pbm  ??.pbm 8x8.png
rm ?.pbm ??.pbm out.bin header.txt

# 8x16 ANK+ひらがな

printf "P4\n8 256\n" > header.txt

for x in $(seq 0 15)
do
	rm -f out.bin
	for y in $(seq 0 15)
	do
		echo $x-$y
		for r in $(seq 0 7)
		do
			dd if="$1" bs=1 count=1 skip=$((0x50000+$x*128+$y*8+$r)) 2>/dev/null >> out.bin
			dd if="$1" bs=1 count=1 skip=$((0x40000+$x*128+$y*8+$r)) 2>/dev/null >> out.bin
		done
	done
	cat header.txt out.bin > $x.pbm
done
convert +append ?.pbm  ??.pbm 8x16.png
rm ?.pbm ??.pbm out.bin header.txt

# 非漢字 1～7区

printf "P4\n8 256\n" > header.txt

for ku in $(seq 7)
do
	for slice in 0 1 2
	do
		for sub in 0 1
		do
			dd if="$1" skip=$((0x41200+0x1000*$slice+16*32*($ku-1)+16*16*$sub)) bs=1 count=$((16*16)) of=right.bin
			dd if="$1" skip=$((0x51200+0x1000*$slice+16*32*($ku-1)+16*16*$sub)) bs=1 count=$((16*16)) of=left.bin
			cat header.txt right.bin > right.pbm
			cat header.txt  left.bin >  left.pbm
			convert +append left.pbm right.pbm $ku-$slice-$sub.png
		done
	done
	convert +append $ku-?-?.png 0$ku.png
done

# 第一水準 16～31区

for ku in $(seq 16 31)
do
	for slice in 0 1 2
	do
		for sub in 0 1
		do
			dd if="$1" skip=$((0x46000+0x4000*$slice+16*32*($ku-16)+16*16*$sub)) bs=1 count=$((16*16)) of=right.bin
			dd if="$1" skip=$((0x56000+0x4000*$slice+16*32*($ku-16)+16*16*$sub)) bs=1 count=$((16*16)) of=left.bin
			cat header.txt right.bin > right.pbm
			cat header.txt  left.bin >  left.pbm
			convert +append left.pbm right.pbm $ku-$slice-$sub.png
		done
	done
	convert +append $ku-?-?.png $ku.png
done

for ku in $(seq 32 47)
do
	for slice in 0 1 2
	do
		for sub in 0 1
		do
			dd if="$1" skip=$((0x44000+0x4000*$slice+16*32*($ku-32)+16*16*$sub)) bs=1 count=$((16*16)) of=right.bin
			dd if="$1" skip=$((0x54000+0x4000*$slice+16*32*($ku-32)+16*16*$sub)) bs=1 count=$((16*16)) of=left.bin
			cat header.txt right.bin > right.pbm
			cat header.txt  left.bin >  left.pbm
			convert +append left.pbm right.pbm $ku-$slice-$sub.png
		done
	done
	convert +append $ku-?-?.png $ku.png
done

rm header.txt right.bin left.bin right.pbm left.pbm *-?-?.png

# 第二水準 48～79区

printf "P4\n16 256\n" > header.txt

for ku in $(seq 48 79)
do
	for slice in 0 1 2
	do
		for sub in 0 1
		do
			dd if="$1" skip=$((0x68000+0x8000*$slice+32*32*($ku-48)+32*16*$sub)) bs=1 count=$((32*16)) of=out.bin
			cat header.txt out.bin > $ku-$slice-$sub.pbm
		done
	done
	convert +append $ku-?-?.pbm $ku.png
done

# 第二水準 80～83区

for ku in $(seq 80 83)
do
	for slice in 0 1 2
	do
		for sub in 0 1
		do
			dd if="$1" skip=$((0x62000+0x2000*$slice+32*32*($ku-80)+32*16*$sub)) bs=1 count=$((32*16)) of=out.bin
			cat header.txt out.bin > $ku-$slice-$sub.pbm
		done
	done
	convert +append $ku-?-?.pbm $ku.png
done

rm header.txt out.bin *-?-?.pbm

