# ProTracker 2.3F
Continuation of the ProTracker 2 series for Amiga 68k, based on a disassembly and re-source of ProTracker 2.3D. \
Download: https://16-bits.org/PT23F.LHA \
\
Some new changes worthy of a mention:
1) It has been fully bugfixed to work as expected on really fast Amigas (a ton of CPU-wait-routines have been replaced with scanline-wait and other safe delay routines)
2) It has been modified to fully support 128kB samples (all the old >64kB (>$FFFE) limits/bugs are gone, both in the player and GUI)
3) A ton of other bugs have been fixed

The asm syntax is AsmOne/AsmPro, and it may not be compatible with other assemblers.
