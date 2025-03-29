#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#define COMPACTOR_CODE 181

#define SWAP32(value) \
( \
	(((uint32_t)((value) & 0x000000FF)) << 24) | \
	(((uint32_t)((value) & 0x0000FF00)) <<  8) | \
	(((uint32_t)((value) & 0x00FF0000)) >>  8) | \
	(((uint32_t)((value) & 0xFF000000)) >> 24)   \
)

#ifdef _WIN32
#define PATH_MAX MAX_PATH
#endif

static bool bigEndian;
static char tmpFilename[PATH_MAX+4+1];

static bool unpack(const char *filenameIn, const char *filenameOut);

int main(int argc, char *argv[])
{
	// detect endianness
	volatile uint32_t endiantest32 = 0xFF;
	bigEndian = (*(uint8_t *)&endiantest32 != 0xFF);

	if (argc != 2)
	{
		printf("Usage: ptunpack <filename.pak>\n");
		return -1;
	}

	strcpy(tmpFilename, argv[1]);

	uint32_t filenameLen = (uint32_t)strlen(tmpFilename);
	if (filenameLen >= 5)
		tmpFilename[filenameLen-4] = '\0';
	strcat(tmpFilename, ".raw");
	
	if (!unpack(argv[1], tmpFilename))
		return 1;
	else
		return 0;
}

static bool unpack(const char *filenameIn, const char *filenameOut)
{
	FILE *f = NULL;
	uint8_t *srcData = NULL, *dstData = NULL;

	f = fopen(filenameIn, "rb");
	if (f == NULL)
	{
		printf("ERROR: Could not open input file for reading!\n");
		goto error;
	}

	// fetch input file length
	fseek(f, 0, SEEK_END);
	uint32_t packedLength = (uint32_t)ftell(f);
	rewind(f);

	if (packedLength <= 4) goto corruptFile;
	packedLength -= 4; // skip unpacked length field

	srcData = (uint8_t *)malloc(packedLength);
	if (srcData == NULL)
	{
		printf("ERROR: Out of memory!\n");
		goto error;
	}
	
	uint32_t unpackedLength;
	fread(&unpackedLength, 4, 1, f);
	if (!bigEndian)
		unpackedLength = SWAP32(unpackedLength);
	fread(srcData, 1, packedLength, f);
	fclose(f);
	f = NULL;
	
	if (unpackedLength == 0 || unpackedLength >= 1<<20)
		goto corruptFile;
	
	dstData = (uint8_t *)malloc(unpackedLength);
	if (dstData == NULL)
	{
		printf("ERROR: Out of memory!\n");
		goto error;
	}

	uint8_t *src = srcData;
	uint8_t *dst = dstData;
	uint8_t *srcEnd = srcData + packedLength;
	uint8_t *dstEnd = dstData + unpackedLength;
	
	// RLE decode
	while (src < srcEnd && dst < dstEnd)
	{
		const uint8_t byte = *src++;
		if (byte == COMPACTOR_CODE)
		{
			if (src >= srcEnd) goto corruptFile;
			uint16_t numBytes = (uint16_t)(*src++) + 1;

			if (src >= srcEnd) goto corruptFile;
			const uint8_t data = *src++;

			// packer is sometimes buggy, some protection is needed
			if (dst+numBytes > dstEnd)
				numBytes = dstEnd - dst;

			memset(dst, data, numBytes);
			dst += numBytes;
		}
		else
		{
			*dst++ = byte;
		}
	}
	free(srcData);

	f = fopen(filenameOut, "wb");
	if (f == NULL)
	{
		printf("ERROR: Could not open output file for writing!\n");
		goto error;
	}
	fwrite(dstData, 1, unpackedLength, f);
	fclose(f);
	free(dstData);

	printf("RLE decoding done!\n");
	printf("=============================================\n");	
	printf("Decoded size: %d bytes\n", unpackedLength);
	return true;
	
corruptFile:
	printf("ERROR: Corrupt input file!\n");
error:
	if (srcData != NULL) free(srcData);
	if (dstData != NULL) free(dstData);
	if (f       != NULL) fclose(f);
	return false;
}
