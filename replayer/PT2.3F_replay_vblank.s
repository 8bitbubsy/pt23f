;*******************************************************
;* ---- ProTracker V2.3F Replay Routine (VBlank) ----  *
;*******************************************************
;
; This is the vblank version of the PT2.3F replayer. If you don't know
; the difference between CIA and vblank, you probably want to use the
; CIA version instead.
;
; This replayer has been slightly optimized over the PT2.3D replayer,
; but it's still far from fully optimized. It has also been rewritten to
; behave like PT2.3F's internal replayer, for maximum accuracy.
;
; Changelog:
; - 13.03.2025: Initial version
;

; Simple test code. Attempts to call mt_music() 50 times a second, but may play
; at the wrong tempo, especially in some emulator configs.
main
	BSR.W	mt_init			; setup module
mloop	; ---------------------------
vloop	MOVE.L	$DFF004,D0		; wait for vblank
	AND.L	#$1FF00,D0
	CMP.L	#303<<8,D0
	BNE.B	vloop
	; ---------------------------
	BTST	#6,$BFE001		; test for mouse button
	BEQ.B	exit
	; ---------------------------
	BSR.W	mt_music
	; ---------------------------
	BRA.B	mloop
exit	BSR.W	mt_end
	RTS

LEDStatus	dc.b 0
	EVEN

;---- Playroutine ----

n_note		EQU 0  ; W (MUST be first!)
n_cmd		EQU 2  ; W (MUST be second!)
n_cmdlo		EQU 3  ; B (offset in n_cmd)
n_start		EQU 4  ; L (aligned)
n_loopstart	EQU 8  ; L
n_wavestart	EQU 12 ; L
n_peroffset	EQU 16 ; L (offset to finetuned period-LUT section)
n_length	EQU 20 ; W (aligned)
n_replen	EQU 22 ; W
n_period	EQU 24 ; W
n_dmabit	EQU 26 ; W
n_wantedperiod	EQU 28 ; W
n_finetune	EQU 30 ; B
n_volume	EQU 31 ; B
n_toneportdirec	EQU 32 ; B
n_toneportspeed	EQU 33 ; B
n_vibratocmd	EQU 34 ; B
n_vibratopos	EQU 35 ; B
n_tremolocmd	EQU 36 ; B
n_tremolopos	EQU 37 ; B
n_wavecontrol	EQU 38 ; B
n_glissfunk	EQU 39 ; B
n_sampleoffset	EQU 40 ; B
n_pattpos	EQU 41 ; B
n_loopcount	EQU 42 ; B
n_funkoffset	EQU 43 ; B

mt_init
	MOVEM.L	D0-A6,-(SP)

	LEA	mt_data,A0
	MOVE.L	A0,mt_SongDataPtr
	MOVE.B	950(A0),mt_SongLength
	LEA	12(A0),A1
	MOVE.L	A1,mt_SampleStructPtr
	
	; count number of patterns (find highest referred pattern)
	LEA	952(A0),A1	; order list address
	MOVEQ	#128-1,D0	; 128 order list entries
	MOVEQ	#0,D1
mtloop	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT.B	mtloop
	DBRA	D0,mtloop2
	ADDQ.B	#1,D2
	
	; generate mt_SampleStarts list and fix samples
	
	LSL.L	#8,D2
	LSL.L	#2,D2		; D2 *= 1024 
	ADD.L	#1084,D2
	ADD.L	A0,D2
	MOVE.L	D2,A2		; A2 is now the address of first sample's data

	LEA	mt_SampleStarts(PC),A1
	MOVEQ	#31-1,D3
mtloop3	MOVEQ	#0,D0
	MOVE.W	42(A0),D0	; get sample length
	BEQ.B	mtskip2		; sample is empty, don't handle
	MOVEQ	#0,D1
	MOVE.W	46(A0),D1	; get repeat
	MOVEQ	#0,D2
	MOVE.W  48(A0),D2	; get replen
	BNE.B   mtskip
	MOVEQ	#1,D2
	MOVE.W  D2,48(A0)	; replen is zero, set to 1 (fixes lock-up)
