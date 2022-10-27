                ProTracker v2.3F 
         ==============================
              27th of October, 2022

 If you find any bugs, please email me at olav.sorensen@live.no
 Based on a disassembly of PT2.3D.

 NOTE:
  This specific version is fully 128kB sample compliant, so
  if you use loop points above the 64kB barrier, then the
  module will fail to play correctly on most ProTracker
  versions except some 3.x ones.

 PT2.3D by:
 - Peter "CRAYON" Hanning
 - Lars "ZAP" Hamre
 - Detron

 PT2.3E/PT2.3F by:
 - Olav "8bitbubsy" Sorensen

 Recommended CPU speed for PT2.3E/PT2.3F:
 - 14MHz+

 For *optimal* tracker performance, have:
 - 2MB chipmem
 - At least 1MB of fastmem
 - 68020 or better CPU


 -- PT2.3F changelog: --

 == Update 27.10.2022 ===============================================
 - "Sample exchange" on sample 31/$1F would cause severe instability
 - Loading IFF samples would result in junk after the sample data
 - Some of the delay durations (setting edit skip, red mouse pointer
   etc.) were too short in comparison to previous PT versions.
 ====================================================================

 == Update 04.08.2022 ===============================================
 - Don't allow 'loop toggle' (sampler screen) on empty samples.
   It would set replen to 0, which could make crazy things happen...
 ====================================================================

 == Update 30.05.2022 ===============================================
 - Fixed EDx command causing a guru in 14.04.2022 version.
   Sorry again! This was a stupid mistake.
 ====================================================================

 == Update 14.04.2022 ===============================================
 - Fixed severely broken E9x command from 03.03.2022 version (sorry!)
 ====================================================================

 == Update 03.03.2022 ===============================================
 - Miscellaneous bug fixes ("Play Waveform", "Play Range", + more)
 - Fixed quadrascope period clamping bug 
 - Fixed sample playback line not showing when using "real" VU-meters
 ====================================================================

 == Update 20.01.2021 ===============================================
 - Fixed a bug where ending a parallel port sample session before
   filling the whole buffer, would render the tracker unstable.
 - The quadrascope shouldn't read out-of-bounds anymore on
   non-looping samples.
 - Another minor quadrascope fix
 ====================================================================

 == Update 18.01.2021 ===============================================
 - Fix >64kB bugs in the parallel port sampling code
 ====================================================================

 == Update 14.07.2020 ===============================================
 - Bugfix for 68000: Pasting to an empty sample would cause a crash
 ====================================================================

 == Update 30.05.2020 ===============================================
 - Fixed: The scopes would show a blank waveform when using 9xx
   (set sample offset) on a non-looping sample
 ====================================================================

 == Update 09.05.2020 ===============================================
 - Had to revert some of the IFF fixes because they would cause
  memory leaks...
 ====================================================================

 == Update 02.03.2020 ===============================================
 - Fixed: RAW sample loading got broken at 20.02.2020. Sorry!
 ====================================================================

 == Update 20.02.2020 ===============================================
 - Bugfix: Loading an .iff sample longer than 128kB would result in
   131070-(64..256) bytes instead of 131070 bytes.
 - Bugfix: When loading .iff samples, the "DISP:" value in the SAMPLER
   screen would be too big, and thus it whould show overflowed data.
 - Bugfix: Moving the right loop pin (SAMPLER screen) could behave
   strange on samples bigger than $FFFE/65534.
 ====================================================================

 == Update 15.02.2020 ===============================================
 - Fixed crashes when loading samples (accidental typo in a stealth
   update that was not listed here).
 - Also fixed memory access issue when drawing blank scopes
 ====================================================================

 == Update 10.11.2019 ===============================================
 - The TUNE/FREE fields were not showing correct values at all times
 ====================================================================

 == Update 01.11.2019 ===============================================
 - More quadrascope fixes, of course, what did you expect? ;)
 ====================================================================

 == Update 28.10.2019 ===============================================
 - Yet again some more quadrascope bugfixes. This time the scopes will properly
   render on loops where start=0 and end<len. Also fixed a small mistake done
   by the original author.
 ====================================================================

 == Update 26.10.2019 ===============================================
 - Quadrascope now uses 16.16 fixed-point rates to not accumulate big errors
   over time when playing a long sample. Also fixed some other scope rate bugs.
 ====================================================================

 == Update 25.10.2019 ===============================================
 - Fixed a problem with selecting the palette color with the mouse in
   the setup screen (on certain Amiga configurations only).
 - Fixed a problem where the RGB sliders in the setup screen do not update
   when you toggle between "VU-MTR" and "ANALYZ".
 - All fixes after the first PT2.3E final version has now been merged to
   PT2.3F. This ought to happen to begin with, but it never did. Sorry!

 == Update 24.10.2019 ===============================================
 - The "ALL" option in the "CLEAR" dialog didn't properly reset some stuff
 - Replaced all calls to _LVOAllocMem/_LVOFreeMem with custom routines
   that adds 40 bytes of padding for out-of-bounds protection (buggy code).
   This also fixes the scopes sometimes showing garbage after a sample
   has been played, for a split second. (would also affect "real" VU-meters)
   Stupid workaround, but a huge timesaver, as I don't want to analyze
   every single memory block read/write in this whole source code...
 ====================================================================

 == Update 26.08.2019 ===============================================
 - Fixed scopes not working on high sample numbers (stupid bug I made)
 ====================================================================

 == Update 15.08.2019 ===============================================
 - Added a program icon
 - Fix config load error when ran from WB icon (thanks to ross @ abime!)
 - Fixed scopes behaving completely wrong (oops)
 ====================================================================

 == Update 17.05.2019 ===============================================
 - Slightly more accurate scope rate calculation through rounded LUT
 ====================================================================

 -- PT2.3E changelog: --

 == Update 23.02.2019 ===============================================
 - This is now considered the final release version! No new changes.
 ====================================================================

 == Update 22.09.2018 ===============================================
 - Fixed crash when trying to copy a sample to itself (Edit Op. #2)
 ====================================================================

 == Update 22.09.2018 ===============================================
 - Fixed crash when trying to copy a sample to itself (Edit Op. #2)
 ====================================================================

 == Update 24.08.2018 ===============================================
 - Fix: The "song length up" gadget clamped to 127 instead of 128
 - Add more delay to POSED. up/down gadgets (or keyboard)
 ====================================================================

 == Update 10.08.2018 ===============================================
 - Added ALT+G (Toggle record mode - song/patt)
 - Pressing any key after startup will remove the intro text scroller
 ====================================================================

 == Update 07.08.2018 =========================================================
 - PSED bugs fixed (entry select bug, proper update on cancelling insert, etc)
 - Replayer effect E4x was accidentally broken during re-sourcing, fixed
 - The "D" (Pos delete) GUI button didn't work correctly
 - If effect 9xx was used before stopping the song, the sample play line in the 
   sample editor could start at the wrong position when jamming samples.
 - If CIA B was used instead of A, it would NOT be successfully released after
   exiting the tracker. (bug exists even in PT1.2A...)
 ==============================================================================

 == Update 29.11.2017 =============================================
 - 15 sample .MODs (UST/NST) now load properly, it was a bug I made
 ==================================================================

 == Update 10.11.2017 ============================
 - The VU-Meters would act choppy on slower Amigas
 =================================================

 I forgot to write changelogs before these, but there were *a ton* of bugfixes!
