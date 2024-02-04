
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
	options:	y = y direction first, f = flip bits\n", stderr);
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
	bool flip   = strchr(options, 'f') != NULL;

	int fd = open (infile, O_RDONLY
#ifdef O_BINARY
		| O_BINARY
#endif
		);
	if (fd < 0)
	{
		perror(infile);
		exit(EXIT_FAILURE);
	}
	lseek(fd, skip, SEEK_SET);
	printf("0x%x - 0x%x\n", skip, skip + (width / 8 * height + padding) * num - 1);

	int mask_init = flip ? 0x01 : 0x80;
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
			int mask = mask_init;
			unsigned char *pp = p;
			for (int x = 0; x < width ; x++)
			{
				putchar((*p & mask) ? 'O' : '.');
				mask = flip ? (mask << 1) : (mask >> 1);
				if ((mask & 0xff) == 0)
				{
					mask = mask_init;
					p += yfirst ? height : 1;
				}
			}
			putchar('\n');
			if (yfirst)
				p = pp + 1;
			else if ( mask != mask_init )
				p++;
		}
		lseek(fd, padding, SEEK_CUR);
	}

	printf("%d bytes consumed\n", (int)lseek(fd, 0, SEEK_CUR) - skip);
	close(fd);
	exit(EXIT_SUCCESS);
}