mtskip	ADD.L	D2,D1
	CMP.L   #1,D1		; loop enabled? (repeat+replen > 1)
	BHI.B   mtskip2		; yes
	CLR.W   (A2)		; no, clear first word of sample (prevents beep)
mtskip2	MOVE.L	A2,(A1)+	; move sample address into mt_SampleStarts slot
	ADD.L	D0,D0		; turn into real sample length
	ADD.L	D0,A2		; add to address
	LEA	30(A0),A0	; skip to next sample list entry
	DBRA	D3,mtloop3

	; initialize stuff
	MOVE.B	$BFE001,D0		; copy of LED filter state
	AND.B	#2,D0
	MOVE.B	D0,LEDStatus
	BSET	#1,$BFE001		; turn off LED filter
	; --------------------
	MOVE.B	#6,mt_Speed
	CLR.B	mt_Counter
	CLR.B	mt_SongPos
	CLR.W	mt_PatternPos
	CLR.B	mt_PattDelayTime
	CLR.B	mt_PattDelayTime2
	BSR.W	mt_RestoreEffects
	BSR.B	mt_TurnOffVoices
	
	MOVEM.L	(SP)+,D0-A6
	RTS
	
mt_end
	BCLR	#1,$BFE001		; restore previous LED filter state
	MOVE.L	D0,-(SP)
	MOVE.B	LEDStatus(PC),D0
	OR.B	D0,$BFE001
	MOVE.L	(SP)+,D0
mt_TurnOffVoices
	MOVE.W	#$F,$DFF096		; turn off voice DMAs
	CLR.W	$DFF0A8			; clear voice volumes
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	RTS

mt_RestoreEffects
	LEA	mt_audchan1temp(PC),A0
	BSR.B	reefsub
	LEA	mt_audchan2temp(PC),A0
	BSR.B	reefsub
	LEA	mt_audchan3temp(PC),A0
	BSR.B	reefsub
	LEA	mt_audchan4temp(PC),A0
reefsub	CLR.B	n_wavecontrol(A0)
	CLR.B	n_glissfunk(A0)
	CLR.B	n_finetune(A0)
	CLR.B	n_loopcount(A0)
	RTS

mt_music
	MOVEM.L	D0-A6,-(SP)
	ADDQ.B	#1,mt_Counter
	MOVE.B	mt_Counter(PC),D0
	CMP.B	mt_Speed(PC),D0
	BLO.B	mt_NoNewNote
	CLR.B	mt_Counter
	TST.B	mt_PattDelayTime2
	BEQ.B	mt_GetNewNote
	BSR.B	mt_NoNewAllChannels
	BRA.W	mt_dskip

mt_NoNewNote
	BSR.B	mt_NoNewAllChannels
	BRA.W	mt_NoNewPositionYet

mt_NoNewAllChannels
	LEA	mt_audchan1temp(PC),A6
	LEA	$DFF0A0,A5
	BSR.W	mt_CheckEffects
	LEA	mt_audchan2temp(PC),A6
	LEA	$DFF0B0,A5
	BSR.W	mt_CheckEffects
	LEA	mt_audchan3temp(PC),A6
	LEA	$DFF0C0,A5
	BSR.W	mt_CheckEffects
	LEA	mt_audchan4temp(PC),A6
	LEA	$DFF0D0,A5
	BRA.W	mt_CheckEffects

