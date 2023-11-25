
/*
	manipulate d88/d87 disk images (5"/3.5")

	make a blank disk (w/ NEC logical format for 1dd/2d)
		$0 blank.d88 {1d|1dd|2d|2dd|2hd}

	TODO: make a blank disk based on an existing disk
		$0 infile.d88 blank.d88

	TODO: convert format (5"2D <=> 3.5"1DD)
		$0 infile.d88 outfile.d88 {1dd|2d}

	TODO:
		Fujitsu logical format (.d77)
		write protect on/off
		edit volume label
		inspector
		make system disk
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/fcntl.h>

//#define NEC
#define FUJITSU

#define	SECTOR_SIZE	256

struct phyfrm
{
	const char *name;
	int cyls, heads, sects;
	int format;
};

const phyfrm phyfrm_table[] =
{
	{ "1D",  35, 1, 16, 0x00 },
	{ "1DD", 80, 1, 16, 0x10 },
	{ "2D",  40, 2, 16, 0x00 },
	{ "2DD", 80, 2, 16, 0x10 },
	{ "2HD", 77, 2, 26, 0x20 },
};

struct d88_sector
{
	char m_c, m_h, m_r, m_n;
	unsigned short m_sectors;
	char m_density;
	char m_deleted;
	char m_bios_status;
	char m_reserved[5];
	unsigned short m_sector_size;
	unsigned char m_data[SECTOR_SIZE];

	d88_sector()
	{
		memset(this, 0, sizeof(*this));
		m_r = 1;
		m_n = 1;
		m_sectors = 16;
		m_sector_size = SECTOR_SIZE;
	}

	d88_sector(const phyfrm *params, int i_c, int i_h, int i_r)
	{
		m_c = i_c;
		m_h = i_h;
		m_r = i_r;
		m_n = 1;
		m_sectors = params->sects;
		m_density = m_deleted = m_bios_status = 0;
		memset(m_reserved, 0, sizeof(m_reserved));
		m_sector_size = SECTOR_SIZE;
#ifdef NEC
		memset(m_data, 0xff, sizeof(m_data));
#endif
#ifdef FUJITSU
		memset(m_data, 0xe5, sizeof(m_data));
#endif
	}
};

struct d88_header
{
	char m_name[17];
	char m_reserved[9];
	char m_protected;
	char m_format;
	unsigned int m_disk_size;
	unsigned int m_track_data_table[164];

	d88_header()
	{
		memset(this, 0, sizeof(*this));
		m_disk_size = sizeof(d88_header);
	}

	d88_header(const phyfrm *params, const char *i_name = "")
	{
		strncpy(m_name, i_name, sizeof(m_name));
		memset(m_reserved, 0, sizeof(m_reserved));
		m_protected = 0;
		m_format = params->format;
		m_disk_size = sizeof(d88_header) + 
			params->cyls * params->heads * params->sects * sizeof(d88_sector);
		memset(m_track_data_table, 0, sizeof(m_track_data_table));
		for (int track = 0; track < params->cyls * params->heads; track++)
		{
			m_track_data_table[track] = sizeof(d88_header) + 
				sizeof(d88_sector) * params->sects * track;
		}
	}
};

bool format_by_params(const char *outfile, const struct phyfrm *params)
{
	struct stat st;
	if (stat(outfile, &st) >= 0)
	{
		fprintf(stderr, "%s exists\n", outfile);
		return false;
	}

	int fd = creat(outfile, 0644);
	if (fd < 0)
	{
		fprintf(stderr, "cannot create %s\n", outfile);
		return false;
	}

	printf("creating %s disk\n", params->name);
	d88_header header(params, params->name);
	if (write(fd, &header, sizeof(header)) < sizeof(header))
	{
		fprintf(stderr, "disk full writing %s\n", outfile);
		close(fd);
		return false;
	}

	for (int cyl = 0; cyl < params->cyls; cyl++)
	{
		for (int head = 0; head < params->heads; head++)
		{
			for (int sect = 1; sect <= params->sects; sect++)
			{
				//fprintf(stderr, "C:%d H:%d S:%d\n", cyl, head, sect);
				d88_sector sector(params, cyl, head, sect);
#ifdef NEC
				// 5" 2D
				if (params->cyls == 40 && params->heads == 2 && 
					cyl == 18 && head == 1)
				{
					if (sect == 13)
					{
						// ID
						memset(sector.m_data, 0, sizeof(sector.m_data));
					}
					if (14 <= sect)
					{
						// FAT
						int clus = (cyl * 2 + head) * 2;
						sector.m_data[clus    ] = 0xfe;
						sector.m_data[clus + 1] = 0xfe;
					}
				}

				// 3.5" 1DD
				if (params->cyls == 80 && params->heads == 1 && cyl == 37)
				{
					// 2D
					if (sect == 13)
					{
						// ID
						memset(sector.m_data, 0, sizeof(sector.m_data));
					}
					if (14 <= sect)
					{
						// FAT
						int clus = cyl * 2;
						sector.m_data[clus    ] = 0xfe;
						sector.m_data[clus + 1] = 0xfe;
					}
				}
#endif
#ifdef FUJITSU
				// 5" 2D
				if (params->cyls == 40 && params->heads == 2)
				{
					if (cyl == 0 && head == 0 && sect == 3)
					{
						// ID
						memset(sector.m_data, 0, sizeof(sector.m_data));
						strncpy(sector.m_data[0], "S  ", 3);
					}
					if (cyl == 1)
					{
						// FAT/rootdir
						memset(sector.m_data, 0xff, sizeof(sector.m_data));
						if (sect == 1)
							sector.m_data[0] = 0;
					}
				}
#endif
				if (write(fd, &sector, sizeof(sector)) < sizeof(sector))
				{
					fprintf(stderr, "disk full writing %s\n", outfile);
					close(fd);
					return false;
				}
			}
		}
	}

	close(fd);
	return true;
}

bool format_by_copy(const char *infile, const char *outfile)
{
	struct stat st;
	if (stat(infile, &st) < 0)
	{
		fprintf(stderr, "%s not exist\n", infile);
		return false;
	}
	if (stat(outfile, &st) >= 0)
	{
		fprintf(stderr, "%s exists\n", outfile);
		return false;
	}

	int ifd = open(infile, O_RDONLY | O_BINARY);
	if (ifd < 0)
	{
		fprintf(stderr, "cannot open %s\n", infile);
		return false;
	}

	int ofd = creat(outfile, 0644);
	if (ofd < 0)
	{
		fprintf(stderr, "cannot create %s\n", outfile);
		close(ifd);
		return false;
	}

	d88_header header;

	close(ifd);
	close(ofd);
	return false;
}

int main(int argc, const char **argv)
{
	if (argc != 3)
	{
		fputs("usage:\n\t$0 infile outfile\n\t$0 outfile {1d|1dd|2d|2dd|2hd}\n", stderr);
		exit(EXIT_FAILURE);
	}

	bool result = false;
	for (int i = 0; i < sizeof(phyfrm_table)/sizeof(struct phyfrm); i++)
	{
		if (strcasecmp(phyfrm_table[i].name, argv[2]) == 0)
		{
			result = format_by_params(argv[1], &phyfrm_table[i]);
			goto end;
		}
	}
	result = format_by_copy(argv[1], argv[2]);

end:
	exit(result ? EXIT_SUCCESS : EXIT_FAILURE);
}

