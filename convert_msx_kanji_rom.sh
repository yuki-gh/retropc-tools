#! /bin/bash

infile="$1"

outfile=ascii_8x16.pbm
chars=96

echo "P4" > $outfile
echo "8 $((16*$chars))" >> $outfile

i=0
while [ $i -lt $chars ]
do
	dd if=$infile of=frac.bin bs=8 skip=$(($i*4)) count=1 2>/dev/null
	cat frac.bin >> $outfile
	dd if=$infile of=frac.bin bs=8 skip=$(($i*4+2)) count=1 2>/dev/null
	cat frac.bin >> $outfile
	i=$(($i+1))
done
rm frac.bin

outfile=ascii_8x11.pbm
chars=96

echo "P4" > $outfile
echo "8 $((16*$chars))" >> $outfile

i=0
while [ $i -lt $chars ]
do
	dd if=$infile of=frac.bin bs=8 skip=$(($i*4+1)) count=1 2>/dev/null
	cat frac.bin >> $outfile
	dd if=$infile of=frac.bin bs=8 skip=$(($i*4+3)) count=1 2>/dev/null
	cat frac.bin >> $outfile
	i=$(($i+1))
done
rm frac.bin