mt_GetNewNote
	; Setup pattern pointer
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	952(A0),A1	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVE.B	mt_SongPos(PC),D0
	MOVEQ	#0,D1
	MOVE.B	(A1,D0.W),D1
	LSL.L	#8,D1
	LSL.L	#2,D1
	MOVEQ	#0,D0
	MOVE.W	mt_PatternPos(PC),D0
	ADD.L	D0,D1
	ADD.L	D1,A0
	MOVE.L	A0,mt_PatternPtr
	
	CLR.W	mt_DMACONtemp

	LEA	$DFF0A0,A5
	LEA	mt_audchan1temp(PC),A6
	BSR.B	mt_PlayVoice
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	
	LEA	$DFF0B0,A5
	LEA	mt_audchan2temp(PC),A6
	BSR.B	mt_PlayVoice
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	
	LEA	$DFF0C0,A5
	LEA	mt_audchan3temp(PC),A6
	BSR.B	mt_PlayVoice
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	
	LEA	$DFF0D0,A5
	LEA	mt_audchan4temp(PC),A6
	BSR.B	mt_PlayVoice
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)

	BRA.W	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.B	mt_plvskip
	BSR.W	mt_PerNop
mt_plvskip
	MOVE.L	mt_PatternPtr(PC),A0
	MOVE.L	(A0)+,(A6)	; Read note from pattern
	MOVE.L	A0,mt_PatternPtr
	
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2	; Get lower 4 bits of instrument
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0		; Get higher 4 bits of instrument
	AND.B	#$F0,D0
	OR.B	D0,D2
	BEQ.W	mt_SetRegisters	; Instrument was zero

	LEA	mt_SampleStarts(PC),A1
	MOVE.L	mt_SampleStructPtr(PC),A3
	
	MOVE	D2,D4
	SUBQ.L	#1,D2
	LSL.L	#2,D2
	MULU.W	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)

	MOVEQ	#0,D0
	MOVE.B	2(A3,D4.L),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	; ----------------------------------
	LSL.B	#2,D0 ; update n_peroffset
	LEA	mt_ftunePerTab(PC),A4
	MOVE.L	(A4,D0.W),n_peroffset(A6)
	; ----------------------------------
	MOVEQ	#0,D3
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3		; Get repeat
	BEQ.B	mt_NoLoop
	MOVE.L	n_start(A6),D2		; Get start
	ADD.L	D3,D3
	ADD.L	D3,D2			; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0		; Get repeat
	ADD.W	6(A3,D4.L),D0		; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	BRA.B	mt_SetRegisters

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
mt_SetRegisters
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ.W	mt_CheckMoreEffects	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$FF0,D0
	CMP.W	#$E50,D0 ; finetune
	BEQ.B	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.B	mt_ChkTonePorta
	CMP.B	#5,D0	; TonePortamento + VolSlide
	BEQ.B	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.B	mt_SetPeriod
	BSR.W	mt_CheckMoreEffects
	BRA.B	mt_SetPeriod

mt_DoSetFineTune
	BSR.W	mt_SetFineTune
	BRA.B	mt_SetPeriod

mt_ChkTonePorta
	BSR.W	mt_SetTonePorta
	BRA.W	mt_CheckMoreEffects

mt_SetPeriod
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#37-1,D7
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS.B	mt_ftufound
	ADDQ.W	#2,D0
	DBRA	D7,mt_ftuloop
mt_ftufound
	MOVE.L	n_peroffset(A6),A1
	MOVE.W	(A1,D0.W),n_period(A6)

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 		; Notedelay
	BEQ.W	mt_CheckMoreEffects

	MOVE.W	n_dmabit(A6),$DFF096
	BTST	#2,n_wavecontrol(A6)
	BNE.B	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.B	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.L	n_start(A6),(A5)	; Set start
	BNE.B   mt_sdmaskp
	CLR.L	n_loopstart(A6)
	MOVEQ	#1,D0
	MOVE.W	D0,4(A5)
	MOVE.W	D0,n_replen(A6)
mt_sdmaskp
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,6(A5)		; Set period
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA.W	mt_CheckMoreEffects
 
mt_SetDMA	
	; scanline-wait (wait before starting Paula DMA)
	LEA	$DFF006,A0
	MOVEQ	#7-1,D1
lineloop1
	MOVE.B	(A0),D0
