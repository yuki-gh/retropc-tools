#! /usr/bin/env python

# import io
import os
import sys


def main():
	len1 = os.path.getsize(sys.argv[1])
	len2 = os.path.getsize(sys.argv[2])
	if len1 != len2:
		exit()

	with (open(sys.argv[1], 'rb') as infile1,
	      open(sys.argv[2], 'rb') as infile2,
	      open(sys.argv[3], 'wb') as outfile):
		inbuf1 = infile1.read()
		inbuf2 = infile2.read()
		outbuf = bytearray(len1 + len2)
		for i in range(len1):
			outbuf[i*2  ] = inbuf1[i]
			outbuf[i*2+1] = inbuf2[i]
		outfile.write(outbuf)


if __name__ == "__main__":
	main()
