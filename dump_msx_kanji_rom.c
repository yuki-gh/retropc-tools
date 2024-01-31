
/*
	MSXの漢字ROMフォントを画像化する

	$0 kanji.rom
	でカレントに以下のファイルを出力
	ascii_8x11.pbm
	ascii_8x16.pbm
	nonkanji.pbm
	kana_8x12.pbm
	kana_8x16.pbm
	sym_8x11.pbm
	sym_8x16.pbm
	kanji1.pbm
	kanji2.pbm
	あとは
	for f in *.pbm; do convert $f ${f%.pbm}.png; done
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

void dump(int fd, const char *outfile, int num, int skip, int numx)
{
	FILE *fp = fopen(outfile, "wb");
	if (fp == NULL)
		return;
	fprintf(fp, "P4\n%d %d\n", 8 * numx, (num + numx - 1) / numx * 16);

	lseek(fd, skip, SEEK_SET);
	int bs = 8;
	char *inbuf = malloc(bs * 4 * num);
	char *outbuf = malloc(bs * 2 * num);
	char *p = inbuf;
	for (int i = 0; i < num; i++)
	{
		read(fd, p, bs);
		lseek(fd, bs, SEEK_CUR);
		p += bs;
		read(fd, p, bs);
		lseek(fd, bs, SEEK_CUR);
		p += bs;
	}
	memset(outbuf, 0, bs * 2 * num);
	char *q = outbuf;
	p = inbuf;

	for (int i = 0; i < num; i += numx)
	{
		for (int y = 0; y < 16; y++)
		{
			char *pp = p;
			for (int x = 0; x < numx; x++)
			{
				*q++ = *p;
				p += bs * 2;
			}
			p = pp + 1;
		}
		p += 16 * (numx - 1);
	}

	fwrite(outbuf, bs * 2, num, fp);
	free(inbuf);
	free(outbuf);
	fclose(fp);
}

void dumpw(int fd, const char *outfile, int num, int skip, int numx)
{
	num = (num + 15) & ~15;

	FILE *fp = fopen(outfile, "wb");
	if (fp == NULL)
		return;
	fprintf(fp, "P4\n%d %d\n", 16 * numx, (num + numx - 1) / numx * 16);

	lseek(fd, skip, SEEK_SET);
	int bs = 8;
	char *inbuf = malloc(bs * 4 * num);
	char *outbuf = malloc(bs * 4 * num);
	char *p = inbuf;
	for (int i = 0; i < num; i++)
	{
		read(fd, p, bs);
		lseek(fd, bs, SEEK_CUR);
		p += bs;
		read(fd, p, bs);
		lseek(fd, -bs*2, SEEK_CUR);
		p += bs;
		read(fd, p, bs);
		lseek(fd, bs, SEEK_CUR);
		p += bs;
		read(fd, p, bs);
		p += bs;
	}
	memset(outbuf, 0, bs * 2 * num);
	char *q = outbuf;
	p = inbuf;

	for (int i = 0; i < num; i += numx)
	{
		for (int y = 0; y < 16; y++)
		{
			char *pp = p;
			for (int x = 0; x < numx * 2; x++)
			{
				*q++ = *p;
				p += bs * 2;
			}
			p = pp + 1;
		}
		p += 16 * (numx * 2 - 1);
	}

	fwrite(outbuf, bs * 4, num, fp);
	free(inbuf);
	free(outbuf);
	fclose(fp);
}

int main(int argc, const char **argv)
{
	const char *infile = argv[1];

	int fd = open (infile, O_RDONLY
#ifdef O_BINARY
		| O_BINARY
#endif
		);
	if (fd < 0)
		exit(1);

	dump(fd, "ascii_8x16.pbm", 96, 0, 16);
	dump(fd, "ascii_8x11.pbm", 96, 8, 16);

	dumpw(fd, "nonkanji.pbm", 96*8, 0xc00, 32);

	dump(fd, "kana_8x16.pbm", 64, 0x6c00, 16);
	dump(fd, "kana_8x12.pbm", 64, 0x6c08, 16);
	dump(fd, "sym_8x16.pbm", 32, 0x7400, 16);
	dump(fd, "sym_8x11.pbm", 32, 0x7408, 16);
	// 0x7800 blank 8x16 128chars

	dumpw(fd, "kanji1.pbm", 96*32, 0x8000, 96);
	dumpw(fd, "kanji2.pbm", 96*36, 0x20000, 96);
	// 0x3b000 blank 16x16 640chars

}