waiteol1
	CMP.B	(A0),D0
	BEQ.B	waiteol1
	DBRA	D1,lineloop1

	MOVE.W	mt_DMACONtemp(PC),D0
	OR.W	#$8000,D0		; Set bits
	MOVE.W	D0,$DFF096
	
	; scanline-wait (wait for Paula DMA to latch)
	MOVEQ	#7-1,D1
lineloop2
	MOVE.B	(A0),D0
waiteol2
	CMP.B	(A0),D0
	BEQ.B	waiteol2
	DBRA	D1,lineloop2
	
	LEA	$DFF000,A5
	LEA	mt_audchan4temp(PC),A6
	MOVE.L	n_loopstart(A6),$D0(A5)
	MOVE.W	n_replen(A6),$D4(A5)
	LEA	mt_audchan3temp(PC),A6
	MOVE.L	n_loopstart(A6),$C0(A5)
	MOVE.W	n_replen(A6),$C4(A5)
	LEA	mt_audchan2temp(PC),A6
	MOVE.L	n_loopstart(A6),$B0(A5)
	MOVE.W	n_replen(A6),$B4(A5)
	LEA	mt_audchan1temp(PC),A6
	MOVE.L	n_loopstart(A6),$A0(A5)
	MOVE.W	n_replen(A6),$A4(A5)

mt_dskip
	ADD.W	#16,mt_PatternPos
	MOVE.B	mt_PattDelayTime(PC),D0
	BEQ.B	mt_dskpc
	MOVE.B	D0,mt_PattDelayTime2
	CLR.B	mt_PattDelayTime
mt_dskpc
	TST.B	mt_PattDelayTime2
	BEQ.B	mt_dskpa
	SUBQ.B	#1,mt_PattDelayTime2
	BEQ.B	mt_dskpa
	SUB.W	#16,mt_PatternPos
mt_dskpa
	TST.B	mt_PBreakFlag
	BEQ.B	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
	CLR.B	mt_PBreakPos
mt_nnpysk
	CMP.W	#1024,mt_PatternPos
	BLO.B	mt_NoNewPositionYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#127,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	CMP.B	mt_SongLength(PC),D1
	BLO.B	mt_NoNewPositionYet
	CLR.B	mt_SongPos
	
mt_NoNewPositionYet
	TST.B	mt_PosJumpFlag
	BNE.B	mt_NextPosition
mt_exit	MOVEM.L	(SP)+,D0-A6
	RTS
	
mt_CheckEffects
	BSR.B	mt_chkefx2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS
	
	CNOP 0,4
mt_JumpList1
	dc.l mt_Arpeggio		; 0xy (Arpeggio)
	dc.l mt_PortaUp			; 1xx (Portamento Up)
	dc.l mt_PortaDown		; 2xx (Portamento Down)
	dc.l mt_TonePortamento		; 3xx (Tone Portamento)
	dc.l mt_Vibrato			; 4xy (Vibrato)
	dc.l mt_TonePlusVolSlide	; 5xy (Tone Portamento + Volume Slide)
	dc.l mt_VibratoPlusVolSlide	; 6xy (Vibrato + Volume Slide)
	dc.l SetBack			; 7 - not used here
	dc.l SetBack			; 8 - unused!
	dc.l SetBack			; 9 - not used here
	dc.l SetBack			; A - not used here
	dc.l SetBack			; B - not used here
	dc.l SetBack			; C - not used here
	dc.l SetBack			; D - not used here
	dc.l mt_E_Commands		; Exy (Extended Commands)
	dc.l SetBack			; F - not used here

mt_chkefx2
	BSR.W	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.B	mt_Return3
	MOVEQ	#0,D0
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	MOVE.W	D0,D1
	LSL.B	#2,D1
	MOVE.L	mt_JumpList1(PC,D1.W),A4
	JMP	(A4) ; every efx has RTS at the end, this is safe

