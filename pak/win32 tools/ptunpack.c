#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

static uint8_t compCode = 181;

static bool unpack(const char *filenameIn, const char *filenameOut);

int main(int argc, char *argv[])
{
	char inName[4096+1], tmpFileName[4096+1];

	if (argc < 2 || argc > 3)
	{
		printf("Usage: ptunpack <filename.pak> [--rle-id]\n");
		printf("  --rle-id decvalue     Sets the compactor code. 181 is used if not entered.\n\n");
		return -1;
	}

	strcpy(inName, argv[1]);
	if (argc == 3)
		compCode = (uint8_t)atoi(argv[2]);

	size_t filenameLen = strlen(inName);

	strcpy(tmpFileName, inName);
	tmpFileName[filenameLen-3] = 'r';
	tmpFileName[filenameLen-2] = 'a';
	tmpFileName[filenameLen-1] = 'w';
	unpack(inName, tmpFileName);

	return 0;
}

static bool unpack(const char *filenameIn, const char *filenameOut)
{
	FILE *in = fopen(filenameIn, "rb");
	if (in == NULL)
	{
		printf("ERROR: Could not open input file for reading!\n");
		return false;
	}

	// fetch input file length
	fseek(in, 0, SEEK_END);
	size_t packedLen = ftell(in);
	rewind(in);

	uint8_t *src = (uint8_t *)malloc(packedLen);
	if (src == NULL)
	{
		fclose(in);
		printf("ERROR: Out of memory! (tried to alloc %d bytes...)\n", packedLen);
		return false;
	}

	// read input file to buffer
	fread(src, 1, packedLen, in);
	fclose(in);

	uint32_t decodedLength = (src[0] << 24) | (src[1] << 16) | (src[2] << 8) | src[3];
	if (decodedLength >= (1 << 20))
	{
		free(src);
		printf("ERROR: Internal error.\n");
		return false;
	}

	uint8_t *tmpBuffer = (uint8_t *)malloc(decodedLength + 16); // needs some padding
	if (tmpBuffer == NULL)
	{
		free(src);
		printf("ERROR: Out of memory! (tried to alloc %d bytes...)\n", decodedLength + 16);
		return false;
	}

	uint8_t *packSrc = src + 4;
	uint8_t *packDst = tmpBuffer;

	// RLE decode

	int32_t i = packedLen - 4;
	while (i > 0)
	{
		const uint8_t byte = *packSrc++;
		if (byte == compCode)
		{
			uint16_t count = *packSrc++;
			const uint8_t data = *packSrc++;
			while (count >= 0)
			{
				*packDst++ = data;
				count--;
			}

			i -= 2;
		}
		else
		{
			*packDst++ = byte;
		}

		i--;
	}

	free(src);

	FILE *out = fopen(filenameOut, "wb");
	if (out == NULL)
	{
		free(tmpBuffer);
		printf("ERROR: Could not open output file for writing!\n");
		return false;
	}

	fwrite(tmpBuffer, 1, decodedLength, out);
	fclose(out);

	free(tmpBuffer);

	printf("Done. Unpacked length: %d (0x%08X)\n", decodedLength, decodedLength);
	return true;
}
