                ProTracker v2.3F 
         ==============================
              14th of April, 2025

 If you find any bugs, please email me at the email/Discord found on
 the website 16-bits.org.

 NOTE:
  This specific version is fully 128kB sample compliant, so if you use
  loop points above the 64kB barrier, then the module will fail to
  play correctly on most ProTracker versions, except some 3.x ones.

 PT2.3D by:
 - Peter "CRAYON" Hanning
 - Lars "ZAP" Hamre
 - Detron

 PT2.3E/PT2.3F by:
 - Olav "8bitbubsy" Sorensen

 -- PT2.3F changelog: --
 
 == Update 14.04.2025 ===============================================
 - SHIFT + ALT/CTRL + z = play sample range (hi XSM!)
 ====================================================================
 
 == Update 13.04.2025 ===============================================
 - You can now use SHIFT + ALT/CTRL + left/right/up/down to adjust
   the sample data mark in the sampler screen.
 - Removed some unneeded stuff (PT lock & "show rasterbar" keys)
 ====================================================================

 == Update 10.04.2025 ===============================================
 - Sample loops are now updated properly when dragging the loop
   points while the sample is playing.
 ====================================================================

 == Update 17.11.2024 ===============================================
 - Small arpeggio effect optimization
 ====================================================================
  
 == Update 12.09.2024 ===============================================
 - Bug-fix and speed-up of the volume change ("VOL") function in
   Edit Op. #3.
 ====================================================================

 == Update 09.10.2023 ===============================================
 - The following sample editing functions have been optimized to take
   less time to complete:
    1) Resample (Sampler screen)
    2) Volume ("RAMP") (Sampler screen)
    3) Volume change ("VOL") (Edit Op. #3)
    4) Fade Up ("FU") (Edit Op. #3)
    5) Fade Down ("FD") (Edit Op. #3)
    6) Boost (Edit Op. #3, only very lightly optimized)
    7) Filter (Edit Op. #3)
    8) X-Fade (Edit Op. #3, only very lightly optimized)
    9) Mix (Edit Op. #3)
 - The sample chord editor now produces better samples (16-bit mixing
   + normalized gain before converting to 8-bit), and takes up less
   RAM. It's still as slow as before, if not slightly slower.
 - Removed the custom length stuff from the sample chord editor. I
   don't really think they were all that useful.
 - Slightly reduced the duration of "red mouse cursor" errors
 - A sample's waveform no longer "wiggles" while scrolling through it
   in the sampler screen. It still flickers, though.
 - The mouse now moves slightly more smoothly (no crude acceleration)
 - Bugfix: Redraw sample after having mixed ("MIX") samples together
 - Removed the Karplus-Strong (E8x) command/effect. Not only was it
   not documented anywhere, but it was the most useless and annoying
   effect to ever exist. Probably also the least used.
 - Removed CTRL+V (filter all samples) and CTRL+G (boost all samples)
 - Edited and cleaned up the PT help file
 ====================================================================
 
 == Update 14.06.2023 ===============================================
 - The spectrum analyzer didn't work like it should when jamming
   samples with the computer keyboard (if finetune wasn't zero).
 - Nasty out-of-bounds memory access fixed for the spectrum analyzer
   in some edge cases.
 ====================================================================
 
 == Update 08.03.2023 ===============================================
 - Fixed: Another vblank+>31 speed fix, for Note Retrigger (E9x)
 - Removed note retrigger LUT (was used to remove DIV). Frees up
   around 528 bytes of RAM. This optimization was a bit pointless as
   a bunch of note retriggers at once is very uncommon.
 ====================================================================
 
 == Update 07.03.2023 ===============================================
 - Fixed: Text editing delays were too short when writing/deleting
   characters and moving the text cursor (in comparison to PT2.3D).
 - Fixed: If arpeggio was used in vblank timing mode together with a
   speed above 31, it would not work correctly.
 - Fixed: Changing speed in SETUP was wrongly limited to 0..32.
   (I had forgotten about vblank timing mode when I made this change)
 - Lowered process stack from 16kB to 2kB, to free up more RAM for
   systems like a stock A500.
 - The waveform plotter in the sample editor has been given a small
   optimization. It's still very slow and flickery on a 7MHz 68k
   Amiga, though...
 ====================================================================
 
 == Update 25.01.2023 ===============================================
 - Fixed: Weird things would happen if you were in text/number edit
   mode while efx F00 (stop song) got triggered (hi again Per Arne)
 ====================================================================

 == Update 11.01.2023 ===============================================
 - Some specific errors (e.g. "CAN'T FIND DIR !") could cause a
   messed up Workbench screen on exit.
 - Allow CTRL+Fn (Record From) keys while the sampler screen is open
   (hi Per Arne).
 ====================================================================

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