SetBack	MOVE.W	n_period(A6),6(A5)
	CMP.B	#7,D0
	BEQ.W	mt_Tremolo
	CMP.B	#$A,D0
	BEQ.W	mt_VolumeSlide
mt_Return3
	RTS

mt_PerNop
	MOVE.W	n_period(A6),6(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_Counter(PC),D0
	MOVE.B	mt_ArpTab(PC,D0.W),D0
	CMP.B	#1,D0
	BEQ.B	mt_Arpeggio1
	CMP.B	#2,D0
	BEQ.B	mt_Arpeggio2
mt_Arpeggio0
	MOVE.W	n_period(A6),6(A5)
	RTS
	
mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.B	mt_ArpeggioFind

mt_Arpeggio2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
mt_ArpeggioFind
	ADD.W	D0,D0
	MOVE.L	n_peroffset(A6),A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#37-1,D3
mt_arploop
	CMP.W	(A0)+,D1
	BHS.B	mt_ArpeggioFound
	DBRA	D3,mt_arploop
	RTS
	
mt_ArpeggioFound
	MOVE.W	-2(A0,D0.W),6(A5)
	RTS
	
	; DIV -> LUT optimization. DIVU is 140+ cycles on a 68000.
mt_ArpTab
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
	dc.b 2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	dc.b 1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
	dc.b 2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	dc.b 1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
	dc.b 2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0

mt_FinePortaUp
	TST.B	mt_Counter
	BNE.W	mt_Return3
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.B	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_Counter
	BNE.W	mt_Return3
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.B	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVE.L	n_peroffset(A6),A4
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A4,D0.W),D2
	BHS.B	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.B	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.B	mt_StpGoss
	TST.W	D0
	BEQ.B	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A4,D0.W),D2
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.B	mt_ClearTonePorta
	BGE.W	mt_Return3
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ.W	mt_Return3
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.B	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.B	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.B	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.B	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.B	mt_GlissSkip
	MOVE.L	n_peroffset(A6),A0	
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.B	mt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.B	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.B	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.B	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#3,D2
	BEQ.B	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.B	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.B	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.B	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.B	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.B	mt_vib_set
