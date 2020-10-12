#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

static uint8_t compCode = 181;

static bool pack(const char *filenameIn, const char *filenameOut);

int main(int argc, char *argv[])
{
	char inName[4096+1], tmpFileName[4096+1];

	if (argc < 2 || argc > 3)
	{
		printf("Usage: ptpack <filename.raw> [--rle-id]\n");
		printf("  --rle-id decvalue     Sets the compactor code. 181 is used if not entered.\n\n");
		return -1;
	}

	strcpy(inName, argv[1]);
	if (argc == 3)
		compCode = (uint8_t)atoi(argv[2]);

	const size_t filenameLen = strlen(inName);

	strcpy(tmpFileName, inName);
	tmpFileName[filenameLen-3] = 'p';
	tmpFileName[filenameLen-2] = 'a';
	tmpFileName[filenameLen-1] = 'k';
	pack(inName, tmpFileName);

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
	size_t DataLen = ftell(in);
	rewind(in);

	uint8_t *DataPtr = (uint8_t *)malloc(DataLen);
	if (DataPtr == NULL)
	{
		fclose(in);
		printf("ERROR: Out of memory! (tried to alloc %d bytes...)\n", DataLen);
		return false;
	}

	fread(DataPtr, 1, DataLen, in);
	fclose(in);

	/* The following mess is a direct 68k asm of ptcompactor.s found in
	** the ProTracker 1.2A source code.
	*/
	uint8_t *a0 = NULL, *a1 = NULL;
	int32_t d0 = 0, d1 = 0, d4 = 0, d7 = 0;
	
	goto Main;

JustCode:
	*a1++ = compCode; // Output compacter code
	*a1++ = 0;        // Output zero
	*a1++ = compCode; // Output compacter code
	goto NextByte;    // Do next byte

Equal:
	d1 = d0;
	d4++;                // Add one to equal-count
	if (d4 >= 255)       // 255 or more?
		goto FlushBytes; // Yes, flush buffer
	goto NextByte;       // Do next byte

FlushBytes:
	if (d4 >= 3)         // 4 or more
		goto FourOrMore; // Yes, output codes
NotFour:
	*a1++ = d1 & 0xFF;            // Output byte
	if (--d4 != -1) goto NotFour; // Loop...
	d4 = 0;        // Zero count
	goto NextByte; // Another byte
FourOrMore:
	*a1++ = compCode;  // Output compacter code
	*a1++ = d4 & 0xFF; // Output count
	*a1++ = d1 & 0xFF; // Output byte
	d4 = 0;            // Zero count
	d0++;
	goto NextByte;    // Do next byte

Main:
	uint8_t *ToPtr = (uint8_t *)malloc(DataLen);
	if (ToPtr == NULL)
	{
		free(DataPtr);
		printf("ERROR: Out of memory! (tried to alloc %d bytes...)\n", DataLen);
		return false;
	}

	a0 = DataPtr; // From ptr.
	a1 = ToPtr;   // To ptr.
	d7 = DataLen; // Length
	d4 = 0;       // Clear count

EqLoop:
	d0 = *a0++;         // Get a byte
	if (d0 == compCode) // Same as compacter code?
		goto JustCode;  // Output JustCode

	if (d7 == 1)
		goto endskip;

	if (d0 == *a0)  // Same as previous byte?
		goto Equal; // Yes, it was equal
endskip:
	if (d4 > 0)          // Not equal, any equal buffered?
		goto FlushBytes; // Yes, output them
	*a1++ = d0 & 0xFF;   // Output byte
	d4 = 0;
NextByte:
	d7--;                    // Subtract 1 from length
	if (d7 > 0) goto EqLoop; // Loop until length = 0

	if (d4 == 0)    // Any buffered bytes?
		goto endok; // No, goto end

	if (d4 >= 3)          // More than 4?
		goto FourOrMore2; // Yes, skip
NotFour2:
	*a1++ = d0 & 0xFF;             // Output byte
	if (--d4 != -1) goto NotFour2; // Loop...
	goto endok;                    // Goto end;
FourOrMore2:
	*a1++ = compCode;  // Output compacter code
	*a1++ = d4 & 0xFF; // Output count
	*a1++ = d0 & 0xFF; // Output byte
endok:
	free(DataPtr);

	FILE *out = fopen(filenameOut, "wb");
	if (out == NULL)
	{
		free(ToPtr);
		printf("ERROR: Could not open output file for writing!\n");
		return false;
	}

	fputc((DataLen & 0xFF000000) >> 24, out);
	fputc((DataLen & 0x00FF0000) >> 16, out);
	fputc((DataLen & 0x0000FF00) >>  8, out);
	fputc((DataLen & 0x000000FF) >>  0, out);

	fwrite(ToPtr, 1, (uint32_t)(a1 - ToPtr), out);
	fclose(out);

	free(ToPtr);

	printf("Done. Packed length: %d (0x%08X)\n", (uint32_t)(a1 - ToPtr) + 4, (uint32_t)(a1 - ToPtr) + 4);
	return true;
}
