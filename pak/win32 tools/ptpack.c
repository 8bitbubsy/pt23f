#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#define COMPACTOR_CODE 181
#define RLE_BYTES_THRESHOLD 4 /* minimum equal running bytes for RLE */

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

static bool pack(const char *filenameIn, const char *filenameOut);

int main(int argc, char *argv[])
{
	// detect endianness
	volatile uint32_t endiantest32 = 0xFF;
	bigEndian = (*(uint8_t *)&endiantest32 != 0xFF);
	
	if (argc != 2)
	{
		printf("Usage: ptpack <filename.raw>\n");
		return -1;
	}

	strcpy(tmpFilename, argv[1]);

	uint32_t filenameLen = (uint32_t)strlen(tmpFilename);
	if (filenameLen >= 5)
		tmpFilename[filenameLen-4] = '\0';
	strcat(tmpFilename, ".pak");
	
	if (!pack(argv[1], tmpFilename))
		return 1;
	else
		return 0;
}

static bool pack(const char *filenameIn, const char *filenameOut)
{
	FILE *in = fopen(filenameIn, "rb");
	if (in == NULL)
	{
		printf("ERROR: Could not open input file for reading!\n");
		return false;
	}

	// get input file length
	fseek(in, 0, SEEK_END);
	uint32_t srcDataLen = (uint32_t)ftell(in);
	rewind(in);

	uint8_t *srcData = (uint8_t *)malloc(srcDataLen);
	if (srcData == NULL)
	{
		fclose(in);
		printf("ERROR: Out of memory!\n");
		return false;
	}

	fread(srcData, 1, srcDataLen, in);
	fclose(in);
	
	uint8_t *dstData = (uint8_t *)malloc(srcDataLen*3); // *3 should work in all cases
	if (dstData == NULL)
	{
		free(srcData);
		printf("ERROR: Out of memory!\n");
		return false;
	}
	
	uint8_t *src = srcData;
	uint8_t *dst = dstData;
	uint8_t *srcEnd = srcData+srcDataLen;
	
	while (src < srcEnd)
	{
		uint8_t byte = *src++;
		if (byte == COMPACTOR_CODE) // byte is equal to RLE ID, special case
		{
			*dst++ = COMPACTOR_CODE; // RLE identifier
			*dst++ = 0; // RLE count (minus one)
			*dst++ = COMPACTOR_CODE; // RLE data
			continue;
		}
		
		// scan amount of equal following bytes
		
		uint16_t count;
		for (count = 0; count < 256; count++)
		{
			if (src+count >= srcEnd || byte != src[count])
				break;
		}
		
		src += count;
		count++;

		if (count < RLE_BYTES_THRESHOLD)
		{
			// too few equal bytes, store them instead of compressing
			memset(dst, byte, count);
			dst += count;
		}
		else
		{
			if (count > 256) // edge case
			{
				count = 256;
				src -= 2;
			}
			
			*dst++ = COMPACTOR_CODE; // RLE identifier
			*dst++ = (uint8_t)(count-1); // RLE count (minus one)
			*dst++ = byte; // RLE data
		}
	}
	free(srcData);
	
	FILE *out = fopen(filenameOut, "wb");
	if (out == NULL)
	{
		free(dstData);
		printf("ERROR: Could not open output file for writing!\n");
		return false;
	}

	// write unpacked length dword
	uint32_t dword = srcDataLen;
	if (!bigEndian)
		dword = SWAP32(dword);
	fwrite(&dword, 4, 1, out);

	// write pack data
	uint32_t packedLength = (uint32_t)(dst - dstData);
	fwrite(dstData, 1, packedLength, out);
	packedLength += 4;

	fclose(out);

	free(dstData);

	printf("RLE encoding done!\n");
	printf("=============================================\n");
	printf("    Original size: %d bytes\n", srcDataLen);
	printf("     Encoded size: %d bytes\n", packedLength);
	printf("Compression ratio: %.3f", srcDataLen / (double)packedLength);

	if (srcDataLen == packedLength)
		printf("\n");
	else if (srcDataLen > packedLength)
		printf(" (bytes saved: %d)\n", srcDataLen - packedLength);
	else
		printf(" (bytes wasted: %d)\n", packedLength - srcDataLen);

	return true;
}