mt_vib_sine
	MOVE.B	(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.B	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.B	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR.W	mt_TonePortNoChange
	BRA.W	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.B	mt_Vibrato2
	BRA.W	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.B	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.B	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#3,D2
	BEQ.B	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.B	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.B	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.B	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.B	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.B	mt_tre_set
mt_tre_sine
	MOVE.B	(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.B	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.B	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.B	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#64,D0
	BLS.B	mt_TremoloOk
	MOVE.W	#64,D0
mt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	ADDQ.L	#4,SP			; hack to not set volume in mt_CheckEffects
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.B	mt_sofskip
	SUB.W	D0,n_length(A6)
	ADD.W	D0,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#1,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BEQ.B	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#64,n_volume(A6)
	BMI.B	mt_vsuskip
	MOVE.B	#64,n_volume(A6)
mt_vsuskip
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.B	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#64,D0
	BLS.B	mt_VolumeOk
	MOVEQ	#64,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU.W	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.B	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ.W	mt_end
	CLR.B	mt_Counter
	MOVE.B	D0,mt_Speed
	RTS
	
	CNOP 0,4
mt_JumpList2
	dc.l mt_PerNop		; 0 - not used
	dc.l mt_PerNop		; 1 - not used
	dc.l mt_PerNop		; 2 - not used
	dc.l mt_PerNop		; 3 - not used
	dc.l mt_PerNop		; 4 - not used
	dc.l mt_PerNop		; 5 - not used
	dc.l mt_PerNop		; 6 - not used
	dc.l mt_PerNop		; 7 - not used
	dc.l mt_PerNop		; 8 - not used
	dc.l mt_SampleOffset	; 9xx (Set Sample Offset)
	dc.l mt_PerNop		; A - not used
	dc.l mt_PositionJump	; Bxx (Position Jump)
	dc.l mt_VolumeChange	; Cxx (Set Volume)
	dc.l mt_PatternBreak	; Dxx (Pattern Break)
	dc.l mt_E_Commands	; Exy (Extended Commands)
	dc.l mt_SetSpeed	; Fxx (Set Speed)
		
mt_CheckMoreEffects
	MOVEQ	#0,D0
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	LSL.B	#2,D0
	MOVE.L	mt_JumpList2(PC,D0.W),A4
	JMP	(A4) ; every efx has RTS at the end, this is safe
	
	CNOP 0,4
mt_E_JumpList
	dc.l mt_FilterOnOff		; E0x (Set LED Filter)
	dc.l mt_FinePortaUp		; E1x (Fine Portamento Up)
	dc.l mt_FinePortaDown		; E2x (Fine Portamento Down)
	dc.l mt_SetGlissControl		; E3x (Glissando/Funk Control)
	dc.l mt_SetVibratoControl	; E4x (Vibrato Control)
	dc.l mt_SetFineTune		; E5x (Set Finetune)
	dc.l mt_JumpLoop		; E6x (Pattern Loop)
	dc.l mt_SetTremoloControl	; E7x (Tremolo Control)
	dc.l mt_KarplusStrong		; E8x (Karplus-Strong)
	dc.l mt_RetrigNote		; E9x (Retrig Note)
	dc.l mt_VolumeFineUp		; EAx (Fine Volume-Slide Up)
	dc.l mt_VolumeFineDown		; EBx (Fine Volume-Slide Down)
	dc.l mt_NoteCut			; ECx (Note Cut)
	dc.l mt_NoteDelay		; EDx (Note Delay)
	dc.l mt_PatternDelay		; EEx (Pattern Delay)
	dc.l mt_FunkIt			; EFx (Invert Loop)
	
mt_E_Commands
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4-2,D0
	MOVE.L	mt_E_JumpList(PC,D0.W),A4
	JMP	(A4) ; every E-efx has RTS at the end, this is safe
	
mt_FilterOnOff
	TST.B	mt_Counter
	BNE.W	mt_Return3
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#1,D0
	ADD.B	D0,D0
	AND.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	; ----------------------------------
	LSL.B	#2,D0	; update n_peroffset
	LEA	mt_ftunePerTab(PC),A4
	MOVE.L	(A4,D0.W),n_peroffset(A6)
	; ----------------------------------
	RTS

mt_JumpLoop
	TST.B	mt_Counter
	BNE.W	mt_Return3
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.B	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.B	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ.W	mt_Return3
mt_jmploop
	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.B	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR.W	#4,D0
	AND.B	#63,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_KarplusStrong
	RTS

mt_RetrigNote
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.B	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_Counter(PC),D1
	BNE.B	mt_rtnskp
	MOVE.W	n_note(A6),D1
	AND.W	#$0FFF,D1
	BNE.B	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_Counter(PC),D1
mt_rtnskp
	AND.B	#$1F,D1	; just in case
	LSL.W	#5,D0
	ADD.W	D0,D1
	MOVE.B	mt_RetrigTab(PC,D1.W),D0
	BNE.B	mt_rtnend
mt_DoRetrig
	MOVE.W	n_dmabit(A6),$DFF096	; Channel DMA off
	MOVE.L	n_start(A6),(A5)	; Set sampledata pointer
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	n_period(A6),6(A5)  	; Set period

	; scanline-wait (wait before starting Paula DMA)
	LEA	$DFF006,A0
	MOVEQ	#7-1,D1
lineloop3
	MOVE.B	(A0),D0
waiteol3
	CMP.B	(A0),D0
	BEQ.B	waiteol3
	DBRA	D1,lineloop3

	MOVE.W	n_dmabit(A6),D0
	BSET	#15,D0	; Set bits
	MOVE.W	D0,$DFF096

	; scanline-wait (wait for Paula DMA to latch)
	MOVEQ	#7-1,D1
lineloop4
	MOVE.B	(A0),D0
waiteol4
	CMP.B	(A0),D0
	BEQ.B	waiteol4
	DBRA	D1,lineloop4

	MOVE.L	n_loopstart(A6),(A5)
	MOVE.W	n_replen(A6),4(A5)
mt_rtnend
	RTS
	
	; DIV -> LUT optimization. Maybe a bit extreme, but DIVU is 140+
	; cycles on a 68000.
mt_RetrigTab
	dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b 0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
	dc.b 0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1
	dc.b 0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1
	dc.b 0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1
	dc.b 0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1
	dc.b 0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1
	dc.b 0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1

mt_VolumeFineUp
	TST.B	mt_Counter
	BNE.W	mt_Return3
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA.W	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_Counter
	BNE.W	mt_Return3
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA.W	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_Counter(PC),D0
	BNE.W	mt_Return3
	CLR.B	n_volume(A6)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_Counter,D0
	BNE.W	mt_Return3
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ.W	mt_Return3
	BRA.W	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_Counter
	BNE.W	mt_Return3
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelayTime2
	BNE.W	mt_Return3
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelayTime
	RTS

mt_FunkIt
	TST.B	mt_Counter
	BNE.W	mt_Return3
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ.W	mt_Return3
mt_UpdateFunk
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.B	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.B	mt_funkend
	CLR.B	n_funkoffset(A6)
	MOVE.L	n_wavestart(A6),A0
	CMP.L	#0,A0
	BEQ.B	mt_funkend
	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.B	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	RTS

mt_FunkTable
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24
	
	; this LUT prevents MULU for getting correct period section
	CNOP 0,4
mt_ftunePerTab
	dc.l mt_ftune0,mt_ftune1,mt_ftune2,mt_ftune3
	dc.l mt_ftune4,mt_ftune5,mt_ftune6,mt_ftune7
	dc.l mt_ftune8,mt_ftune9,mt_ftuneA,mt_ftuneB
	dc.l mt_ftuneC,mt_ftuneD,mt_ftuneE,mt_ftuneF

mt_PeriodTable
; Tuning 0, Normal
mt_ftune0
	dc.w 856,808,762,720,678,640,604,570,538,508,480,453
	dc.w 428,404,381,360,339,320,302,285,269,254,240,226
	dc.w 214,202,190,180,170,160,151,143,135,127,120,113,0
; Tuning 1
mt_ftune1
	dc.w 850,802,757,715,674,637,601,567,535,505,477,450
	dc.w 425,401,379,357,337,318,300,284,268,253,239,225
	dc.w 213,201,189,179,169,159,150,142,134,126,119,113,0
; Tuning 2
mt_ftune2
	dc.w 844,796,752,709,670,632,597,563,532,502,474,447
	dc.w 422,398,376,355,335,316,298,282,266,251,237,224
	dc.w 211,199,188,177,167,158,149,141,133,125,118,112,0
; Tuning 3
mt_ftune3
	dc.w 838,791,746,704,665,628,592,559,528,498,470,444
	dc.w 419,395,373,352,332,314,296,280,264,249,235,222
	dc.w 209,198,187,176,166,157,148,140,132,125,118,111,0
; Tuning 4
mt_ftune4
	dc.w 832,785,741,699,660,623,588,555,524,495,467,441
	dc.w 416,392,370,350,330,312,294,278,262,247,233,220
	dc.w 208,196,185,175,165,156,147,139,131,124,117,110,0
; Tuning 5
mt_ftune5
	dc.w 826,779,736,694,655,619,584,551,520,491,463,437
	dc.w 413,390,368,347,328,309,292,276,260,245,232,219
	dc.w 206,195,184,174,164,155,146,138,130,123,116,109,0
; Tuning 6
mt_ftune6
	dc.w 820,774,730,689,651,614,580,547,516,487,460,434
	dc.w 410,387,365,345,325,307,290,274,258,244,230,217
	dc.w 205,193,183,172,163,154,145,137,129,122,115,109,0
; Tuning 7
mt_ftune7
	dc.w 814,768,725,684,646,610,575,543,513,484,457,431
	dc.w 407,384,363,342,323,305,288,272,256,242,228,216
	dc.w 204,192,181,171,161,152,144,136,128,121,114,108,0
; Tuning -8
mt_ftune8
	dc.w 907,856,808,762,720,678,640,604,570,538,508,480
	dc.w 453,428,404,381,360,339,320,302,285,269,254,240
	dc.w 226,214,202,190,180,170,160,151,143,135,127,120,0
; Tuning -7
mt_ftune9
	dc.w 900,850,802,757,715,675,636,601,567,535,505,477
	dc.w 450,425,401,379,357,337,318,300,284,268,253,238
	dc.w 225,212,200,189,179,169,159,150,142,134,126,119,0
; Tuning -6
mt_ftuneA
	dc.w 894,844,796,752,709,670,632,597,563,532,502,474
	dc.w 447,422,398,376,355,335,316,298,282,266,251,237
	dc.w 223,211,199,188,177,167,158,149,141,133,125,118,0
; Tuning -5
mt_ftuneB
	dc.w 887,838,791,746,704,665,628,592,559,528,498,470
	dc.w 444,419,395,373,352,332,314,296,280,264,249,235
	dc.w 222,209,198,187,176,166,157,148,140,132,125,118,0
; Tuning -4
mt_ftuneC
	dc.w 881,832,785,741,699,660,623,588,555,524,494,467
	dc.w 441,416,392,370,350,330,312,294,278,262,247,233
	dc.w 220,208,196,185,175,165,156,147,139,131,123,117,0
; Tuning -3
mt_ftuneD
	dc.w 875,826,779,736,694,655,619,584,551,520,491,463
	dc.w 437,413,390,368,347,328,309,292,276,260,245,232
	dc.w 219,206,195,184,174,164,155,146,138,130,123,116,0
; Tuning -2
mt_ftuneE
	dc.w 868,820,774,730,689,651,614,580,547,516,487,460
	dc.w 434,410,387,365,345,325,307,290,274,258,244,230
	dc.w 217,205,193,183,172,163,154,145,137,129,122,115,0
; Tuning -1
mt_ftuneF
	dc.w 862,814,768,725,684,646,610,575,543,513,484,457
	dc.w 431,407,384,363,342,323,305,288,272,256,242,228
	dc.w 216,203,192,181,171,161,152,144,136,128,121,114,0

	CNOP 0,4
mt_audchan1temp	dcb.b	26
		dc.w	$0001	; voice #1 DMA bit
		dcb.b	16
	CNOP 0,4
mt_audchan2temp	dcb.b	26
		dc.w	$0002	; voice #2 DMA bit
		dcb.b	16
	CNOP 0,4
mt_audchan3temp	dcb.b	26
		dc.w	$0004	; voice #3 DMA bit
		dcb.b	16
	CNOP 0,4
mt_audchan4temp	dcb.b	26
		dc.w	$0008	; voice #4 DMA bit
		dcb.b	16

	CNOP 0,4
mt_SampleStarts		dcb.l 31,0
mt_SongDataPtr		dc.l 0
mt_SampleStructPtr	dc.l 0
mt_PatternPtr		dc.l 0
mt_PatternPos		dc.w 0
mt_DMACONtemp		dc.w 0
mt_SongLength		dc.b 0
mt_Speed		dc.b 6
mt_Counter		dc.b 0
mt_SongPos		dc.b 0
mt_PBreakPos		dc.b 0
mt_PosJumpFlag		dc.b 0
mt_PBreakFlag		dc.b 0
mt_LowMask		dc.b $FF
mt_PattDelayTime	dc.b 0
mt_PattDelayTime2	dc.b 0

	SECTION music,DATA_C

	CNOP 0,4
mt_data INCBIN "music.mod"

;/* End of File */
