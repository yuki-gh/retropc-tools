
/*
	dump font binary

	usage: $0 infile width height num [padding [skip [options]]]
*/

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

const unsigned short ucs2n66[] = {
	0x20,
	0x2597,
	0x2596,
	0x2584,

	0x259d,
	0x2590,
	0x259e,
	0x259f,
	
	0x2598,
	0x259a,
	0x258c,
	0x2599,
	
	0x2580,
	0x259c,
	0x259b,
	0x2588,
};

int main(int argc, const char **argv)
{
	if (argc < 5 || argc > 8)
	{
		fputs(
"usage: $0 infile width height num [padding [skip [options]]]\n\
	infile:		input file (font binary)\n\
	width, height:	pixels per char\n\
	num:		num of chars\n\
	padding:	num of padding bytes between chars\n\
	skip:		num of bytes to skip from beginning (0xHEX ok)\n\
	options:	y = y direction first\n", stderr);
		exit(EXIT_FAILURE);
	}

	const char *infile = argv[1];
	int width = atoi(argv[2]);
	int height = atoi(argv[3]);
	int num = atoi(argv[4]);
	int padding = (argc > 5) ? atoi(argv[5]) : 0;
	int skip = (argc > 6) ? strtol(argv[6], NULL, 0) : 0;
	const char *options = (argc > 7) ? argv[7] : "";
	bool yfirst = strchr(options, 'y') != NULL;

	int fd = open (infile, O_RDONLY | O_BINARY);
	if (fd < 0)
	{
		perror(infile);
		exit(EXIT_FAILURE);
	}
	lseek(fd, skip, SEEK_SET);

	for (int ch = 0; ch < num; ch++)
	{
		printf("\nchar %d (0x%x)\n", ch, ch);
		unsigned char buf[256];
		ssize_t count = read(fd, buf, width * height / 8);
		if (count < width * height / 8)
			break;
		unsigned char *p = buf;

		for (int y = 0; y < height; y++)
		{
			int mask = 0x80;
			unsigned char *pp = p;
			for (int x = 0; x < width ; x++)
			{
				putchar((*p & mask) ? 'O' : '.');
				if ((mask >>= 1) == 0)
				{
					mask = 0x80;
					p += yfirst ? height : 1;
				}
			}
			putchar('\n');
			if (yfirst)
				p = pp + 1;
			else if ( mask != 0x80 )
				p++;
		}
		lseek(fd, padding, SEEK_CUR);
	}

	printf("%d bytes consumed\n", (int)lseek(fd, 0, SEEK_CUR) - skip);
	close(fd);
	exit(EXIT_SUCCESS);
}

