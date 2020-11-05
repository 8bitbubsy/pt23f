# ProTracker 2.3F
Continuation of the ProTracker 2 series for Amiga 68k, based on a disassembly and re-source of ProTracker 2.3D.

A huge amount of bugs have been fixed, and the tracker has been modified to fully support 128kB samples (e.g. the old >64kB (>$FFFE) limits/bugs are gone).
The replayer has been touched as little as possible to stay accurate, though two effects had to be bugfixed to prevent possible crashes (EFx and E8x), and a bug was fixed to support >64kB loop points.

I have only built this with AsmPro, so I don't know if it works with other assemblers.
