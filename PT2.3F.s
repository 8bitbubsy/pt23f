; ProTracker v2.3F source code
; ============================
;    11th of December, 2025
;
;    (tab width = 8+ spaces)
;
; If you find any bugs, please contact me through the email/Discord
; found at 16-bits.org.
;
; Original PT2.3D by Peter "CRAYON" Hanning and Detron,
; which is based on PT2.0A by Lars "ZAP" Hamre.
;
; PT2.3D raw disassemble by Per "Super-Hans" Johansson.
; Re-source job and PT2.3E/PT2.3F version by 8bitbubsy (me).
;

; mouse movement speed (1..16)
MOUSE_SPEED	EQU 11

; video frames to wait during "error" (red mouse cursor)
ERR_WAIT_TIME	EQU 40

SCREEN_W		EQU 320
SCREEN_H		EQU 256
SONG_SIZE_100PAT	EQU 1084+(1024*100)
SONG_SIZE_64PAT		EQU 1084+(1024*64)

PaulaDMAWaitScanlines_000	EQU 5-1
PaulaDMAWaitScanlines_020	EQU 7-1
GUIDelayScanlines_000		EQU 0 ; no delay needed on 68k
GUIDelayScanlines_020		EQU 40-1

; FileFormat
sd_sampleinfo		EQU 20
sd_numofpatt		EQU 950
sd_pattpos		EQU 952
sd_magicid		EQU 1080
sd_patterndata		EQU 1084

; audXtemp offsets
n_note			EQU 0  ; W (MUST be first!)
n_cmd			EQU 2  ; W (MUST be second!)
n_cmdlo			EQU 3  ; B (lower byte of cmd)
n_start			EQU 4  ; L (aligned)
n_wavestart		EQU 8  ; L
n_loopstart		EQU 12 ; L
n_oldstart		EQU 16 ; L
n_peroffset		EQU 20 ; L (offset to finetuned period-LUT section)
n_dmabit		EQU 24 ; W (aligned)
n_length		EQU 26 ; W
n_replen		EQU 28 ; W
n_period		EQU 30 ; W
n_wantedperiod		EQU 32 ; W
n_oldlength		EQU 34 ; W
n_periodout		EQU 36 ; W
n_repeat		EQU 38 ; W
n_finetune		EQU 40 ; B
n_volume		EQU 41 ; B
n_toneportdirec		EQU 42 ; B
n_toneportspeed		EQU 43 ; B
n_vibratocmd		EQU 44 ; B
n_vibratopos		EQU 45 ; B
n_tremolocmd		EQU 46 ; B
n_tremolopos		EQU 47 ; B
n_wavecontrol		EQU 48 ; B
n_glissfunk		EQU 49 ; B
n_sampleoffset		EQU 50 ; B
n_pattpos		EQU 51 ; B
n_loopcount		EQU 52 ; B
n_funkoffset		EQU 53 ; B
n_trigger		EQU 54 ; B
n_samplenum		EQU 55 ; B
n_volumeout 		EQU 56 ; B
n_sampleoffset2		EQU 57 ; B
n_muted			EQU 58 ; B

ChanStructSize		EQU 60 ; (must be a multiple of 4!)

; Exec Library Offsets
_LVOFindTask		EQU -294
_LVOFindName		EQU -276
_LVOForbid		EQU -132
_LVOPermit		EQU -138
_LVOAddPort		EQU -354
_LVORemPort		EQU -360
_LVOWaitPort		EQU -384
_LVOOpenLibrary		EQU -552
_LVOCloseLibrary	EQU -414
_LVOOpenDevice		EQU -444
_LVOCloseDevice		EQU -450
_LVODoIO		EQU -456
_LVOSendIO		EQU -462
_LVOGetMsg		EQU -372
_LVOReplyMsg		EQU -378
_LVOAllocMem		EQU -198
_LVOFreeMem		EQU -210
_LVOAvailMem		EQU -216
_LVOAddIntServer	EQU -168
_LVORemIntServer	EQU -174
_LVOOpenResource	EQU -498
_LVOSetIntVector	EQU -162
_LVORemDevice		EQU -438
_LVOOldOpenLibrary	EQU -408
_LVOSetSignal		EQU -306
_LVOWait		EQU -318
_LVOSignal		EQU -324

; CIA Resource Offsets
_AddICRVector		EQU -6
_RemICRVector		EQU -12

; DOS Library Offsets
_LVOOpen		EQU -30
_LVOClose		EQU -36
_LVORead		EQU -42
_LVOWrite		EQU -48
_LVODeleteFile		EQU -72
_LVORename		EQU -78
_LVOLock		EQU -84
_LVOUnLock		EQU -90
_LVOExamine		EQU -102
_LVOExNext		EQU -108
_LVOInfo		EQU -114
_LVOSeek		EQU -66
_LVOCreateDir		EQU -120
_LVOCurrentDir		EQU -126
_LVODateStamp		EQU -192
_LVODelay		EQU -198
_LVOExecute		EQU -222
_LVOUnLoadSeg		EQU -156
_LVOParentDir		EQU -210
_LVODupLock		EQU -96
_LVOCreateProc		EQU -138

; Intuition Library Offsets
_LVOCloseScreen		EQU -66
_LVOOpenScreen		EQU -198
_LVOOpenWorkbench	EQU -210
_LVOScreenToBack	EQU -246
_LVOScreenToFront	EQU -252
_LVOWBenchToFront	EQU -342

; Graphics Library Offsets
_LVOWaitBlit		EQU -228
_LVOOwnBlitter		EQU -456
_LVODisownBlitter	EQU -462

; Power Packer Library Offsets
_LVOppLoadData		EQU -30
_LVOppAllocCrunchInfo	EQU -96
_LVOppFreeCrunchInfo	EQU -102
_LVOppCrunchBuffer	EQU -108
_LVOppWriteDataHeader	EQU -114

; DateStamp
ofib_DateStamp		EQU $84
ds_Days			EQU $00
ds_Minute		EQU $04
ds_Tick			EQU $08

; Memory Alloc Flags
MEMF_PUBLIC		EQU $0001
MEMF_CHIP		EQU $0002
MEMF_FAST		EQU $0004
MEMF_CLEAR		EQU $10000
MEMF_TOTAL		EQU $80000

; IO Block Offsets
IO_COMMAND		EQU $1C
IO_FLAGS		EQU $1E
IO_ACTUAL		EQU $20
IO_LENGTH		EQU $24
IO_DATA			EQU $28
IO_OFFSET		EQU $2C

; Device Commands 
CMD_READ		EQU $2
CMD_WRITE		EQU $3
CMD_UPDATE		EQU $4
TD_MOTOR		EQU $9
TD_FORMAT		EQU $B
TD_CHANGESTATE		EQU $E
TD_PROTSTATUS		EQU $F

DirNameLength		EQU 30
ConfigFileSize		EQU 1024
KeyBufSize		EQU 20

ThisTask		EQU $114
pr_CLI			EQU $AC
pr_MsgPort		EQU $5C
sm_ArgList		EQU $24
cli_CommandName		EQU $10
SHARED_LOCK		EQU -2

; -----------------------------------------------------------------------------
;                         RUNBACK HUNK (modified by ross)  
; -----------------------------------------------------------------------------

	SECTION ptrunback,CODE

rb_HunkStart
	MOVE.L	4.W,A6
	LEA	DOSname,A1
	JSR	_LVOOldOpenLibrary(A6)
	MOVE.L	D0,A5			; dosbase

	MOVE.L	ThisTask(A6),A3
	MOVE.L	pr_CLI(A3),D6		; d6 = CLI or WB (NULL)
	BNE.B	.fromCLI

	; Get startup message if we started from Workbench
	LEA	pr_MsgPort(A3),A0
	JSR	_LVOWaitPort(A6)	; wait for a message
	LEA	pr_MsgPort(A3),A0
	JSR	_LVOGetMsg(A6)		; then get it
	MOVE.L	D0,A3			; a3 = WBStartup message
	MOVE.L	sm_ArgList(A3),A0
	MOVE.L	(A0),D5			; (wa_Lock) FileLock on program dir
	EXG	A5,A6			; _dos
	BSR.B	.common

	; Reply to the startup message
	JSR	_LVOForbid(A6)		; it prohibits WB to unloadseg me
	LEA	(A3),A1
	JMP	_LVOReplyMsg(A6)	; reply to WB message and exit

.fromCLI
	; Get FileLock via command name if we started from CLI
	LINK	A3,#-256

	; Copy BCPL string to C-style string
	LEA	(SP),A1
	LSL.L	#2,D6
	MOVE.L	D6,A0
	MOVE.L	cli_CommandName(A0),A0
	ADD.L	A0,A0
	ADD.L	A0,A0
	MOVE.B	(A0)+,D0
.loop	MOVE.B	(A0)+,(A1)+
	SUBQ.B	#1,D0
	BNE.B	.loop
	CLR.B	(A1)

	; Get a lock on the program and its parent
	EXG	A5,A6		; _dos
	MOVE.L	SP,D1		; d1 = STRPTR name (command string)
	MOVEQ	#SHARED_LOCK,D2	; d2 = accessMode
	JSR	_LVOLock(A6)
	MOVE.L	D0,D7
	MOVE.L	D0,D1
	JSR	_LVOParentDir(A6)
	MOVE.L	D7,D1
	MOVE.L	D0,D6		; d6 = Lock on CLI program dir
	MOVE.L	D0,D5		; d5 = common Lock
	JSR	_LVOUnLock(A6)
	UNLK	A3

.common
	MOVE.L	D5,D1
	JSR	_LVODupLock(A6)
	MOVE.L	D0,rb_CurrentDir
	MOVE.L	#rb_Progname,D1
	MOVEQ	#0,D2
	MOVE.B	9(A3),D2	; priority
	LEA	rb_HunkStart-4(PC),A0
	MOVE.L	(A0),D3		; ptr to next segment
	CLR.L	(A0)		; unlink next segment
	MOVE.L	#2048,D4	; stack=2kB (big enough for this program)
	JSR	_LVOCreateProc(A6)
	MOVE.L	D6,D1		; UnLock program dir or zero (from WB)
	JSR	_LVOUnLock(A6)
	LEA	(A6),A1
	LEA	(A5),A6
	JSR	_LVOCloseLibrary(A6)
	MOVEQ	#0,D0
	RTS

; -----------------------------------------------------------------------------
;                                   MAIN CODE
; -----------------------------------------------------------------------------

	SECTION ptcode,CODE

PTStart
	MOVEQ	#0,D0
	MOVE.L	4.W,A6
	SUB.L	A1,A1
	JSR	_LVOFindTask(A6)
	MOVE.L	D0,PTProcess
	MOVE.L	D0,A0
	MOVE.L	$B8(A0),PTProcessTmp
	BSR.W	Main
	MOVE.L	PTProcess(PC),A0
	MOVE.L	PTProcessTmp(PC),$B8(A0)
	MOVE.L	4.W,A6
	JSR	_LVOForbid(A6)
	MOVE.L	DOSBase,A6
	MOVE.L	rb_CurrentDir(PC),D1
	JSR	_LVOUnLock(A6)
	LEA	PTStart-4(PC),A0
	MOVE.L	A0,D1
	LSR.L	#2,D1
	JSR	_LVOUnLoadSeg(A6)
	MOVEQ	#0,D0
	RTS
	
; ------------------------------------------------------------------------------
; Scanline-wait routines. Used for Paula DMA latch waiting, and GUI interaction
;
; Note:
;  "InitDelayRoutines" has to be called on program init to use these.
; ------------------------------------------------------------------------------	
WaitForPaulaLatch
	MOVEM.L	D0/D7/A0,-(SP)
	LEA	$DFF006,A0
	MOVE.W	PaulaDMAWaitScanlines,D7
.loop1	MOVE.B	(A0),D0
.loop2	CMP.B	(A0),D0
	BEQ.B	.loop2
	DBRA	D7,.loop1
	MOVEM.L	(SP)+,D0/D7/A0
	RTS

GUIDelay
	TST.W	GUIDelayScanlines	; delay needed at all (68k)?
	BEQ.B	.end			; nope!
	MOVEM.L	D0/D7/A0,-(SP)
	LEA	$DFF006,A0
	MOVE.W	GUIDelayScanlines,D7
.loop1	MOVE.B	(A0),D0
.loop2	CMP.B	(A0),D0
	BEQ.B	.loop2
	DBRA	D7,.loop1
	MOVEM.L	(SP)+,D0/D7/A0
.end	RTS

InitDelayRoutines
	MOVE.L	A6,-(SP)
	MOVE.L	D0,-(SP)
	MOVE.L	4.W,A6
	MOVE.W	296(A6),D0
	BTST	#1,D0
	BNE.B	.not68000
	MOVE.W	#PaulaDMAWaitScanlines_000,PaulaDMAWaitScanlines
	MOVE.W	#GUIDelayScanlines_000,GUIDelayScanlines
	BRA.B	.end
.not68000
	MOVE.W	#PaulaDMAWaitScanlines_020,PaulaDMAWaitScanlines
	MOVE.W	#GUIDelayScanlines_020,GUIDelayScanlines
.end	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A6
	RTS	
	
; ------------------------------------------------------------------------------
; 32-bit unsigned div/mul routines. Software-based if CPU is 68000.
;
; Note:
;  "InitMulDivRoutines" has to be called on program init to use these.
; ------------------------------------------------------------------------------	

	; 32x32 -> 32 unsigned multiplication
	;
	; Input:
	;  D0.L - Multiplicand
	;  D1.L - Multiplier
	;
	; Output:
	;  D0.L - 32-bit unsigned result
MULU32
	TST.B	_CPUIs68000
	BNE.B	SoftMULU32
	MULU.L	D1,D0
	RTS
SoftMULU32
	MOVE.L	D2,-(SP)
	MOVE.L	D3,-(SP)
	MOVE.L	D0,D2
	MOVE.L	D1,D3
	SWAP	D2
	SWAP	D3
	MULU.W	D1,D2
	MULU.W	D0,D3
	MULU.W	D1,D0
	ADD.W	D3,D2
	SWAP	D2
	CLR.W	D2
	ADD.L	D2,D0
	MOVE.L	(SP)+,D3
	MOVE.L	(SP)+,D2
	RTS

	; 32/32 -> 32 unsigned division (without remainder)
	;
	; Input:
	;  D0.L - Dividend
	;  D1.L - Divisor
	;
	; Output:
	;  D0.L - 32-bit unsigned quotient
DIVU32
	TST.B	_CPUIs68000
	BNE.B	SoftDIVU32
	DIVU.L	D1,D0
	RTS
SoftDIVU32
	MOVEM.L	D1/D2/D3,-(SP)
	SWAP	D1
	TST.W	D1
	BNE.B	.L1
	SWAP	D1
	MOVE.L	D1,D3
	SWAP	D0
	MOVE.W	D0,D3
	BEQ.B	.L0
	DIVU.W	D1,D3
	MOVE.W	D3,D0
.L0	SWAP	D0
	MOVE.W	D0,D3
	DIVU.W	D1,D3
	MOVE.W	D3,D0
	BRA.B	.end
.L1	SWAP	D1
	MOVE.L	D1,D2
	MOVE.L	D0,D1
	CLR.W	D1
	SWAP	D1
	SWAP	D0
	CLR.W	D0
	MOVEQ	#16-1,D3
.loop	ADD.L	D0,D0
	ADDX.L	D1,D1
	CMP.L	D1,D2
	BHI.B	.L2
	SUB.L	D2,D1
	ADDQ.L	#1,D0
.L2	DBRA	D3,.loop
.end	MOVEM.L	(SP)+,D1/D2/D3
	RTS
	
InitMulDivRoutines
	MOVE.L	A6,-(SP)
	MOVE.L	D0,-(SP)
	MOVE.L	4.W,A6
	MOVE.W	296(A6),D0
	BTST	#1,D0
	SEQ	_CPUIs68000
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A6
	RTS
	
_CPUIs68000 dc.b 1
	EVEN
	
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

Main
	MOVE.L	SP,StackSave	; important! (leaking memory without it, for some reason)
	; ---------------------
	BSR.W	InitDelayRoutines
	BSR.W	InitMulDivRoutines
	BSR.W	OpenLotsOfThings
	BSR.W	SetVBInt
	BSR.W	SetMusicInt
	JSR	SetPatternPos
	BSR.W	SetNormalPtrCol
	BSR.W	StorePtrCol
	BSR.W	RedrawToggles
	BSR.W	DoShowFreeMem
	BSR.W	SetTempo
	BSR.W	SetInputHandler
	BSR.W	PTScreenToFront
	BSR.W	CheckInitError
	BSR.W	DirBrowseGadg2
	MOVEQ	#0,D3
	MOVE.W	DirPathNum(PC),D3
	LEA	dpnum(PC),A0
	ADD.L	D3,A0
	MOVE.B	#$FF,(A0)
	BSR.W	DirBrowseGadg2
	LEA	VersionText(PC),A0
	JSR	ShowStatusText
	MOVE.L	SongDataPtr,A0
	MOVE.B	#1,sd_numofpatt(A0)	
	BSR.W	DisplayMainScreen
	; fall-through

MainLoop
	JSR	CheckMIDIin
	BSR.W	DoKeyBuffer
	BSR.W	CheckToggleRasterbarKeys
	BSR.W	CheckSamplerScreenKeys	
	BSR.W	CheckPatternInvertKeys
	BSR.W	CheckTransKeys
	BSR.W	CheckCtrlKeys
	BSR.W	CheckAltKeys
	BSR.W	CheckListQuickJump
	BSR.W	CheckKeyboard
	BSR.W	CheckF1_F2
	BSR.W	CheckF3_F5
	BSR.W	CheckF6_F10
	BSR.W	CheckPlayKeys
	BSR.W	CheckHelpKey
	BSR.W	ArrowKeys2
	BSR.W	ShowFreeMem
	BSR.W	CheckBlockPos
	JSR	CheckSampleLength	; test if we need to alloc more mem
	BSR.W	CheckPatternRedraw
	TST.B	SetSignalFlag
	BNE.B	.skip
	MOVE.L	4.W,A6
	MOVEQ	#0,D0
	MOVE.L	#$30000000,D1
	JSR	_LVOSetSignal(A6)	
	MOVE.L	#$70000000,D0
	JSR	_LVOWait(A6)
	AND.L	#$10000000,D0
	BNE.B	.skip2
.skip	SF	SetSignalFlag
	BTST	#6,$BFE001	; left mouse button
	BNE.W	StopInputLoop
.skip2	BSR.W	ArrowKeys
	BRA.W	CheckGadgets	
	BRA.W	MainLoop
	
CheckToggleRasterbarKeys
	TST.W	LeftAmigaStatus
	BEQ.W	Return1
	TST.W	CtrlKeyStatus
	BEQ.W	Return1
	MOVE.B	RawKeyCode,D0
	CMP.B	#48,D0	; '<'
	BNE.W	Return1
	EOR.B	#1,ShowRasterbar
	RTS

	; used stop further key/mouse input for a while
StopInputLoop	
	TST.B	StopInputFlag
	BNE.W	MainLoop
	MOVEQ	#8*2,D1
	BSR.W	WaitD1
	BRA.B	StopInputLoop
	
;---- Sample data range/mark special keys (sampler screen) ----
	
	; SHIFT + ALT/CTRL + z:
	;  Play Range
	;
	; SHIFT + ALT/CTRL + up/down/left/right:
	;  Extends/shrinks sample range
CheckSamplerScreenKeys
	TST.W	SamScrEnable
	BEQ.B	SKeysCheckEnd
	TST.W	ShiftKeyStatus
	BEQ.B	SKeysCheckEnd
	TST.W	AltKeyStatus
	BNE.B	.doit
	TST.W	CtrlKeyStatus
	BEQ.B	SKeysCheckEnd
.doit	; ----------------------------
	MOVE.B	RawKeyCode,D0
	CMP.B	#49,D0 ; z
	BEQ.B	PlayRange2
	CMP.B	#79,D0 ; left
	BEQ.W	ExtendLeftMarkSide
	CMP.B	#78,D0 ; right
	BEQ.W	ShrinkLeftMarkSide
	CMP.B	#76,D0 ; up
	BEQ.W	ExtendRightMarkSide
	CMP.B	#77,D0 ; down
	BEQ.W	ShrinkRightMarkSide
SKeysCheckEnd
	RTS

PlayRange2
	CLR.B	RawKeyCode
	MOVE.L	MarkStartOfs,D1
	BMI.B	SKeysCheckEnd
	MOVE.L	MarkEndOfs,D0
	CMP.L	D0,D1
	BEQ.B	SKeysCheckEnd
	LEA	SampleInfo,A0
	MOVE.L	D1,StartOfs
	SUB.L	D1,D0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)
	CLR.W	4(A0)
	MOVE.W	#1,6(A0)
	MOVE.W	PlayInsNum,D0
	MOVE.W	D0,-(SP)
	MOVE.B	D0,PlayInsNum2
	CLR.W	PlayInsNum
	JSR	PlayNote
	MOVE.W	(SP)+,PlayInsNum
	RTS

ExtendLeftMarkSide
	CLR.B	RawKeyCode
	TST.W	MarkStart
	BEQ.B	SKeysCheckEnd
	CMP.W	#3,MarkStart
	BLS.B	SKeysCheckEnd
	JSR	InvertRange
	SUBQ.W	#1,MarkStart
	BRA.B	UpdateNewMark
	
ShrinkLeftMarkSide
	CLR.B	RawKeyCode
	TST.W	MarkStart
	BEQ.W	SKeysCheckEnd
	CMP.W	#316,MarkStart
	BGE.W	SKeysCheckEnd
	JSR	InvertRange
	ADDQ.W	#1,MarkStart
	BRA.B	UpdateNewMark
	
ExtendRightMarkSide
	CLR.B	RawKeyCode
	TST.W	MarkStart
	BEQ.W	SKeysCheckEnd
	CMP.W	#316,MarkEnd
	BGE.W	SKeysCheckEnd
	JSR	InvertRange
	ADDQ.W	#1,MarkEnd
	BRA.B	UpdateNewMark
	
ShrinkRightMarkSide
	CLR.B	RawKeyCode
	TST.W	MarkStart
	BEQ.W	SKeysCheckEnd
	CMP.W	#3,MarkEnd
	BLS.W	SKeysCheckEnd
	JSR	InvertRange
	SUBQ.W	#1,MarkEnd
	; -- fall-through --

UpdateNewMark
	MOVE.W	MarkStart,D0
	MOVE.W	MarkEnd,D1
	CMP.W	D0,D1
	BHS.B	.ok
	MOVE.W	D0,MarkEnd
	MOVE.W	D1,MarkStart
.ok	JSR	InvertRange
	JMP	MarkToOffset
	
	CNOP 0,4
PTProcess	dc.l	0
PTProcessTmp	dc.l	0
rb_CurrentDir	dc.l	0
rb_PtDir	dc.l	0
rb_Progname	dc.b	'PT2.3F',0
VersionText	dc.b	'ProTracker v2.3F',0
InitError	dc.b	0
	EVEN

CheckInitError
	MOVE.B	InitError(PC),D0
	BEQ.W	Return1
	BTST	#0,D0
	BEQ.B	cieskp1
	JSR	PLSTMemErr
cieskp1
	MOVE.B	InitError(PC),D0
	BTST	#1,D0
	BEQ.B	cieskp2
	JSR	PLSTOpenErr
	JSR	FreePLST
cieskp2
	MOVE.B	InitError(PC),D0
	BTST	#2,D0
	BEQ.B	cieskp3
	JSR	ConfigErr
cieskp3
	MOVE.B	InitError(PC),D0
	BTST	#3,D0
	BEQ.W	Return1
	JSR	ConfigErr2
	BSR.W	SetNormalPtrCol
	BRA.W	StorePtrCol

CheckPatternRedraw
	TST.B	UpdateTempo
	BEQ.B	chkredr
	CLR.B	UpdateTempo
	BSR.W	SetTempo
chkredr	CMP.L	#'patp',RunMode
	BNE.W	Return1
	JSR	ShowPosition
	JSR	RefreshPosEd
	TST.B	PattRfsh
	BEQ.W	Return1
	MOVE.L	PattRfshNum,PatternNumber
	JMP	RedrawPattern
	
; ----------------------------------------------------------------------------
; Allocates a block of memory
;
; Input:
;  D0 - byteSize
;  D1 - attributes
;
; Output:
;  D0 - memoryBlock (0 if alloc failed)
; ----------------------------------------------------------------------------
PTAllocMem
	MOVEM.L	D1/A1/A6,-(SP)
	MOVE.L	4.W,A6
	JSR	_LVOAllocMem(A6)
	MOVEM.L	(SP)+,D1/A1/A6
	RTS

; ----------------------------------------------------------------------------
; Frees a block of memory
;
; Input:
;  A1 - memoryBlock
;  D0 - byteSize
; ----------------------------------------------------------------------------
PTFreeMem
	MOVEM.L	D0/D1/A1/A6,-(SP)
	MOVE.L	4.W,A6
	JSR	_LVOFreeMem(A6)	
	MOVEM.L	(SP)+,D0/D1/A1/A6
	RTS
	
;---- Cleanup upon exit from PT ----

ExitCleanup
	JSR	StopIt
	SF	EdEnable
	BSR.W	EscPressed
	BSR.W	EscPressed
	BSR.W	ResetVBInt
	BSR.W	ResetMusicInt
	BSR.W	ResetInputHandler
	BSR.W	SetOldCopList
	JSR	CloseMIDI
	JSR	FreeCopyBuf
errorexit1
	BSR.W	PTScreenToBack
	BSR.W	ClosePTScreen
	MOVE.L	4.W,A6
	MOVE.L	GfxBase,A1
	JSR	_LVOCloseLibrary(A6)
	MOVE.L	IntuitionBase,A1
	JSR	_LVOCloseLibrary(A6)
	MOVE.L	DOSBase,A1
	JSR	_LVOCloseLibrary(A6)
	TST.L	PPLibBase		; did we open powerpacker.library?
	BEQ.B	exex1			; no, don't attempt to close it
	MOVE.L	PPLibBase,A1
	JSR	_LVOCloseLibrary(A6)
exex1	MOVE.L	SongDataPtr,D1
	BEQ.B	exex2
	MOVE.L	D1,A1
	MOVE.L	SongAllocSize,D0
	JSR	PTFreeMem
exex2	BSR.W	FreeDirMem
	BSR.W	GiveBackInstrMem
	JSR	FreePLST
	JSR	TurnOffVoices
	BCLR	#1,$BFE001
	MOVE.B	LEDStatus,D0
	AND.B	#2,D0
	OR.B	D0,$BFE001	; Restore LED Status	
	MOVEQ	#0,D0
	MOVE.W	D0,$DFF0A8	; clear voice #1 volume
	MOVE.W	D0,$DFF0B8	; clear voice #2 volume
	MOVE.W	D0,$DFF0C8	; clear voice #3 volume
	MOVE.W	D0,$DFF0D8	; clear voice #4 volume
	MOVE.L	StackSave,SP	; important! (leaking memory without it, for some reason)
Return1	RTS

;---- Open Lots Of Things ----

SetDefaultSampleReplens
	MOVE.L	SongDataPtr,A0
	LEA	sd_sampleinfo(A0),A0
	MOVEQ	#31-1,D0
.loop	MOVE.W	#1,28(A0)
	LEA	30(A0),A0
	DBRA	D0,.loop
	RTS

OpenLotsOfThings
	MOVE.B	$BFE001,LEDStatus
	BSET	#1,$BFE001
	JSR	TurnOffVoices
	MOVEQ	#0,D0
	MOVE.W	D0,$DFF0A8		; clear voice #1 volume
	MOVE.W	D0,$DFF0B8		; clear voice #2 volume
	MOVE.W	D0,$DFF0C8		; clear voice #3 volume
	MOVE.W	D0,$DFF0D8		; clear voice #4 volume
	MOVE.L	4.W,A6
	; -------------------------------
	; set song playback counter delta
	; -------------------------------
	CMP.B	#60,$0212(A6) 		; 50=PAL, 60=NTSC
	BEQ.B	.NTSC
	MOVE.L	#PDELTA_PAL,PlaybackSecsDelta
	BRA.B	.L1
.NTSC	MOVE.W	$DFF004,D0
	LSR.W	#8,D0
	AND.B	#$3F,D0
	CMP.B	#20,D0			; Agnus is ECS or AGA?
	BLO.B	.L0			; nope
	MOVE.L	#PDELTA_PAL_ON_NTSC,PlaybackSecsDelta
	BRA.B	.L1
.L0	MOVE.L	#PDELTA_NTSC,PlaybackSecsDelta
.L1	; -------------------------------
	LEA	DOSname(PC),A1		; Open DOS library
	MOVEQ	#0,D0
	JSR	_LVOOpenLibrary(A6)
	MOVE.L	D0,DOSBase
	LEA	GraphicsName(PC),A1	; Open graphics library
	MOVEQ	#0,D0
	JSR	_LVOOpenLibrary(A6)
	MOVE.L	D0,GfxBase
	LEA	IntuitionName(PC),A1	; Open Intuition library
	MOVEQ	#0,D0
	JSR	_LVOOpenLibrary(A6)
	MOVE.L	D0,IntuitionBase
	
	BSR.W	OpenPTScreen
	BEQ.W	errorexit1
	
	MOVE.L	DOSBase,A6
	MOVE.L	rb_CurrentDir(PC),D1
	JSR	_LVOCurrentDir(A6)

	MOVE.L	#TextBitplane,D0
	MOVE.W	D0,NoteBplptrLow	; set low word
	SWAP	D0
	MOVE.W	D0,NoteBplptrHigh	; set high word
	
	MOVE.L	SongAllocSize,D0
	MOVE.L	#MEMF_PUBLIC!MEMF_CLEAR,D1
	JSR	PTAllocMem
	MOVE.L	D0,SongDataPtr
	BEQ.W	errorexit1
	BSR.W	SetDefaultSampleReplens
	
	MOVE.L	SongDataPtr,A0
	MOVE.W	#$017F,sd_numofpatt(A0)
	MOVE.L	#'M.K.',sd_magicid(A0)	; M.K. again...
	
	MOVEQ	#6,D0
	MOVE.L	D0,CurrSpeed
	CLR.W	PEDpos
	MOVE.L	#ModulesPath2,PathPtr

	MOVE.L	#CopCol1,CopListColorPtr
	MOVE.L	#CopListBpl4,CopListBpl4Ptr
	MOVE.L	#KbdTransTable2,KeyTransTabPtr
	MOVE.L	#NoteNames1,NoteNamesPtr
	MOVE.L	#VUmeterColors,TheRightColors
	
	MOVE.L	#BitplaneData,D0 	; Set pointers to bitplane data
	LEA	CopListBitplanes,A1
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)
	SWAP	D0
	ADD.L	#10240,D0
	MOVE.W	D0,14(A1)
	SWAP	D0
	MOVE.W	D0,10(A1)
	BSR.W	SetDefSpritePtrs
	BSR.W	UpdateCursorPos
	JSR	RedrawPattern
	JSR	ShowPosition
	JSR	ShowSongLength
	MOVE.W	#1,InsNum
	JSR	ShowSampleInfo
	
	LEA	TopMenusPos,A0
	LEA	TopMenusBuffer,A1
	MOVEQ	#44-1,D0
stmloop	MOVEQ	#25-1,D1
stmloop2
	MOVE.B	(A0)+,(A1)+
	MOVE.B	$27FF(A0),$044B(A1)
	DBRA	D1,stmloop2
	LEA	15(A0),A0
	DBRA	D0,stmloop
	
	JSR	DoResetAll
	JSR	cfgupda
	JSR	LoadConfigOnStartup ; --PT2.3D bug fix: make sure cwd is correct at this point
	MOVE.L	#NoteNames1,NoteNamesPtr
	TST.B	Accidental
	BEQ.B	alotskip
	MOVE.L	#NoteNames2,NoteNamesPtr
alotskip
	TST.B	OneHundredPattFlag
	BEQ.B	alotskip3
	MOVE.L	SongDataPtr,D1
	BEQ.B	alotskip2
	MOVE.L	D1,A1
	MOVE.L	SongAllocSize,D0
	JSR	PTFreeMem
alotskip2
	MOVE.L	#SONG_SIZE_100PAT,SongAllocSize
	MOVE.L	#100-1,MaxPattern
	MOVE.L	SongAllocSize,D0
	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,SongDataPtr
	BEQ.W	errorexit1
	BSR.W	SetDefaultSampleReplens
alotskip3
	TST.B	LoadPLSTFlag
	BEQ.B	ChangeCopList
	JSR	DoLoadPLST
	
ChangeCopList
	TST.W	SamScrEnable
	BNE.W	Return1
	BSR.W	SetupAnaCols
SetupVUCols
	TST.W	SamScrEnable
	BNE.W	Return1
	LEA	CopListMark2,A0	; VUmeter coloring
	MOVE.W	#$B907,D5	; Start position
	LEA	VUmeterColors,A5
	MOVEQ	#48-1,D7		; Change 48 lines
alotlp4	MOVE.W	D5,(A0)+
	MOVE.W	#$FFFE,(A0)+
	LEA	VUmeterColRegs(PC),A1
	MOVEQ	#2-1,D6
alotlp5	MOVE.W	(A5),D4
	MOVE.W	(A1)+,(A0)+
	MOVE.W	#3,FadeX
	MOVE.W	D4,D0
	JSR	FadeCol
	MOVE.W	D0,(A0)+
	MOVE.W	(A1)+,(A0)+
	MOVE.W	D4,(A0)+
	MOVE.W	(A1)+,(A0)+
	MOVE.W	#$FFFD,FadeX
	MOVE.W	D4,D0
	JSR	FadeCol
	MOVE.W	D0,(A0)+
	DBRA	D6,alotlp5
	ADDQ	#2,A5
	ADD.W	#$0100,D5	; Next line...
	DBRA	D7,alotlp4
	RTS

VUmeterColRegs
	dc.w	$01AA,$01AC,$01AE,$01B2,$01B4,$01B6
	
	CNOP 0,4
CopListBpl4Ptr	dc.l	0
CopListColorPtr	dc.l	0
DOSname		dc.b	'dos.library',0
IntuitionName	dc.b	'intuition.library',0
GraphicsName	dc.b	'graphics.library',0
	EVEN

SetupAnaCols
	LEA	CopListAnalyzer,A5
	MOVE.W	ColorTable+12,D2
	MOVEQ	#40-1,D0	; Change col 40 lines
	MOVE.W	#$687D,D1	; Start pos
	TST.B	ScreenAdjustFlag
	BEQ.B	sacloop
	SUBQ.W	#8,D1
sacloop	MOVE.W	D1,(A5)+	; Set wait
	MOVE.W	#$FFFE,(A5)+
	MOVE.W	#$018C,(A5)+	; Set analyzer color
	ADDQ	#2,A5
	ADD.W	#$0060,D1	; Move x-pos
	MOVE.W	D1,(A5)+	; Wait
	MOVE.W	#$FFFE,(A5)+
	MOVE.W	#$018C,(A5)+	; Set text color
	MOVE.W	D2,(A5)+
	ADD.W	#$A0,D1		; Next line...
	DBRA	D0,sacloop
	TST.B	DisableAnalyzer
	BNE.B	ClearAnalyzerColors
SetAnalyzerColors
	LEA	CopListAnalyzer+6,A1
	LEA	AnalyzerColors,A0
	MOVEQ	#40-1,D0		; 40 lines
sanclop	MOVE.W	(A0)+,(A1)
	LEA	16(A1),A1
	DBRA	D0,sanclop
	RTS

ClearAnalyzerColors
	LEA	CopListAnalyzer+6,A0
	MOVE.W	ColorTable+12,D1
	MOVEQ	#40-1,D0		; 40 lines.
cacloop	MOVE.W	D1,(A0)
	LEA	16(A0),A0
	DBRA	D0,cacloop
	RTS

SetSamSpritePtrs
	MOVE.L	#LoopSpriteData1,Ch1SpritePtr
	MOVE.L	#LoopSpriteData2,Ch2SpritePtr
	MOVE.L	#PlayPosSpriteData,Ch3SpritePtr
	MOVE.L	#NoSpriteData,Ch4SpritePtr
	BRA.B	sdsp2
SetDefSpritePtrs
	MOVE.L	#VUSpriteData1,Ch1SpritePtr
	MOVE.L	#VUSpriteData2,Ch2SpritePtr
	MOVE.L	#VUSpriteData3,Ch3SpritePtr
	MOVE.L	#VUSpriteData4,Ch4SpritePtr
sdsp2
	MOVE.L	#CursorSpriteData,CursorPosPtr
	MOVE.L	#PointerSpriteData,PointerSpritePtr
	MOVE.L	#LineCurSpriteData,LineCurPosPtr
	MOVE.L	#NoSpriteData,NoSpritePtr
	MOVE.L	PointerSpritePtr(PC),SpritePtrsPtr
	
	LEA	SpritePtrsPtr,A0	; Set pointers to spritedata
	LEA	CopperSpriteList,A1
	MOVEQ	#16-1,D2
alotloop2
	MOVE.W	(A0)+,2(A1)
	ADDQ	#4,A1
	DBRA	D2,alotloop2
	RTS

	CNOP 0,4
PointerSpritePtr	dc.l	0

	
;---- Vertical Blank Interrupt ----

SetVBInt
	MOVEQ	#5,D0
	LEA	VBIntServer(PC),A1
	MOVE.L	4.W,A6
	JSR	_LVOAddIntServer(A6)
	RTS

ResetVBInt
	MOVEQ	#5,D0
	LEA	VBIntServer(PC),A1
	MOVE.L	4.W,A6
	JSR	_LVORemIntServer(A6)
	RTS

vbint
	TST.B	ShowRasterbar
	BEQ.B	.skip1
	MOVE.W	#$125,$DFF180	; rasterbars to measure frame time left
.skip1
	MOVEM.L	D0-D7/A0-A6,-(SP)
	; ------------------------------
	BSR.W	TickPlaybackCounter
	BSR.W	CheckIfProgramIsActive
	BEQ.W	vbiend
	BSR.W	UpdatePointerPos
	BSR.W	Scope ; draw scopes early to lower chance of flickering
	TST.B	RealVUMetersFlag
	BEQ.B	.skip2
	BSR.W	RealVUMeters
	BRA.B	vbint2
.skip2	BSR.W	VUMeters
vbint2	BSR.W	SpecAnaInt
	BSR.W	ArrowKeys
	BSR.W	CheckKeyRepeat
	MOVE.L	SongPosition,CurrPos
	MOVE.L	SongDataPtr,A0
	LEA	sd_pattpos(A0),A0
	ADD.L	CurrPos,A0
	MOVE.B	(A0),D1
	MOVE.B	D1,PattRfshNum+3
	CMP.B	LongFFFF+3,D1
	BEQ.B	vbiskip
	ST	PattRfsh
vbiskip
	MOVE.B	D1,LongFFFF+3
	TST.B	PattRfsh
	BNE.B	vbiskip2
	TST.W	BlockMarkFlag
	BNE.B	vbiskip2
	TST.B	UpdateTempo
	BNE.B	vbiskip2
	TST.W	KeyBufPos
	BEQ.B	vbiskip3
vbiskip2
	MOVE.L	4.W,A6
	MOVE.L	PTProcess(PC),A1
	MOVE.L	#$20000000,D0
	JSR	_LVOSignal(A6)
vbiskip3
	BTST	#6,$BFE001	; left mouse button
	BNE.B	vbiskip4
	MOVE.L	4.W,A6
	MOVE.L	PTProcess(PC),A1
	MOVE.L	#$10000000,D0
	JSR	_LVOSignal(A6)
vbiskip4
	; bit of a kludge to get scope muting working
	TST.B	RightMouseButtonHeld
	BEQ.B	rmbnotheld
rmbheld
	BTST.B	#10-8,$DFF016
	BEQ.B	rmbreleased
	BRA.B	vbiend
rmbnotheld
	BTST.B	#10-8,$DFF016
	BEQ.B	vbiend
	ST	RightMouseButtonHeld
	BRA.B	vbiend
rmbreleased
	CLR.B	RightMouseButtonHeld
	BSR.W	CheckScopeMuting	
vbiend	; ------------------------------
	MOVEM.L	(SP)+,D0-D7/A0-A6
	TST.B	ShowRasterbar
	BEQ.B	.skip2
	MOVE.W	#0,$DFF180 	; rasterbars to measure frame time left
.skip2
	RTS
	
	CNOP 0,4
VBIntServer
	dc.l 0,0
	dc.b 2,0 ; type, priority
	dc.l vbintname
	dc.l 0,vbint

vbintname	dc.b	'ProTracker VBlank',0
	EVEN

CheckPatternRedraw2
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.W	WordNumber,-(SP)
	MOVE.W	TextOffset,-(SP)
	MOVE.L	LongFFFF,-(SP)
	MOVE.W	TextLength,-(SP)
	MOVE.L	ShowTextPtr,-(SP)
	BSR.W	CheckPatternRedraw
	MOVE.L	(SP)+,ShowTextPtr
	MOVE.W	(SP)+,TextLength
	MOVE.L	(SP)+,LongFFFF
	MOVE.W	(SP)+,TextOffset
	MOVE.W	(SP)+,WordNumber
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

CheckIfProgramIsActive
	MOVE.L	IntuitionBase,A6
	MOVE.L	60(A6),D0
	CMP.L	PTScreenHandle(PC),D0
	BNE.B	cipiaskip2
	CMP.L	WBScreenHandle(PC),D0
	BEQ.B	cipiaskip
	MOVE.L	D0,WBScreenHandle
	BSR.B	SetCopList
	CLR.W	LeftAmigaStatus
	ST	StopInputFlag
cipiaskip
	MOVEQ	#1,D0
	RTS
cipiaskip2
	CMP.L	WBScreenHandle(PC),D0
	BEQ.B	cipiaskip3
	MOVE.L	D0,WBScreenHandle
	BSR.B	SetOldCopList
	SF	StopInputFlag
cipiaskip3
	MOVEQ	#0,D0
	RTS
	
;---- Copper List ----

SetCopList
	MOVE.L	#CopperList1,$DFF080	
	RTS

SetOldCopList
	MOVE.L	GfxBase,A0
	MOVE.L	38(A0),$DFF080
	RTS
	
;---- Intuition Routines ----

OpenPTScreen
	MOVE.L	IntuitionBase,A6
	LEA	PTScreenStruct(PC),A0
	JSR	_LVOOpenScreen(A6)
	MOVE.L	D0,PTScreenHandle
	RTS

ClosePTScreen
	MOVE.L	IntuitionBase,A6
	MOVE.L	PTScreenHandle(PC),D0
	BEQ.B	cptsskip
	MOVE.L	D0,A0
	JSR	_LVOCloseScreen(A6)
	CLR.L	PTScreenHandle
cptsskip
	RTS

PTScreenToBack
	MOVEM.L	D1/A0-A1/A6,-(SP)
	MOVE.L	IntuitionBase,A6
	MOVE.L	PTScreenHandle(PC),D0
	BEQ.B	ptstbskip
	MOVE.L	D0,A0
	JSR	_LVOScreenToBack(A6)
ptstbskip
	MOVE.L	4.W,A0
	CMP.W	#32,20(A0)
	BLS.B	ptstbskip2
	MOVE.L	GfxBase,A0
	MOVEQ	#28,D0
	AND.B	236(A0),D0
	CMP.B	#28,D0
	BNE.B	ptstbskip2
	MOVE.W	BeamCONTemp,$DFF1DC
ptstbskip2
	MOVEM.L	(SP)+,D1/A0-A1/A6
	RTS

PTScreenToFront
	MOVEM.L	D1/A0-A1/A6,-(SP)
	MOVE.L	4.W,A0
	CMP.W	#32,20(A0)
	BLS.B	ptstfskip
	MOVE.L	GfxBase,A0
	MOVEQ	#28,D0
	AND.B	236(A0),D0
	CMP.B	#28,D0
	BNE.B	ptstfskip
	MOVE.L	380(A0),A0
	MOVE.W	40(A0),BeamCONTemp
ptstfskip
	MOVE.L	IntuitionBase,A6
	MOVE.L	PTScreenHandle(PC),A0
	JSR	_LVOScreenToFront(A6)
	MOVEM.L	(SP)+,D1/A0-A1/A6
	RTS

WorkbenchToFront
	MOVEM.L	D1/A0-A1/A6,-(SP)
	MOVE.L	IntuitionBase,A6
	JSR	_LVOWBenchToFront(A6)
	MOVEM.L	(SP)+,D1/A0-A1/A6
	RTS	

	CNOP 0,4
PTScreenHandle dc.l 0
WBScreenHandle dc.l 0

PTScreenStruct	
	dc.w 0			; LeftEdge
	dc.w 0			; TopEdge
	dc.w 320		; Width
	dc.w 12			; Height (lower than 12 = crash. Found out the hard way!)
	dc.w 1			; Depth	(only one bitplane. We don't render in the screen)
	dc.b 0			; DetailPen
	dc.b 1			; BlockPen
	dc.w 0			; ViewModes
	dc.w $008F		; Types ($008F = CUSTOMSCREEN | SCREENBEHIND)
	dc.l 0			; TextAttr struct pointer
	dc.l VersionText	; DefaultTitle
	dc.l 0			; Gadget struct pointer
	dc.l 0			; BitMap struct pointer

;---- Music Interrupt ----

SetMusicInt
	TST.B	IntMode
	BNE.B	SetCIAInt
	MOVEQ	#5,D0
	LEA	MusicIntServer(PC),A1
	MOVE.L	4.W,A6
	JSR	_LVOAddIntServer(A6)
	RTS

ResetMusicInt
	TST.B	IntMode
	BNE.W	ResetCIAInt
	MOVEQ	#5,D0
	LEA	MusicIntServer(PC),A1
	MOVE.L	4.W,A6
	JSR	_LVORemIntServer(A6)
	RTS

	CNOP 0,4
MusicIntServer
	dc.l 0,0
	dc.b 2,1 ; type, priority
	dc.l musintname
	dc.l 0,IntMusic

musintname	dc.b "ProTracker MusicInt",0
	EVEN

;---- CIA Interrupt ----

ciatalo = $400
ciatahi = $500
ciatblo = $600
ciatbhi = $700
ciacra  = $E00
ciacrb  = $F00

SetCIAInt
	MOVEQ	#2,D6
	LEA	$BFD000,A5
	MOVE.B	#'b',CIAAname+3
SetCIALoop
	MOVEQ	#0,D0
	LEA	CIAAname(PC),A1
	MOVE.L	4.W,A6
	JSR	_LVOOpenResource(A6)
	MOVE.L	D0,CIAAbase
	BEQ.W	Return1
	
	MOVE.L	D0,A6
	MOVE.L	GfxBase,A0
	MOVE.W	206(A0),D0	; DisplayFlags
	BTST	#2,D0		; PAL?
	BEQ.B	WasNTSC
	MOVE.L	#1773447,D7 ; PAL (= round[709379.0 * (125/50)])
	BRA.B	sciask
WasNTSC	MOVE.L	#1789773,D7 ; NTSC (= round[715909.09090 * (125/50)])
sciask	MOVE.L	D7,TimerValue
	DIVU.W	#125,D7 ; Default to normal 50 Hz timer
	
TryTimerB
	LEA	MusicIntServer(PC),A1
	MOVEQ	#1,D0	; Bit 1: Timer B
	JSR	_AddICRVector(A6)
	MOVE.L	#1,TimerFlag
	TST.L	D0
	BNE.B	TryTimerA
	MOVE.L	A5,CIAAaddr
	MOVE.B	D7,ciatblo(A5)
	LSR.W	#8,D7
	MOVE.B	D7,ciatbhi(A5)
	BSET	#0,ciacrb(A5)
	BRA.W	SetTempo

TryTimerA
	LEA	MusicIntServer(PC),A1
	MOVEQ	#0,D0	; Bit 0: Timer A
	JSR	_AddICRVector(A6)
	CLR.L	TimerFlag
	TST.L	D0
	BNE.B	CIAError
	MOVE.L	A5,CIAAaddr
	MOVE.B	D7,ciatalo(A5)
	LSR.W	#8,D7
	MOVE.B	D7,ciatahi(A5)
	BSET	#0,ciacra(A5)
	BRA.W	SetTempo

CIAError
	MOVE.B	#'a',CIAAname+3
	LEA	$BFE001,A5
	SUBQ.W	#1,D6
	BNE.W	SetCIALoop
	CLR.L	CIAAbase
	RTS

ResetCIAInt
	MOVE.L	CIAAbase(PC),D0
	BEQ.W	Return1
	CLR.L	CIAAbase
	MOVE.L	D0,A6
	MOVE.L	CIAAaddr(PC),A5
	TST.L	TimerFlag
	BEQ.B	ResTimerA
	
	BCLR	#0,ciacrb(A5)
	MOVEQ	#1,D0
	BRA.B	RemInt

ResTimerA
	BCLR	#0,ciacra(A5)
	MOVEQ	#0,D0
RemInt	LEA	MusicIntServer(PC),A1
	JSR	_RemICRVector(A6)
	RTS

	CNOP 0,4
CIAAbase	dc.l	0
TimerFlag	dc.l	0
TimerValue	dc.l	0
CIAAname	dc.b	'ciaa.resource',0
	EVEN

;---- Tempo ----

TempoGadg
	CMP.W	#60,D0
	BHS	Return1
	CMP.W	#44,D0
	BHS.B	TemDown
TemUp	MOVE.W	RealTempo(PC),D0
	ADDQ.W	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	teupsk
	ADDQ.W	#8,D0
	ADDQ.W	#1,D0
teupsk	CMP.W	#255,D0
	BLS.B	teposk
	MOVE.W	#255,D0
teposk	MOVE.W	D0,RealTempo
	BSR	SetTempo
	JMP	Wait_4000

TemDown	MOVE.W	RealTempo(PC),D0
	SUBQ.W	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	tednsk
	SUBQ.W	#8,D0
	SUBQ.W	#1,D0
tednsk	CMP.W	#32,D0
	BHS.B	teposk
	MOVE.W	#32,D0
	BRA.B	teposk


ChangeTempo
	CMP.W	#97,D0
	BHS.B	TempoDown
	CMP.W	#86,D0
	BHS.B	TempoUp
	RTS

TempoUp	MOVE.W	Tempo,D0
	ADDQ.W	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	temupsk
	ADDQ.W	#8,D0
	ADDQ.W	#1,D0
temupsk	CMP.W	#255,D0
	BLS.B	temposk
	MOVE.W	#255,D0
temposk	MOVE.W	D0,Tempo
	MOVE.W	D0,RealTempo
	BSR.B	ShowTempo
	BSR.B	SetTempo
	JMP	Wait_4000
	
TempoDown
	MOVE.W	Tempo,D0
	SUBQ.W	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	temdnsk
	SUBQ.W	#8,D0
	SUBQ.W	#1,D0
temdnsk	CMP.W	#32,D0
	BHS.B	temposk
	MOVE.W	#32,D0
	BRA.B	temposk

ShowTempo
	MOVE.W	#607,TextOffset
	MOVE.W	RealTempo(PC),WordNumber
	JMP	Print3DecDigits

SetTempo
	MOVEQ	#125,D0
	MOVE.L	CIAAbase(PC),D1
	BEQ.B	setesk3
	MOVE.W	RealTempo(PC),D0
	CMP.W	#32,D0
	BHS.B	setemsk
	MOVEQ	#32,D0
setemsk	MOVE.W	D0,RealTempo
setesk3	TST.W	SamScrEnable
	BNE.B	setesk2
	MOVE.W	#4964,TextOffset
	MOVE.W	D0,WordNumber
	JSR	Print3DecDigits
setesk2	MOVE.L	CIAAbase(PC),D0
	BEQ.W	Return1
	MOVE.W	RealTempo(PC),D0
	MOVE.L	TimerValue(PC),D1
	DIVU.W	D0,D1
	MOVE.L	CIAAaddr(PC),A5
	MOVE.L	TimerFlag(PC),D0
	BEQ.B	SetTemA
	MOVE.B	D1,ciatblo(A5)	;and set the CIA timer
	LSR.W	#8,D1
	MOVE.B	D1,ciatbhi(A5)
	RTS

SetTemA	MOVE.B	D1,ciatalo(A5)
	LSR.W	#8,D1
	MOVE.B	D1,ciatahi(A5)
	RTS

	CNOP 0,4
CIAAaddr	dc.l 0
RealTempo	dc.w 125

;---- Input Event Handler ----

SetInputHandler
	LEA	InpEvPort,A0
	MOVE.B	#4,8(A0)
	MOVE.B	#0,14(A0)
	MOVE.B	#$1F,15(A0)
	MOVE.L	PTProcess(PC),16(A0)
	LEA	20(A0),A1
	MOVE.L	A1,(A1)
	ADDQ	#4,(A1)
	CLR.L	4(A1)
	MOVE.L	A1,8(A1)
	MOVE.L	4.L,A6
	LEA	InputDevName,A0
	MOVEQ	#0,D0
	LEA	InpEvIOReq,A1
	MOVEQ	#0,D1
	MOVE.L	#InpEvPort,14(A1)
	JSR	_LVOOpenDevice(A6)
	LEA	InpEvIOReq,A1
	MOVE.W	#9,IO_COMMAND(A1) ; IND_ADDHANDLER
	MOVE.L	#InpEvStuff,IO_DATA(A1)
	JSR	_LVODoIO(A6)
	RTS

ResetInputHandler
	MOVE.L	4.W,A6
	LEA	InpEvIOReq,A1
	MOVE.W	#10,IO_COMMAND(A1) ; IND_REMHANDLER
	MOVE.L	#InpEvStuff,IO_DATA(A1)
	JSR	_LVODoIO(A6)
	LEA	InpEvIOReq,A1
	JSR	_LVOCloseDevice(A6)
	RTS

	CNOP 0,4
InpEvStuff
	dc.l	0,0
	dc.b	2,52 ; type, priority
	dc.l	inpevname
	dc.l	0,InputHandler

inpevname
	dc.b "ProTracker InputHandler",0
	EVEN

InputHandler ; A0-InputEvent, A1-Data Area
	MOVEM.L	D1/D2/A0-A3,-(SP)
	TST.B	StopInputFlag
	BEQ.B	inphend
	SUB.L	A2,A2
	MOVE.L	A0,A1
inploop	MOVE.B	4(A1),D0	; ie_Class
	CMP.B	#1,D0		; IECLASS_RAWKEY
	BEQ.W	InpRawkey
	CMP.B	#2,D0		; IECLASS_RAWMOUSE
	BEQ.B	InpRawmouse
	MOVE.L	A1,A2
InpNext	MOVE.L	0(A1),A1	; ie_NextEvent
	MOVE.L	A1,D0		; pointer == NULL?	
	BNE.B	inploop
inphend	MOVE.L	A0,D0
	MOVEM.L	(SP)+,D1/D2/A0-A3
	RTS
	
InpUnchain
	MOVE.L	A2,D0
	BNE.B	InpUnc2
	MOVE.L	0(A1),A0
	RTS
InpUnc2	MOVE.L	0(A1),0(A2)
	RTS
	
	; Changed the mouse code as PT2.3A introduced crude acceleration,
	; which made the mouse very annoying during precise sliding.
InpRawmouse
	BSR.B	InpUnchain
	; ----------------------
	TST.B	DiskDriveBusy	; is floppy drive accessing?
	BNE.B	InpNext
	; ----------------------
	MOVEQ	#MOUSE_SPEED,D0
	MULS.W	10(A1),D0	; ie_x (mouse pointer pos)
	MOVE.W	MouseX,D1
	LSL.W	#4,D1
	ADD.W	MouseXFrac,D1
	ADD.W	D1,D0
	BPL.B	.L0
	MOVEQ	#0,D0
	MOVE.W	D0,MouseXFrac
	BRA.B	.L2
.L0	CMP.W	#(SCREEN_W-1)<<4,D0
	BLE.B	.L1
	MOVE.W	#(SCREEN_W-1)<<4,D0
.L1	MOVE.W	D0,D1
	AND.W	#15,D1
	MOVE.W	D1,MouseXFrac
	LSR.W	#4,D0
	SWAP	D0
	; ----------------------
.L2	MOVEQ	#MOUSE_SPEED,D1
	MULS.W	12(A1),D1	; ie_y (mouse pointer pos)
	MOVE.W	MouseY,D2
	LSL.W	#4,D2	
	ADD.W	MouseYFrac,D2
	ADD.W	D2,D1
	BPL.B	.L3
	CLR.W	D0
	MOVE.W	D0,MouseYFrac
	BRA.B	.L5
.L3	CMP.W	#(SCREEN_H-1)<<4,D1
	BLE.B	.L4
	MOVE.W	#(SCREEN_H-1)<<4,D1
.L4	MOVE.W	D1,D2
	AND.W	#15,D2
	MOVE.W	D2,MouseYFrac
	LSR.W	#4,D1
	MOVE.W	D1,D0
	; ----------------------
.L5	MOVE.L	D0,MouseX	; writes to X and Y in one go (safer)
	; ----------------------
	BRA.W	InpNext
	
InpRawkey
	BSR.W	InpUnchain
	MOVE.W	6(A1),D0	; ie_Code
	BSR.W	ProcessRawkey
	BRA.W	InpNext
	
;---- Process rawkey code from the keyboard ----

ProcessRawkey
	CMP.B	LastRawkey(PC),D0
	BEQ.W	kbintDone
	MOVE.B	D0,LastRawkey	
	; -------------------------
	CMP.B	#96,D0
	BEQ.W	ShiftOn
	CMP.B	#97,D0
	BEQ.W	ShiftOn2
	CMP.B	#100,D0
	BEQ.W	AltOn
	CMP.B	#101,D0
	BEQ.W	AltOn2
	CMP.B	#99,D0
	BEQ.W	CtrlOn
	CMP.B	#102,D0
	BEQ.W	LeftAmigaOn
	CMP.B	#99+128,D0
	BEQ.W	CtrlOff
	CMP.B	#100+128,D0
	BEQ.W	AltOff
	CMP.B	#101+128,D0
	BEQ.W	AltOff
	CMP.B	#96+128,D0
	BEQ.W	ShiftOff2
	CMP.B	#97+128,D0
	BEQ.W	ShiftOff
	CMP.B	#102+128,D0
	BEQ.W	LeftAmigaOff
	CMP.B	#98,D0
	BEQ.W	KeyRepOn
	CMP.B	#98+128,D0
	BEQ.W	KeyRepOff
	MOVE.W	8(A1),D1
	AND.W	#64,D1
	BEQ.B	kbintSetKey
	CMP.B	#54,D0
	BEQ.W	WorkbenchToFront
	CMP.B	#55,D0
	BEQ.W	PTScreenToBack
kbintSetKey
	TST.B	D0
	BNE.B	kbintDoSet
	MOVE.B	#127,LastRawkey
	BRA.W	PTScreenToBack
kbintDoSet
	MOVE.W	KeyBufPos(PC),D1
	CMP.W	#KeyBufSize,D1
	BHS.B	kbintDone
	LEA	KeyBuffer(PC),A3
	MOVE.B	D0,(A3,D1.W)
	ADDQ.W	#1,KeyBufPos
kbintDone
	RTS

ShiftOff2
	CLR.W	ShiftKeyStatus
	BRA.W	kbintSetKey

KeyRepOn
	ST	KeyRepeat
	RTS

KeyRepOff
	SF	KeyRepeat
	RTS

ShiftOn2
	MOVE.W	#1,ShiftKeyStatus
	BRA.W	kbintSetKey

ShiftOff
	CLR.W	ShiftKeyStatus
	RTS

AltOn
	MOVE.W	#1,AltKeyStatus
	RTS

AltOn2
	MOVE.W	#1,AltKeyStatus
	BRA.W	kbintSetKey

AltOff
	CLR.W	AltKeyStatus
	RTS

CtrlOn
	MOVE.W	#1,CtrlKeyStatus
	RTS

CtrlOff
	CLR.W	CtrlKeyStatus
	RTS

LeftAmigaOn
	MOVE.W	#1,LeftAmigaStatus
	RTS

LeftAmigaOff
	CLR.W	LeftAmigaStatus
	RTS

DoKeyBuffer
	MOVE.W	KeyBufPos(PC),D0
	BEQ.B	dkbend
	SUBQ.W	#1,D0
	LEA	KeyBuffer(PC),A0
	MOVE.B	(A0,D0.W),D1
	MOVE.W	D0,KeyBufPos
	MOVE.B	D1,RawKeyCode
	MOVE.B	D1,SaveKey
	MOVE.W	KeyRepDelay,KeyRepCounter
	BTST	#7,D1
	BEQ.B	dkbend
	CLR.W	KeyRepCounter
dkbend	RTS

KeyBufPos	dc.w	0
ShiftKeyStatus	dc.w	0
AltKeyStatus	dc.w	0
CtrlKeyStatus	dc.w	0
LeftAmigaStatus	dc.w	0
KeyRepCounter	dc.w	0
KeyBuffer	dcb.b	KeyBufSize,0
KeyRepeat	dc.b	0
LastRawkey	dc.b	255,0
SaveKey		dc.b	0
	EVEN

;---- Key repeat ----

CheckKeyRepeat
	TST.B	KeyRepeat
	BEQ.W	Return1
	MOVE.W	KeyRepCounter(PC),D0
	BEQ.W	Return1
	SUBQ.W	#1,D0
	BEQ.B	RepDown
	MOVE.W	D0,KeyRepCounter
	RTS

RepDown
	MOVE.B	SaveKey(PC),RawKeyCode
	MOVE.W	KeyRepSpeed,KeyRepCounter
	MOVE.L	4.W,A6
	MOVE.L	PTProcess(PC),A1
	MOVE.L	#$20000000,D0
	JSR	_LVOSignal(A6)
	RTS
	
;---- Song Playback Counter ----

; 8bitbubsy: less code overhead and improved tick accuracy (less drifting)

; ------------ PAL Amiga video -------------
; Horizontal clock: 15625.088105727Hz (3546895.0 / 227.0)         
; Lines: 313
; Frame rate = 49.9204092835Hz (HorizontalClock / Lines)
PDELTA_PAL EQU 86036300 ; round[2^32 / FrameRate]
; ------------------------------------------

; ------------ NTSC Amiga video ------------
; Horizontal clock: 15734.265734266Hz (3579545.4545454 (recurring) / 227.5)               
; Lines: 263
; Frame rate = 59.8261054535Hz (HorizontalClock / Lines)	
PDELTA_NTSC EQU 71790856 ; round[2^32 / FrameRate]	
; ------------------------------------------

; --- PAL-on-NTSC Amiga video (ECS/AGA) ----
; Horizontal clock: 15768.922707249Hz (3579545.4545454 (recurring) / 227.0)
; Lines: 313
; Frame rate = 50.3799447516Hz (HorizontalClock / Lines)	
PDELTA_PAL_ON_NTSC EQU 85251529 ; round[2^32 / FrameRate]	
; ------------------------------------------

DrawPlaybackCounter
	MOVE.L	PlaybackSecs(PC),D0
	BRA.B	DoDrawPlaybackCounter
DPCEnd	RTS

TickPlaybackCounter
	CMP.L	#'patp',RunMode	; normal song playback mode?
	BNE.B	DPCEnd		; nope, don't tick counter
	MOVE.L	PlaybackSecsDelta(PC),D1
	ADD.L	D1,PlaybackSecsFrac
	BCC.B	DPCEnd
	MOVE.L	PlaybackSecs(PC),D0
	ADDQ.L	#1,D0
	MOVE.L	D0,PlaybackSecs
	; -- fall-through --

DoDrawPlaybackCounter
	CMP.W	#4,CurrScreen	; pset-ed screen shown?
	BEQ.W	DDPCEnd		; yep, counter is hidden (no draw)
	; ---------------------
	MOVEQ	#0,D1
	MOVE.W	#(99*60)+59,D1	; 99:59 (limit)
	CMP.L	D1,D0
	BLS.B	.OK
	MOVE.L	D1,D0
.OK	DIVU.W	#60,D0
	; ---------------------
	LEA	FontData,A4
	LEA	FastTwoDecTable,A3
	MOVEQ	#0,D1
	; ---------------------
	ADD.W	D0,D0		; D0.W = minutes (*2 for LUT)
	MOVE.B	0(A3,D0.W),D1
	LEA	(A4,D1.W),A0
	MOVE.B	1(A3,D0.W),D1
	LEA	(A4,D1.W),A1
	; ---------------------
	SWAP	D0			
	ADD.W	D0,D0		; D0.W = seconds (*2 for LUT)
	MOVE.B	0(A3,D0.W),D1
	LEA	(A4,D1.W),A2
	MOVE.B	1(A3,D0.W),D1
	LEA	(A4,D1.W),A3
	; ---------------------
	LEA	TextBitplane+4154,A4
	; ---------------------
	MOVE.B	(A0)+,(A4)+	; draw minutes
	MOVE.B	(A0)+,40-1(A4)
	MOVE.B	(A0)+,80-1(A4)
	MOVE.B	(A0)+,120-1(A4)
	MOVE.B	(A0),160-1(A4)
	MOVE.B	(A1)+,(A4)+
	MOVE.B	(A1)+,40-1(A4)
	MOVE.B	(A1)+,80-1(A4)
	MOVE.B	(A1)+,120-1(A4)
	MOVE.B	(A1),160-1(A4)
	; ---------------------
	ADDQ	#1,A4		; draw seconds
	MOVE.B	(A2)+,(A4)+		
	MOVE.B	(A2)+,40-1(A4)
	MOVE.B	(A2)+,80-1(A4)
	MOVE.B	(A2)+,120-1(A4)
	MOVE.B	(A2),160-1(A4)
	MOVE.B	(A3)+,(A4)+
	MOVE.B	(A3)+,40-1(A4)
	MOVE.B	(A3)+,80-1(A4)
	MOVE.B	(A3)+,120-1(A4)
	MOVE.B	(A3),160-1(A4)	
DDPCEnd	RTS

	CNOP 0,4
PlaybackSecsFrac	dc.l 0
PlaybackSecsDelta	dc.l 0
PlaybackSecs		dc.l 0

;---- Spectrum Analyzer ----

SpecAnaInt
	CMP.W	#1,CurrScreen
	BNE.W	Return1
	TST.B	DisableAnalyzer
	BNE.W	Return1
	TST.B	AnaDrawFlag
	BNE.W	Return1
	ST	AnaDrawFlag
	MOVEQ	#40,D5
	MOVEQ	#126,D6
	LEA	AnalyzerHeights,A0
	LEA	AnalyzerOpplegg,A1
	LEA	AnalyzerOffsets(PC),A2
	LEA	TextBitplane+1976,A3
	MOVEQ	#23-1,D7
spanlab1
	MOVE.W	(A0)+,D0
	CMP.W	#36,D0
	BLO.B	spanskip2
	MOVE.W	#36,D0
spanskip2
	MOVE.W	(A1)+,D1
	CMP.W	D0,D1
	BEQ.B	spanskip3
	BLO.B	span_r2
	SUB.W	D0,D1
	SUBQ.W	#1,D1
	ADD.W	D0,D0
	MOVE.W	(A2,D0.W),D0
spanloop
	CLR.B	(A3,D0.W)
	SUB.W	D5,D0
	DBRA	D1,spanloop
	BRA.B	spanskip3

span_r2	SUB.W	D1,D0
	SUBQ.W	#1,D0
	ADD.W	D1,D1
	MOVE.W	(A2,D1.W),D1
spanloop2
	MOVE.B	D6,(A3,D1.W)
	SUB.W	D5,D1
	DBRA	D0,spanloop2
spanskip3
	ADDQ	#1,A3
	DBRA	D7,spanlab1
	LEA	AnalyzerHeights,A0
	LEA	AnalyzerOpplegg,A1
	MOVEQ	#23-1,D7
spanloop3
	MOVE.W	(A0),D0
	MOVE.W	D0,(A1)+
	BEQ.B	spanskip4
	SUBQ.W	#1,D0
spanskip4
	MOVE.W	D0,(A0)+
	DBRA	D7,spanloop3
	SF	AnaDrawFlag
	RTS

ClearAnaHeights
	LEA	AnalyzerOpplegg,A0
	LEA	AnalyzerHeights,A1
	MOVEQ	#23-1,D7
	MOVEQ	#0,D0
cahloop	MOVE.W	D0,(A0)+
	MOVE.W	D0,(A1)+
	DBRA	D7,cahloop
	RTS

PlayNoteAnalyze	 ; called by keyboard play (bugfixed in PT2.3F)
	MOVEM.L	D0-D4/A0,-(SP)
	MOVEQ	#0,D2
	MOVE.B	3(A6),D2
	BRA.B	SpecAna2

	; for (i = 0 to 64) x = round[i * (24/64)]
SpecAnaVolLUT
	dc.b  0, 0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6
	dc.b  6, 6, 7, 7, 8, 8, 8, 9, 9, 9,10,10,11,11,11,12
	dc.b 12,12,13,13,14,14,14,15,15,15,16,16,17,17,17,18
	dc.b 18,18,19,19,20,20,20,21,21,21,22,22,23,23,23,24
	dc.b 24
	EVEN

SpectrumAnalyzer ; called by playroutine (bugfixed in PT2.3F)
	TST.B	n_muted(A6)	; channel muted?
	BNE.W	Return1		; yes, don't do
	MOVEM.L	D0-D4/A0,-(SP)
	;MOVEQ	#0,D2
	MOVE.B	n_volume(A6),D2	; Get channel volume
SpecAna2
	TST.B	AnaDrawFlag
	BNE.W	ohno
	ST	AnaDrawFlag
	; --------------------
	; Volume
	; --------------------
	TST.B	D2		; volume zero?
	BEQ.B	saend		; yes, don't do
	CMP.B	#64,D2		; volume above 64?
	BHI.B	saend		; yes, don't do
	EXT.W	D2
	MOVE.B	(SpecAnaVolLUT,PC,D2.W),D2 ; D2.W = 0..24
	MOVE.W	D2,D3
	LSR.B	#1,D3
	; --------------------
	; Period (fixed for C-1 finetune < 0 and B-3 finetune > 0)
	; --------------------
	CMP.W	#108,D0		; period below 108 (B-3 finetune +7)?
	BLO.B	saend		; yes, don't do
	CMP.W	#907,D0		; period above 907 (C-1 finetune -8)?
	BHI.B	saend		; yes, don't do
	; --------------------
	MOVE.W	#856,D4
	CMP.W	D4,D0		; lo-clamp to C-3 finetune 0
	BLS.B	.L0
	MOVE.W	D4,D0
.L0	MOVEQ	#113,D4
	CMP.W	D4,D0		; hi-clamp to B-3 finetune 0
	BHS.B	.L1
	MOVE.W	D4,D0
.L1	; --------------------
	SUB.W	D4,D0		; Subtract 113 (highest rate)	
	MOVE.W	#743,D1
	SUB.W	D0,D1		; Invert range 0-743
	MULU.W	D1,D1		; 0 - 743^2
	DIVU.W	#25093,D1	; 0 - 743^2 -> 0..22 (25093 = round[743^2 / 22])
	MOVE.W	D1,D0
	; --------------------
	; --------------------
	MOVEQ	#36,D1
	LEA	AnalyzerHeights+1,A0
	ADD.W	D0,D0
	ADD.W	D0,A0
	; --------------------
	MOVE.B	(A0),D4		; cache it (for safety)
	ADD.B	D2,D4
	CMP.B	D1,D4
	BLO.B	saskip2
	MOVE.B	D1,D4
saskip2	MOVE.B	D4,(A0)
	SUBQ.W	#2,A0		; A0 = -2(A0)
	; --------------------
	TST.B	D0
	BEQ.B	saskip4
	MOVE.B	(A0),D4		; cache it (for safety)
	ADD.B	D3,D4
	CMP.B	D1,D4
	BLO.B	saskip3
	MOVE.B	D1,D4
saskip3	MOVE.B	D4,(A0)
saskip4	ADDQ.W	#4,A0		; A0 = 2(A0)
	; --------------------
	CMP.B	#22*2,D0
	BEQ.B	saend
	MOVE.B	(A0),D4		; cache it (for safety)
	ADD.B	D3,D4
	CMP.B	D1,D4
	BLO.B	saskip5
	MOVE.B	D1,D4
saskip5	MOVE.B	D4,(A0)
	; --------------------
saend	SF	AnaDrawFlag
ohno	MOVEM.L	(SP)+,D0-D4/A0
	RTS

AnalyzerOffsets
	dc.w $0730,$0708,$06E0,$06B8,$0690,$0668,$0640,$0618
	dc.w $05F0,$05C8,$05A0,$0578,$0550,$0528,$0500,$04D8
	dc.w $04B0,$0488,$0460,$0438,$0410,$03E8,$03C0,$0398
	dc.w $0370,$0348,$0320,$02F8,$02D0,$02A8,$0280,$0258
	dc.w $0230,$0208,$01E0,$01B8,$0190,$0168,$0140,$0118
	dc.w $00F0
	
AnaDrawFlag	dc.b 0
	EVEN

;---- Scope (normal type) ----

ns_sampleptr	= 0  ; L
ns_endptr	= 4  ; L
ns_repeatptr	= 8  ; L
ns_rependptr	= 12 ; L
ns_period	= 16 ; W
ns_volume	= 18 ; B
ns_oneshotflag	= 19 ; B
ns_posfrac	= 20 ; W

ScopeInfoSize	= 24 ; should be a multiple of 4!

Scope
	LEA	audchan1temp,A0
	LEA	ScopeSamInfo,A1
	LEA	ScopeInfo,A2
	LEA	BlankSample,A3
	MOVEQ	#4-1,D6			; do 4 channels
ScoLoop
	MOVE.W	n_period(A0),D0
	BEQ.W	ScoSampleEnd		; end if no period
	
	MOVE.W	n_periodout(A0),ns_period(A2)
	MOVE.B	n_volumeout(A0),ns_volume(A2)
	
	TST.B	n_trigger(A0)
	BEQ.B	ScoContinue
ScoRetrig
	SF	n_trigger(A0)
	TST.B	n_samplenum(A0)
	BEQ.W	ScoNextChan
	SF	ns_oneshotflag(A2)
	CLR.W	ns_posfrac(A2)
	BSR.W	SetScope
	MOVEQ	#0,D0
	MOVE.B	n_samplenum(A0),D0
	SUBQ.W	#1,D0
	LSL.W	#4,D0	
	MOVE.L	ns_sampleptr(A1,D0.W),ns_sampleptr(A2)
	MOVE.L	ns_endptr(A1,D0.W),ns_endptr(A2)
	MOVE.L	ns_repeatptr(A1,D0.W),ns_repeatptr(A2)
	MOVE.L	ns_rependptr(A1,D0.W),ns_rependptr(A2)
	MOVE.L	ns_sampleptr(A2),D0
	CMP.L	A3,D0 ; at end of sample...
	BEQ.W	ScoNextChan
	BRA.B	ScoChk
	
ScoContinue
	MOVE.L	ns_sampleptr(A2),D0
	CMP.L	A3,D0 ; at end of sample...
	BEQ.B	ScoNextChan
	MOVE.W	ns_period(A2),D1
	BEQ.B	ScoNextChan
	
	; PT2.3F: better scope pitch/delta precision

FRAC_BITS EQU 6				; max bits for period 113 w/ DIVU.W

	CMP.W	#113,D1			; min. Paula period in normal video modes
	BHS.B	ScoOk			; (clamp also needed for DIVU.W)
	MOVEQ	#113,D1
ScoOk	MOVE.L	#71051*(1<<FRAC_BITS),D2 ; PaulaClk / VBlankHz = 71051.0 (exact)
	DIVU.W	D1,D2
	MOVEQ	#0,D1
	MOVE.W	D2,D1
	ROR.L	#FRAC_BITS,D1
	SWAP	D1			; D1.L is now laid out as 16.16fp
	ADD.W	D1,ns_posfrac(A2)	; add delta fraction
	CLR.W	D1
	SWAP	D1
	ADDX.L	D1,D0			; add integer + fraction overflow bit	
	
ScoChk	CMP.L	ns_endptr(A2),D0
	BLO.B	ScoUpdatePtr
	TST.L	ns_repeatptr(A2)
	BNE.B	ScoHandleLoop
ScoSampleEnd
	MOVE.L	A3,D0
	BRA.B	ScoUpdatePtr
ScoHandleLoop	
	MOVE.L	ns_endptr(A2),D1
	SUB.L	ns_repeatptr(A2),D1	; D1.L = loop length
	CMP.L	#256,D1			; loopLength < 256 = use MOD (DIV) instead
	BHS.B	ScoNoDivLoop
	DIVU.W	D1,D0			; 140 cycles
	CLR.W	D0
	SWAP	D0
	ADD.L	ns_repeatptr(A2),D0
	MOVE.L	ns_rependptr(A2),ns_endptr(A2)
	BRA.B	ScoLoopDone
	; --------------------------------
ScoNoDivLoop
	SUB.L	ns_endptr(A2),D0
	ADD.L	ns_repeatptr(A2),D0
	MOVE.L	ns_rependptr(A2),ns_endptr(A2)
	CMP.L	ns_endptr(A2),D0
	BHS.B	ScoNoDivLoop
	; ^^
	; 90-92 cycles per iteration
	; --------------------------------
ScoLoopDone
	SF	ns_oneshotflag(A2)
ScoUpdatePtr
	MOVE.L	D0,ns_sampleptr(A2) 
ScoNextChan
	LEA	ScopeInfoSize(A2),A2
	LEA	ChanStructSize(A0),A0
	DBRA	D6,ScoLoop

	; now draw channels
	TST.B	ScopeEnable
	BEQ.B	clsnot
	CMP.W	#1,CurrScreen
	BNE.B	clsnot
	TST.B	EdEnable
	BNE.B	clsnot
	
	; clear scopes (slightly optimized in PT2.3F)
	LEA	TextBitplane+2256,A0
	MOVEQ	#(33/3)-1,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
clscop	MOVEM.L	D1-D6,(A0)
	LEA	40(A0),A0
	MOVEM.L	D1-D6,(A0)
	LEA	40(A0),A0
	MOVEM.L	D1-D6,(A0)
	LEA	40(A0),A0
	DBRA	D0,clscop
	
clsnot	MOVEQ	#-1,D4
	TST.W	SamScrEnable
	BEQ.B	ScoNClr
	MOVEQ	#0,D4
ScoNClr	MOVEQ	#0,D7
	MOVE.W	$DFF002,D6 ; dmaconr
	
	MOVEQ	#0,D5
	LEA	TextBitplane+(72*40+16),A1
	LEA	xBlankSample,A2
	LEA	audchan1toggle(PC),A4
	TST.B	TToneCh1Flag
	BNE.B	ScoSkp1
	TST.W	(A4)
	BEQ.B	ScoSkp1
	BTST	#0,D6		; voice #1 active?
	BEQ.B	ScoSkp1
	LEA	ScopeInfo+(ScopeInfoSize*0),A2
	MOVE.B	ns_volume(A2),D5
ScoSkp1	BSR.W	ScoDraw

	MOVEQ	#0,D5
	LEA	TextBitplane+(72*40+22),A1
	LEA	xBlankSample,A2
	LEA	audchan2toggle(PC),A4
	TST.B	TToneCh2Flag
	BNE.B	ScoSkp2
	TST.W	(A4)
	BEQ.B	ScoSkp2
	BTST	#1,D6		; voice #2 active?
	BEQ.B	ScoSkp2
	LEA	ScopeInfo+(ScopeInfoSize*1),A2
	MOVE.B	ns_volume(A2),D5
ScoSkp2	BSR.B	ScoDraw

	MOVEQ	#0,D5
	LEA	TextBitplane+(72*40+28),A1
	LEA	xBlankSample,A2
	LEA	audchan3toggle(PC),A4
	TST.B	TToneCh3Flag
	BNE.B	ScoSkp3
	TST.W	(A4)
	BEQ.B	ScoSkp3
	BTST	#2,D6		; voice #3 active?
	BEQ.B	ScoSkp3
	LEA	ScopeInfo+(ScopeInfoSize*2),A2
	MOVE.B	ns_volume(A2),D5
ScoSkp3	BSR.B	ScoDraw

	MOVEQ	#0,D5
	LEA	TextBitplane+(72*40+34),A1
	LEA	xBlankSample,A2
	LEA	audchan4toggle(PC),A4
	TST.B	TToneCh4Flag
	BNE.B	ScoSkp4
	TST.W	(A4)
	BEQ.B	ScoSkp4
	BTST	#3,D6		; voice #4 active?
	BEQ.B	ScoSkp4
	LEA	ScopeInfo+(ScopeInfoSize*3),A2
	MOVE.B	ns_volume(A2),D5
ScoSkp4	BSR.B	ScoDraw
	TST.L	D7
	BEQ.W	sdloscr
ScoRTS	RTS


; --- Scope drawing ---

ScoDraw
	TST.B	RealVUMetersFlag
	BNE.W	rScoDraw		; go to different scope drawing routine
	TST.B	ScopeEnable
	BEQ.W	sdlpos
	CMP.W	#1,CurrScreen
	BNE.W	sdlpos
	TST.B	EdEnable
	BNE.W	sdlpos
	CMP.B	#64,D5
	BLS.B	sdsk1
	MOVEQ	#64,D5
sdsk1	EXT.W	D5
	LSL.W	#8,D5
	ADD.W	D5,D5			; D5.W =  0..32768
	NEG.W	D5			; D5.W = -0..32768

	MOVE.L	ns_sampleptr(A2),A0
	MOVEQ	#5-1,D2
	LEA	(64*2)+scopeYTab(PC),A5
	
	; --PT2.3D bug fix: scope loop fix
	MOVE.L	ns_endptr(A2),A4	; sample end
	TST.L	ns_repeatptr(A2)	; loop enabled?
	BEQ.B	sdlp1			; no, let's use the old scope routine
	TST.B	ns_oneshotflag(A2)	; oneshot cycle?
	BNE.B	sdlp1			; yes, let's use the original scope routine first
	
	; ---- new scope routine for looped samples ----
	MOVE.L	ns_rependptr(A2),A4	; sample loop end
	MOVE.L	ns_repeatptr(A2),A3	; sample loop start
sdlp1LOOP
	MOVEQ	#8-1,D3			; we do 8 pixels per bitplane byte
sdlp2LOOP
	CMP.L	A4,A0			; did we reach sample loop end yet?
	BHS.B	sWrapLoop		; yes, wrap loop
sdlnowrap
	MOVE.B	(A0)+,D0		; get byte from sample data	
	EXT.W	D0			; extend to word
	MULS.W	D5,D0			; multiply by volume
	SWAP	D0			; D0.W = -63..64
	ADD.W	D0,D0
	MOVE.W	(A5,D0.W),D0
	BSET	D3,(A1,D0.W)		; set the current bitplane bit
	DBRA	D3,sdlp2LOOP
	ADDQ	#1,A1			; we have done 8 bits now, increase bitplane ptr
	DBRA	D2,sdlp1LOOP
	BRA.B	sdlpos
sWrapLoop
	MOVE.L	A3,A0			; set read address to sample loop start
	BRA.B	sdlnowrap
	
	; --END OF FIX--------------------
	
	; ---- old scope routine for non-looping samples (or oneshot-cycle) ----
sdlp1
	MOVEQ	#8-1,D3			; we do 8 pixels per bitplane byte
sdlp2
	MOVEQ	#0,D0
	CMP.L	A4,A0			; did we reach sample end yet?
	BHS.B	.drawit			; yes, draw empty sample
	; -----------------------------
	MOVE.B	(A0)+,D0		; get byte from sample data
	EXT.W	D0			; extend to word
	MULS.W	D5,D0			; multiply by volume
	SWAP	D0			; D0.W = -63..64
	ADD.W	D0,D0
	MOVE.W	(A5,D0.W),D0
.drawit	BSET	D3,(A1,D0.W)		; set the current bitplane bit
	DBRA	D3,sdlp2
	ADDQ	#1,A1			; we have done 8 bits now, increase bitplane ptr
	DBRA	D2,sdlp1
	; ----------------------------------------------------
			
sdlpos	; process sample play position (the blue line)
	TST.B	D4
	BNE.W	ScoRTS
	
	TST.B	VolToolBoxShown	; -PT2.3D bug fix: hide sample playline if volbox is open
	BNE.B	sdloscr		; ---
	
	LEA	xBlankSample(PC),A0
	CMP.L	A0,A2
	BEQ.B	sdloscr
	MOVE.L	ns_sampleptr(A2),D1
	MOVE.L	SamDrawStart(PC),D0
	CMP.L	D0,D1
	BLS.W	ScoRTS
	CMP.L	SamDrawEnd(PC),D1
	BHS.W	ScoRTS
	SUB.L	D0,D1
	
	; dirty fix for new scopes on non-looping samples
	CMP.L	#2,D1
	BLT.B	sdloscr

	MOVE.L	#314,D0
	JSR	MULU32
	MOVE.L	SamDisplay,D1
	BEQ.W	ScoRTS
	JSR	DIVU32

	ST	D4
	ST	D7
	ADDQ.W	#6,D0
	MOVE.W	#139,D1
sdlpspr	MOVEQ	#64,D2
	LEA	PlayPosSpriteData,A0
	JMP	SetSpritePos

sdloscr	MOVEQ	#0,D0
	MOVE.W	#270,D1
	BRA.B	sdlpspr

SetScope
	MOVEQ	#0,D1
	MOVE.B	n_samplenum(A0),D1
	SUBQ.B	#1,D1
	LSL.W	#4,D1
	LEA	ScopeSamInfo,A4
	ADD.W	D1,A4

	; -- PT2.3D bug fix: show 9xx properly on scopes ( doesn't include 9xx quirks :-( )
	TST.L	RunMode
	BEQ.B	ss9Done	
	MOVE.B	n_cmd(A0),D0
	AND.B	#$0F,D0
	CMP.B	#$09,D0
	BNE.B	ss9Done
	MOVE.B	n_cmdlo(A0),D0
	BEQ.B	ss9Skip1
	MOVE.B	D0,n_sampleoffset2(A0)
ss9Skip1
	MOVEQ	#0,D0
	MOVE.B	n_sampleoffset2(A0),D0
	LSL.W	#7,D0
	CMP.W	n_oldlength(A0),D0
	BHS.B	ss9Skip2
	SUB.W	D0,n_oldlength(A0)
	ADD.W	D0,D0
	ADD.L	D0,n_oldstart(A0)
	BRA.B	ss9Done
ss9Skip2
	MOVE.W	#$0001,n_oldlength(A0)
ss9Done
	; -----------------------------------------------------------------------------
	
	MOVE.L	n_oldstart(A0),D0
	MOVE.L	D0,ns_sampleptr(A4)
	MOVEQ	#0,D1
	MOVE.W	n_oldlength(A0),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	D0,ns_endptr(A4)

	; check for loop
	MOVE.W	n_repeat(A0),D1
	ADD.W	n_replen(A0),D1
	CMP.W	#1,D1			; (n_repeat+n_replen) > 1? (loop enabled)
	BLS.B	sconorep		; nope, no loop...
	
	; set loop pointers
	MOVE.W	n_replen(A0),D1
	MOVE.L	n_loopstart(A0),D0	
	MOVE.L	D0,ns_repeatptr(A4)
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	D0,ns_rependptr(A4)

	; 8bitbubsy:
	; Fix for one-shot loops (where n_repeat=0 and n_replen < n_length)
	; This is needed with our new scopes which wraps around loop points internally
	MOVE.W	n_repeat(A0),D0
	BNE.B	.skip			; n_repeat != 0
	MOVE.L	ns_endptr(A4),D0
	CMP.L	ns_rependptr(A4),D0	; ns_rependptr != ns_endptr? (loopend < samplelen)
	BEQ.B	.skip			; nope, they are equal
	ST	ns_oneshotflag(A2)	; yes, activate oneshot flag for one loop cycle
.skip	RTS
	
sconorep
	CLR.L	ns_repeatptr(A4)
	RTS

scopeYTab
	dc.w -640,-640,-640,-640,-600,-600,-600,-600,-560,-560,-560,-560,-520,-520,-520,-520
	dc.w -480,-480,-480,-480,-440,-440,-440,-440,-400,-400,-400,-400,-360,-360,-360,-360
	dc.w -320,-320,-320,-320,-280,-280,-280,-280,-240,-240,-240,-240,-200,-200,-200,-200
	dc.w -160,-160,-160,-160,-120,-120,-120,-120, -80, -80, -80, -80, -40, -40, -40, -40
	dc.w    0,   0,   0,   0,  40,  40,  40,  40,  80,  80,  80,  80, 120, 120, 120, 120
	dc.w  160, 160, 160, 160, 200, 200, 200, 200, 240, 240, 240, 240, 280, 280, 280, 280
	dc.w  320, 320, 320, 320, 360, 360, 360, 360, 400, 400, 400, 400, 440, 440, 440, 440
	dc.w  480, 480, 480, 480, 520, 520, 520, 520, 560, 560, 560, 560, 600, 600, 600, 600
	dc.w  640

	; --- Scopes drawing in real VU-Meters mode (fetch peak) ---

rScoDraw
	MOVE.L	D7,-(SP)
	MOVE.L	D4,-(SP)
	SF	D7			; do not draw scopes
	TST.B	ScopeEnable
	BEQ.W	rsdkip
	CMP.W	#1,CurrScreen
	BNE.W	rsdkip
	TST.B	EdEnable
	BNE.W	rsdkip
	ST	D7			; do draw scopes
rsdkip	CMP.B	#64,D5
	BLS.B	rsdsk1
	MOVEQ	#64,D5
rsdsk1	EXT.W	D5
	LSL.W	#8,D5
	ADD.W	D5,D5			; D5.W =  0..32768
	NEG.W	D5			; D5.W = -0..32768

	MOVE.L	ns_sampleptr(A2),A0
	MOVEQ	#5-1,D2	
	ADDQ	#6,A4
	LEA	(64*2)+scopeYTab(PC),A5

	; --PT2.3D bug fix: scope loop fix
	MOVE.L	ns_endptr(A2),D4
	TST.L	ns_repeatptr(A2)	; loop enabled?
	BEQ.B	rsdlp1			; no, let's use the old scope routine
	TST.B	ns_oneshotflag(A2)	; oneshot cycle?
	BNE.B	rsdlp1			; yes, let's use the original scope routine first
		
	; ---- new scope routine for looped samples ----
	MOVE.L	ns_rependptr(A2),D4	; sample loop end
	MOVE.L	ns_repeatptr(A2),A3	; sample loop start
rsdlp1LOOP
	MOVEQ	#8-1,D3			; we do 8 pixels per bitplane byte
rsdlp2LOOP
	CMP.L	D4,A0			; did we reach sample loop end yet?
	BHS.B	rWrapLoop		; yes, wrap loop
rsdlnowrap
	MOVE.B	(A0)+,D0		; get byte from sample data
	EXT.W	D0			; extend to word
	MULS.W	D5,D0			; multiply by volume
	SWAP	D0			; D0.W = -63..64
	
	MOVE.W	D0,D1			; D1 = amplitude
	BPL.B 	rnotSigned		; D1 >= 0?
	NEG.W 	D1			; no, D1 = ABS(D1)
rnotSigned
	CMP.W	(A4),D1			; D1 < amp?
	BLS.B	rnoNewStore		; yes, don't update
	MOVE.W	D1,(A4)			; store current amp for use in real VU-Meter mode
rnoNewStore
	TST.B	D7			; draw scopes or not?
	BEQ.B	rsdlskip		; nope...

	ADD.W	D0,D0
	MOVE.W	(A5,D0.W),D0	
	BSET	D3,(A1,D0.W)		; set the current bitplane bit
rsdlskip
	DBRA	D3,rsdlp2LOOP
	ADDQ	#1,A1			; we have done 8 bits now, increase bitplane ptr
	DBRA	D2,rsdlp1LOOP
	MOVE.L	(SP)+,D4
	MOVE.L	(SP)+,D7
	SUBQ	#6,A4
	BRA.W	sdlpos
rWrapLoop
	MOVE.L	A3,A0			; set read address to sample loop start
	BRA.B	rsdlnowrap
	; --END OF FIX--------------------
	
	; ---- old scope routine for non-looping samples ----
rsdlp1
	MOVEQ	#8-1,D3			; we do 8 pixels per bitplane byte
rsdlp2
	MOVEQ	#0,D0
	CMP.L	D4,A0			; did we reach sample end yet?
	BHS.B	rnoNewStore2		; yes, draw empty sample
	
	MOVE.B	(A0)+,D0		; get byte from sample data
	EXT.W	D0			; extend to word
	MULS.W	D5,D0			; multiply by volume
	SWAP	D0			; D0.W = -63..64

	MOVE.W	D0,D1			; D1 = amplitude
	BPL.B 	rnotSigned2		; D1 >= 0?
	NEG.W 	D1			; no, D1 = ABS(D1)
rnotSigned2
	CMP.W	(A4),D1			; D1 < amp?
	BLS.B	rnoupdate		; yes, don't update
	MOVE.W	D1,(A4)			; store current value for use in real VU-Meter mode
rnoupdate

	ADD.W	D0,D0
	MOVE.W	(A5,D0.W),D0
rnoNewStore2
	TST.B	D7			; draw scopes or not?
	BEQ.B	rsdlskip2		; nope...
	BSET	D3,(A1,D0.W)		; set the current bitplane bit
rsdlskip2
	DBRA	D3,rsdlp2
	ADDQ	#1,A1			; we have done 8 bits now, increase bitplane ptr
	DBRA	D2,rsdlp1
	MOVE.L	(SP)+,D4
	MOVE.L	(SP)+,D7
	SUBQ	#6,A4
	BRA.W	sdlpos

ToggleAnaScope
	BSR.W	WaitForButtonUp
	TST.B	AboutScreenShown
	BNE.B	HideAboutScreen	
	MOVE.W	MouseX2,D0
	MOVE.W	MouseY2,D1
	CMP.W	#55,D1
	BHI.B	tasny
	CMP.W	#305,D0
	BHI.B	ShowAboutScreen
tasny	MOVEQ	#0,D4
	TST.B	AnaScopFlag
	BNE.B	tasana
	ST	AnaScopFlag
	BRA.W	RedrawAnaScope
tasana	SF	AnaScopFlag
	BRA.W	RedrawAnaScope
	
HideAboutScreen
	MOVEQ	#0,D4
	MOVE.B	SaveScope,ScopeEnable
	MOVE.B	SaveDA,DisableAnalyzer
	SF	AboutScreenShown
	BRA.W	RedrawAnaScope

	CNOP 0,4
xBlankSample		dc.l BlankSample
SamDrawStart		dc.l 0
SamDrawEnd		dc.l 0
DisableScopeMuting	dc.b 0
ScopeEnable		dc.b 0
AnaScopFlag		dc.b 1
	EVEN

ShowAboutScreen
	MOVE.B	ScopeEnable(PC),SaveScope
	MOVE.B	DisableAnalyzer,SaveDA
	SF	ScopeEnable
	ST	DisableAnalyzer
	ST	AboutScreenShown
	BSR.W	ClearAnalyzerColors
	BSR.W	ClearRightArea
	MOVEQ	#1,D4
	LEA	AboutBoxData,A0
	MOVE.L	#AboutBoxSize,D0
	BSR.W	cgjojo ; decompact
	RTS
	
;---- Show Free/Tune Memory ----

DoShowFreeMem
	ST	UpdateFreeMem
ShowFreeMem
	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.B	UpdateFreeMem
	BEQ.B	sfmskp
	SF	UpdateFreeMem
	CLR.L	FreeMemory
	CLR.L	TuneMemory
sfmskp	BSR.B	ShowTuneMem
	MOVEQ	#MEMF_CHIP,D1
	TST.B	ShowPublicFlag
	BEQ.B	sfmskp2
	MOVEQ	#MEMF_PUBLIC,D1
sfmskp2	MOVE.L	4.W,A6
	JSR	_LVOAvailMem(A6)
	CMP.L	FreeMemory(PC),D0
	BEQ.B	fremend
	MOVE.L	D0,FreeMemory
	TST.B	ShowDecFlag
	BNE.B	shfrdec
	CMP.L	#$00FFFFFF,D0
	BLS.B	sfmskp3
	MOVE.L	#$00FFFFFF,D0
sfmskp3
	MOVE.L	D0,D6
	MOVE.W	#5273,TextOffset
	SWAP	D0
	AND.W	#$FF,D0
	MOVE.W	D0,WordNumber
	JSR	PrintHexByte
	MOVE.W	D6,WordNumber
	JSR	PrintHexWord
fremend	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

shfrdec	MOVE.L	FreeMemory(PC),D0	
	MOVE.W	#5273,TextOffset
	JSR	Print6DecDigits
	BRA.B	fremend

ShowTuneMem
	MOVE.L	SongDataPtr,A0
	LEA	42(A0),A0
	MOVE.W	TuneUp(PC),D7
	SUBQ.W	#1,D7
	MOVE.W	#31,TuneUp
	MOVEQ	#0,D0	; Zero length
stumeloop	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	ADD.L	D1,D1
	ADD.L	D1,D0	; Add samplelength
	LEA	30(A0),A0
	DBRA	D7,stumeloop
	ADD.L	#1084,D0	; Add 1084 to length
	MOVE.L	SongDataPtr,A0
	MOVEQ	#128-1,D7
	LEA	952(A0),A0
	MOVEQ	#0,D6
stumeloop2
	MOVE.B	(A0)+,D5
	CMP.B	D5,D6
	BHI.B	stumeskip
	MOVE.B	D5,D6
stumeskip
	DBRA	D7,stumeloop2
	ADDQ.W	#1,D6
	MOVE.W	D6,NumPatterns
	LSL.L	#8,D6
	LSL.L	#2,D6
	ADD.L	D6,D0	; Add 1024 x Number of patterns
	CMP.L	TuneMemory(PC),D0
	BEQ.W	Return1
	MOVE.L	D0,TuneMemory
	TST.B	ShowDecFlag
	BNE.B	shtudec
	MOVE.L	D0,D6
	MOVE.W	#4993,TextOffset
	SWAP	D0
	AND.W	#$FF,D0
	MOVE.W	D0,WordNumber
	JSR	PrintHexByte
	MOVE.W	D6,WordNumber
	JMP	PrintHexWord

shtudec	MOVE.L	TuneMemory(PC),D0
	MOVE.W	#4993,TextOffset
	JMP	Print6DecDigits

	CNOP 0,4
FreeMemory	dc.l	0
TuneMemory	dc.l	0
TuneUp		dc.w	31
UpdateFreeMem	dc.b	0
	EVEN

;---- Audio Channel Toggles ----

CheckToggle		; this routine is now officially spaghettios in PT2.3E
	MOVE.W	MouseY2,D0
	CMP.W	#1,CurrScreen
	BNE.W	Return1
	CMP.W	#44,D0
	BHS.W	Return1
	MOVEQ	#1,D6
	BTST	#2,$DFF016	; right mouse button
	BNE.B	DoToggleMute
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	ST	n_muted+audchan1temp
	ST	n_muted+audchan2temp
	ST	n_muted+audchan3temp
	ST	n_muted+audchan4temp
	CLR.W	audchan1toggle
	CLR.W	audchan2toggle
	CLR.W	audchan3toggle
	CLR.W	audchan4toggle
DoToggleMute
	CMP.W	#34,D0
	BHS.W	ToggleCh4
	CMP.W	#23,D0
	BHS.B	ToggleCh3
	CMP.W	#12,D0
	BHS.B	ToggleCh2
ToggleCh1
	LEA	audchan1toggle(PC),A0
	TST.W	(A0)
	BEQ.B	RestoreCh1
	CLR.W	$DFF0A8
	ST	n_muted+audchan1temp
	BRA.W	TogCh
RestoreCh1
	SF	n_muted+audchan1temp
	BSR.W	SetBackCh1Vol
	BRA.B	TogCh
ToggleCh2
	LEA	audchan2toggle(PC),A0
	TST.W	(A0)
	BEQ.B	RestoreCh2
	ST	n_muted+audchan2temp
	CLR.W	$DFF0B8
	BRA.B	TogCh
RestoreCh2
	SF	n_muted+audchan2temp
	BSR.W	SetBackCh2Vol
	BRA.B	TogCh
ToggleCh3
	LEA	audchan3toggle(PC),A0
	TST.W	(A0)
	BEQ.B	RestoreCh3
	ST	n_muted+audchan3temp
	CLR.W	$DFF0C8
	BRA.B	TogCh
RestoreCh3
	SF	n_muted+audchan3temp
	BSR.W	SetBackCh3Vol
	BRA.B	TogCh
ToggleCh4
	LEA	audchan4toggle(PC),A0
	TST.W	(A0)
	BEQ.B	RestoreCh4
	ST	n_muted+audchan4temp
	CLR.W	$DFF0D8
	BRA.B	TogCh
RestoreCh4
	SF	n_muted+audchan4temp
	BSR.W	SetBackCh4Vol
TogCh
	CLR.B	RawKeyCode
	EOR.W	#1,(A0)
	BSR.B	RedrawToggles
	TST.B	D6			; did we come from the keyboard keys?
	BEQ.B	tcskip			; yes, don't wait for mouse button up
	BSR.W	WaitForButtonUp
tcskip	
	;JSR	Wait_4000	; unneeded, makes muting more laggy
	;JMP	Wait_4000	; --
	RTS

RedrawToggles
	CMP.W	#1,CurrScreen
	BNE.W	Return1
	LEA	audchan1toggle(PC),A0
	BSR.B	RedrawSingleTogg
	LEA	audchan2toggle(PC),A0
	BSR.B	RedrawSingleTogg
	LEA	audchan3toggle(PC),A0
	BSR.B	RedrawSingleTogg
	LEA	audchan4toggle(PC),A0
RedrawSingleTogg
	LEA	BitplaneData,A1
	MOVEQ	#0,D0
	MOVE.W	2(A0),D0
	ADD.L	D0,A1
	MOVEQ	#0,D0
	MOVE.W	4(A0),D0
	LEA	ToggleONdata,A2
	TST.W	(A0)
	BNE.B	rtskip
	LEA	ToggleOFFdata,A2
rtskip	ADD.L	D0,A2
	MOVEQ	#11-1,D4
rtloop2	MOVE.W	88(A2),10240(A1)
	MOVE.W	(A2)+,(A1)
	LEA	40(A1),A1
	DBRA	D4,rtloop2
	RTS

	; this portition is called from somewhere else
rtdoit	MOVEQ	#11-1,D4
rtloop	MOVE.W	176(A2),10240(A1)
	MOVE.W	(A2)+,(A1)
	LEA	40(A1),A1
	DBRA	D4,rtloop
	RTS

;---- VU-meters ----

VUMeters
	MOVEQ	#-23,D0		; lowest possible sprite value (-23 = 233)
	LEA	VUSpriteData1,A0
	CMP.B	(A0),D0		; VU #1 == 233?
	BEQ.B	svum2		; yes, don't sink
	ADDQ.B	#1,(A0)		; sink
svum2	LEA	200(A0),A0	; A0 = VU #2 sprite
	CMP.B	(A0),D0		; VU #2 == 233?
	BEQ.B	svum3		; yes, don't sink
	ADDQ.B	#1,(A0)		; sink
svum3	LEA	200(A0),A0	; A0 = VU #3 sprite
	CMP.B	(A0),D0		; VU #3 == 233?
	BEQ.B	svum4		; yes, don't sink
	ADDQ.B	#1,(A0)		; sink
svum4	LEA	200(A0),A0	; A0 = VU #4 sprite
	CMP.B	(A0),D0		; VU #4 == 233?
	BEQ.B	svumend		; yes, don't sink
	ADDQ.B	#1,(A0)		; sink
svumend	RTS
	
RealVUMeters
	LEA	VUSpriteData1,A0
	LEA	6+audchan1toggle(PC),A1
	LEA	VUmeterHeights,A2
	; ------------------------
	MOVEQ	#4-1,D3
rvuloop	MOVE.W	(A1),D0
	MOVE.B	(A2,D0.W),(A0)
	SUBQ.W	#5,(A1)
	BPL.B	.L0
	CLR.W	(A1)
.L0	ADDQ	#8,A1
	LEA	200(A0),A0
	DBRA	D3,rvuloop
	RTS

; last value = sample peak from scopes (0..64, for real VU-meters)
audchan1toggle	dc.w 1,  78,$00,0
audchan2toggle	dc.w 1, 518,$16,0
audchan3toggle	dc.w 1, 958,$2C,0
audchan4toggle	dc.w 1,1398,$42,0

;---- Disk Op. ----

DiskOp	CLR.B	RawKeyCode
	MOVE.W	CurrScreen,D0
	CMP.W	#3,D0
	BEQ.W	ExitFromDir
	CMP.W	#1,D0
	BNE.W	Return1
ShowDirScreen
	ST	DiskOpWasJustOpened
	BSR.W	WaitForButtonUp
	MOVE.W	#3,CurrScreen
	ST	DisableAnalyzer
	ST	NoSampleInfo
	BSR.W	ClearAnalyzerColors
	BSR.W	Clear100Lines
	BSR.W	SaveMainPic
lbC001DF6
	BSR.B	SwapDirScreen
	BEQ.W	DisplayMainAll
	BSR.W	ShowDiskSpace
	BSR.W	ShowModPackMode
	BSR.W	ShowPackModeTrackBuff
	BSR.W	ShowSaveModePattBuff
DoAutoDir
	TST.B	AutoDirFlag
	BEQ.B	lbC001E42
	MOVE.W	DirPathNum(PC),D0
	BEQ.W	LoadModuleGadg
	CMP.W	#1,D0
	BEQ.W	LoadSongGadg
	CMP.W	#2,D0
	BEQ.W	LoadSampleGadg
	CMP.W	#3,D0
	BEQ.W	LoadTrackGadg
	CMP.W	#4,D0
	BEQ.W	SavePatternGadg
	BRA.W	SelectModules

lbC001E42
	MOVE.W	DirPathNum(PC),D0
	BEQ.W	SelectModules
	CMP.W	#1,D0
	BEQ.W	SelectSongs
	CMP.W	#2,D0
	BEQ.W	SelectSamples
	CMP.W	#3,D0
	BEQ.W	SelectTracks
	CMP.W	#4,D0
	BEQ.W	SelectPatterns
	BRA.W	SelectModules

SwapDirScreen
	MOVE.L	DecompMemPtr,D0
	BEQ.B	sdirs2
	MOVE.L	D0,A1
	BSR.B	sdirs4
	BRA.W	FreeDecompMem
sdirs2	LEA	DirScreenData,A0
	TST.W	DiskOpScreen2
	BEQ.B	sdirs3
	LEA	DirScreen2Data,A0
sdirs3	MOVE.L	#DirScreenSize,D0 ; exact size for both screens
	BSR.W	Decompact
	BEQ.B	sxoutofmem
sdirs4	LEA	BitplaneData,A0
	MOVEQ	#2-1,D2		; 2 bitplanes
sdloop1	MOVE.W	#1000-1,D0	; 100 scanlines
sdloop2	MOVE.L	(A1)+,(A0)+
	DBRA	D0,sdloop2
	LEA	6240(A0),A0
	DBRA	D2,sdloop1
	BSR.W	FreeDecompMem
	MOVEQ	#-1,D0
	RTS

sxoutofmem
	BSR.W	ssxfree
	MOVEQ	#0,D0
	RTS

CheckDirGadgets
	MOVE.W	MouseX2,D0
	MOVE.W	MouseY2,D1
	CMP.W	#44,D1
	BHI.W	CheckDirGadgets2
	CMP.W	#33,D1
	BLS.B	ExtrasMenu
	CMP.W	#11,D0
	BLO.W	DirBrowseGadg
	CMP.W	#177,D0
	BLO.W	DirPathGadg
	CMP.W	#187,D0
	BLO.W	ChangeDiskOpMode
	CMP.W	#216,D0
	BLO.W	ParentDirGadg
	CMP.W	#308,D0
	BLO.W	ShowFreeDiskGadg
	BRA.W	CheckDirGadgets2

ExtrasMenu
	CLR.W	SelectDiskFlag
	MOVEM.L	D0/D1,-(SP)
	BSR.W	ClearFileNames
	LEA	FileNamesPtr(PC),A5
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVEM.L	(SP)+,D0/D1
	CMP.W	#82,D0
	BHS.W	ToggleMenu
	CMP.W	#22,D1
	BHI.B	DeleteFileGadg
	CMP.W	#11,D1
	BHI.B	RenameFileGadg
	BRA.W	DiskFormatGadg

RenameFileGadg
	BSR.W	StorePtrCol
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	MOVE.L	PathPtr,A4
	BSR.W	ShowDirPath
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	RenameFileDirOk
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BNE.W	RestorePtrCol
	
RenameFileDirOk
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#10,Action
	LEA	SelectFileText,A0
	JSR	ShowStatusText
	BRA.W	RestorePtrCol

DeleteFileGadg
	MOVE.W	DirPathNum(PC),D0
	BEQ.W	DeleteModuleGadg
	CMP.W	#1,D0
	BEQ.W	DeleteSongGadg
	CMP.W	#2,D0
	BEQ.W	DeleteSampleGadg
	CMP.W	#3,D0
	BEQ.W	DeleteTrackGadg
	CMP.W	#4,D0
	BEQ.W	DeletePattGadg
	RTS

ToggleMenu
	CMP.W	#146,D0
	BHS.W	SelectMenu
	CMP.W	#22,D1
	BHI.W	ToggleSaveModeBuff
	CMP.W	#11,D1
	BHI.W	TogglePackModeBuff
ToggleModPack
	EOR.B	#1,ModPackMode
ShowModPackMode
	LEA	ToggleOFFText(PC),A0
	TST.B	ModPackMode
	BEQ.B	smpmskp
	LEA	ToggleONText2(PC),A0
smpmskp	MOVEQ	#3,D0
	MOVE.W	#175,D1
	JSR	ShowText3
	BRA.W	WaitForButtonUp

ChangeDiskOpMode
	CLR.W	SelectDiskFlag
	NOT.W	DiskOpScreen2	
	CMP.W	#1,DirPathNum
	BNE.B	lbC002022
	MOVE.W	#3,DirPathNum
lbC002022
	CMP.W	#2,DirPathNum
	BNE.B	lbC002034
	MOVE.W	#4,DirPathNum
lbC002034
	CMP.W	#3,DirPathNum
	BNE.B	lbC002046
	MOVE.W	#1,DirPathNum
lbC002046
	CMP.W	#4,DirPathNum
	BNE.B	lbC002058
	MOVE.W	#2,DirPathNum
lbC002058
	BRA.W	lbC001DF6

ShowNotImpl
	LEA	NotImplText(PC),A0
	JSR	ShowStatusText
	BRA.W	SetErrorPtrCol

NotImplText	dc.b	'Not implemented',0
	EVEN

TogglePackModeBuff
	TST.W	DiskOpScreen2
	BEQ.B	TogglePackMode
ToggleTrackBuffFlag
	EOR.B	#1,LoadTrackToBufferFlag
	BRA.B	ShowPackModeTrackBuff
TogglePackMode
	EOR.B	#1,PackMode
ShowPackModeTrackBuff
	TST.W	DiskOpScreen2
	BEQ.B	ShowPackMode
	LEA	ToggleCURText(PC),A0
	TST.B	LoadTrackToBufferFlag
	BEQ.B	spmtbskip
	LEA	ToggleBUFText(PC),A0
spmtbskip
	MOVEQ	#3,D0
	MOVE.W	#615,D1
	JSR	ShowText3
	BRA.W	WaitForButtonUp

ShowPackMode
	LEA	ToggleOFFText(PC),A0
	TST.B	PackMode
	BEQ.B	spmskip
	LEA	ToggleONText2(PC),A0
spmskip	MOVEQ	#3,D0
	MOVE.W	#615,D1
	JSR	ShowText3
	BRA.W	WaitForButtonUp

ToggleSaveModeBuff
	TST.W	DiskOpScreen2
	BEQ.B	ToggleSaveMode
TogglePattBuffFlag
	EOR.B	#1,LoadPattToBufferFlag
	BRA.B	ShowSaveModePattBuff
ToggleSaveMode
	ADDQ.B	#1,RawIFFPakMode
	CMP.B	#3,RawIFFPakMode
	BNE.B	ShowSaveModePattBuff
	SF	RawIFFPakMode
ShowSaveModePattBuff
	TST.W	DiskOpScreen2
	BEQ.B	ShowSampleSaveMode
	LEA	ToggleCURText(PC),A0
	TST.B	LoadPattToBufferFlag
	BEQ.B	ssmpbskip
	LEA	ToggleBUFText(PC),A0	
ssmpbskip
	MOVEQ	#3,D0
	MOVE.W	#1055,D1
	JSR	ShowText3
	BRA.W	WaitForButtonUp

ShowSampleSaveMode
	LEA	RAWText(PC),A0
	TST.B	RawIFFPakMode
	BEQ.B	sssmskip
	LEA	IFFText(PC),A0
	CMP.B	#1,RawIFFPakMode
	BEQ.B	sssmskip
	LEA	PAKText(PC),A0
sssmskip
	MOVEQ	#3,D0
	MOVE.W	#1055,D1
	JSR	ShowText3
	BRA.W	WaitForButtonUp

RAWText	dc.b "RAW",0
IFFText	dc.b "IFF",0
PAKText	dc.b "PAK",0
	EVEN

SelectMenu
	CMP.W	#156,D0
	BHS.B	LoadMenu
	CMP.W	#22,D1
	BHI.W	SelectSamples
	CMP.W	#11,D1
	BHI.W	SelectSongs
	BRA.W	SelectModules

LoadMenu
	CMP.W	#238,D0
	BHS.B	SaveMenu
	CMP.W	#22,D1
	BHI.W	LoadSampleGadg
	CMP.W	#11,D1
	BHI.W	LoadSongGadg
	BRA.W	LoadModuleGadg

SaveMenu
	CMP.W	#22,D1
	BHI.W	SaveSampleGadg
	CMP.W	#11,D1
	BHI.W	SaveSongGadg
	BRA.W	SaveModuleGadg

CheckDirGadgets2
	MOVE.W	MouseX2,D0
	MOVE.W	MouseY2,D1
	CMP.W	#3,CurrScreen
	BNE.W	Return1
	CMP.W	#308,D0
	BLO.W	FileNamePressed
	CMP.W	#42,D1
	BLS.W	lbC0037F8
	CMP.W	#51,D1
	BLS.W	FilenameOneUp
	CMP.W	#82,D1
	BLO.B	ExitFromDir
	CMP.W	#91,D1
	BLO.W	FilenameOneDown
	BRA.W	lbC003926

ExitFromDir
	CLR.W	SelectDiskFlag
	BSR.W	WaitForButtonUp
	CLR.B	RawKeyCode
	BSR.W	RestoreMainPic
	BSR.W	Clear100Lines
DisplayMainAll
	BSR.W	DisplayMainScreen
	JSR	ShowSongLength
	JSR	ShowSampleInfo
	JSR	ShowSongName
	JSR	Show_MS
	TST.W	LoadInProgress
	BNE.B	dimaskp
	JSR	ShowAllRight
dimaskp	JMP	ShowPosition

DirBrowseGadg
	BTST	#2,$DFF016	; right mouse button
	BEQ.W	ShowDiskDrives
DirBrowseGadg2
	MOVEQ	#0,D3
	MOVE.W	DirPathNum(PC),D3
	LEA	dpnum(PC),A0
	ADD.L	D3,A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	ADDQ.B	#1,D0
	MOVE.B	lbB002386(PC),D1
	CMP.B	D1,D0
	BLO.B	lbC002264
	MOVEQ	#0,D0
lbC002264	MOVE.B	D0,(A0)
	MOVE.L	PathPtr,A0
	MOVEQ	#64-1,D1
	MOVEQ	#0,D2
lbC002270	MOVE.B	D2,(A0)+
	DBRA	D1,lbC002270
	TST.W	D0
	BEQ.B	lbC00227E
	BSR.B	lbC0022E0
	BRA.B	lbC0022C8

lbC00227E
	LEA	ModulesPath,A0
	TST.W	D3
	BEQ.B	lbC0022BE
	LEA	SongsPath,A0
	CMP.W	#1,D3
	BEQ.B	lbC0022BE
	LEA	SamplePath,A0
	CMP.W	#2,D3
	BEQ.B	lbC0022BE
	LEA	TrackPath,A0
	CMP.W	#3,D3
	BEQ.B	lbC0022BE
	LEA	PattPath,A0
	CMP.W	#4,D3
	BEQ.B	lbC0022BE
	LEA	ModulesPath,A0
lbC0022BE
	MOVE.L	PathPtr,A1
lbC0022C4
	MOVE.B	(A0)+,(A1)+
	BNE.B	lbC0022C4
lbC0022C8
	BSR.W	ShowDirPath
	MOVE.W	#3,WaitTime
	BRA.W	WaitALittle

	CNOP 0,4
dpnum	dc.l 0
	dc.w 0
DirPathNum
	dc.w 5

lbC0022E0	MOVE.L	A2,-(SP)
	MOVE.B	D0,D3
	MOVE.L	DOSBase,A0
	MOVE.L	34(A0),A0
	MOVE.L	24(A0),D1
	LSL.L	#2,D1
	MOVE.L	D1,A0
	MOVE.L	4(A0),D1
	LSL.L	#2,D1
	MOVE.L	D1,A0
	MOVEQ	#1,D0
	MOVEQ	#0,D2
lbC002302	CMP.L	#2,4(A0)
	BEQ.B	lbC002322
	;CMP.L	#0,4(A0)
	TST.L	4(A0)
	BEQ.B	lbC002334
lbC002316	MOVE.L	(A0),D1
	BEQ.B	lbC002362
	LSL.L	#2,D1
	MOVE.L	D1,A0
	BRA.B	lbC002302

lbC002322	ADDQ.W	#1,D0
	TST.L	D2
	BNE.B	lbC002316
	SUBQ.B	#1,D3
	BNE.B	lbC002316
	MOVE.L	40(A0),D2
	LSL.L	#2,D2
	BRA.B	lbC002316

lbC002334	MOVE.L	40(A0),D1
	BEQ.B	lbC002316
	LSL.L	#2,D1
	MOVE.L	D1,A2
	CMP.B	#3,(A2)+
	BNE.B	lbC002316
	CMP.B	#$44,(A2)+
	BNE.B	lbC002316
	CMP.B	#$46,(A2)
	BNE.B	lbC002316
	ADDQ.W	#1,D0
	TST.L	D2
	BNE.B	lbC002316
	SUBQ.B	#1,D3
	BNE.B	lbC002316
	MOVE.L	40(A0),D2
	LSL.L	#2,D2
	BRA.B	lbC002316

lbC002362	MOVE.L	PathPtr,A1
	MOVE.L	D2,A0
	MOVE.B	D0,lbB002386
	MOVE.B	(A0)+,D1
	BEQ.B	lbC002382
	AND.B	#$1F,D1
lbC002378	MOVE.B	(A0)+,(A1)+
	SUBQ.B	#1,D1
	BNE.B	lbC002378
	MOVE.B	#$3A,(A1)+
lbC002382	MOVE.L	(SP)+,A2
	RTS

ActionTemp	dc.w	0
lbB002386	dc.b	2
DiskOpWasJustOpened	dc.b	0
SelectDiskText	dc.b	'Select disk',0
OldDiskOpMode	dc.b	0
	EVEN

ShowDiskDrives
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	MOVE.W	Action,ActionTemp
	CLR.W	Action
	LEA	SelectDiskText(PC),A0
	JSR	ShowStatusText
	MOVE.W	#1,SelectDiskFlag
	CLR.W	FileListBufferEntry
	
	MOVEQ	#' ',D0
	LEA	FileListBuffer(PC),A0
	MOVE.L	#(36*16)-1,D1
sdLoop1	MOVE.B	D0,(A0)+
	DBRA	D1,sdLoop1

	MOVEQ	#0,D3
	MOVE.W	DirPathNum(PC),D3
	LEA	dpnum(PC),A0
	ADD.L	D3,A0
	SUBQ.B	#1,(A0)
	BSR.W	DirBrowseGadg2
	LEA	ModulesPath,A0
	TST.W	D3
	BEQ.B	sddSkp1
	LEA	SongsPath,A0
	CMP.W	#1,D3
	BEQ.B	sddSkp1
	LEA	SamplePath,A0
	CMP.W	#2,D3
	BEQ.B	sddSkp1
	LEA	TrackPath,A0
	CMP.W	#3,D3
	BEQ.B	sddSkp1
	LEA	PattPath,A0
	CMP.W	#4,D3
	BEQ.B	sddSkp1
	LEA	ModulesPath,A0
sddSkp1
	LEA	FileListBuffer(PC),A1
sdLoop2	MOVE.B	(A0)+,(A1)+
	BNE.B	sdLoop2
	MOVE.B	#' ',-1(A1)

	MOVEQ	#1,D0
	LEA	FileListBuffer(PC),A1
	MOVE.L	A1,A3
	MOVEQ	#0,D4
	MOVE.B	lbB002386(PC),D4
	SUBQ.W	#1,D4
	CMP.B	#15,D4
	BLO.B	sddSkp2
	MOVEQ	#15,D4
sddSkp2	LEA	36(A3),A3
	MOVE.L	A3,A1
	MOVEM.L	D0/A2,-(SP)
	MOVE.B	D0,D3
	MOVE.L	DOSBase,A0
	MOVE.L	34(A0),A0
	MOVE.L	24(A0),D1
	LSL.L	#2,D1
	MOVE.L	D1,A0
	MOVE.L	4(A0),D1
	LSL.L	#2,D1
	MOVE.L	D1,A0
	MOVEQ	#1,D0
	MOVEQ	#0,D2
lbC002496
	CMP.L	#2,4(A0)
	BEQ.B	lbC0024B6
	TST.L	4(A0)
	BEQ.B	lbC0024C8
lbC0024AA
	MOVE.L	(A0),D1
	BEQ.B	lbC0024F6
	LSL.L	#2,D1
	MOVE.L	D1,A0
	BRA.B	lbC002496

lbC0024B6
	ADDQ.W	#1,D0
	TST.L	D2
	BNE.B	lbC0024AA
	SUBQ.B	#1,D3
	BNE.B	lbC0024AA
	MOVE.L	40(A0),D2
	LSL.L	#2,D2
	BRA.B	lbC0024AA

lbC0024C8
	MOVE.L	40(A0),D1
	BEQ.B	lbC0024AA
	LSL.L	#2,D1
	MOVE.L	D1,A2
	CMP.B	#3,(A2)+
	BNE.B	lbC0024AA
	CMP.B	#$44,(A2)+
	BNE.B	lbC0024AA
	CMP.B	#$46,(A2)
	BNE.B	lbC0024AA
	ADDQ.W	#1,D0
	TST.L	D2
	BNE.B	lbC0024AA
	SUBQ.B	#1,D3
	BNE.B	lbC0024AA
	MOVE.L	40(A0),D2
	LSL.L	#2,D2
	BRA.B	lbC0024AA

lbC0024F6
	MOVE.L	D2,A0
	MOVE.B	(A0)+,D1
	BEQ.B	lbC00250A
	AND.B	#$1F,D1
lbC002500
	MOVE.B	(A0)+,(A1)+
	SUBQ.B	#1,D1
	BNE.B	lbC002500
	MOVE.B	#':',(A1)+
lbC00250A
	MOVEM.L	(SP)+,D0/A2
	ADDQ.B	#1,D0
	DBRA	D4,sddSkp2
lbC002516
	LEA	FileListBuffer(PC),A0
	MOVE.W	FileListBufferEntry(PC),D0
	MULU.W	#36,D0
	ADD.L	D0,A0
	MOVEQ	#36,D0
	MOVE.W	#1881,D1
	MOVEQ	#0,D4
	MOVE.B	lbB002386(PC),D4
	CMP.B	#8,D4
	BLE.B	lbC002542
	MOVEQ	#8,D4
lbC002542	SUBQ.W	#1,D4
lbC002544
	MOVEM.L	D0-D7/A0-A6,-(SP)
	JSR	ShowText3
	MOVEM.L	(SP)+,D0-D7/A0-A6
	LEA	36(A0),A0
	ADD.L	#240,D1
	DBRA	D4,lbC002544
	RTS

SelectDiskFlag		dc.w	0
FileListBufferEntry	dc.w	0
FileListBuffer		dcb.b	36*16,0
	EVEN

SelectModules
	MOVEQ	#0,D0
	BRA.B	lbC0027CA
SelectSongs
	TST.W	DiskOpScreen2
	BNE.B	SelectTracks
	MOVEQ	#1,D0
	BRA.B	lbC0027CA
SelectSamples
	TST.W	DiskOpScreen2
	BNE.B	SelectPatterns
	MOVEQ	#2,D0
	BRA.B	lbC0027CA
SelectTracks
	MOVEQ	#3,D0
	BRA.B	lbC0027CA
SelectPatterns
	MOVEQ	#4,D0
lbC0027CA
	TST.B	DiskOpWasJustOpened
	BNE.B	ChangePath
	TST.B	ModOnlyFlag
	BEQ.B	ChangePath
	CMP.B	OldDiskOpMode(PC),D0
	BEQ.B	ChangePath
	MOVE.B	D0,OldDiskOpMode
	LEA	FileNamesPtr(PC),A0
	CLR.L	4(A0)
ChangePath
	SF	DiskOpWasJustOpened
	LEA	TextBitplane+178,A0
	MOVEQ	#0,D2
	MOVEQ	#27-1,D1
chpalop	MOVE.W	D2,(A0)
	LEA	40(A0),A0
	DBRA	D1,chpalop
	LEA	ModulesPath2,A4
	MOVE.W	#178,D1
	MOVE.W	D0,DirPathNum
	BEQ.B	chpaski
	LEA	SongsPath2,A4
	MOVE.W	#618,D1
	CMP.W	#1,D0
	BEQ.B	chpaski
	LEA	SamplePath2,A4
	MOVE.W	#1058,D1
	CMP.W	#2,D0
	BEQ.B	chpaski
	LEA	TrackPath2,A4
	MOVE.W	#618,D1
	CMP.W	#3,D0
	BEQ.B	chpaski
	LEA	PattPath2,A4
	MOVE.W	#1058,D1
	CMP.W	#4,D0
	BEQ.B	chpaski
	LEA	ModulesPath2,A4
	MOVE.W	#178,D1
chpaski	LEA	TextBitplane,A0
	ADD.W	D1,A0
	MOVE.W	#$0100,(A0)
	MOVE.W	#$0F80,40(A0)
	MOVE.W	#$0FC0,80(A0)
	MOVE.W	#$0F80,120(A0)
	MOVE.W	#$0100,160(A0)
	MOVE.L	A4,PathPtr
	BSR.W	ShowDirPath
	BRA.W	WaitForButtonUp
	
;---- Song Gadgets ----

LoadTrackGadg
	BSR.W	lbC002E76
	BSR.W	StorePtrCol
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectTracks
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	LoadTrackDirOk
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BNE.W	RestorePtrCol
LoadTrackDirOk
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#11,Action
	LEA	SelectTrackText,A0
	JSR	ShowStatusText
	BRA.W	RestorePtrCol

SaveTrack
	BSR.W	SelectTracks
	LEA	SaveTrackText,A0
	BSR.W	AreYouSure
	BNE.W	Return1
	BSR.W	ClearFileNames
	LEA	FormatBoxPos,A0
	LEA	TrackNameBox,A1
	BSR.W	DoSwapBox
	BSR.W	WaitForButtonUp
	LEA	EnterFilenameText,A0
	JSR	ShowStatusText
	BSR.W	lbC002E64
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	InputFileName,A6
	MOVE.L	#"trk.",(A6)+
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#16,TextEndPtr
	MOVE.W	#14,TextLength
	MOVE.W	#3012,A4
	CLR.B	EnterTextFlag
	JSR	GetTextLine
	BSR.W	RestorePtrCol
	LEA	TrackNameBox,A1
	LEA	FormatBoxPos,A0
	BSR.W	DoSwapBox
	BSR.W	ClearFileNames
	LEA	TrackPath2,A0
	BSR.W	CopyPath
	LEA	InputFileName,A0
	MOVEQ	#20-1,D0
stloop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,stloop
	JSR	StopIt
	BSR.W	lbC002AD4
	MOVE.W	#11,Action
	JMP	ShowAllRight

DeleteTrackGadg
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectTracks
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	lbC0029D8
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BEQ.B	lbC0029D8
	BRA.W	RestorePtrCol

lbC0029D8
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#12,Action
	LEA	SelectTrackText,A0
	JSR	ShowStatusText
	BRA.W	SetDeletePtrCol

LoadTrack
	MOVE.W	#1,LoadInProgress
	LEA	TrackPath2,A0
	BSR.W	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
lotrloop2
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,lotrloop2
	MOVE.L	#TrackReadBuffer,DiskDataPtr
	MOVE.L	#FileName,FileNamePtr
	MOVE.L	#64*4,DiskDataLength
	LEA	LoadingTrackText,A0
	JSR	ShowStatusText
	JSR	DoLoadData
	BEQ.B	lotrdone
	JSR	CheckAbort
	BEQ.B	lotrdone
	TST.B	LoadTrackToBufferFlag
	BNE.B	LoadTrackToBuffer
	MOVE.L	SongDataPtr,A0
	LEA	sd_patterndata(A0),A0
	MOVE.L	PatternNumber,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	ADD.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	AND.L	#3,D0
	LSL.L	#2,D0
	ADD.L	D0,A0
	LEA	TrackReadBuffer,A1
	MOVEQ	#64-1,D0
lotrloop3
	MOVE.L	(A1)+,(A0)
	LEA	16(A0),A0
	DBRA	D0,lotrloop3
	BRA.B	lotrskip
LoadTrackToBuffer
	LEA	TrackBuffer,A1
	LEA	TrackReadBuffer,A0
	MOVEQ	#64-1,D0
lotrloop4
	MOVE.L	(A0)+,(A1)+
	DBRA	D0,lotrloop4
lotrskip
	TST.B	AutoExitFlag
	BEQ.B	lotrdone
	BSR.W	ExitFromDir
lotrdone
	CLR.W	LoadInProgress
	JSR	ShowAllRight
	BSR.W	SetNormalPtrCol
	JSR	RedrawPattern
	RTS

lbC002AD4
	MOVE.L	#FileName,FileNamePtr
	MOVE.L	#TrackBuffer,DiskDataPtr
	TST.B	LoadTrackToBufferFlag
	BNE.B	lbC002B38
	MOVE.L	#TrackReadBuffer,DiskDataPtr
	MOVE.L	SongDataPtr,A0
	LEA	sd_patterndata(A0),A0
	MOVE.L	PatternNumber,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	ADD.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	AND.L	#3,D0
	LSL.L	#2,D0
	ADD.L	D0,A0
	LEA	TrackReadBuffer,A1
	MOVEQ	#64-1,D0
lbC002B2E
	MOVE.L	(A0),(A1)+
	LEA	16(A0),A0
	DBRA	D0,lbC002B2E
lbC002B38
	MOVE.L	#$100,DiskDataLength
	JSR	DoSaveData
	JSR	ShowAllRight
	BSR.W	SetNormalPtrCol
	BRA.W	DoAutoDir

DeleteTrack
	LEA	DeleteTrackText,A0
	BSR.W	AreYouSure
	BNE.W	DeleteTrackGadg
	LEA	DeletingTrackText,A0
	JSR	ShowStatusText
	LEA	TrackPath2,A0
	BSR.W	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
dtrloop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,dtrloop
	MOVE.W	#11,Action
	JMP	Delete3

SavePatternGadg
	BSR.W	lbC002E76
	BSR.W	StorePtrCol
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectPatterns
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	SavePatternDirOk
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BNE.W	RestorePtrCol
SavePatternDirOk
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#13,Action
	LEA	SelectPatternText,A0
	JSR	ShowStatusText
	BRA.W	RestorePtrCol

SavePattern
	BSR.W	SelectPatterns
	LEA	SavePatternText,A0
	BSR.W	AreYouSure
	BNE.W	Return1
	BSR.W	ClearFileNames
	LEA	TrackNameBox,A1
	LEA	FormatBoxPos,A0
	BSR.W	DoSwapBox
	BSR.W	WaitForButtonUp
	LEA	EnterFilenameText,A0
	JSR	ShowStatusText
	BSR.W	lbC002E64
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	InputFileName,A6
	MOVE.L	#"pat.",(A6)+
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#16,TextEndPtr
	MOVE.W	#14,TextLength
	MOVE.W	#3012,A4
	CLR.B	EnterTextFlag
	JSR	GetTextLine
	BSR.W	RestorePtrCol
	LEA	TrackNameBox,A1
	LEA	FormatBoxPos,A0
	BSR.W	DoSwapBox
	BSR.W	ClearFileNames
	LEA	PattPath2,A0
	BSR.W	CopyPath
	LEA	InputFileName,A0
	MOVEQ	#20-1,D0
spaloop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,spaloop
	JSR	StopIt
	BSR.W	DoSavePattern
	MOVE.W	#13,Action
	JMP	ShowAllRight

DeletePattGadg
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectPatterns
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	lbC002CD0
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BEQ.B	lbC002CD0
	BRA.W	RestorePtrCol

lbC002CD0
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#14,Action
	LEA	SelectPatternText,A0
	JSR	ShowStatusText
	BRA.W	SetDeletePtrCol

LoadPattern
	MOVE.W	#1,LoadInProgress
	LEA	PattPath2,A0
	BSR.W	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
lopaloop2
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,lopaloop2
	MOVE.L	#PattDiskBuffer,DiskDataPtr
	MOVE.L	#FileName,FileNamePtr
	MOVE.L	#64*4*4,DiskDataLength
	LEA	LoadingPatternText,A0
	JSR	ShowStatusText
	JSR	DoLoadData
	BEQ.B	lopadone
	JSR	CheckAbort
	BEQ.B	lopadone
	TST.B	LoadPattToBufferFlag
	BNE.B	LoadPattToBuffer
	MOVE.L	SongDataPtr,A0
	LEA	sd_patterndata(A0),A0
	MOVE.L	PatternNumber,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	ADD.L	D0,A0
	LEA	PattDiskBuffer,A1
	MOVE.W	#(64*4)-1,D0
lopaloop3
	MOVE.L	(A1)+,(A0)+
	DBRA	D0,lopaloop3
	BRA.B	lopaskip
LoadPattToBuffer
	LEA	PatternBuffer,A1
	LEA	PattDiskBuffer,A0
	MOVE.W	#(64*4)-1,D0
lopaloop4
	MOVE.L	(A0)+,(A1)+
	DBRA	D0,lopaloop4	
lopaskip
	TST.B	AutoExitFlag
	BEQ.B	lopadone
	BSR.W	ExitFromDir
lopadone
	CLR.W	LoadInProgress
	JSR	ShowAllRight
	BSR.W	SetNormalPtrCol
	JSR	RedrawPattern
	RTS

DoSavePattern
	MOVE.L	#FileName,FileNamePtr
	MOVE.L	#PatternBuffer,DiskDataPtr
	TST.B	LoadPattToBufferFlag
	BNE.B	dsapattskip
	MOVE.L	#PattDiskBuffer,DiskDataPtr
	MOVE.L	SongDataPtr,A0
	LEA	sd_patterndata(A0),A0
	MOVE.L	PatternNumber,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	ADD.L	D0,A0
	LEA	PattDiskBuffer,A1
	MOVE.W	#(64*4)-1,D0
dsapattloop
	MOVE.L	(A0)+,(A1)+
	DBRA	D0,dsapattloop
dsapattskip
	MOVE.L	#64*4*4,DiskDataLength
	JSR	DoSaveData
	JSR	ShowAllRight
	BSR.W	SetNormalPtrCol
	BRA.W	DoAutoDir

DeletePattern
	LEA	DeletePatternText,A0
	BSR.W	AreYouSure
	BNE.W	DeletePattGadg
	LEA	DeletingPatternText,A0
	JSR	ShowStatusText
	LEA	PattPath2,A0
	BSR.W	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
dpaloop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,dpaloop
	MOVE.W	#13,Action
	JMP	Delete3

lbC002E64
	LEA	InputFileName,A0
	MOVEQ	#20-1,D0
lbC002E6C
	MOVE.B	#0,(A0)+
	DBRA	D0,lbC002E6C
	RTS

lbC002E76
	CMP.W	#2,Action
	BEQ.B	lbC002EAC
	CMP.W	#4,Action
	BEQ.B	lbC002EAC
	CMP.W	#6,Action
	BEQ.B	lbC002EAC
	CMP.W	#12,Action
	BEQ.B	lbC002EAC
	CMP.W	#14,Action
	BEQ.B	lbC002EAC
	BRA.W	Return1

lbC002EAC
	BSR.W	SetNormalPtrCol
	RTS
	
;---- Song Gadgets ----

LoadSongGadg
	TST.W	DiskOpScreen2
	BNE.W	LoadTrackGadg
	BSR.B	lbC002E76
	BSR.W	StorePtrCol
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectSongs
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	LoadSongDirOk
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BNE.W	RestorePtrCol
LoadSongDirOk
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#1,Action
	LEA	SelectSongText,A0
	JSR	ShowStatusText
	BRA.W	RestorePtrCol

SaveSongGadg
	TST.W	DiskOpScreen2
	BNE.W	SaveTrack
	BSR.W	SelectSongs
	LEA	SaveSongText,A0
	BSR.W	AreYouSure
	BNE.W	Return1
	BSR.W	RestorePtrCol
	BSR.W	ClearFileNames
	JSR	StopIt
	JSR	SaveSong
	MOVE.W	#1,Action
	RTS

DeleteSongGadg
	TST.W	DiskOpScreen2
	BNE.W	DeleteTrackGadg
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectSongs
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	DeleteSongDirOk
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BEQ.B	DeleteSongDirOk
	BRA.W	RestorePtrCol

DeleteSongDirOk
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#2,Action
	LEA	SelectSongText,A0
	JSR	ShowStatusText
	BRA.W	SetDeletePtrCol
	
;---- Module Gadgets ----

LoadModuleGadg
	BSR.W	lbC002E76
	BSR.W	StorePtrCol
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectModules
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	LoadModDirOk
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BEQ.B	LoadModDirOk
	BRA.W	RestorePtrCol

LoadModDirOk
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#3,Action
	LEA	SelectModuleText,A0
	JSR	ShowStatusText
	BRA.W	RestorePtrCol

SaveModuleGadg
	CLR.W	lbW015B92
	TST.B	SaveIconsFlag
	BEQ.B	smogskip
	MOVE.W	#1,lbW015B92
smogskip
	CLR.W	makeExeModFlag
	BTST	#2,$DFF016	; right mouse button
	BNE.B	smogskip2
	MOVE.W	#1,makeExeModFlag
smogskip2
	BSR.W	SelectModules
	LEA	SaveModuleText,A0
	CMP.W	#1,makeExeModFlag
	BNE.B	smogskip3
	LEA	SaveExeText,A0
smogskip3
	BSR.W	AreYouSure
	BNE.W	Return1
	JSR	SaveModule
	MOVE.W	#3,Action
	JMP	ShowAllRight

DeleteModuleGadg
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectModules
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	DeleteModDirOk
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BEQ.B	DeleteModDirOk
	BRA.W	RestorePtrCol

DeleteModDirOk
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#4,Action
	LEA	SelectModuleText,A0
	JSR	ShowStatusText
	BRA.W	SetDeletePtrCol
	
;---- Sample Gadgets ----

LoadSampleGadg
	TST.W	DiskOpScreen2
	BNE.W	SavePatternGadg
	BSR.W	lbC002E76
	BSR.W	StorePtrCol
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectSamples
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	LoadSampleDirOk
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BEQ.B	LoadSampleDirOk
	BRA.W	RestorePtrCol

LoadSampleDirOk
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#5,Action
	LEA	SelectSampleText,A0
	JSR	ShowStatusText
	BRA.W	RestorePtrCol

xNotSampleNull	JMP	NotSampleNull

SaveSampleGadg
	TST.W	DiskOpScreen2
	BNE.W	SavePattern
	BSR.W	SelectSamples
	CLR.B	RawKeyCode
	MOVE.W	InsNum,D0
	BEQ.B	xNotSampleNull
	LEA	SaveSampleText,A0
	BSR.W	AreYouSure
	BNE.W	Return1
dosavesample
	BSR.W	StorePtrCol
	JSR	CreateSampleName
	CMP.B	#2,RawIFFPakMode
	BNE.W	WriteSample	; PAK flag disabled
	
	; Sample Crunch (PAK)
	TST.L	DiskDataLength
	BEQ.W	Return1
	LEA	FileName,A0
dssaloop
	TST.B	(A0)+
	BNE.B	dssaloop
	MOVE.B	#'.',-1(A0)
	MOVE.B	#'p',(A0)+
	MOVE.B	#'p',(A0)+
	MOVE.B	#$00,(A0)
ShowSampleCrunchBox
	BSR.W	ClearFileNames
	LEA	FormatBoxPos,A0
	LEA	CrunchBoxData,A1
	BSR.W	DoSwapBox
	JSR	ShowCrunchModeTexts
	LEA	AreYouSureText,A0
	JSR	ShowStatusText
dssaloop2
	BSR.W	DoKeyBuffer
	MOVE.B	RawKeyCode,D0
	CMP.B	#69,D0	; ESC
	BEQ.B	AbortSampleCrunchBox
	BSR.W	CheckPatternRedraw2
	BTST	#6,$BFE001	; left mouse button
	BNE.B	dssaloop2
	MOVE.W	MouseX,D0
	MOVE.W	MouseY,D1
	CMP.W	#89,D0
	BLO.B	dssaloop2
	CMP.W	#212,D0
	BHI.B	dssaloop2
	CMP.W	#72,D1
	BLO.B	SampleCrunchSettings
	CMP.W	#82,D1
	BHI.B	dssaloop2
	CMP.W	#136,D0
	BLO.W	DoSampleCrunch
	CMP.W	#166,D0
	BLO.B	dssaloop2
AbortSampleCrunchBox
	LEA	CrunchBoxData,A1
	LEA	FormatBoxPos,A0
	BSR.W	DoSwapBox
	BSR.W	ClearFileNames
	LEA	CrunchAbortedText(PC),A0
	JSR	ShowStatusText
	BRA.W	SetErrorPtrCol
	
SampleCrunchSettings
	CMP.W	#$36,D1
	BLO.W	dssaloop2
	CMP.W	#$88,D0
	BLO.B	SampleCrunchSpeed
	CMP.W	#$A6,D0
	BLO.W	dssaloop2
	ADDQ.L	#1,CrunchBufferMode
	CMP.L	#3,CrunchBufferMode
	BNE.B	tcbmskip
	CLR.L	CrunchBufferMode
tcbmskip
	JSR	ShowCrunchModeTexts
	BRA.W	dssaloop2
	
SampleCrunchSpeed
	ADDQ.L	#1,CrunchSpeed
	CMP.L	#5,CrunchSpeed
	BNE.B	tcsskip
	CLR.L	CrunchSpeed
tcsskip
	JSR	ShowCrunchModeTexts
	BRA.W	dssaloop2

DoSampleCrunch
	LEA	CrunchBoxData,A1
	LEA	FormatBoxPos,A0
	BSR.W	DoSwapBox
	BSR.W	ClearFileNames
WriteSample
	MOVE.L	DiskDataLength,D1
	BEQ.W	Return1
	MOVEQ	#0,D1
	MOVE.W	InsNum,D1
	LSL.L	#2,D1
	LEA	SongDataPtr,A0
	MOVE.L	(A0,D1.W),DiskDataPtr	
	BSR.W	SetDiskPtrCol
	MOVE.L	DOSBase,A6
	MOVE.L	FileNamePtr,D1
	MOVE.L	#1006,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BNE.B	SaveSample
	JSR	CantOpenFile
	BRA.W	ErrorRestoreCol
	
SaveSample
	LEA	SavingSampleText,A0
	JSR	ShowStatusText
	TST.B	RawIFFPakMode
	BEQ.B	WriteRawSample
	CMP.B	#2,RawIFFPakMode
	BEQ.B	WritePakSample
WriteIFFSample
	MOVE.L	FileHandle,D1
	MOVE.L	#IFFFORM,D2
	MOVEQ	#IFFEND-IFFFORM,D3
	MOVE.L	D3,-(SP)
	JSR	_LVOWrite(A6)
	CMP.L	(SP)+,D3
	BEQ.B	WriteRawSample
	JSR	CantSaveFile
WriteRawSample
	MOVE.L	FileHandle,D1
	MOVE.L	DiskDataPtr,D2
	MOVE.L	DiskDataLength,D3
	JSR	_LVOWrite(A6)
	CMP.L	DiskDataLength,D3
	BEQ.B	wrsskip
	JSR	CantSaveFile
wrsskip
	MOVE.L	FileHandle,D1
	JSR	_LVOClose(A6)
	CLR.L	FileHandle
	MOVE.W	#5,Action
	JSR	ShowAllRight
	BSR.W	RestorePtrCol
	BRA.W	DoAutoDir
WritePakSample
	CLR.L	CrunchInfoPtr
	MOVE.L	DiskDataLength,D0
	ADD.L	#104,D0
	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,CrunchBufferPtr
	BNE.B	wpsskip
	JSR	OutOfMemErr
	BRA.W	SampleCrunchCleanUp
wpsskip
	MOVE.L	CrunchBufferPtr(PC),A1
	TST.B	SamplePackFlag
	BEQ.B	wpsskip2
	LEA	IFFFORM(PC),A0
	MOVEQ	#104-1,D0
wpsloop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,wpsloop
wpsskip2
	MOVE.L	DiskDataPtr,A0
	MOVE.L	DiskDataLength,D0
	SUBQ.L	#1,D0
wpsloop2
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,wpsloop2
	MOVE.L	PPLibBase,D0
	BNE.B	wpsskip3
	LEA	PPLibName,A1
	MOVE.L	4.W,A6
	MOVEQ	#0,D0
	JSR	_LVOOpenLibrary(A6)
	MOVE.L	D0,PPLibBase
	BNE.B	wpsskip3
	LEA	PPLibErrorText,A0
	BRA.W	SampleCrunchError
wpsskip3
	MOVE.L	D0,A6
	CMP.W	#$23,20(A6)
	BGE.B	wpsskip4
	LEA	MustHavePP35Text,A0
	BRA.W	SampleCrunchError
wpsskip4
	MOVE.L	CrunchSpeed,D0
	MOVE.L	CrunchBufferMode,D1
	LEA	CrunchInterrupt,A0
	SUB.L	A1,A1
	MOVE.L	PPLibBase,A6
	JSR	_LVOppAllocCrunchInfo(A6)
	MOVE.L	D0,CrunchInfoPtr
	BEQ.W	SampleCrunchOutOfMemory
	LEA	CrunchingText,A0
	JSR	ShowStatusText
	MOVE.L	CrunchInfoPtr(PC),A0
	MOVE.L	CrunchBufferPtr(PC),A1
	MOVE.L	DiskDataLength,D0
	TST.B	SamplePackFlag
	BEQ.B	wpsskip5
	ADD.L	#104,D0
wpsskip5
	MOVE.L	PPLibBase,A6
	JSR	_LVOppCrunchBuffer(A6)
	LEA	CrunchAbortedText(PC),A0
	;CMP.L	#0,D0
	TST.L	D0
	BEQ.W	SampleCrunchError
	LEA	BufOverflowText(PC),A0
	CMP.L	#-1,D0
	BEQ.W	SampleCrunchError
	MOVE.L	D0,CrunchBufferLen
	LEA	CrunchGainText,A0
	JSR	ShowStatusText
	MOVE.L	CrunchBufferLen(PC),D1
	MOVE.L	DiskDataLength,D2
	TST.B	SamplePackFlag
	BEQ.B	wpsskip6
	ADD.L	#104,D2
wpsskip6
	CMP.L	#$FFFF,D2
	BLE.B	wpsskip7
	LSR.L	#1,D2
	LSR.L	#1,D1
	BRA.B	wpsskip6
wpsskip7
	MULU.W	#100,D1
	DIVU.W	D2,D1
	NEG.W	D1
	ADD.W	#100,D1
	MOVE.W	D1,WordNumber
	MOVE.W	#5139,TextOffset
	JSR	Print3DecDigits
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	BSR.W	WaitALittle
	LEA	SavingSampleText,A0
	JSR	ShowStatusText
	MOVE.L	FileHandle,D0
	MOVE.L	CrunchSpeed,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.L	PPLibBase,A6
	JSR	_LVOppWriteDataHeader(A6)
	MOVE.L	FileHandle,D1
	MOVE.L	CrunchBufferPtr(PC),D2
	MOVE.L	CrunchBufferLen(PC),D3
	MOVE.L	DOSBase,A6
	JSR	_LVOWrite(A6)
	CMP.L	CrunchBufferLen(PC),D3
	BEQ.B	SampleCrunchCleanUp
	JSR	CantSaveFile
SampleCrunchCleanUp
	MOVE.L	FileHandle,D1
	MOVE.L	DOSBase,A6
	JSR	_LVOClose(A6)
	;CMP.L	#0,CrunchInfoPtr
	TST.L	CrunchInfoPtr
	BEQ.B	sccskip
	MOVE.L	CrunchInfoPtr(PC),A0
	MOVE.L	PPLibBase,A6
	JSR	_LVOppFreeCrunchInfo(A6)
sccskip
	MOVE.L	CrunchBufferPtr(PC),D1
	BEQ.B	sccskip2
	MOVE.L	D1,A1
	MOVE.L	DiskDataLength,D0
	ADD.L	#104,D0
	JSR	PTFreeMem
sccskip2
	BSR.W	SetNormalPtrCol
	JSR	ShowAllRight
	BRA.W	DoAutoDir
	
SampleCrunchError
	JSR	ShowStatusText
	BSR.W	SetErrorPtrCol
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	BSR.W	WaitALittle
	BRA.B	SampleCrunchCleanUp
	
SampleCrunchOutOfMemory
	LEA	NoBufMemText(PC),A0
	JSR	ShowStatusText
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	BSR.W	WaitALittle
	LEA	ChooseSmallerText(PC),A0
	JSR	ShowStatusText
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	BSR.W	WaitALittle
	MOVE.L	CrunchBufferPtr(PC),D1
	BEQ.B	scoomskip
	MOVE.L	D1,A1
	MOVE.L	DiskDataLength,D0
	ADD.L	#104,D0
	JSR	PTFreeMem
scoomskip
	MOVE.L	FileHandle,D1
	MOVE.L	DOSBase,A6
	JSR	_LVOClose(A6)
	BRA.W	ShowSampleCrunchBox

	CNOP 0,4
CrunchBufferLen		dc.l 0
CrunchInfoPtr		dc.l 0
CrunchBufferPtr		dc.l 0
CrunchAbortedText	dc.b 'Crunch aborted!',0
BufOverflowText		dc.b 'Buffer Overflow!',0
NoBufMemText		dc.b 'No mem for buffer',0
ChooseSmallerText	dc.b 'Choose smaller !!',0
	EVEN

	CNOP 0,4
IFFFORM	dc.b "FORM"
	dc.l 0
	dc.b "8SVX"
IFFVHDR	dc.b "VHDR"
	dc.l 20
	dc.l 0,0,32	; oneshot, repeat, hisamples
	dc.w 16726	; This is really NTSC (16574 for PAL!!!)
	dc.b 1,0	; octaves, compression
	dc.l $10000	; volume
IFFNAME	dc.b "NAME"
	dc.l 24
	dcb.b 24,0
	dc.b "ANNO"
	dc.l 16
	dc.b "ProTracker 2.3F",0
IFFBODY	dc.b "BODY"
	dc.l 0
IFFEND

;---- Delete Sample ----

DeleteSampleGadg
	TST.W	DiskOpScreen2
	BNE.W	DeletePattGadg	; different buttons in Disk Op. #2
	BSR.W	StorePtrCol
	BSR.W	WaitForButtonUp
	BSR.W	ClearFileNames
	BSR.W	SelectSamples
	LEA	FileNamesPtr(PC),A5
	BSR.W	HasDiskChanged
	BEQ.B	DeleteSamDirOk
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BEQ.B	DeleteSamDirOk
	BRA.W	RestorePtrCol

DeleteSamDirOk
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	MOVE.W	#6,Action
	LEA	SelectSampleText,A0
	JSR	ShowStatusText
	BRA.W	SetDeletePtrCol

;---- Directory Path Gadget ----

DirPathGadg
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	MOVE.L	PathPtr,A6
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#63,TextEndPtr
	MOVE.W	#18,TextLength
	MOVE.W	#1484,A4
	BSR.W	GetTextLine
	; PT2.3D change: refresh dir after typing dir + enter
	TST.W	AbortStrFlag
	BNE.W	SetNormalPtrCol
	MOVE.L	D0,-(SP)
	MOVE.W	DirPathNum(PC),D0
	BSR.W	ChangePath
	BSR	ClearFileNames
	MOVE.L	A5,-(SP)
	LEA	FileNamesPtr(PC),A5
	BSR.W	ClearDirTotal
	BSR.W	DirDisk
	BEQ.W	dpgok
	MOVEA.L	(SP)+,A5
	MOVE.L	(SP)+,D0
	BRA.W	SetNormalPtrCol
dpgok
	BSR.W	RedrawFileNames
	MOVEA.L	(SP)+,A5
	MOVE.L	A0,-(SP)
	MOVE.W	DirPathNum(PC),D0	; D0 = DirPathNum (Disk Op. Load/Save mode)			
	BEQ.B	moduleAction		; D0 #0 = load module
	CMP.B	#1,D0
	BEQ.B	songAction			; D0 #1 = load song
sampleAction						; D0 #2 = load sample
	MOVE.W	#5,Action			; load sample action
	LEA	SelectSampleText,A0
	BRA.B	dpgend
moduleAction
	MOVE.W	#3,Action			; load module action
	LEA	SelectModuleText,A0
	BRA.B	dpgend
songAction
	MOVE.W	#1,Action			; load song action
	LEA	SelectSongText,A0
dpgend
	JSR	ShowStatusText
	MOVE.L	(SP)+,A0
	MOVE.L	(SP)+,D0
	; ----------------------------------------------------
	BRA.W	SetNormalPtrCol

CopyPath
	LEA	FileName,A1
	TST.B	(A0)		; If no path
	BEQ.W	Return1
cploop	MOVE.B	(A0)+,(A1)+	; Copy path to filename
	BNE.B	cploop
	CMP.B	#':',-2(A1)	; If ending with ':' it's ok
	BEQ.B	PathCharBack
	CMP.B	#'/',-2(A1)	; If ending with '/' it's ok
	BEQ.B	PathCharBack
	MOVE.B	#'/',-1(A1)	; Add '/' to end path
	RTS

PathCharBack
	SUBQ.L	#1,A1
	RTS

ShowDirPath
	CMP.W	#3,CurrScreen
	BNE.W	Return1
	MOVEM.L	D0/D1/A0/A1,-(SP)
	MOVE.L	PathPtr,A0
	MOVEQ	#18,D0
	MOVE.W	#1484,D1
	JSR	ShowText3
	MOVEM.L	(SP)+,D0/D1/A0/A1
	RTS
	
;---- File List Gadgets ----

FilenameOneUp
	ST	SetSignalFlag
	TST.W	SelectDiskFlag
	BNE.B	fnouskip
	TST.W	Action
	BEQ.W	Return1
	JSR	GUIDelay		; PT2.3D change: wait properly on every scroll
fnouskip2
	LEA	FileNamesPtr(PC),A5
	MOVE.W	FileNameScrollPos(PC),D0
	BEQ.W	Return1
	SUBQ.W	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.W	RedrawFileNames
	SUBQ.W	#3,D0
	BPL.W	RedrawFileNames
	MOVEQ	#0,D0
	BRA.W	RedrawFileNames
fnouskip
	MOVE.W	FileListBufferEntry(PC),D0
	BEQ.W	Return1
	SUBQ.W	#1,D0
	MOVE.W	D0,FileListBufferEntry
	BRA.W	lbC002516

lbC0037F8
	TST.W	SelectDiskFlag
	BNE.B	lbC003826
	TST.W	Action
	BEQ.W	Return1
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	lbC003832
	LEA	FileNamesPtr(PC),A5
	MOVE.W	FileNameScrollPos(PC),D0
	BEQ.W	Return1
lbC003820
	CLR.W	D0
	BRA.W	RedrawFileNames

lbC003826
	CLR.W	FileListBufferEntry
	BRA.W	lbC002516

lbC003832
	TST.W	SelectDiskFlag
	BNE.W	Return1
	LEA	FileNamesPtr(PC),A5
	MOVE.W	FileNameScrollPos(PC),D0
	MULU.W	#36,D0
	MOVE.L	(A5),A1
	MOVE.B	(A1,D0.L),D1
	CMP.L	#'mod.',(A1,D0.L)
	BNE.B	lbC00385C
	MOVE.B	4(A1,D0.L),D1
lbC00385C
	BSR.W	lbC0039E8
	SUB.L	#$24,D0
	BMI.B	lbC003820
	MOVE.B	(A1,D0.L),D2
	CMP.L	#'mod.',(A1,D0.L)
	BNE.B	lbC00387A
	MOVE.B	4(A1,D0.L),D2
lbC00387A
	BSR.W	lbC0039F0
	CMP.B	D1,D2
	BEQ.B	lbC00385C
	MOVE.B	D2,D1
lbC003884
	SUBI.L	#$24,D0
	BMI.B	lbC003820
	MOVE.B	(A1,D0.L),D2
	CMP.L	#'mod.',(A1,D0.L)
	BNE.B	lbC00389E
	MOVE.B	4(A1,D0.L),D2
lbC00389E
	BSR.W	lbC0039F0
	CMP.B	D1,D2
	BEQ.B	lbC003884
	DIVU.W	#$24,D0
	ADDQ.W	#1,D0
	BRA.W	RedrawFileNames

FilenameOneDown
	ST	SetSignalFlag
	TST.W	SelectDiskFlag
	BNE.B	fnodskip
	TST.W	Action
	BEQ.W	Return1
	JSR	GUIDelay		; PT2.3D change: wait properly on every scroll
fnodskip2
	LEA	FileNamesPtr(PC),A5
	MOVE.W	FileNameScrollPos(PC),D0
	ADDQ.W	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	fnod2
	ADDQ.W	#3,D0
fnod2	MOVE.W	16(A5),D1
	SUBQ.W	#8,D1
	BMI.W	Return1
	CMP.W	D1,D0
	BLS.W	RedrawFileNames
	MOVE.W	D1,D0
	BRA.W	RedrawFileNames
fnodskip
	MOVEQ	#0,D0
	MOVE.B	lbB002386(PC),D0
	CMP.W	#8,D0
	BLE.W	Return1
	SUBQ.W	#8,D0
	MOVE.W	FileListBufferEntry(PC),D1
	CMP.W	D0,D1
	BGE.W	Return1
	ADDQ.W	#1,D1
	MOVE.W	D1,FileListBufferEntry
	BRA.W	lbC002516

lbC003926
	TST.W	SelectDiskFlag
	BNE.B	lbC00395A
	TST.W	Action
	BEQ.W	Return1
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	lbC00397A
	LEA	FileNamesPtr(PC),A5
	MOVE.W	FileNameScrollPos(PC),D0
	MOVE.W	16(A5),D1
	SUBQ.W	#8,D1
	BMI.W	Return1
	MOVE.W	D1,D0
	BRA.W	RedrawFileNames

lbC00395A
	MOVEQ	#0,D0
	MOVE.B	lbB002386(PC),D0
	CMP.W	#8,D0
	BLE.W	Return1
	SUBQ.W	#8,D0
	MOVE.W	D0,FileListBufferEntry
	BRA.W	lbC002516

lbC00397A
	TST.W	SelectDiskFlag
	BNE.W	Return1
	LEA	FileNamesPtr(PC),A5
	MOVE.W	FileNameScrollPos(PC),D0
	MULU.W	#36,D0
	MOVE.L	(A5),A1
	MOVE.B	(A1,D0.L),D1
	CMP.L	#'mod.',(A1,D0.L)
	BNE.B	lbC0039A4
	MOVE.B	4(A1,D0.L),D1
lbC0039A4
	BSR.B	lbC0039E8
	ADD.L	#$24,D0
	MOVE.W	16(A5),D2
	SUBQ.W	#8,D2
	BMI.W	Return1
	MULU.W	#36,D2
	CMP.L	D2,D0
	BLS.B	lbC0039C8
	MOVE.L	D2,D0
	DIVU.W	#36,D0
	BRA.W	RedrawFileNames

lbC0039C8
	MOVE.B	(A1,D0.L),D2
	CMP.L	#'mod.',(A1,D0.L)
	BNE.B	lbC0039DA
	MOVE.B	4(A1,D0.L),D2
lbC0039DA
	BSR.B	lbC0039F0
	CMP.B	D1,D2
	BEQ.B	lbC0039A4
	DIVU.W	#$24,D0
	BRA.W	RedrawFileNames

lbC0039E8
	MOVE.B	D1,D3
	BSR.B	lbC0039F8
	MOVE.B	D3,D1
	RTS

lbC0039F0
	MOVE.B	D2,D3
	BSR.B	lbC0039F8
	MOVE.B	D3,D2
	RTS

lbC0039F8
	CMP.B	#65,D3
	BLO.B	lbC003A08
	CMP.B	#90,D3
	BHI.B	lbC003A08
	ADD.B	#32,D3
lbC003A08
	RTS

;---- Clicked on a filename ----

FileNamePressed
	SUB.W	#44,D1
	ST	UpdateFreeMem
	CMP.W	#3,D1
	BLO.W	Return1
	CMP.W	#50,D1
	BHI.W	Return1
	SUBQ.W	#3,D1
	AND.L	#$FFFF,D1
	DIVU.W	#6,D1
	TST.W	SelectDiskFlag
	BNE.W	lbC003ADC
	TST.W	Action
	BEQ.W	Return1
	MOVE.W	D1,FileNameScrollPos+2
	LEA	FileNamesPtr(PC),A5
	MOVE.W	FileNameScrollPos(PC),D0
	ADD.W	D1,D0
	CMP.W	16(A5),D0
	BHS.W	Return1
	MULU.W	#36,D0
	ADD.L	(A5),D0
	MOVE.L	D0,A0
	TST.L	32(A0)
	BMI.W	AddDirectory
	MOVEQ	#DirNameLength-1,D0
	LEA	DirInputName,A1
fnploop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,fnploop
	MOVE.W	Action,D6
	CMP.W	#1,D6
	BEQ.W	LoadSong
	CMP.W	#2,D6
	BEQ.W	DeleteSong
	CMP.W	#3,D6
	BEQ.W	xLoadModule
	CMP.W	#4,D6
	BEQ.W	DeleteModule
	CMP.W	#5,D6
	BEQ.W	LoadSample
	CMP.W	#6,D6
	BEQ.W	DeleteSample
	CMP.W	#10,D6
	BEQ.W	RenameFile
	CMP.W	#11,D6
	BEQ.W	LoadTrack
	CMP.W	#12,D6
	BEQ.W	DeleteTrack
	CMP.W	#13,D6
	BEQ.W	LoadPattern
	CMP.W	#14,D6
	BEQ.W	DeletePattern
	RTS

lbC003ADC
	ADD.W	FileListBufferEntry(PC),D1
	MOVEQ	#0,D3
	MOVE.W	DirPathNum(PC),D3
	LEA	dpnum(PC),A0
	ADD.L	D3,A0
	MOVEQ	#0,D0
	MOVE.B	lbB002386(PC),D0
	CMP.B	D0,D1
	BLO.B	lbC003AFE
	RTS

lbC003AFE
	SUBQ.B	#1,D1
	MOVE.B	D1,(A0)
	BSR.W	DirBrowseGadg2
	CLR.W	SelectDiskFlag
	MOVE.W	ActionTemp(PC),Action
	BRA.W	DoAutoDir

xLoadModule	JMP	LoadModule

AddDirectory
	MOVE.L	A0,-(SP)
	MOVE.L	PathPtr,A0
	BSR.W	CopyPath
	MOVE.L	(SP)+,A0
	MOVEQ	#DirNameLength-1,D0
addplop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,addplop
	LEA	FileName,A0
	MOVE.L	PathPtr,A1
	MOVEQ	#97-1,D0 ; 62
addplp2	MOVE.B	(A0)+,(A1)+
	DBRA	D0,addplp2
addpdir	BSR.W	ShowDirPath
	MOVE.W	Action,D6
	CMP.W	#1,D6
	BEQ.W	LoadSongGadg
	CMP.W	#2,D6
	BEQ.B	xDeleteSongGadg
	CMP.W	#3,D6
	BEQ.W	LoadModuleGadg
	CMP.W	#4,D6
	BEQ.B	xDeleteModuleGadg
	CMP.W	#5,D6
	BEQ.W	LoadSampleGadg
	CMP.W	#6,D6
	BEQ.B	xDeleteSampleGadg
	CMP.W	#10,D6
	BEQ.W	RenameFileGadg
	CMP.W	#11,D6
	BEQ.W	LoadTrackGadg
	CMP.W	#12,D6
	BEQ.B	xDeleteTrackGadg
	CMP.W	#13,D6
	BEQ.W	SavePatternGadg
	CMP.W	#14,D6
	BEQ.B	xDeletePattGadg
	RTS

xDeleteModuleGadg
	BSR.W	DoAutoDir
	BRA.W	DeleteModuleGadg

xDeleteSongGadg
	BSR.W	DoAutoDir
	BRA.W	DeleteSongGadg

xDeleteSampleGadg
	BSR.W	DoAutoDir
	BRA.W	DeleteSampleGadg

xDeleteTrackGadg
	BSR.W	DoAutoDir
	BRA.W	DeleteTrackGadg

xDeletePattGadg
	BSR.W	DoAutoDir
	BRA.W	DeletePattGadg

ParentDirGadg
	BSR.W	WaitForButtonUp
	MOVE.L	PathPtr,A0
	MOVE.L	A0,A1
pdgloop	TST.B	(A1)+
	BNE.B	pdgloop
	SUBQ.L	#1,A1
	CMP.L	A0,A1
	BLS.W	Return1
	SUBQ.L	#1,A1
	CMP.B	#'/',(A1)
	BNE.B	pdgskp1
	CLR.B	(A1)
pdgskp1	CMP.B	#':',(A1)
	BEQ.W	addpdir
	CMP.B	#'/',(A1)
	BEQ.B	pdgslsh
	CLR.B	(A1)
	CMP.L	A0,A1
	BLS.W	addpdir
	SUBQ.L	#1,A1
	BRA.B	pdgskp1

pdgslsh	CLR.B	(A1)
	BRA.W	addpdir

	CNOP 0,4
FileNamesPtr
	dc.l	0  ; A5+ 0
	dc.l	0  ;   + 4
	dc.l	0  ;   + 8
	dc.l	0  ;   +12
	dc.w	0  ;   +16
	dc.w	24 ;   +18
	
FileNameScrollPos
	dc.w	0
	dc.w	0
	
;---- Has Disk Changed ----

HasDiskChanged
	MOVE.L	DOSBase,A6
	MOVE.L	A4,D1
	MOVEQ	#-2,D2
	JSR	_LVOLock(A6)
	MOVE.L	D0,FileLock
	BEQ.B	ExamineError
	MOVE.L	FileLock,D1
	MOVE.L	#FileInfoBlock,D2
	JSR	_LVOExamine(A6)
	TST.L	D0
	BEQ.B	ExamineError
	LEA	FileInfoBlock,A0
	MOVE.L	ofib_DateStamp+ds_Days(A0),D0
	CMP.L	4(A5),D0
	BNE.B	DiskChanged
	MOVE.L	ofib_DateStamp+ds_Minute(A0),D0
	CMP.L	8(A5),D0
	BNE.B	DiskChanged
	MOVE.L	ofib_DateStamp+ds_Tick(A0),D0
	CMP.L	12(A5),D0
	BNE.B	DiskChanged
	MOVE.L	FileLock,D1
	JSR	_LVOUnLock(A6)
	MOVEQ	#0,D0
	RTS

DiskChanged
	MOVE.L	ofib_DateStamp+ds_Days(A0),4(A5)
	MOVE.L	ofib_DateStamp+ds_Minute(A0),8(A5)
	MOVE.L	ofib_DateStamp+ds_Tick(A0),12(A5)
	MOVE.L	FileLock,D1
	JSR	_LVOUnLock(A6)
	MOVEQ	#-1,D0
	RTS

ExamineError
	CLR.L	4(A5)
	MOVEQ	#-1,D0
	RTS

ShowFreeDiskGadg
	CLR.W	SelectDiskFlag
	BSR.W	WaitForButtonUp
	MOVE.L	PathPtr,A4
	BSR.B	LockAndGetInfo
	BNE.W	Return1
	BSR.W	DirDiskUnlock
	BSR.W	ClearFileNames
	LEA	FileNamesPtr(PC),A5
	MOVE.W	FileNameScrollPos(PC),D0
	BSR.W	RedrawFileNames
	JMP	ShowAllRight

LockAndGetInfo
	BSR.W	StorePtrCol
	BSR.W	SetDiskPtrCol
	CLR.W	FileNameScrollPos
	MOVE.L	DOSBase,A6
	MOVE.L	A4,D1
	MOVEQ	#-2,D2
	JSR	_LVOLock(A6)
	MOVE.L	D0,FileLock
	BEQ.W	DirDiskError
	LEA	ReadingDirText,A0
	JSR	ShowStatusText
	MOVE.L	FileLock,D1
	MOVE.L	#InfoData,D2
	JSR	_LVOInfo(A6)
	LEA	InfoData,A0
	MOVE.L	12(A0),D0 ; id_NumBlocks	
	; -------------------------------------------------
	; This code snippet was taken from PT3.15.S
	MOVEM.L	D3/D4,-(SP)
	MOVE.L	16(A0),D1		; id_NumBlocksUsed
	MOVE.L	20(A0),D2		; id_BytesPerBlock
	SUB.L	D1,D0			; Sub all blocks used from total blocks
	MOVE.W	D0,D3			; THIS IS NOT VERY FAST!!!!!
	SWAP	D0			; We must split register, coz mulu won't
	MOVE.W	D0,D4			; accept longwords!
	MULU.W	D2,D3			; Ex: cannot calc a volume with size: 50 Mb
	MULU.W	D2,D4			; But now we can! hehe! Plystre!
	SWAP	D4
	OR.L	D4,D3			; OKI. Let's insert the "reminder"!!!
	MOVE.L	D3,FreeDiskSpace	; Here is the size of bytes free on disk!
	MOVEM.L	(SP)+,D3/D4
	; -------------------------------------------------
ShowDiskSpace
	MOVE.W	#1510,TextOffset
	MOVE.L	FreeDiskSpace,D7
	TST.B	ShowDecFlag
	BNE.B	sdsdec
	SWAP	D7
	MOVE.W	D7,WordNumber
	JSR	PrintHexWord
	SWAP	D7
	MOVE.W	D7,WordNumber
	JSR	PrintHexWord
	MOVEQ	#0,D0
	RTS

sdsdec
	; PT2.3D bug fix: show "A LOT..." when free space is more than 8 digits
	CMP.L	#99999999,D7
	BLS.B	sdsdecok
	MOVE.L	#tooMuchText,ShowTextPtr
	MOVE.W	#8,TextLength
	JSR	ShowText
	BRA.B	sdsdecend
sdsdecok
	DIVU.W	#10000,D7
	MOVE.W	D7,WordNumber
	JSR	Print4DecDigits
	SWAP	D7
	MOVE.W	D7,WordNumber
	JSR	Print4DecDigits
sdsdecend
	MOVEQ	#0,D0
	RTS
	
tooMuchText	dc.b "A LOT..."
	EVEN

;---- Get Disk Directory ----

AllocDirMem
	ADD.W	#50,DirEntries
	MOVE.W	DirEntries(PC),D0
	MULU.W	#36,D0
	MOVE.L	DirAllocSize(PC),D6
	MOVE.L	D0,DirAllocSize
	MOVE.L	#MEMF_CLEAR,D1
	JSR	PTAllocMem
	MOVE.L	D0,D7
	BEQ.B	baehsj
	
	MOVE.L	FileNamesPtr(PC),D1
	MOVE.L	D7,FileNamesPtr
	TST.L	D1
	BEQ.W	Return1
	TST.L	D6
	BEQ.W	Return1
	MOVE.L	D1,A0
	MOVE.L	D7,A1
	MOVE.L	D6,D0
admloop	MOVE.B	(A0)+,(A1)+
	SUBQ.L	#1,D6
	BNE.B	admloop
	MOVE.L	D1,A1
	JSR	PTFreeMem
	RTS

FreeDirMem
	MOVE.L	FileNamesPtr(PC),D1
	BEQ.W	Return1
	MOVE.L	D1,A1
	MOVE.L	DirAllocSize(PC),D0
	JSR	PTFreeMem
	CLR.L	FileNamesPtr
	CLR.W	DirAllocSize
	CLR.W	DirEntries
	RTS

baehsj  JSR	OutOfMemErr
	MOVEQ	#-1,D0
	RTS

	CNOP 0,4
DirAllocSize	dc.l	0
DirEntries	dc.w	0

DirDisk	BSR.B	FreeDirMem
	BSR.W	AllocDirMem
	BSR.W	LockAndGetInfo	; puts DOSBase into A6
	BNE.W	Return1
	MOVE.L	FileLock,D1
	MOVE.L	#FileInfoBlock,D2
	JSR	_LVOExamine(A6)
	TST.L	D0
	BEQ.B	DirDiskError
ddloop1	MOVE.L	FileLock,D1
	MOVE.L	#FileInfoBlock,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOExNext(A6)
	TST.L	D0
	BEQ.B	DirDiskUnlock
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	AbortDir
	BSR.W	NewDirEntry
	BRA.B	ddloop1

AbortDir
	CLR.L	4(A5)
	LEA	DirAbortedText(PC),A0
	JSR	ShowStatusText
	BSR.B	DirDiskUnlock
	BSR	WaitALittle
	JSR	ShowAllRight
	MOVEQ	#0,D0
	RTS

DirDiskUnlock
	MOVE.L	FileLock,D1
	JSR	_LVOUnLock(A6)
	BSR	RestorePtrCol
	MOVEQ	#0,D0
	RTS

DirAbortedText	dc.b 'dir aborted !',0
	EVEN

DirDiskError
	TST.L	FileLock
	BEQ.B	ddeskip
	MOVE.L	FileLock,D1
	JSR	_LVOUnLock(A6)
ddeskip	;BSR.W	PTScreenToFront (8bitbubsy: this causes issues on exit!)
	BSR.W	RestorePtrCol
	LEA	CantFindDirText(PC),A0
	JSR	ShowStatusText
	BSR.W	SetErrorPtrCol
	MOVEQ	#-1,D0
	RTS

ClearDirTotal
	CLR.W	16(A5)
	RTS	

CantFindDirText	dc.b "can't find dir !",0
	EVEN

NewDirEntry
	LEA	FIB_FileName,A0
	TST.B	ShowDirsFlag
	BNE.B	ndeok1
	TST.L	FIB_EntryType
	BPL.W	Return1
ndeok1	TST.L	FIB_EntryType
	BPL.B	ndeok2
	TST.B	ModOnlyFlag
	BEQ.B	ndeok2
	TST.W	DirPathNum
	BNE.B	ndeok2
	MOVE.L	(A0),D0
	AND.L	#$DFDFDFFF,D0
	CMP.L	#'MOD.',D0
	BNE.W	Return1
ndeok2	MOVE.W	16(A5),D0
	CMP.W	DirEntries(PC),D0
	BLO.B	ndeok3
	MOVE.L	A0,-(SP)
	BSR.W	AllocDirMem
	MOVE.L	(SP)+,A0
ndeok3	MOVE.W	16(A5),D6
	BEQ.B	ndeadd1		; If first entry
	SUBQ.W	#1,D6
	MOVE.L	(A5),A1
ndeloopname
	MOVEQ	#0,D2
	MOVE.L	FIB_EntryType,D0
	MOVE.L	32(A1),D1
	TST.L	D0
	BPL.B	ndesfil	; if directory, all is well
	TST.L	D1
	BMI.B	ndenext	; was file, so skip if directory
	BRA.B	ndelopc
ndesfil	TST.L	D1	; if file
	BPL.B	ndeinse
ndelopc	MOVE.B	(A0,D2.W),D0 ; Get a character
	BEQ.B	ndeinse
	CMP.B	#96,D0  ; Lowercase?
	BLO.B	ndeskp1
	SUB.B	#32,D0	; Switch to upper
ndeskp1	MOVE.B	(A1,D2.W),D1
	BEQ.B	ndenext
	CMP.B	#96,D1
	BLO.B	ndeskp2
	SUB.B	#32,D1
ndeskp2	CMP.B	D0,D1
	BHI.B	ndeinse
	BNE.B	ndenext
	ADDQ.W	#1,D2
	BRA.B	ndelopc
ndenext	LEA	36(A1),A1	; next entry
	DBRA	D6,ndeloopname	; loop entries
	MOVE.L	(A5),A1
	MOVE.W	16(A5),D0
	MULU.W	#36,D0
	ADD.W	D0,A1
	BRA.B	ndeadd2

ndeinse	MOVE.L	(A5),A2
	MOVE.W	16(A5),D0
	MULU.W	#36,D0
	ADD.W	D0,A2
	MOVE.L	A2,A3
	LEA	36(A3),A3
nde3loop	MOVE.W	-(A2),-(A3)
	CMP.L	A2,A1
	BNE.B	nde3loop
	BRA.B	ndeadd2

ndeadd1	MOVE.L	(A5),A1			; Put new filename into list
ndeadd2	LEA	FIB_FileName,A0
	MOVE.L	A1,A3
	MOVEQ	#36-1,D0		; Clear old filename
nde4loop
	CLR.B	(A3)+
	DBRA	D0,nde4loop
	MOVE.W	FIB_DateStamp+ds_Days+2,30(A1)
	MOVEQ	#-1,D0
	TST.L	FIB_EntryType
	BPL.B	ndefskp
	MOVE.L	FIB_FileSize,D0
ndefskp	MOVE.L	D0,32(A1)
	MOVEQ	#30-1,D0		; Copy new filename
nde4loop2
	MOVE.B	(A0)+,D1
	MOVE.B	D1,(A1)+
	TST.B	D1
	BEQ.B	nde4skip
	DBRA	D0,nde4loop2
nde4skip
	ADDQ.W	#1,16(A5)	; Files + 1
	RTS

RedrawFileNames
	MOVE.L	D0,-(SP)
	BSR.W	ShowDirPath
	MOVE.L	(SP)+,D0
	MOVE.W	D0,FileNameScrollPos
	TST.W	16(A5)
	BEQ.W	Return1
	MOVEA.W	#1881,A6
	MOVE.W	A6,TextOffset
	MOVE.L	(A5),D6
	MULU.W	#36,D0
	ADD.L	D0,D6
	MOVE.W	16(A5),D0
	SUB.W	FileNameScrollPos(PC),D0
	CMP.W	#8,D0
	BHS.B	ShowFileNames
	SUBQ.W	#1,D0
	MOVE.W	D0,D7
	BRA.B	sfnloop

ShowFileNames
	MOVE.W	#$91,D0
	BSR.W	WaitForVBlank
	MOVEQ	#8-1,D7
sfnloop	MOVE.W	A6,TextOffset
	MOVE.L	D6,A0
	MOVEQ	#0,D0
	MOVE.W	30(A0),D0
	BSR.W	CalculateDate
	MOVE.W	TheDay(PC),WordNumber	
	JSR	Print2DecDigits
	MOVE.W	TheMonth(PC),WordNumber	
	JSR	Print2DecDigits
	MOVE.W	TheYear(PC),WordNumber	
	JSR	Print2DecDigits
	ADDQ.W	#1,TextOffset
	MOVE.L	D6,ShowTextPtr
	MOVE.W	#24,TextLength
	TST.W	DirPathNum
	BNE.B	sfnskip
	TST.B	ModOnlyFlag
	BEQ.B	sfnskip
	MOVE.L	D6,A0
	MOVE.L	(A0),D0
	AND.L	#$DFDFDFFF,D0
	CMP.L	#"MOD.",D0
	BNE.B	sfnskip
	ADDQ.L	#4,ShowTextPtr
sfnskip	JSR	SpaceShowText
	LEA	32(A6),A6
	MOVE.W	A6,TextOffset
	MOVE.L	D6,A0
	MOVE.L	32(A0),D1
	BMI.B	sfndir
	TST.B	ShowDecFlag
	BNE.B	sfndec
	SWAP	D1
	AND.W	#$000F,D1
	BSR.W	ShowOneDigit
	MOVE.L	D6,A0
	MOVE.W	34(A0),WordNumber
	JSR	PrintHexWord
sfnend	ADD.L	#36,D6
	LEA	208(A6),A6
	DBRA	D7,sfnloop
	RTS

sfndec	MOVE.L	D1,D0
	SUBQ.W	#1,TextOffset
	JSR	Print6DecDigits
	BRA.B	sfnend

sfndir	MOVE.L	#DirText,ShowTextPtr
	SUBQ.W	#1,TextOffset
	MOVE.W	#6,TextLength
	JSR	ShowText
	BRA.B	sfnend

CalculateDate
	DIVU.W	#1461,D0
	LSL.W	#2,D0
	MOVE.W	D0,TheYear
	CLR.W	D0
	SWAP	D0
	CMP.W	#789,D0
	BEQ.B	cadleap
	BLO.B	cadskp2
	SUBQ.W	#1,D0
cadskp2	DIVU.W	#365,D0
	MOVE.L	D0,D1
	SWAP	D1
	CMP.W	#4,D0
	BLO.B	cadskip
	SUBQ.W	#1,D0
cadskip	ADD.W	D0,TheYear
	LEA	MonthTable(PC),A1
	MOVEQ	#24,D0
cadloop	SUBQ.W	#2,D0
	MOVE.W	(A1,D0.W),D2
	CMP.W	D2,D1
	BHS.B	cadskp3
	TST.W	D0
	BNE.B	cadloop
cadskp3	LSR.W	#1,D0
	ADDQ.W	#1,D0
	MOVE.W	D0,TheMonth
	SUB.W	D2,D1
	ADDQ.W	#1,D1
	MOVE.W	D1,TheDay
cadend	MOVEQ	#0,D0
	MOVE.W	TheYear(PC),D0
	ADD.W	#78,D0
	DIVU.W	#100,D0
	SWAP	D0
	MOVE.W	D0,TheYear
	RTS
cadleap	ADDQ.W	#2,TheYear
	MOVE.W	#2,TheMonth
	MOVE.W	#29,TheDay
	BRA.B	cadend

TheYear		dc.w 0
TheMonth	dc.w 0
TheDay		dc.w 0
MonthTable	dc.w 0,31,59,90,120,151,181,212,243,273,304,334
DirText		dc.b " (DIR)"
	EVEN
	
;---- Update Mousepointer Position ----

UpdatePointerPos
	MOVE.W	MouseX(PC),D0
	ADDQ.W	#3,D0
	MOVE.W	MouseY(PC),D1
	MOVEQ	#16,D2
	MOVE.L	PointerSpritePtr(PC),A0
	JMP	SetSpritePos

;---- Play Song ----

PlaySong
	MOVEQ	#0,D0
SongFrom
	BSR.W	StopIt
	BTST	#2,$DFF016	; right mouse button
	BNE.B	sofr1
	MOVE.W	PlayFromPos(PC),D0
sofr1	MOVE.W	D0,ScrPattPos
	LSL.W	#4,D0
	AND.L	#$FFF,D0
	MOVE.L	D0,PatternPosition
wfbu1	BTST	#6,$BFE001	; left mouse button
	BEQ.B	wfbu1
	CLR.B	RawKeyCode
	CLR.B	SaveKey
	BSR.W	SetPlayPtrCol
	CLR.L	PlaybackSecsFrac
	CLR.L	PlaybackSecs
	BSR.W	DrawPlaybackCounter
	MOVE.L	#'patp',RunMode
	CLR.W	DidQuantize
	MOVE.L	#-1,LongFFFF
	BSR.W	SetScrPatternPos
SetPlayPosition
	MOVE.L	CurrPos,D0
	MOVE.L	SongDataPtr,A0
	CMP.B	sd_numofpatt(A0),D0
	BHS.B	SongPosToZero
	MOVE.L	CurrPos,SongPosition
	RTS

SongPosToZero
	CLR.L	SongPosition
	CLR.L	CurrPos
	RTS
	
;---- Play Pattern ----

PlayPattern
	CMP.W	#8,CurrScreen
	BEQ.W	lbC009F6C
ppskip
	MOVEQ	#0,D0
PattFrom
	BSR.W	StopIt
	BTST	#2,$DFF016	; right mouse button
	BNE.B	pafr1
	MOVE.W	PlayFromPos(PC),D0
pafr1	MOVE.W	D0,ScrPattPos
	LSL.W	#4,D0
	AND.L	#$FFF,D0
	MOVE.L	D0,PatternPosition
wfbu2	BTST	#6,$BFE001	; left mouse button
	BEQ.B	wfbu2
	CLR.B	RawKeyCode
	CLR.B	SaveKey
	MOVE.L	#'patt',RunMode
	BSR.W	SetPlayPtrCol
	RTS

;---- Record Pattern/Song ----

RecordPattern
	MOVEQ	#0,D0
RecordFrom
	; 8bitbubsy: allow CTRL+Fn (ALT+Fn is already allowed)
	;TST.W	SamScrEnable
	;BNE.W	Return1
	;
	BSR.W	StopIt
	BTST	#2,$DFF016	; right mouse button
	BNE.B	refr1
	MOVE.W	PlayFromPos(PC),D0
refr1	MOVE.W	D0,ScrPattPos
	LSL.W	#4,D0
	AND.L	#$FFF,D0
	MOVE.L	D0,PatternPosition
wfbu3	BTST	#6,$BFE001	; left mouse button
	BEQ.B	wfbu3
	BSR.W	SetEditPtrCol
	CLR.B	RawKeyCode
	CLR.B	SaveKey
	BSR.W	SaveUndo
	MOVE.L	#'edit',EditMode
	MOVE.L	#'patt',RunMode
	TST.B	RecordMode
	BEQ.W	Return1
	MOVE.L	#'patp',RunMode
	BRA.W	SetPlayPosition

;---- Show Main Screen ----

DisplayMainScreen
	CLR.W	BlockMarkFlag
	MOVE.W	#1,CurrScreen
	SF	NoSampleInfo
	TST.W	LoadInProgress
	BNE.B	dmsskp3
	BSR.W	SetNormalPtrCol
	TST.W	RunMode
	BEQ.B	dmsskip
	BSR.W	SetPlayPtrCol
dmsskip	TST.L	EditMode
	BEQ.B	dmsskp2
	BSR.W	SetEditPtrCol
dmsskp2	BSR.W	StorePtrCol
dmsskp3	ST	DisableAnalyzer
	BSR.W	ClearAnaHeights
	BSR.W	ClearRightArea
	LEA	TopMenusPos,A0
	LEA	TopMenusBuffer,A1
	MOVEQ	#44-1,D0
cgloop4	MOVEQ	#25-1,D1
cgloop5	MOVE.B	(A1)+,(A0)+
	MOVE.B	1099(A1),10239(A0)
	DBRA	D1,cgloop5
	LEA	15(A0),A0
	DBRA	D0,cgloop4
	BSR.W	RedrawToggles
	BSR.W	DrawPlaybackCounter
	TST.B	EdEnable
	BNE.W	EditOp
	MOVEQ	#0,D4
RedrawAnaScope
	MOVE.W	#145,D0
	BSR.W	WaitForVBlank
	SF	ScopeEnable
	ST	DisableAnalyzer
	BSR.W	ClearRightArea
	LEA	SpectrumAnaData,A0
	MOVE.L	#SpectrumAnaSize,D0
	TST.B	AnaScopFlag
	BEQ.B	cgjojo
	LEA	ScopeData,A0
	MOVE.L	#ScopeSize,D0
	
cgjojo	BSR.W	Decompact
	BEQ.B	cgjaja
	LEA	SpectrumAnaPos,A0
	MOVEQ	#1,D7
cgloop1	MOVEQ	#55-1,D6	; 55 lines in picture.
cgloop2	MOVEQ	#25-1,D5	; 25 bytes(x8)
cgloop3	MOVE.B	(A1)+,(A0)+
	DBRA	D5,cgloop3
	ADDQ	#1,A1
	LEA	15(A0),A0
	DBRA	D6,cgloop2
	LEA	8040(A0),A0
	DBRA	D7,cgloop1
	BSR.W	FreeDecompMem
cgjaja	TST.L	D4
	BNE.W	Return1
	TST.B	AnaScopFlag
	BNE.B	cgscope
	BSR.W	ClearAnaHeights
	BSR.B	ClearRightArea
	SF	DisableAnalyzer
	BRA.W	SetAnalyzerColors
cgscope	ST	ScopeEnable
	BRA.W	ClearAnalyzerColors
	
;---- Clear Areas ----

ClearFileNames
	MOVE.W	#145,D0
	BSR.W	WaitForVBlank
	LEA	TextBitplane+1800,A1
	MOVE.W	#550-1,D0
	MOVEQ	#0,D1
cfnloop	MOVE.L	D1,(A1)+
	DBRA	D0,cfnloop
	RTS

ClearRightArea
	LEA	TextBitplane+55,A0
	MOVEQ	#0,D2
	MOVEQ	#99-1,D0
cnblloop1
	MOVEQ	#25-1,D1
cnblloop2
	MOVE.B	D2,(A0)+
	DBRA	D1,cnblloop2
	LEA	15(A0),A0
	DBRA	D0,cnblloop1
	RTS

Clear100Lines
	LEA	TextBitplane,A0
	MOVE.W	#1000-1,D0
	MOVEQ	#0,D1
chlloop	MOVE.L	D1,(A0)+
	DBRA	D0,chlloop
	RTS
	
;---- Are You Sure Requester ----

AreYouSure
	MOVE.L	A0,LastAreYouSureTextPtr
	ST	DisableScopeMuting
	MOVE.B	DisableAnalyzer,SaveDA
	MOVE.B	ScopeEnable(PC),SaveScope
	SF	ScopeEnable
	JSR	ShowStatusText
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	BSR.W	Wait_4000
	CMP.W	#1,CurrScreen
	BNE.B	aysskip
	TST.B	DisableAnalyzer
	BNE.B	aysskip
	ST	DisableAnalyzer
	BSR.W	ClearAnaHeights
	BSR.W	ClearRightArea
aysskip	LEA	SureBoxData,A1
	BSR.W	SwapBoxMem
	BSR.W	WaitForButtonUp
	BSR.W	Wait_4000
	CLR.B	RawKeyCode
surebuttoncheck
	ST	AskBoxShown
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	SureAnswerNo
	BSR.W	CheckPatternRedraw2
	BSR.W	DoKeyBuffer
	MOVE.B	RawKeyCode,D0
	CMP.B	#21,D0 ; Pressed Y
	BEQ.W	SureAnswerYes
	CMP.B	#68,D0 ; Pressed Return
	BEQ.W	SureAnswerYes
	CMP.B	#54,D0 ; Pressed N
	BEQ.B	SureAnswerNo
	CMP.B	#69,D0 ; Pressed Esc
	BEQ.B	SureAnswerNo
	BTST	#6,$BFE001	; left mouse button
	BNE.B	surebuttoncheck
	MOVE.W	MouseX(PC),D0
	MOVE.W	MouseY(PC),D1
	CMP.W	#$AB,D0
	BLO.B	surebuttoncheck
	CMP.W	#$FC,D0
	BHI.B	surebuttoncheck
	CMP.W	#$48,D1
	BLO.B	surebuttoncheck
	CMP.W	#$52,D1
	BHI.B	surebuttoncheck
	CMP.W	#$C5,D0
	BLO.B	SureAnswerYes
	CMP.W	#$EA,D0
	BLO.B	surebuttoncheck
SureAnswerNo	
	LEA	SureBoxData,A1
	BSR.W	SwapBoxMem
	JSR	ShowAllRight
	BSR.W	ClearAnaHeights
	MOVE.B	SaveDA,DisableAnalyzer
	MOVE.B	SaveScope,ScopeEnable
	; --PT2.3D change: don't show busy mouse on 15 sample .mod loading
	MOVE.L	LastAreYouSureTextPtr(PC),A0
	LEA	Loadas31Text(PC),A1
	CMP.L	A0,A1	
	BEQ.B	noBusyCursor
	BSR.W	ErrorRestoreCol
noBusyCursor
	; ----------------------------------------------------------------
	BSR.W	WaitForButtonUp
	BSR.W	Wait_4000
	CLR.B	RawKeyCode
	MOVEQ	#-1,D0
	SF	AskBoxShown
	RTS
	
	CNOP 0,4
LastAreYouSureTextPtr	dc.l 0

SureAnswerYes
	LEA	SureBoxData,A1
	BSR.B	SwapBoxMem
	JSR	ShowAllRight
	BSR.W	ClearAnaHeights
	MOVE.B	SaveDA,DisableAnalyzer
	MOVE.B	SaveScope,ScopeEnable
	BSR.W	RestorePtrCol
	BSR.B	WaitForButtonUp
	BSR.W	Wait_4000
	CLR.B	RawKeyCode
	MOVEQ	#0,D0
	SF	AskBoxShown
	SF	DisableScopeMuting
	RTS

SwapBoxMem
	LEA	SureBoxPos,A0
	MOVEQ	#39-1,D0
ssbmloop1
	MOVEQ	#13-1,D1
ssbmloop2
	MOVE.B	10240(A0),D2
	MOVE.B	546(A1),10240(A0)
	MOVE.B	D2,546(A1)
	MOVE.B	(A0),D2
	MOVE.B	(A1),(A0)+
	MOVE.B	D2,(A1)+
	DBRA	D1,ssbmloop2
	LEA	$001B(A0),A0
	ADDQ	#1,A1
	DBRA	D0,ssbmloop1
	LEA	TextBitplane+2100,A0
	LEA	TextDataBuffer,A1
	MOVEQ	#39-1,D0
ssbmloop3
	MOVEQ	#13-1,D1
ssbmloop4
	MOVE.B	(A0),D2
	MOVE.B	(A1),(A0)+
	MOVE.B	D2,(A1)+
	DBRA	D1,ssbmloop4
	LEA	$1B(A0),A0
	ADDQ	#1,A1
	DBRA	D0,ssbmloop3
	RTS

WaitForButtonUp
	BTST	#6,$BFE001	; left mouse button
	BEQ.B	WaitForButtonUp
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	WaitForButtonUp
	MOVE.W	#$91,D0
WaitForVBlank
	MOVE.L	$DFF004,D1
	LSR.L	#8,D1
	AND.W	#$1FF,D1
	CMP.W	D1,D0
	BNE.B	WaitForVBlank
	RTS
	
;---- Set Pointercolors ----

SetDeletePtrCol
	MOVE.L	A6,-(SP)
	MOVE.L	CopListColorPtr(PC),A6
	MOVE.W	#$0AA,2(A6)
	MOVE.W	#$077,6(A6)
	MOVE.W	#$044,10(A6)
	MOVE.L	(SP)+,A6
	RTS

SetNormalPtrCol
	MOVE.L	A6,-(SP)
	MOVE.L	CopListColorPtr(PC),A6
	MOVE.W	#$0AAA,2(A6)
	MOVE.W	#$0777,6(A6)
	MOVE.W	#$0444,10(A6)
	MOVE.L	(SP)+,A6
	RTS

SetDiskPtrCol
	MOVE.L	A6,-(SP)
	MOVE.L	CopListColorPtr(PC),A6
	MOVE.W	#$0A0,2(A6)
	MOVE.W	#$070,6(A6)
	MOVE.W	#$040,10(A6)
	MOVE.L	(SP)+,A6
	RTS

SetPlayPtrCol
	MOVE.L	A6,-(SP)
	MOVE.L	CopListColorPtr(PC),A6
	MOVE.W	#$AA0,2(A6)
	MOVE.W	#$770,6(A6)
	MOVE.W	#$440,10(A6)
	MOVE.L	(SP)+,A6
	RTS

SetEditPtrCol
	MOVE.L	A6,-(SP)
	MOVE.L	CopListColorPtr(PC),A6
	MOVE.W	#$05B,2(A6)
	MOVE.W	#$049,6(A6)
	MOVE.W	#$006,10(A6)
	MOVE.L	(SP)+,A6
	RTS

SetWaitPtrCol
	MOVE.L	A6,-(SP)
	MOVE.L	CopListColorPtr(PC),A6
	MOVE.W	#$A5A,2(A6)
	MOVE.W	#$727,6(A6)
	MOVE.W	#$404,10(A6)
	MOVE.L	(SP)+,A6
	RTS

SetErrorPtrCol
	MOVE.L	A6,-(SP)
	MOVE.L	CopListColorPtr(PC),A6
	MOVE.W	#$C00,2(A6)
	MOVE.W	#$900,6(A6)
	MOVE.W	#$700,10(A6)
	MOVE.L	(SP)+,A6
	ST	UpdateFreeMem
	BSR.B	WaitALittle
	JSR	ShowAllRight
	BSR.W	SetNormalPtrCol
	SF	DisableScopeMuting	; kludge
	MOVEQ	#0,D0
	RTS

WaitALittle
	MOVEQ	#0,D1
	MOVE.W	WaitTime(PC),D1
	BNE.B	WaitD1
	MOVEQ	#1,D1
WaitD1	AND.L	#$FFFF,D1		; 8bb: just in case...
	MOVEM.L	D0/A0-A1/A6,-(SP)
	MOVE.L	DOSBase,A6
	JSR	_LVODelay(A6)
	MOVEM.L	(SP)+,D0/A0-A1/A6
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	RTS

WaitTime	dc.w ERR_WAIT_TIME

StorePtrCol
	MOVE.L	A6,-(SP)
	MOVE.L	CopListColorPtr(PC),A6
	MOVE.W	2(A6),PointerCol1Save
	MOVE.W	6(A6),PointerCol2Save
	MOVE.W	10(A6),PointerCol3Save
	MOVE.L	(SP)+,A6
	RTS

ErrorRestoreCol
	BSR.W	SetErrorPtrCol
RestorePtrCol
	MOVE.L	A6,-(SP)
	ST	UpdateFreeMem
	MOVE.L	CopListColorPtr(PC),A6
	MOVE.W	PointerCol1Save,2(A6)
	MOVE.W	PointerCol2Save,6(A6)
	MOVE.W	PointerCol3Save,10(A6)
	MOVE.L	(SP)+,A6
	RTS
	
	
;---- Check special keys ----

CheckPlayKeys
	MOVE.B	RawKeyCode,D0
	CMP.B	#101,D0
	BEQ.W	PlaySong
	CMP.B	#103,D0
	BEQ.W	PlayPattern
	CMP.B	#64,D0
	BNE.B	cpkskip
	TST.L	RunMode
	BNE.W	StopIt
	TST.L	EditMode
	BNE.W	StopIt
	BRA.W	Edit
cpkskip
	CMP.B	#97,D0
	BEQ.W	RecordPattern
	CMP.B	#69,D0
	BEQ.W	EscPressed
	CMP.B	#66,D0
	BEQ.W	TabulateCursor
	;CMP.B	#127,D0	(8bb: probably broke in PT2.3...)
	;BEQ.W	GotoCLI
	CMP.B	#48,D0
	BEQ.W	TurnOffVoices
	CMP.B	#42,D0
	BEQ.W	DecAutoInsSlot
	CMP.B	#43,D0
	BEQ.W	IncAutoInsSlot
	CMP.B	#60,D0
	BEQ.W	KillSample
	CMP.B	#13,D0
	BEQ.W	togglepnote
	
	CMP.B	#67,D0
	BEQ.B	ToggleHiLoInstr
	MOVE.W	HiLowInstr,D1
	LEA	kpinstable(PC),A0
	MOVEQ	#0,D2
kpinsloop
	CMP.B	(A0,D2.W),D0
	BEQ.B	kpinsfound
	ADDQ.W	#1,D2
	CMP.W	#16,D2
	BLO.B	kpinsloop
	RTS

kpinsfound
	ADD.W	D2,D1
	BEQ.B	insnull
	BRA.B	redrsa2

ToggleHiLoInstr
	BCHG	#4,HiLowInstr+1
	MOVE.W	InsNum,D1
	BCHG	#4,D1
	BRA.B	redrsa2

ShiftOn
	MOVE.W	#1,ShiftKeyStatus
	RTS

redrsa3	MOVE.W	D1,InsNum
redrsam	CLR.B	RawKeyCode
	CLR.L	SavSamInf
	JSR	ShowSampleInfo
	JMP	RedrawSample

insnull	TST.W	InsNum
	BEQ.B	insnul2
	MOVE.W	InsNum,LastInsNum
	CLR.W	InsNum
	MOVEQ	#0,D1
	BRA.B	redrsa2

insnul2	JMP	ShowSampleInfo

kpinstable
	dc.b 15,90,91,92
	dc.b 93,61,62,63,74
	dc.b 45,46,47,94,29,30
	dc.b 31
	EVEN

redrsa2
	TST.B	pnoteflag
	BEQ.B	redrsa3
	CLR.B	RawKeyCode
	TST.W	AltKeyStatus
	BNE.B	setpnote
	MOVE.W	D1,InsNum
	JSR	ShowSampleInfo
	MOVE.W	InsNum,D0
	ADD.W	D0,D0
	MOVE.W	pnotetable(PC,D0.W),D0
	MOVEQ	#-1,D2
	BSR.W	playtheinstr
	JMP	RedrawSample

pnotetable
	dc.w 24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,24,24,24,24,24,24
	dc.w 24,24

setpnote
	ADD.W	D1,D1
	LEA	pnotetable(PC,D1.W),A0
	MOVE.L	A0,SplitAddress
	MOVE.W	#4,SamNoteType
	LEA	SelectNoteText(PC),A0
	JMP	ShowStatusText

SelectNoteText	dc.b "select note",0
	EVEN

togglepnote
	CLR.B	RawKeyCode
	MOVEQ	#0,D0
	MOVE.B	pnoteflag(PC),D0
	ADDQ.B	#1,D0
	CMP.B	#3,D0
	BLO.B	tpnskp
	MOVEQ	#0,D0
tpnskp	MOVE.B	D0,pnoteflag
	LEA	pnotechar(PC,D0.W),A0
	MOVEQ	#1,D0
	MOVE.W	#5159,D1
	JMP	ShowText3

pnotechar	dc.b 32,128,129
pnoteflag	dc.b 0
	EVEN

;---- Check transpose keys ----

CheckTransKeys
	TST.W	LeftAmigaStatus
	BEQ.W	Return1
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	MOVE.B	RawKeyCode,D1
	CLR.B	RawKeyCode
	MOVE.B	SampleAllFlag(PC),-(SP)
	BSR.B	ctksub
	MOVE.B	(SP)+,SampleAllFlag
	RTS

ctksub	MOVEQ	#0,D0
	SF	SampleAllFlag
	CMP.B	#1,D1
	BEQ.W	NoteUp
	CMP.B	#16,D1
	BEQ.W	NoteDown
	CMP.B	#32,D1
	BEQ.W	OctaveUp
	CMP.B	#49,D1
	BEQ.W	OctaveDown
	
	MOVE.W	#300,D0
	CMP.B	#2,D1
	BEQ.W	NoteUp
	CMP.B	#17,D1
	BEQ.W	NoteDown
	CMP.B	#33,D1
	BEQ.W	OctaveUp
	CMP.B	#50,D1
	BEQ.W	OctaveDown
	
	MOVEQ	#0,D0
	ST	SampleAllFlag
	CMP.B	#3,D1
	BEQ.W	NoteUp
	CMP.B	#18,D1
	BEQ.W	NoteDown
	CMP.B	#34,D1
	BEQ.W	OctaveUp
	CMP.B	#51,D1
	BEQ.W	OctaveDown
	
	MOVE.W	#300,D0
	CMP.B	#4,D1
	BEQ.W	NoteUp
	CMP.B	#19,D1
	BEQ.W	NoteDown
	CMP.B	#35,D1
	BEQ.W	OctaveUp
	CMP.B	#52,D1
	BEQ.W	OctaveDown
	RTS
	
;---- Check control keys ----

CheckCtrlKeys
	TST.W	CtrlKeyStatus
	BEQ.W	Return1
	MOVEQ	#0,D0
	MOVE.B	RawKeyCode,D0
	CMP.B	#35,D0 ; F
	BEQ.W	ToggleFilter
	CMP.B	#33,D0 ; S
	BEQ.W	ToggleSplit
	CMP.B	#55,D0 ; M
	BEQ.W	ToggleMultiMode
	CMP.B	#16,D0 ; Q
	BEQ.W	UnmuteAll
	CMP.B	#32,D0 ; A
	BEQ.W	ToggleMute
	CMP.B	#49,D0 ; Z
	BEQ.W	RestoreEffects
	CMP.B	#19,D0 ; R
	BEQ.W	RestoreFKeyPos
	CMP.B	#20,D0 ; T
	BEQ.W	SwapTrack
	CMP.B	#53,D0 ; B
	BEQ.W	BeginBlock
	CMP.B	#51,D0 ; C
	BEQ.W	CopyBlock
	CMP.B	#50,D0 ; X
	BEQ.W	CutBlock
	CMP.B	#34,D0 ; D
	BEQ.W	DeleteBlock
	CMP.B	#25,D0 ; P
	BEQ.W	PasteBlock
	CMP.B	#23,D0 ; I
	BEQ.W	InsertBlock
	CMP.B	#38,D0 ; J
	BEQ.W	JoinPasteBlock
	CMP.B	#54,D0 ; N
	BEQ.W	Re_MarkBlock
	CMP.B	#21,D0 ; Y
	BEQ.W	BackwardsBlock
	CMP.B	#17,D0 ; W
	BEQ.W	PolyphonizeBlock	
	CMP.B	#18,D0 ; E
	BEQ.W	ExpandTrack
	CMP.B	#24,D0 ; O
	BEQ.W	ContractTrack
	CMP.B	#37,D0 ; H
	BEQ.W	TransBlockUp
	CMP.B	#40,D0 ; L
	BEQ.W	TransBlockDown
	CMP.B	#39,D0 ; K
	BEQ.W	KillToEndOfTrack
	CMP.B	#22,D0 ; U
	BEQ.W	UndoLastChange	
	CMP.B	#68,D0 ; CR
	BEQ.W	InsCmdTrack
	CMP.B	#65,D0 ; Del
	BEQ.W	DelCmdTrack
	
	CMP.B	#1,D0
	BLO.W	Return1
	CMP.B	#10,D0
	BHI.W	Return1
	BNE.B	cckskip
	MOVEQ	#0,D0
cckskip	MOVE.W	D0,EditMoveAdd
	CLR.B	RawKeyCode
	ADD.B	#'0',D0
	LEA	ematext(PC),A0
	MOVE.B	D0,11(A0)
	JSR	ShowStatusText
	BSR.W	Show_MS
	MOVE.W	#20,WaitTime
	BSR.W	WaitALittle
	JMP	ShowAllRight

ematext	dc.b	'editskip = 0',0
	EVEN

;---- Check alt keys ----

TogglePosEdScreen
	CMP.W	#3,CurrScreen
	BEQ.W	Return2	; if Disk Op. is shown
	BRA.W	PosEd

ToggleRecMode
	EOR.B	#1,RecordMode
	BEQ.B	trmSkip
	LEA	RecSongText(PC),A0
	BRA.B	trmShow
trmSkip
	LEA	RecPattText(PC),A0
trmShow
	JSR	ShowStatusText	
	; update rec mode string in edit op. #2 (if shown)
	CMP.W	#1,CurrScreen
	BNE.B	trmEnd
	CMP.B	#2,EdScreen
	BNE.B	trmEnd
	BSR.W	ShowRecordMode
trmEnd
	BSR.W	WaitALittle
	JSR	ShowAllRight
	RTS

RecPattText	dc.b 'rec mode: patt',0
RecSongText	dc.b 'rec mode: song',0
	EVEN

CheckAltKeys
	TST.W	AltKeyStatus
	BEQ.W	Return1
	MOVEQ	#0,D0
	MOVE.B	RawKeyCode,D0
	CMP.B	#49,D0 ; Z
	BEQ.W	ToggleCh1
	CMP.B	#50,D0 ; X
	BEQ.W	ToggleCh2
	CMP.B	#51,D0 ; C
	BEQ.W	ToggleCh3
	CMP.B	#52,D0 ; V
	BEQ.W	ToggleCh4
	CMP.B	#53,D0 ; B
	BEQ.B	xBoost
	CMP.B	#35,D0 ; F
	BEQ.B	xFilter
	CMP.B	#20,D0 ; T
	BEQ.B	xTuningTone
	CMP.B	#33,D0 ; S
	BEQ.B	xSamplerScreen
	CMP.B	#19,D0 ; R
	BEQ.B	xResample
	CMP.B	#18,D0 ; E
	BEQ.W	DoEditOp
	CMP.B	#23,D0 ; I
	BEQ.W	AutoInsert
	CMP.B	#34,D0 ; D
	BEQ.W	DiskOp
	CMP.B	#39,D0 ; K
	BEQ.W	KillInstrTrack
	CMP.B	#32,D0 ; A
	BEQ.B	xSampler
	CMP.B	#16,D0 ; Q
	BEQ.W	ChkQuit
	CMP.B	#21,D0 ; Y
	BEQ.W	SaveAllSamples
	CMP.B	#55,D0 ; M
	BEQ.W	ToggleMetroFlag
	CMP.B	#25,D0 ; P	(new in PT2.3E)
	BEQ.W	TogglePosEdScreen
	CMP.B	#36,D0 ; G	(new in PT2.3E)
	BEQ.W	ToggleRecMode	
	RTS

xFilter		JMP	Filter
xBoost		JMP	Boost
xTuningTone	JMP	TuningTone
xSamplerScreen	JMP	SamplerScreen
xResample	JMP	Resample
xSampler	JMP	Sampler

;---- List Quick Jump Routines (SHIFT+alphanumeric) ----

CheckListQuickJump
	TST.W	AltKeyStatus
	BNE.W	Return1
	TST.W	CtrlKeyStatus
	BNE.W	Return1
	TST.W	LeftAmigaStatus
	BNE.W	Return1
	TST.W	ShiftKeyStatus
	BEQ.W	Return1
	CMP.W	#3,CurrScreen
	BEQ.B	DiskOpQuickJump
	CMP.W	#6,CurrScreen
	BEQ.W	PLSTQuickJump
	CMP.W	#4,CurrScreen
	BEQ.W	PEDQuickJump
	RTS

GetASCIIKey
	MOVEQ	#0,D1
	MOVE.B	RawKeyCode,D1
	BEQ.B	gakskip
	BTST	#7,D1
	BNE.B	gakskip
	LEA	UnshiftedKeymap,A4
	AND.W	#$7F,D1
	CMP.B	#64,D1
	BHI.B	gakskip
	MOVE.B	(A4,D1.W),D1
	CLR.B	RawKeyCode
	RTS
gakskip
	MOVEQ	#-1,D1
	RTS

DiskOpQuickJump
	BSR.B	GetASCIIKey
	BMI.W	Return1
	LEA	FileNamesPtr(PC),A5
	MOVE.L	(A5),A1
	MOVEQ	#-36,D0
	BSR.W	lbC0039E8
doqjloop
	ADD.L	#36,D0
	MOVE.W	16(A5),D2
	SUBQ.W	#8,D2
	BMI.W	Return1
	MULU.W	#36,D2
	CMP.L	D2,D0
	BLS.B	doqjskip
	MOVE.L	D2,D0
	DIVU.W	#36,D0
	BSR.W	RedrawFileNames
	BRA.W	ErrorRestoreCol
doqjskip
	MOVE.B	(A1,D0.L),D2
	TST.W	DirPathNum
	BNE.B	doqjskip2
	CMP.L	#'mod.',(A1,D0.L)
	BNE.B	doqjloop
	MOVE.B	4(A1,D0.L),D2
doqjskip2
	BSR.W	lbC0039F0
	CMP.B	D1,D2
	BNE.B	doqjloop
	DIVU.W	#36,D0
	BRA.W	RedrawFileNames

PLSTQuickJump
	BSR.W	GetASCIIKey
	BMI.W	Return1
	TST.W	lbW010D56
	BNE.W	Return1
	MOVE.L	PLSTmem,A1
	MOVEQ	#-30,D0
	BSR.W	lbC0039E8
plstqjloop
	ADD.L	#30,D0
	MOVE.W	PresetMarkTotal,D2
	SUB.W	#12,D2
	BMI.W	Return1
	MULU.W	#30,D2
	CMP.L	D2,D0
	BLS.B	plstqjskip
	MOVE.L	D2,D0
	DIVU.W	#30,D0
	JSR	lbC010F82
	BRA.W	ErrorRestoreCol
plstqjskip
	MOVE.B	6(A1,D0.L),D2
	BSR.W	lbC0039F0
	CMP.B	D1,D2
	BNE.B	plstqjloop
	DIVU.W	#30,D0
	JMP	lbC010F82

PEDQuickJump
	BSR.W	GetASCIIKey
	BMI.W	Return1
	MOVE.L	PLSTmem,A1
	MOVEQ	#-30,D0
pedqjloop
	ADD.L	#30,D0
	MOVEQ	#0,D2
	MOVE.W	PresetTotal,D2
	SUB.W	#10,D2
	BMI.W	Return1
	MULU.W	#30,D2
	CMP.L	D2,D0
	BLS.B	pedqjskip
	MOVE.L	D2,D0
	DIVU.W	#30,D0
	JSR	pdodsx
	BRA.W	ErrorRestoreCol
pedqjskip
	MOVE.B	6(A1,D0.L),D2
	CMP.B	D1,D2
	BNE.B	pedqjloop
	DIVU.W	#30,D0
	MOVE.W	D0,PEDpos
	JMP	ShowPresetNames

;----

ToggleMetroFlag
	CLR.B	RawKeyCode
	TST.W	ShiftKeyStatus
	BNE.B	SetMetroChannel
	EOR.B	#1,MetroFlag
	BRA.W	Show_MS

SetMetroChannel
	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	ADDQ.W	#1,D0
	MOVE.B	D0,MetroChannel
	CMP.W	#1,CurrScreen
	BNE.W	Return1
	TST.B	EdEnable
	BEQ.W	Return1
	CMP.B	#2,EdScreen
	BNE.W	Return1
	BRA.W	ShowMetronome

AutoInsert	
	CLR.B	RawKeyCode
	EOR.B	#1,AutoInsFlag
ShowAutoInsert
	CMP.W	#4,CurrScreen
	BEQ.W	Return1
	MOVE.W	#"  ",D0
	TST.B	AutoInsFlag
	BEQ.B	auins2
	MOVE.B	#'I',D0
	LSL.W	#8,D0
	MOVE.B	AutoInsSlot,D0
	ADD.B	#'1',D0
	CMP.B	#'9'+1,D0
	BNE.B	auins2
	MOVE.B	#'0',D0
auins2	MOVE.W	D0,AutoInsText
	MOVE.W	#4560,D1
	MOVEQ	#2,D0
	LEA	AutoInsText(PC),A0
	JMP	ShowText3

AutoInsText	dc.w	0
AutoInsFlag	dc.b	0
MetroFlag	dc.b	0
	EVEN
	
DecAutoInsSlot
	CLR.B	RawKeyCode
	TST.B	AutoInsFlag
	BEQ.W	Return1
	MOVE.B	AutoInsSlot,D0
	SUBQ.B	#1,D0
	TST.W	ShiftKeyStatus
	BEQ.B	daisskip
	SUBQ.B	#3,D0
daisskip
	TST.B	D0
	BMI.B	daisskip3
daisskip2
	MOVE.B	D0,AutoInsSlot
	BRA.W	Show_MS
daisskip3
	MOVEQ	#0,D0
	BRA.B	daisskip2

IncAutoInsSlot
	CLR.B	RawKeyCode
	TST.B	AutoInsFlag
	BEQ.W	Return1
	MOVE.B	AutoInsSlot,D0
	ADDQ.B	#1,D0
	TST.W	ShiftKeyStatus
	BEQ.B	iaisskip
	ADDQ.B	#3,D0
iaisskip
	CMP.B	#9,D0
	BLE.B	iaisskip2
	MOVEQ	#9,D0
iaisskip2
	MOVE.B	D0,AutoInsSlot
	BRA.W	Show_MS

SaveInstr	dc.w 0

SaveAllSamples
	LEA	SaveAllSamplesText(PC),A0
	BSR.W	AreYouSure
	BNE.B	sarts
	MOVE.W	InsNum,SaveInstr
	MOVE.W	#1,InsNum
.loop	JSR	ShowSampleInfo
	BSR.W	dosavesample
	ADDQ.W	#1,InsNum
	CMP.W	#32,InsNum
	BLO.B	.loop
	MOVE.W	SaveInstr(PC),InsNum
	JMP	ShowSampleInfo
sarts
	RTS
	
SaveAllSamplesText
	dc.b	"save all samples?",0
	EVEN

;---- Jump between channels ----

TabulateCursor
	CLR.B	RawKeyCode
	TST.W	ShiftKeyStatus
	BNE.B	TabCurRight
	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	ADDQ.W	#1,D0
	CMP.W	#4,D0
	BNE.B	tacskip
	MOVEQ	#0,D0
tacskip	MULU.W	#6,D0
	MOVE.W	D0,PattCurPos
	BRA.W	UpdateCursorPos

TabCurRight
	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	ADDQ.W	#5,D0
	DIVU.W	#6,D0
	SUBQ.W	#1,D0
	BPL.B	tacskip
	MOVEQ	#3,D0
	BRA.B	tacskip
	
;---- Escape was pressed ----

EscPressed	CLR.B	RawKeyCode
	CLR.B	SaveKey
	MOVE.W	CurrScreen,D0
	CMP.W	#2,D0
	BLO.B	BotExit
TopExit	MOVE.W	CurrScreen,D0
	CMP.W	#2,D0
	BEQ.W	ExitHelpScreen
	CMP.W	#3,D0
	BEQ.W	ExitFromDir
	CMP.W	#4,D0
	BEQ.B	pedexit
	CMP.W	#5,D0
	BEQ.W	ExitSetup
	CMP.W	#6,D0
	BEQ.B	plstexit
	CMP.W	#7,D0
	BEQ.W	ExitSetup
	CMP.W	#8,D0
	BEQ.B	plstexit
	RTS

BotExit	TST.W	SamScrEnable
	BNE.B	samplerexit
	TST.W	BlockMarkFlag
	BNE.W	blkunma
	CMP.W	#1,CurrScreen
	BNE.W	Return1
	TST.B	EdEnable
	BNE.W	ExitEditOp
	RTS

samplerexit
	 JMP	ExitFromSam
pedexit	 JMP	PED_Exit
plstexit JMP	ExitPLST

GotoCLI	CLR.B	RawKeyCode
	CLR.B	SaveKey
	TST.L	RunMode
	BNE.B	gcliskip
	BSR.W	StopIt
	BSR.W	ResetMusicInt
gcliskip	BSR.W	WorkbenchToFront
	MOVE.L	ExtCmdAddress(PC),D1
	BEQ.B	gcliskip2
	CLR.L	ExtCmdAddress
	MOVE.L	ExtCmdWindow(PC),D2
	MOVEQ	#0,D3
	MOVE.L	DOSBase,A6
	JSR	_LVOExecute(A6)
gcliskip2	ADDQ.B	#1,LastRawkey
	TST.L	RunMode
	BNE.B	gcliskip3
	BSR.W	SetMusicInt
gcliskip3
	BRA.W	PTScreenToFront

;---- Check Help Key ----

HelpSelectText	dc.b	'* help selected *',0
PLSTSelectText	dc.b	'* plst selected *',0
PLSTHelpFlag	dc.b	0 ; free 0
	EVEN
	
CheckHelpKey
	CMP.B	#95,RawKeyCode	; Help Key pressed ?
	BNE.W	Return1
	CLR.B	RawKeyCode
	TST.W	ShiftKeyStatus
	BEQ.B	realhlp
	LEA	HelpSelectText(PC),A0
	EOR.B	#1,PLSTHelpFlag
	BEQ.B	chksel
	LEA	PLSTSelectText(PC),A0
chksel	JSR	ShowStatusText
	BSR.W	WaitALittle
	JMP	ShowAllRight

gtoPLST	JMP	PLST

realhlp	TST.B	PLSTHelpFlag
	BNE.B	gtoPLST
	CMP.W	#2,CurrScreen
	BEQ.W	ExitHelpScreen
	BSR.W	TopExit
	MOVE.W	CurrScreen,SaveCurrScreen
	SF	ScopeEnable
	ST	DisableAnalyzer
	ST	NoSampleInfo
	BSR.W	ClearAnalyzerColors
	BSR.W	SwapHelpScreen
	BEQ.W	exithlp
	BSR.W	Clear100Lines
	TST.L	HelpTextIndex+4
	BNE.B	chkskip
	BSR.W	GetHelpIndex
chkskip	MOVE.L	#HelpFileName,D1
	MOVE.L	#1005,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BNE.W	ShowHelpPage
	LEA	PTPath,A0
	BSR.W	CopyPath
	LEA	HelpFileName(PC),A0
	MOVEQ	#8-1,D0
hefilop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,hefilop
	MOVE.L	#FileName,D1
	MOVE.L	#1005,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.W	HelpFileError
	BRA.B	ShowHelpPage

ExitHelpScreen
	MOVE.L	FileHandle,D1
	BEQ.B	ehsskip
	MOVE.L	DOSBase,A6
	JSR	_LVOClose(A6)
ehsskip	BSR.W	Clear100Lines
	BSR.B	SwapHelpScreen
exithlp	MOVE.W	SaveCurrScreen,CurrScreen
	BRA.W	DisplayMainAll

SwapHelpScreen
	MOVE.L	DecompMemPtr,D0
	BEQ.B	shelps2
	MOVE.L	D0,A1
	BSR.W	ssets3
	BRA.W	FreeDecompMem
shelps2 LEA	HelpScreenData,A0
	MOVE.L	#HelpScreenSize,D0
	BSR.W	Decompact
	BEQ.W	Return1
ssets3
	LEA	BitplaneData,A0
	MOVEQ	#2-1,D2
sxloop1	MOVE.W	#1000-1,D0
sxloop2	MOVE.L	(A0),D1
	MOVE.L	(A1),(A0)+
	MOVE.L	D1,(A1)+
	DBRA	D0,sxloop2
	LEA	6240(A0),A0
	DBRA	D2,sxloop1
	RTS

ShowHelpPage
	MOVE.W	#2,CurrScreen
	MOVE.W	HelpPage(PC),D0
	AND.W	#$00FF,D0
	LSL.W	#2,D0
	LEA	HelpTextIndex,A0
	MOVE.L	FileHandle,D1
	BEQ.W	Return1
	MOVE.L	(A0,D0.W),D2
	ADD.L	#1024,D2
	MOVEQ	#-1,D3
	MOVE.L	DOSBase,A6
	JSR	_LVOSeek(A6)
	MOVE.L	FileHandle,D1
	MOVE.L	#HelpTextData,D2
	MOVE.L	#656,D3
	JSR	_LVORead(A6)
	BSR.W	Clear100Lines
	LEA	HelpTextData+16,A6
	MOVEQ	#120,D6
	MOVEQ	#16-1,D7
shploop	MOVEQ	#0,D0
	MOVE.L	A6,A1
shplop2	CMP.B	#10,(A1)+
	BEQ.B	ShowHelpLine
	TST.B	-1(A1)
	BEQ.B	ShowHelpLine
	ADDQ.W	#1,D0
	BRA.B	shplop2
ShowHelpLine
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A1,A6
	MOVE.W	D6,TextOffset
	MOVE.W	D0,TextLength
	BEQ.B	shlskip
	JSR	ShowText
shlskip	ADD.W	#240,D6
	DBRA	D7,shploop
	BSR.W	Wait_4000
	BRA.W	Wait_4000

HelpPage	dc.w	1

HelpUp  LEA	HelpTextData+7,A0
	BRA.B	HelpMove
HelpDown
	LEA	HelpTextData+10,A0
	BRA.B	HelpMove
HelpLeft
	LEA	HelpTextData+4,A0
	BRA.B	HelpMove
HelpRight
	LEA	HelpTextData+13,A0
HelpMove	CLR.B	RawKeyCode
	MOVEQ	#0,D0
	JSR	HexToInteger2
	TST.W	D0
	BEQ.W	Return1
	AND.W	#$00FF,D0
	MOVE.W	D0,HelpPage
	BRA.W	ShowHelpPage

GetHelpIndex
	MOVE.L	LaHeTx,D0
	CMP.L	HelpTextIndex,D0
	BEQ.W	Return1
	MOVE.L	#HelpFileName,D1
	MOVE.L	#1005,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BNE.B	gehein
	LEA	PTPath,A0
	BSR.W	CopyPath
	LEA	HelpFileName(PC),A0
	MOVEQ	#8-1,D0
hefilp2	MOVE.B	(A0)+,(A1)+
	DBRA	D0,hefilp2
	MOVE.L	#FileName,D1
	MOVE.L	#1005,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.B	HelpFileError
gehein	MOVE.L	D0,D1
	MOVE.L	#HelpTextIndex,D2
	MOVE.L	#256*4,D3
	JSR	_LVORead(A6)
	MOVE.L	FileHandle,D1
	JSR	_LVOClose(A6)
	MOVE.L	HelpTextIndex,LaHeTx
	RTS

HelpFileError
	MOVE.W	#2,CurrScreen
	LEA	NoHelpText(PC),A0
	MOVE.W	#1887,D1
	MOVEQ	#24,D0
	JMP	ShowText3

NoHelpText	dc.b 'Unable to open helpfile!'
HelpFileName	dc.b 'PT.help',0
	EVEN

;---- Check Function Keys F6-F10 ----

CheckF6_F10
	CMP.B	#85,RawKeyCode
	BNE.B	CheckF7
	CLR.B	RawKeyCode
	TST.W	ShiftKeyStatus
	BEQ.B	cf6skip
	MOVE.W	ScrPattPos,F6pos
ShowPosSetText	LEA	PosSetText,A0
	JSR	ShowStatusText
	MOVEQ	#9-1,D2
spsloop	BSR.W	Wait_4000
	DBRA	D2,spsloop
	JMP	ShowAllRight
cf6skip	MOVE.W	F6pos(PC),D0
chkalt	TST.W	AltKeyStatus
	BNE.W	PattFrom
	TST.W	CtrlKeyStatus
	BNE.W	RecordFrom
	TST.W	LeftAmigaStatus
	BNE.W	SongFrom
	TST.W	RunMode
	BNE.W	Return1
	MOVE.W	D0,ScrPattPos
	BRA.W	SetScrPatternPos

CheckF7	CMP.B	#86,RawKeyCode
	BNE.B	CheckF8
	CLR.B	RawKeyCode
	TST.W	ShiftKeyStatus
	BEQ.B	cf7skip
	MOVE.W	ScrPattPos,F7pos
	BRA.B	ShowPosSetText
cf7skip	MOVE.W	F7pos(PC),D0
	BRA.B	chkalt

CheckF8	CMP.B	#87,RawKeyCode
	BNE.B	CheckF9
	CLR.B	RawKeyCode
	TST.W	ShiftKeyStatus
	BEQ.B	cf8skip
	MOVE.W	ScrPattPos,F8pos
	BRA.W	ShowPosSetText
cf8skip	MOVE.W	F8pos(PC),D0
	BRA.W	chkalt

CheckF9	CMP.B	#88,RawKeyCode
	BNE.B	CheckF10
	CLR.B	RawKeyCode
	TST.W	ShiftKeyStatus
	BEQ.B	cf9skip
	MOVE.W	ScrPattPos,F9pos
	BRA.W	ShowPosSetText
cf9skip	MOVE.W	F9pos(PC),D0
	BRA.W	chkalt

CheckF10
	CMP.B	#89,RawKeyCode
	BNE.W	Return1
	CLR.B	RawKeyCode
	TST.W	ShiftKeyStatus
	BEQ.B	cf10skip
	MOVE.W	ScrPattPos,F10pos
	BRA.W	ShowPosSetText
cf10skip	MOVE.W	F10pos(PC),D0
	BRA.W	chkalt

F6pos	dc.w  0
F7pos	dc.w 16
F8pos	dc.w 32
F9pos	dc.w 48
F10pos	dc.w 63

;---- Check Function Keys F3-F5 ----

CheckF3_F5
	MOVEQ	#0,D0
	MOVE.L	D0,A0
	TST.W	ShiftKeyStatus
	BNE.W	CCP4
	TST.W	CtrlKeyStatus
	BNE.W	CCP4
	TST.W	AltKeyStatus
	BNE.W	CutCopPas
	CMP.B	#68,RawKeyCode
	BEQ.B	StepPlayForward
	CMP.B	#65,RawKeyCode
	BEQ.B	StepPlayBackward
	TST.W	SamScrEnable
	BEQ.W	Return1
	CMP.B	#82,RawKeyCode
	BEQ.B	xSamCut
	CMP.B	#83,RawKeyCode
	BEQ.B	xSamCop
	CMP.B	#84,RawKeyCode
	BEQ.B	xSamPas
	RTS

xSamCut	JMP	SamCut
xSamCop	JMP	SamCopy
xSamPas	JMP	SamPaste

StepPlayForward
	MOVE.W	#1,StepPlayEnable
	BSR.W	DoStopIt
	MOVE.W	ScrPattPos,D0
	BSR.W	pafr1
spfloop
	BSR.W	Wait_4000
	TST.W	StepPlayEnable
	BNE.B	spfloop
	BRA.W	SetScrPatternPos

StepPlayBackward
	MOVE.W	#1,StepPlayEnable
	BSR.W	DoStopIt
	MOVE.W	ScrPattPos,D0
	BSR.W	pafr1
spbloop
	BSR.W	Wait_4000
	TST.W	StepPlayEnable
	BNE.B	spbloop
	MOVE.W	ScrPattPos,D0
	SUBQ.W	#2,D0
	AND.W	#63,D0
	MOVE.W	D0,ScrPattPos
	BRA.W	SetScrPatternPos

StepPlayEnable	dc.w	0

CCP4	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	AND.L	#3,D0
	LSL.L	#2,D0
	MOVE.L	D0,A0
CutCopPas
	ADD.L	SongDataPtr,A0
	LEA	sd_patterndata(A0),A0
	MOVE.L	PatternNumber,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	ADD.L	D0,A0
	TST.W	AltKeyStatus
	BNE.B	CutCopPasPatt
	TST.W	CtrlKeyStatus
	BNE.B	CutCopPasCmds
CutCopPasTrack
	CMP.B	#82,RawKeyCode
	BEQ.W	CutTrack
	CMP.B	#83,RawKeyCode
	BEQ.W	CopyTrack
	CMP.B	#84,RawKeyCode
	BEQ.W	PasteTrack
	CMP.B	#68,RawKeyCode
	BEQ.W	InsNoteTrack
	CMP.B	#65,RawKeyCode
	BEQ.W	DelNoteTrack
	RTS

CutCopPasPatt
	CMP.B	#82,RawKeyCode
	BEQ.B	CutPattern
	CMP.B	#83,RawKeyCode
	BEQ.B	CopyPattern
	CMP.B	#84,RawKeyCode
	BEQ.B	PastePattern
	CMP.B	#68,RawKeyCode
	BEQ.W	InsNotePattern
	CMP.B	#65,RawKeyCode
	BEQ.W	DelNotePattern
	RTS

CutCopPasCmds
	CMP.B	#82,RawKeyCode
	BEQ.W	CutCmds
	CMP.B	#83,RawKeyCode
	BEQ.W	CopyCmds
	CMP.B	#84,RawKeyCode
	BEQ.W	PasteCmds
	RTS

CutPattern
	BSR.W	SaveUndo
	LEA	PatternBuffer,A1
	MOVE.W	#256-1,D0
	MOVEQ	#0,D1
cupaloop
	MOVE.L	(A0),(A1)+
	MOVE.L	D1,(A0)+
	DBRA	D0,cupaloop
	CLR.B	RawKeyCode
	JMP	RedrawPattern

CopyPattern
	LEA	PatternBuffer,A1
	MOVE.W	#256-1,D0
copaloop
	MOVE.L	(A0)+,(A1)+
	DBRA	D0,copaloop
	CLR.B	RawKeyCode
	RTS

PastePattern
	BSR.W	SaveUndo
	LEA	PatternBuffer,A1
	MOVE.W	#256-1,D0
papaloop
	MOVE.L	(A1)+,(A0)+
	DBRA	D0,papaloop
	CLR.B	RawKeyCode
	JMP	RedrawPattern

CutTrack
	BSR.W	SaveUndo
	LEA	TrackBuffer,A1
	MOVEQ	#64-1,D0
	MOVEQ	#0,D1
cutrloop
	MOVE.L	(A0),(A1)+
	MOVE.L	D1,(A0)
	LEA	16(A0),A0
	DBRA	D0,cutrloop
	CLR.B	RawKeyCode
	JMP	RedrawPattern

CopyTrack
	LEA	TrackBuffer,A1
	MOVEQ	#64-1,D0
cotrloop
	MOVE.L	(A0),(A1)+
	LEA	16(A0),A0
	DBRA	D0,cotrloop
	CLR.B	RawKeyCode
	RTS

PasteTrack
	BSR.W	SaveUndo
	LEA	TrackBuffer,A1
	MOVEQ	#64-1,D0
patrloop
	MOVE.L	(A1)+,(A0)
	LEA	16(A0),A0
	DBRA	D0,patrloop
	CLR.B	RawKeyCode
	JMP	RedrawPattern

InsNotePattern
	BSR.W	SaveUndo
	MOVEQ	#0,D0
	BSR.W	GetPositionPtr
	BSR.B	inotr
	MOVEQ	#6,D0
	BSR.W	GetPositionPtr
	BSR.B	inotr
	MOVEQ	#12,D0
	BSR.W	GetPositionPtr
	BSR.B	inotr
	MOVEQ	#18,D0
	BSR.W	GetPositionPtr
	BSR.B	inotr
	BRA.B	intskip
InsNoteTrack
	BSR.W	SaveUndo
	BSR.B	inotr
intskip	CLR.B	RawKeyCode
	ADD.W	D2,ScrPattPos
	AND.W	#$3F,ScrPattPos
	BSR.W	SetScrPatternPos
	JMP	RedrawPattern

inotr	MOVE.W	ScrPattPos,D1
	LSL.W	#4,D1
	CMP.W	#63*16,D1
	BEQ.B	inoskip
	MOVE.W	#992,D0
intloop	MOVE.L	(A0,D0.W),16(A0,D0.W)
	SUB.W	#16,D0
	CMP.W	D1,D0
	BGE.B	intloop
inoskip	MOVEQ	#1,D2
	CLR.L	(A0,D1.W)
	RTS

InsCmdTrack
	BSR.W	SaveUndo
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	BSR.B	icmtr
	BRA.B	intskip
icmtr
	MOVE.W	ScrPattPos,D1
	LSL.W	#4,D1
	CMP.W	#63*16,D1
	BEQ.B	icmskip
	MOVE.W	#992,D0
icmloop	MOVE.W	2(A0,D0.W),D2
	AND.W	#$0FFF,D2
	AND.W	#$F000,18(A0,D0.W)
	OR.W	D2,18(A0,D0.W)
	SUB.W	#16,D0
	CMP.W	D1,D0
	BGE.B	icmloop
icmskip	MOVEQ	#1,D2
	AND.W	#$F000,2(A0,D1.W)
	RTS

DelNotePattern
	BSR.W	SaveUndo
	MOVEQ	#0,D0
	BSR.W	GetPositionPtr
	BSR.B	dnt
	MOVEQ	#6,D0
	BSR.W	GetPositionPtr
	BSR.B	dnt
	MOVEQ	#12,D0
	BSR.W	GetPositionPtr
	BSR.B	dnt
	MOVEQ	#18,D0
	BSR.W	GetPositionPtr
	BSR.B	dnt
	BRA.W	intskip
DelNoteTrack
	BSR.W	SaveUndo
	BSR.B	dnt
	BRA.W	intskip

dnt	MOVE.W	ScrPattPos,D0
	BEQ.W	Return1
	SUBQ.W	#1,D0
	LSL.W	#4,D0
dntloop	MOVE.L	16(A0,D0.W),(A0,D0.W)
	ADD.W	#16,D0
	CMP.W	#1024,D0
	BLO.B	dntloop
	MOVE.W	#1008,D1
	MOVEQ	#-1,D2
	CLR.L	(A0,D1.W)
	RTS

DelCmdTrack
	BSR.W	SaveUndo
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	BSR.B	dct
	BRA.W	intskip
dct MOVE.W	ScrPattPos,D0
	BEQ.W	Return1
	SUBQ.W	#1,D0
	LSL.W	#4,D0
dctloop	MOVE.W	18(A0,D0.W),D2
	AND.W	#$0FFF,D2
	AND.W	#$F000,2(A0,D0.W)
	OR.W	D2,2(A0,D0.W)
	ADD.W	#16,D0
	CMP.W	#1024,D0
	BLO.B	dctloop
	MOVE.W	#1008,D1
	MOVEQ	#-1,D2
	AND.W	#$F000,2(A0,D1.W)
	RTS

CutCmds	BSR.W	SaveUndo
	LEA	CmdsBuffer,A1
	CLR.W	D0
cucmloop
	MOVE.L	(A0,D0.W),(A1)+
	AND.L	#$FFFFF000,(A0,D0.W)
	ADD.W	#16,D0
	CMP.W	#1024,D0
	BNE.B	cucmloop
	CLR.B	RawKeyCode
	JMP	RedrawPattern

CopyCmds
	LEA	CmdsBuffer,A1
	CLR.W	D0
cocmloop
	MOVE.L	(A0,D0.W),(A1)+
	ADD.W	#16,D0
	CMP.W	#1024,D0
	BNE.B	cocmloop
	CLR.B	RawKeyCode
	RTS

PasteCmds
	BSR.W	SaveUndo
	LEA	CmdsBuffer,A1
	CLR.W	D0
pacmloop
	MOVE.L	(A0,D0.W),D1
	AND.L	#$FFFFF000,D1
	MOVE.L	(A1)+,D2
	AND.L	#$00000FFF,D2
	OR.L	D2,D1
	MOVE.L	D1,(A0,D0.W)
	ADD.W	#16,D0
	CMP.W	#1024,D0
	BNE.B	pacmloop
	CLR.B	RawKeyCode
	JMP	RedrawPattern
	
;---- Swap Tracks ----

SwapTrack
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	SwapTrackText(PC),A0
	JSR	ShowStatusText
swtloop	BSR.W	GetHexKey
	CMP.B	#128,D1
	BEQ.B	swtabor
	TST.B	D1
	BEQ.B	swtabor
	CMP.B	#4,D1
	BHI.B	swtloop
	BSR.W	SaveUndo
	SUBQ.L	#1,D1
	LSL.L	#2,D1
	MOVE.L	D1,D0
	MOVE.L	SongDataPtr,A0
	LEA	sd_patterndata(A0),A0
	MOVE.L	PatternNumber,D1
	LSL.L	#8,D1
	LSL.L	#2,D1
	ADD.L	D1,A0
	MOVE.L	A0,A1
	ADD.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	AND.L	#$F,D0
	LSL.L	#2,D0
	ADD.L	D0,A1
	MOVEQ	#64-1,D1
swtloop2
	MOVE.L	(A0),D0
	MOVE.L	(A1),(A0)
	MOVE.L	D0,(A1)
	LEA	16(A0),A0
	LEA	16(A1),A1
	DBRA	D1,swtloop2
	JSR	RedrawPattern
swtabor	JSR	ShowAllRight
	BRA.W	RestorePtrCol

SwapTrackText	dc.b 'Swap (1/2/3/4) ?',0
	EVEN

;---- Block Commands ----

BlockFromPos	dc.w 0
BlockToPos	dc.w 0
BlockMarkFlag	dc.w 0
BlockBufferFlag	dc.w 0
JoinPasteFlag	dc.w 0
PolyPasteFlag	dc.w 0
BuffFromPos	dc.w 0
BuffToPos	dc.w 0
BlockMarkText	dc.b 'mark block 00-00',0
BlockErrorText	dc.b 'no block marked !',0
BufEmptyText	dc.b 'buffer is empty !',0
	EVEN

BeginBlock
	CLR.B	RawKeyCode
	TST.W	BlockMarkFlag
	BEQ.B	beblskp
blkunma	CLR.W	BlockMarkFlag
	JMP	ShowAllRight
beblskp MOVE.W	#1,BlockMarkFlag
	MOVE.W	ScrPattPos,BlockFromPos
	MOVE.W	ScrPattPos,BlockToPos
ShowBlockPos
	MOVE.W	BlockFromPos(PC),D0
	MOVE.W	BlockToPos(PC),D1
	CMP.W	D0,D1
	BHS.B	sbpskip
	EXG	D0,D1
sbpskip	LEA	BlockMarkText+12(PC),A0
	BSR.B	IntTo2DecAscii
	LEA	BlockMarkText+15(PC),A0
	MOVE.W	D1,D0
	BSR.B	IntTo2DecAscii
	LEA	BlockMarkText(PC),A0
	JMP	ShowStatusText

Re_MarkBlock
	CLR.B	RawKeyCode
	MOVE.W	#1,BlockMarkFlag
	MOVE.W	BlockToPos(PC),ScrPattPos
	BSR.W	SetScrPatternPos
	BRA.B	ShowBlockPos

CheckBlockPos
	TST.W	BlockMarkFlag
	BEQ.W	Return1
	MOVE.W	ScrPattPos,D0
	CMP.W	BlockToPos(PC),D0
	BEQ.W	Return1
	MOVE.W	D0,BlockToPos
	BRA.B	ShowBlockPos

IntTo2DecAscii
	AND.L	#$FF,D0
	DIVU.W	#10,D0
	ADD.B	#'0',D0
	MOVE.B	D0,-1(A0)
	SWAP	D0
	ADD.B	#'0',D0
	MOVE.B	D0,(A0)
	RTS

CutBlock
	; --PT2.3D change: CTRL+X = sample data cut in sampler screen
	TST.W	SamScrEnable
	BNE.W	xSamCut
	; -----------------------------------------------------------
	CLR.B	RawKeyCode
	TST.W	BlockMarkFlag
	BEQ.W	BlockError
	BSR.B	cobldo
	MOVE.W	#1,BlockMarkFlag
	BRA.W	ClearBlock

CopyBlock
	; --PT2.3D change: CTRL+C = sample data copy in sampler screen
	TST.W	SamScrEnable
	BNE.W	xSamCop
	; ------------------------------------------------------------
	CLR.B	RawKeyCode
	TST.W	BlockMarkFlag
	BEQ.W	BlockError
cobldo	CLR.W	BlockMarkFlag
	MOVE.W	#1,BlockBufferFlag
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	LEA	BlockBuffer,A1
	MOVEQ	#64-1,D0
cobllop	MOVE.L	(A0),(A1)
	LEA	16(A0),A0
	LEA	16(A1),A1
	DBRA	D0,cobllop
	MOVE.W	BlockFromPos(PC),D0
	MOVE.W	BlockToPos(PC),D1
	CMP.W	D0,D1
	BHS.B	coblskp
	EXG	D0,D1
coblskp	MOVE.W	D0,BuffFromPos
	MOVE.W	D1,BuffToPos
	JMP	ShowAllRight
	
PasteBlock
	CLR.B	RawKeyCode
	TST.W	BlockBufferFlag
	BEQ.W	BufferError
	BSR.W	SaveUndo
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	LEA	BlockBuffer,A1
	MOVE.W	BuffFromPos(PC),D0
	MOVE.W	BuffToPos(PC),D1
	MOVE.W	ScrPattPos,D2
	LSL.W	#4,D0
	LSL.W	#4,D1
	LSL.W	#4,D2
pabllop	MOVE.L	(A1,D0.W),D3
	TST.W	JoinPasteFlag
	BEQ.B	pablskp
	MOVE.L	D3,D4
	AND.L	#$FFFFF000,D4
	BNE.B	pablskp
	MOVE.L	(A0,D2.W),D4
	AND.L	#$FFFFF000,D4
	AND.L	#$00000FFF,D3
	OR.L	D4,D3
pablskp	MOVE.L	D3,(A0,D2.W)
	CMP.W	D0,D1
	BEQ.B	pablend
	CMP.W	#63*16,D0
	BEQ.B	pablend
	CMP.W	#63*16,D2
	BEQ.B	pablend
	ADD.W	#16,D0
	ADD.W	#16,D2
	TST.W	PolyPasteFlag
	BEQ.B	pabllop
	MOVEM.L	D0-D2/A1,-(SP)
	BSR.W	GotoNextMulti
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	MOVEM.L	(SP)+,D0-D2/A1
	BRA.B	pabllop
pablend	CLR.W	JoinPasteFlag
	CLR.W	PolyPasteFlag
	JSR	ShowAllRight
	JSR	RedrawPattern
	TST.W	ShiftKeyStatus
	BNE.W	Return1
	MOVE.W	BuffToPos(PC),D0
	SUB.W	BuffFromPos(PC),D0
	ADDQ.W	#1,D0
	ADD.W	ScrPattPos,D0
	CMP.W	#63,D0
	BLS.B	pablset
	MOVEQ	#0,D0
pablset	MOVE.W	D0,ScrPattPos
	BRA.W	SetScrPatternPos

PolyphonizeBlock
	MOVE.W	#1,PolyPasteFlag
JoinPasteBlock
	MOVE.W	#1,JoinPasteFlag
	BRA.W	PasteBlock

InsertBlock	CLR.B	RawKeyCode
	TST.W	BlockBufferFlag
	BEQ.W	BufferError
	CMP.W	#63,ScrPattPos
	BEQ.W	PasteBlock
	MOVE.W	BuffToPos(PC),D0
	SUB.W	BuffFromPos(PC),D0
inbllop	MOVE.L	D0,-(SP)
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	BSR.W	inotr
	MOVE.L	(SP)+,D0
	DBRA	D0,inbllop
	BRA.W	PasteBlock

DeleteBlock
	CLR.B	RawKeyCode
	TST.W	BlockMarkFlag
	BEQ.W	BlockError
	BSR.W	SaveUndo
	MOVE.W	BlockFromPos(PC),D0
	MOVE.W	BlockToPos(PC),D1
	CMP.W	D0,D1
	BHS.B	deblskp
	EXG	D0,D1
deblskp	CMP.W	#63,D1
	BEQ.B	ClearBlock
	CLR.W	BlockMarkFlag
	MOVE.W	D0,ScrPattPos
	ADDQ.W	#1,ScrPattPos
	SUB.W	D0,D1
	MOVE.W	D1,D0
debllop	MOVE.L	D0,-(SP)
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	BSR.W	dnt
	MOVE.L	(SP)+,D0
	DBRA	D0,debllop
	SUBQ.W	#1,ScrPattPos
	JSR	ShowAllRight
	JMP	RedrawPattern

ClearBlock
	TST.W	BlockMarkFlag
	BEQ.W	BlockError
	BSR.W	SaveUndo
	CLR.W	BlockMarkFlag
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	MOVE.W	BlockFromPos(PC),D0
	MOVE.W	BlockToPos(PC),D1
	CMP.W	D0,D1
	BHS.B	clblskp
	EXG	D0,D1
clblskp	LSL.W	#4,D0
	LSL.W	#4,D1
	MOVEQ	#0,D2
clbllop	MOVE.L	D2,(A0,D0.W)
	CMP.W	D0,D1
	BEQ.B	clblend
	ADD.W	#16,D0
	BRA.B	clbllop
clblend	JSR	ShowAllRight
	JMP	RedrawPattern

	; inverts the pattern data (prepares it for backwards play hack)
CheckPatternInvertKeys
	TST.W	CtrlKeyStatus
	BEQ.W	Return1
	TST.W	AltKeyStatus
	BEQ.W	Return1
	TST.W	ShiftKeyStatus
	BEQ.W	Return1
	TST.W	LeftAmigaStatus
	BEQ.W	Return1
	MOVE.B	RawKeyCode,D0
	CMP.B	#70,D0	; DEL
	BNE.W	Return1
	CLR.B	RawKeyCode
	BSR.W	StorePtrCol
	MOVE.L	PatternNumber,D3
	MOVE.W	PattCurPos,D4
	MOVE.L	#0,PatternNumber
.loop1	CLR.W	PattCurPos
.loop2	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	CLR.W	D0
	MOVE.W	#$3F0,D1
	BSR.W	babllop
	ADDQ.W	#6,PattCurPos
	CMP.W	#24,PattCurPos
	BNE.B	.loop2
	TST.W	NumPatterns
	BEQ.B	.skip
	ADDQ.L	#1,PatternNumber
	MOVE.L	PatternNumber,D0
	CMP.W	NumPatterns,D0
	BNE.B	.loop1
.skip	BSR.W	RestorePtrCol
	MOVE.L	D3,PatternNumber
	MOVE.W	D4,PattCurPos
	JSR	RedrawPattern
	RTS

BackwardsBlock
	CLR.B	RawKeyCode
	TST.W	BlockMarkFlag
	BEQ.W	BlockError
	BSR.W	SaveUndo
	CLR.W	BlockMarkFlag
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	MOVE.W	BlockFromPos(PC),D0
	MOVE.W	BlockToPos(PC),D1
	CMP.W	D0,D1
	BHS.B	bablskp
	EXG	D0,D1
bablskp	LSL.W	#4,D0
	LSL.W	#4,D1
babllop	MOVE.L	(A0,D0.W),D2
	MOVE.L	(A0,D1.W),(A0,D0.W)
	MOVE.L	D2,(A0,D1.W)
	CMP.W	D1,D0
	BHS.B	bablend
	ADD.W	#16,D0
	SUB.W	#16,D1
	CMP.W	D1,D0
	BHS.B	bablend
	BRA.B	babllop
bablend	JSR	ShowAllRight
	JMP	RedrawPattern

TransBlockUp
	SF	trblflag
	BRA.B	trbldo
TransBlockDown
	ST	trblflag
trbldo	CLR.B	RawKeyCode
	TST.W	BlockMarkFlag
	BEQ.B	BlockError
	BSR.W	SaveUndo
	MOVE.W	#2,NoteShift
	MOVE.W	BlockFromPos(PC),D0
	MOVE.W	BlockToPos(PC),D1
	CMP.W	D0,D1
	BHS.B	trblskp
	EXG	D0,D1
trblskp	MOVE.W	D0,D5
	LSL.W	#4,D5
	SUB.W	D0,D1
	MOVE.W	D1,D6
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	LEA	(A0,D5.W),A3
	MOVEQ	#0,D3
	MOVE.B	SampleAllFlag(PC),sampallsave
	ST	SampleAllFlag
	TST.B	trblflag
	BEQ.B	trblup
	BSR.W	sandlo2
	MOVE.B	sampallsave(PC),SampleAllFlag
	JMP	RedrawPattern
trblup  BSR.W	sanulo2
	MOVE.B	sampallsave(PC),SampleAllFlag
	JMP	RedrawPattern

trblflag	dc.b	0
sampallsave	dc.b	0
	EVEN

BlockError
	LEA	BlockErrorText(PC),A0
	JSR	ShowStatusText
	BRA.W	SetErrorPtrCol

BufferError
	LEA	BufEmptyText(PC),A0
	JSR	ShowStatusText
	BRA.W	SetErrorPtrCol

ExpandTrack
	CLR.B	RawKeyCode
	BSR.W	SaveUndo
	MOVE.W	ScrPattPos,PosSave
	ADDQ.W	#1,ScrPattPos
	CMP.W	#64,ScrPattPos
	BHS.B	extrend
extrlop	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	BSR.W	inotr
	ADDQ.W	#2,ScrPattPos
	CMP.W	#64,ScrPattPos
	BLO.B	extrlop
extrend	MOVE.W	PosSave(PC),ScrPattPos
	JMP	RedrawPattern

ContractTrack
	CLR.B	RawKeyCode
	BSR.W	SaveUndo
	MOVE.W	ScrPattPos,PosSave
	ADDQ.W	#2,ScrPattPos	; --PT2.3D bug fix: was #1 (fixes CTRL+O)
	CMP.W	#64,ScrPattPos
	BHS.B	cotrend
cotrlop	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	BSR.W	dnt
	ADDQ.W	#1,ScrPattPos	; --PT2.3D bug fix: was #2 (fixes CTRL+O)
	CMP.W	#64,ScrPattPos
	BLO.B	cotrlop
cotrend	MOVE.W	PosSave(PC),ScrPattPos
	JMP	RedrawPattern

PosSave	dc.w	0


KillToEndOfTrack
	CLR.B	RawKeyCode
	BSR.B	SaveUndo
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	MOVE.W	ScrPattPos,D0
	MOVE.W	D0,D1
	LSL.W	#4,D1
	LEA	(A0,D1.W),A0
	MOVEQ	#0,D1
	TST.W	ShiftKeyStatus
	BNE.B	KillToStart
kteot
	CLR.L	(A0)
	LEA	16(A0),A0
	ADDQ.W	#1,D0
	CMP.W	#64,D0
	BLO.B	kteot
	JMP	RedrawPattern

KillToStart
	CLR.L	(A0)
	LEA	-16(A0),A0
	TST.W	D0
	BEQ.B	xRedrawPattern
	SUBQ.W	#1,D0
	BRA.B	KillToStart

xRedrawPattern	JMP	RedrawPattern

UndoLastChange
	CLR.B	RawKeyCode
	MOVEQ	#0,D0
	BSR.W	GetPositionPtr
	LEA	UndoBuffer,A1
	MOVE.W	#256-1,D0
unlalop	MOVE.L	(A1),D1
	MOVE.L	(A0),(A1)+
	MOVE.L	D1,(A0)+
	DBRA	D0,unlalop
	JMP	RedrawPattern

SaveUndo
	MOVEM.L	D0/A0/A1,-(SP)
	MOVEQ	#0,D0
	BSR.W	GetPositionPtr
	LEA	UndoBuffer,A1
	MOVE.W	#256-1,D0
saunlop	MOVE.L	(A0)+,(A1)+
	DBRA	D0,saunlop
	MOVEM.L	(SP)+,D0/A0/A1
	RTS
	
;---- Check Function Keys F1-F2 ----

CheckF1_F2
	CMP.B	#80,RawKeyCode
	BEQ.B	SetOctaveLow
	CMP.B	#81,RawKeyCode
	BEQ.B	SetOctaveHigh
	RTS

SetOctaveLow
	MOVE.L	#KbdTransTable1,KeyTransTabPtr
	CLR.B	RawKeyCode
	RTS

SetOctaveHigh
	MOVE.L	#KbdTransTable2,KeyTransTabPtr
	CLR.B	RawKeyCode
	RTS
	
;---- Get Hex Key ----

GetHexNybble
	MOVE.W	#1,AbortHexFlag
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	MOVEQ	#0,D0
	MOVE.W	TextOffset,D0
	DIVU.W	#40,D0
	ADDQ.W	#5,D0
	MOVE.W	D0,LineCurY
	SWAP	D0
	LSL.W	#3,D0
	ADDQ.W	#4,D0
	MOVE.W	D0,LineCurX
	BSR.W	UpdateLineCurPos
	BSR.W	GetHexKey
	CMP.B	#128,D1
	BEQ.W	ghbdone
	MOVE.L	D1,D0
	MOVE.B	D1,D6
	JSR	PrintHexDigit
	CLR.W	AbortHexFlag
ghndone
	CLR.W	LineCurX
	MOVE.W	#270,LineCurY
	BSR.W	UpdateLineCurPos
	BSR.W	RestorePtrCol
	MOVE.B	D6,D0
	RTS
	
GetHexByte
	MOVE.W	#1,AbortHexFlag
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	MOVEQ	#0,D0
	MOVE.W	TextOffset,D0
	DIVU.W	#40,D0
	ADDQ.W	#5,D0	; --PT2.3D bug fix: text marker one y pixel too much
	MOVE.W	D0,LineCurY
	SWAP	D0
	LSL.W	#3,D0
	ADDQ.W	#4,D0
	MOVE.W	D0,LineCurX
	BSR.W	UpdateLineCurPos
	BSR.B	GetHexKey
	CMP.B	#128,D1
	BEQ.B	ghbdone
	MOVE.L	D1,D0
	MOVE.B	D1,D6
	LSL.B	#4,D6
	JSR	PrintHexDigit
	ADDQ.W	#8,LineCurX
	BSR.W	UpdateLineCurPos
	BSR.B	GetHexKey
	CMP.B	#128,D1
	BEQ.B	ghbdone
	MOVE.L	D1,D0
	OR.B	D1,D6
	JSR	PrintHexDigit
	CLR.W	AbortHexFlag
ghbdone
	CLR.W	LineCurX
	MOVE.W	#270,LineCurY
	BSR.W	UpdateLineCurPos
	BSR.W	RestorePtrCol
	MOVE.B	D6,D0
	RTS

GetHexKey
	CLR.B	MixChar
	MOVE.B	#128,D1
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	ghkreturn
	BSR.W	CheckPatternRedraw2
	MOVEQ	#0,D0
	BSR.W	DoKeyBuffer
	MOVE.B	RawKeyCode,D0
	MOVE.B	D0,MixChar
	BEQ.B	GetHexKey
	MOVE.B	#128,D1
	CLR.B	RawKeyCode
	CMP.B	#68,D0 ; CR
	BEQ.B	ghkreturn
	CMP.B	#69,D0 ; Esc
	BEQ.B	ghkreturn
	CMP.B	#79,D0 ; <--
	BEQ.B	ghkleft
	CMP.B	#78,D0 ; -->
	BEQ.B	ghkright
	BSR.B	CheckHexKey
	CMP.B	#16,D1
	BEQ.B	GetHexKey
ghkreturn
	MOVEQ	#0,D0
	RTS

ghkleft	MOVEQ	#-1,D0
	RTS

ghkright	MOVEQ	#1,D0
	RTS

CheckHexKey
	LEA	RawKeyHexTable,A0
	MOVEQ	#0,D1
chxloop	CMP.B	(A0)+,D0
	BEQ.W	Return1
	ADDQ.B	#1,D1
	CMP.B	#16,D1
	BNE.B	chxloop
	RTS
	
;---- Enter Edit Commands (effects) ----

EditCommand
	TST.L	EditMode
	BEQ.W	Return1
	MOVEQ	#0,D0
	MOVE.B	RawKeyCode,D0
	BSR.B	CheckHexKey
	CMP.B	#16,D1
	BNE.B	DoEditCommand
	RTS

DoEditCommand
	CMP.W	#1,PattCurPos
	BNE.B	ChkPos2
	CMP.W	#1,D1
	BHI.W	Return1
	MOVE.L	#$FFF,D2
	CLR.W	CmdOffset
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	UpdateCommand

ChkPos2	CMP.W	#2,PattCurPos
	BNE.B	ChkPos3
	MOVE.L	#$FFF,D2
	MOVE.W	#2,CmdOffset
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	UpdateCommand

ChkPos3	CMP.W	#3,PattCurPos
	BNE.B	ChkPos4
	MOVE.L	#$F0FF,D2
	MOVE.W	#2,CmdOffset
	LSL.W	#8,D1
	BRA.W	UpdateCommand

ChkPos4	CMP.W	#4,PattCurPos
	BNE.B	ChkPos5
	MOVE.L	#$FF0F,D2
	MOVE.W	#2,CmdOffset
	LSL.W	#4,D1
	BRA.W	UpdateCommand

ChkPos5	CMP.W	#5,PattCurPos
	BNE.B	ChkPos7
	MOVE.L	#$FFF0,D2
	MOVE.W	#2,CmdOffset
	BRA.W	UpdateCommand

ChkPos7	CMP.W	#7,PattCurPos
	BNE.B	ChkPos8
	CMP.W	#1,D1
	BHI.W	Return1
	MOVE.L	#$FFF,D2
	MOVE.W	#4,CmdOffset
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	UpdateCommand

ChkPos8	CMP.W	#8,PattCurPos
	BNE.B	ChkPos9
	MOVE.L	#$FFF,D2
	MOVE.W	#6,CmdOffset
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	UpdateCommand

ChkPos9	CMP.W	#9,PattCurPos
	BNE.B	ChkPos10
	MOVE.L	#$F0FF,D2
	MOVE.W	#6,CmdOffset
	LSL.W	#8,D1
	BRA.W	UpdateCommand

ChkPos10	CMP.W	#10,PattCurPos
	BNE.B	ChkPos11
	MOVE.L	#$FF0F,D2
	MOVE.W	#6,CmdOffset
	LSL.W	#4,D1
	BRA.W	UpdateCommand

ChkPos11	CMP.W	#11,PattCurPos
	BNE.B	ChkPos13
	MOVE.L	#$FFF0,D2
	MOVE.W	#6,CmdOffset
	BRA.W	UpdateCommand

ChkPos13	CMP.W	#13,PattCurPos
	BNE.B	ChkPos14
	CMP.W	#1,D1
	BHI.W	Return1
	MOVE.L	#$FFF,D2
	MOVE.W	#8,CmdOffset
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	UpdateCommand

ChkPos14	CMP.W	#14,PattCurPos
	BNE.B	ChkPos15
	MOVE.L	#$FFF,D2
	MOVE.W	#10,CmdOffset
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	UpdateCommand

ChkPos15	CMP.W	#15,PattCurPos
	BNE.B	ChkPos16
	MOVE.L	#$F0FF,D2
	MOVE.W	#10,CmdOffset
	LSL.W	#8,D1
	BRA.W	UpdateCommand

ChkPos16	CMP.W	#16,PattCurPos
	BNE.B	ChkPos17
	MOVE.L	#$FF0F,D2
	MOVE.W	#10,CmdOffset
	LSL.W	#4,D1
	BRA.W	UpdateCommand

ChkPos17	CMP.W	#17,PattCurPos
	BNE.B	ChkPos19
	MOVE.L	#$FFF0,D2
	MOVE.W	#10,CmdOffset
	BRA.W	UpdateCommand

ChkPos19	CMP.W	#19,PattCurPos
	BNE.B	ChkPos20
	CMP.W	#1,D1
	BHI.W	Return1
	MOVE.L	#$FFF,D2
	MOVE.W	#12,CmdOffset
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.B	UpdateCommand

ChkPos20	CMP.W	#20,PattCurPos
	BNE.B	ChkPos21
	MOVE.L	#$FFF,D2
	MOVE.W	#14,CmdOffset
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.B	UpdateCommand

ChkPos21	CMP.W	#21,PattCurPos
	BNE.B	ChkPos22
	MOVE.L	#$F0FF,D2
	MOVE.W	#14,CmdOffset
	LSL.W	#8,D1
	BRA.B	UpdateCommand

ChkPos22
	CMP.W	#22,PattCurPos
	BNE.B	MustBePos23
	MOVE.L	#$FF0F,D2
	MOVE.W	#14,CmdOffset
	LSL.W	#4,D1
	BRA.B	UpdateCommand

MustBePos23
	MOVE.L	#$FFF0,D2
	MOVE.W	#14,CmdOffset
UpdateCommand
	MOVE.L	SongDataPtr,A0
	LEA	sd_patterndata(A0),A0
	MOVE.L	PatternNumber,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	ADD.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	ScrPattPos,D0
	LSL.W	#4,D0
	EXT.L	D0
	ADD.L	D0,A0
	ADD.W	CmdOffset,A0
	AND.W	D2,(A0)
	ADD.W	D1,(A0)
	MOVE.W	(A0),WordNumber
	MOVEQ	#0,D0
	MOVE.W	ScrPattPos,D0
	MULU.W	#7*40,D0
	MOVEQ	#0,D1
	MOVE.W	PattCurPos,D1
	DIVU.W	#6,D1
	MULU.W	#9,D1
	ADD.L	D1,D0
	ADD.W	#7528,D0
	MOVE.W	D0,TextOffset
	TST.W	CmdOffset
	BEQ.B	ShowInstrNibble
	CMP.W	#4,CmdOffset
	BEQ.B	ShowInstrNibble
	CMP.W	#8,CmdOffset
	BEQ.B	ShowInstrNibble
	CMP.W	#12,CmdOffset
	BEQ.B	ShowInstrNibble
	JSR	PrintHexWord
dscend	BSR.W	EditMoveDown
	CLR.B	RawKeyCode
	RTS

ShowInstrNibble
	SUBQ.W	#1,TextOffset
	MOVE.W	#1,TextLength
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	AND.W	#$F000,D0
	BNE.B	sinokok
	TST.B	BlankZeroFlag
	BEQ.B	sinokok
	MOVE.L	#BlankInsText,D0
	BRA.B	sinprt
sinokok	LSR.W	#4,D0
	LSR.W	#7,D0
	ADD.L	#FastHexTable+1,D0
sinprt	MOVE.L	D0,ShowTextPtr
	JSR	ShowText
	BRA.B	dscend
	
;---- Store/Insert Effect Commands ----

CheckStoreEffect
	CMP.W	#3,CurrScreen
	BEQ.W	Return1
	CMP.W	#6,CurrScreen
	BEQ.W	Return1
	CMP.W	#4,CurrScreen
	BEQ.W	Return1
	MOVEQ	#0,D0
	
	MOVE.B	RawKeyCode,D0
	BEQ.W	Return1
	CMP.B	#70,D0 ; Del
	BEQ.W	CheckKeyboard2
	CMP.B	#10,D0
	BHI.W	Return1
	SUBQ.B	#1,D0
	ADD.B	D0,D0
	MOVE.L	D0,D7
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	MOVE.W	ScrPattPos,D0
	LSL.W	#4,D0
	LEA	(A0,D0.W),A0
	MOVE.W	2(A0),D0
	AND.W	#$FFF,D0
	LEA	EffectMacros,A0
	MOVE.W	D0,(A0,D7.W)
	LEA	CommandStoredText(PC),A0
	JSR	ShowStatusText
	BSR.W	WaitALittle
	JMP	ShowAllRight

CommandStoredText	dc.b	'command stored!',0
	EVEN

CheckInsertEffect
	CLR.W	InsEfx
	MOVEQ	#0,D0
	MOVE.B	RawKeyCode,D0
	BEQ.W	Return1
	CMP.B	#70,D0 ; Del
	BEQ.W	CheckKeyboard2
	CMP.B	#11,D0 ; -
	BEQ.W	DecreaseEffect
	CMP.B	#12,D0 ; = (+)
	BEQ.B	IncreaseEffect
	CMP.B	#13,D0 ; \
	BEQ.B	CopyEffect
	CMP.B	#10,D0
	BHI.W	Return1
	SUBQ.B	#1,D0
	ADD.B	D0,D0
	LEA	EffectMacros,A0
	MOVE.W	(A0,D0.W),InsEfx
DoInsEffect
	MOVE.B	#70,RawKeyCode
	BRA.W	CheckNoteKeys

GetLastEffect
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	MOVE.W	ScrPattPos,D0
	SUBQ.W	#1,D0
	AND.W	#$3F,D0
	LSL.W	#4,D0
	LEA	(A0,D0.W),A0
	MOVE.W	2(A0),D0
	AND.W	#$0FFF,D0
	RTS

CopyEffect
	BSR.B	GetLastEffect
	MOVE.W	D0,InsEfx
	BRA.B	DoInsEffect

IncreaseEffect
	BSR.B	GetLastEffect
	MOVE.W	D0,D1
	AND.W	#$0F00,D1
	CMP.W	#$0E00,D1
	BEQ.B	IncECom
	ADDQ.B	#1,D0
	MOVE.W	D0,InsEfx
	BRA.B	DoInsEffect

IncECom
	MOVE.W	D0,D1
	ADDQ.B	#1,D1
	AND.B	#$0F,D1
	AND.W	#$0FF0,D0
	OR.B	D1,D0
	MOVE.W	D0,InsEfx
	BRA.B	DoInsEffect

DecreaseEffect
	BSR.B	GetLastEffect
	MOVE.W	D0,D1
	AND.W	#$0F00,D1
	CMP.W	#$0E00,D1
	BEQ.B	DecECom
	SUBQ.B	#1,D0
	MOVE.W	D0,InsEfx
	BRA.W	DoInsEffect

DecECom MOVE.W	D0,D1
	SUBQ.B	#1,D1
	AND.B	#$0F,D1
	AND.W	#$0FF0,D0
	OR.B	D1,D0
	MOVE.W	D0,InsEfx
	BRA.W	DoInsEffect

InsEfx	dc.w 0

;---- Check Keyboard for notekeys ----
	
CheckKeyboard
	TST.B	RawKeyCode
	BEQ.W	Return1
	; --PT2.3D change: DEL = sample data cut in sampler screen
	TST.W	SamScrEnable		; sampler screen shown?
	BEQ.B	ckskip			; no, don't check for DEL key
	CMP.B	#70,RawKeyCode		; DEL key pressed?
	BEQ.W	xSamCut			; yes, branch to sample cut routine
ckskip	; --------------------------------------------------------
	TST.W	LeftAmigaStatus
	BNE.W	Return1
	TST.W	CtrlKeyStatus
	BNE.W	Return1
	TST.W	ShiftKeyStatus
	BNE.W	CheckStoreEffect
	TST.W	AltKeyStatus
	BNE.W	CheckInsertEffect
CheckKeyboard2
	MOVE.W	PattCurPos,D0
	BEQ.B	CheckNoteKeys
	CMP.W	#6,D0
	BEQ.B	CheckNoteKeys
	CMP.W	#12,D0
	BEQ.B	CheckNoteKeys
	CMP.W	#18,D0
	BEQ.B	CheckNoteKeys
	TST.L	EditMode
	BNE.W	EditCommand
	RTS

CheckNoteKeys
	LEA	RawKeyScaleTable,A0
	MOVE.B	RawKeyCode,D1
	MOVEQ	#39-1,D0
cnkloop	CMP.B	(A0,D0.W),D1
	BEQ.B	NoteKeyPressed
	DBRA	D0,cnkloop
	RTS
	
UpdateChordNote
	BSR.W	CalculateChordLen
	BRA.W	DisplayChordNotes

NoteKeyPressed
	CLR.W	DidQuantize
	CLR.B	RawKeyCode
	MOVE.L	KeyTransTabPtr,A1
	MOVE.B	(A1,D0.W),D0
	CMP.W	#36,D0
	BHS.B	nkpskip
	MOVE.L	SplitAddress,D1
	BEQ.B	nkpskip
	CLR.L	SplitAddress
	MOVE.L	D1,A0
	MOVE.B	D0,(A0)
	MOVE.W	SamNoteType,D1
	BEQ.W	ShowSplit
	CLR.W	SamNoteType
	AND.W	#$FF,D0
	MOVE.W	D0,(A0)
	CMP.W	#1,D1
	BEQ.B	loclab1
	CMP.W	#3,D1
	BEQ.W	ShowS2TuneNote
	CMP.W	#4,D1
	BEQ.B	xShowAllRight
	CMP.W	#5,D1
	BEQ.W	UpdateChordNote
	CMP.W	#2,D1
	BNE.B	nkpskip
	JMP	ShowResamNote
loclab1	JMP	ShowSamNote
xShowAllRight	JMP	ShowAllRight
nkpskip	MOVE.W	InsNum,PlayInsNum
	TST.B	SplitFlag
	BEQ.B	nkpskip2
	LEA	SplitInstrTable,A1
	MOVE.B	(A1,D0.W),D1
	BEQ.B	nkpskip3
	MOVE.B	D1,PlayInsNum+1
nkpskip3
	LEA	SplitTransTable,A1
	MOVE.B	(A1,D0.W),D0
nkpskip2
	MOVEQ	#0,D2
playtheinstr
	LEA	PeriodTable,A1 ; note in d0 here
	MOVE.L	D0,D4
	ADD.W	D0,D0
	MOVEQ	#0,D3
	MOVE.W	(A1,D0.W),D3
	
	MOVE.L	SongDataPtr,A0 ; This fixes finetune...
	LEA	14(A0),A0
	MOVE.W	InsNum,D1
	BNE.B	nkpskipit
	MOVE.W	LastInsNum,D1
nkpskipit
	MULU.W	#30,D1
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.B	(A0),D1 ; get finetune
	AND.B	#$0F,D1
	LSL.B	#2,D1
	LEA	ftunePerTab,A4
	MOVE.L	(A4,D1.W),A1
	MOVE.W	(A1,D0.W),CurrentPlayNote
	
	TST.L	D2
	BEQ.B	nkpnrml
	CMP.B	#2,pnoteflag
	BNE.W	antpskip
	
nkpnrml	TST.L	EditMode
	BEQ.W	antpskip
AddNoteToPattern
	MOVE.L	SongDataPtr,A0
	LEA	sd_patterndata(A0),A0	; Find first pattern
	MOVE.L	PatternNumber,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	ADD.L	D0,A0	; Find current pattern
	MOVEQ	#0,D0
	MOVE.W	ScrPattPos,D0
	BSR.W	QuantizeCheck
	LSL.W	#4,D0
	EXT.L	D0
	ADD.L	D0,A0	; Find current pos
	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	LSL.W	#2,D0
	EXT.L	D0
	ADD.L	D0,A0	; Find current channel
	TST.W	AltKeyStatus
	BEQ.B	antpsks
	AND.L	#$FFFFF000,(A0)
	MOVE.W	InsEfx(PC),D0
	OR.W	D0,2(A0)
	BRA.B	antp3
antpsks	TST.W	ShiftKeyStatus
	BEQ.B	antpskip2
	CLR.L	(A0)
antpskip2	MOVEQ	#0,D0
	MOVE.W	D3,(A0)	; Put note into pattern
	BEQ.B	antp2
	TST.B	AutoInsFlag
	BEQ.B	antp4
	MOVE.B	AutoInsSlot,D0
	ADD.B	D0,D0
	EXT.W	D0
	LEA	EffectMacros,A1
	MOVE.W	(A1,D0.W),2(A0)
antp4	MOVE.W	PlayInsNum,D0
	LSL.W	#4,D0
	AND.B	#$F,2(A0)
	ADD.B	D0,2(A0)
	LSL.W	#4,D0
	AND.W	#$F000,D0
	OR.W	D0,(A0)
	BRA.B	antp3

antp2	AND.W	#$0FFF,2(A0)
antp3	MOVE.W	2(A0),CurrCmds
	MOVE.L	NoteNamesPtr,A0
	LSL.W	#2,D4
	EXT.L	D4
	ADD.L	D4,A0
	MOVE.L	A0,ShowTextPtr
	MOVE.W	#3,TextLength
	MOVEQ	#0,D0
	MOVE.W	ScrPattPos,D0
	BSR.W	QuantizeCheck
	MULU.W	#7*40,D0
	MOVEQ	#0,D1
	MOVE.W	PattCurPos,D1
	DIVU.W	#6,D1
	MULU.W	#9,D1
	ADD.L	D1,D0
	ADD.W	#7524,D0
	MOVE.W	D0,TextOffset
	TST.W	AltKeyStatus
	BEQ.B	antpnot
	ADDQ.W	#4,D0
	MOVE.W	D0,TextOffset
	BRA.B	antpalt
antpnot	JSR	ShowText	; Show notename
	JSR	PrintHiInstrNum
antpalt
	MOVE.W	CurrCmds,WordNumber
	JSR	PrintHexWord
	BSR.W	EditMoveDown
antpskip
	; --PT2.3D bug fix: instant channel muting
	LEA	audchan1toggle(PC),A0
	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	LSL.B	#3,D0
	MOVE.W	(A0,D0.W),D0
	BNE.B	antpskip3
	RTS
antpskip3
	; ----------------------------------------
	TST.W	DidQuantize
	BNE.B	testmul
	TST.W	CurrentPlayNote
	BNE.W	PlayNote
testmul	TST.B	MultiFlag
	BEQ.W	Return1
GotoNextMulti
	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	LEA	MultiModeNext,A0
	MOVE.B	(A0,D0.W),D0
	SUBQ.W	#1,D0
	AND.W	#3,D0
	MULU.W	#6,D0
	MOVE.W	D0,PattCurPos
	BRA.W	UpdateCursorPos

QuantizeCheck
	TST.L	RunMode
	BEQ.B	qcend
	MOVEQ	#0,D1
	MOVE.B	QuantizeValue(PC),D1
	BEQ.B	qcend
	CMP.W	#1,D1
	BEQ.B	QuanOne
	MOVE.W	#1,DidQuantize
	MOVE.L	D1,D2
	LSR.W	#1,D2
	ADD.W	D0,D2
	AND.W	#$003F,D2
	DIVU.W	D1,D2
	MULU.W	D1,D2
	CMP.W	D0,D2
	BHI.B	qcskip
	CLR.W	DidQuantize
qcskip	MOVE.W	D2,D0
	RTS

QuanOne MOVE.L	CurrSpeed,D1
	LSR.L	#1,D1
	CMP.L	Counter,D1
	BLS.B	QuantToNextNote
qcend	CLR.W	DidQuantize
	RTS

QuantToNextNote
	ADDQ.W	#1,D0
	AND.W	#$003F,D0
	MOVE.W	#1,DidQuantize
	RTS

PlayNote
	CMP.W	#18,PattCurPos
	BLO.B	ChkChan3
	LEA	$DFF0D0,A5
	LEA	audchan4temp,A4
	BRA.B	DoPlayNote

ChkChan3
	CMP.W	#12,PattCurPos
	BLO.B	ChkChan2
	LEA	$DFF0C0,A5
	LEA	audchan3temp,A4
	BRA.B	DoPlayNote

ChkChan2
	CMP.W	#6,PattCurPos
	BLO.B	ChkChan1
	LEA	$DFF0B0,A5
	LEA	audchan2temp,A4
	BRA.B	DoPlayNote

ChkChan1
	; it doesn't seem like this test is needed...
	;TST.W	PattCurPos
	;BNE.W	Return1
	LEA	$DFF0A0,A5
	LEA	audchan1temp,A4
DoPlayNote
	MOVE.L	A5,NoteAddr
	LEA	SampleInfo,A6
	MOVE.W	PlayInsNum,D0
	BEQ.B	dpnplay
	LSL.L	#2,D0
	LEA	SamplePtrs,A0
	LEA	SampleInfo2,A6
	MOVE.L	(A0,D0.W),si_pointer2
	MOVE.L	SongDataPtr,A0
	LEA	-10(A0),A0
	MOVE.W	PlayInsNum,D0
	MOVE.B	D0,PlayInsNum2
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVE.L	22(A0),SampleInfo2
	MOVE.L	26(A0),si_long2
dpnplay	MOVE.B	PlayInsNum2(PC),n_samplenum(A4)
	MOVE.W	4(A6),D0 ; repeat
	BNE.B	dpn2
	MOVE.W	(A6),D0  ; length
	BRA.B	dpn3
dpn2	ADD.W	6(A6),D0 ; add replen
dpn3	MOVEQ	#0,D1
	MOVE.B	3(A6),D1
	; --PT2.3D bug fix: limit sample volume to 64
	CMP.B	#64,D1
	BLS.B	dpnvolok
	MOVEQ	#64,D1
dpnvolok
	; --END OF FIX--------------------------------
	MOVE.W	D1,8(A5)			; Set volume
	MOVE.B	D1,n_volumeout(A4)		; Set quadrascope volume
	MOVE.B	D1,n_volume(A4)
	MOVE.W	CurrentPlayNote,6(A5)		; Set period
	MOVE.W	CurrentPlayNote,n_periodout(A4)	; Set quadrascope period
	MOVE.W	CurrentPlayNote,n_period(A4)

	MOVE.W	n_dmabit(A4),$DFF096		; Turn off all voice DMAs
	MOVE.L	8(A6),D1
	ADD.L	StartOfs,D1
	MOVE.L	D1,(A5)				; Set sampledata pointer
	CLR.L	StartOfs
	MOVE.L	D1,n_start(A4)
	MOVE.L	D1,n_oldstart(A4)		; for quadrascope
	MOVE.W	D0,4(A5)			; Set length
	MOVE.W	D0,n_length(A4)
	MOVE.W	D0,n_oldlength(A4)		; for quadrascope
	BNE.B	dpnnz
	MOVEQ	#1,D0
	MOVE.W	D0,4(A5)
	MOVE.W	D0,n_length(A4)
	
dpnnz	MOVE.W	CurrentPlayNote,D0
	BSR.W	PlayNoteAnalyze
	
	JSR	WaitForPaulaLatch
	MOVE.W	n_dmabit(A4),D0
	OR.W	#$8000,D0	; Set bits
	MOVE.W	D0,$DFF096	; Turn DMAs back on	
	JSR	WaitForPaulaLatch

	MOVEQ	#0,D1
	MOVE.W	4(A6),D1 	; repeat*2
	MOVE.W	D1,n_repeat(A4)
	ADD.L	D1,D1
	ADD.L	8(A6),D1 	; + startptr
	MOVE.L	D1,(A5)		; Set loop pointer
	MOVE.L	D1,n_loopstart(A4)
	MOVE.W	6(A6),4(A5)	; Set loop length
	MOVE.W	6(A6),n_replen(A4)

	ST	n_trigger(A4)
	BRA.W	testmul

PlayInsNum2	dc.b 0
	EVEN

;---- Check Cursor Arrow Keys ----

ArrowKeys
	CMP.B	#4,EnterTextFlag
	BEQ.W	Return1
	MOVE.B	RawKeyCode,D0
	TST.W	GetLineFlag
	BNE.B	arkeskip
	TST.W	ShiftKeyStatus
	BNE.B	arkeskip
	TST.W	AltKeyStatus
	BNE.B	arkeskip
	CMP.W	#2,CurrScreen
	BEQ.B	arkeskip
	CMP.B	#78,D0
	BEQ.W	RightArrow
	CMP.B	#79,D0
	BEQ.W	LeftArrow
arkeskip
	CMP.B	#76,D0
	BEQ.B	UpArrow
	CMP.B	#77,D0
	BEQ.W	DownArrow
	CLR.W	ArrowPressed
	RTS

ArrowPressed	dc.w	0
ArrowRepCounter	dc.w	0

UpArrow	TST.L	RunMode
	BNE.W	Return1
	CMP.W	#2,CurrScreen
	BEQ.W	Return1
	CMP.W	#3,CurrScreen
	BEQ.W	Return1
	CMP.W	#4,CurrScreen
	BEQ.W	Return1
	CMP.W	#6,CurrScreen
	BEQ.W	Return1
	CMP.W	#8,CurrScreen
	BEQ.W	Return1
	TST.W	ArrowPressed
	BEQ.B	MoveOneUp
	ADDQ.W	#1,ArrowRepCounter
	TST.W	AltKeyStatus
	BNE.B	AltUpArrow
	TST.W	ShiftKeyStatus
	BNE.B	ShiftUpArrow
	CMP.W	#6,ArrowRepCounter
	BPL.B	MoveOneUp
	RTS

ShiftUpArrow
	CMP.W	#3,ArrowRepCounter
	BPL.B	MoveOneUp
	RTS

AltUpArrow
	CMP.W	#1,ArrowRepCounter
	BPL.B	MoveOneUp
	RTS

MoveOneUp
	CLR.W	ArrowRepCounter
	MOVE.W	#$FFFF,ArrowPressed
	CMP.L	#'patt',RunMode
	BEQ.W	Return1
	SUBQ.W	#1,ScrPattPos
	AND.W	#$003F,ScrPattPos
	BRA.W	SetScrPatternPos

DownArrow
	TST.L	RunMode
	BNE.W	Return1
	CMP.W	#2,CurrScreen
	BEQ.W	Return1
	CMP.W	#3,CurrScreen
	BEQ.W	Return1
	CMP.W	#4,CurrScreen
	BEQ.W	Return1
	CMP.W	#6,CurrScreen
	BEQ.W	Return1
	CMP.W	#8,CurrScreen
	BEQ.W	Return1
	TST.W	ArrowPressed
	BEQ.B	MoveOneDown
	ADDQ.W	#1,ArrowRepCounter
	TST.W	AltKeyStatus
	BNE.B	AltDownArrow
	TST.W	ShiftKeyStatus
	BNE.B	ShiftDownArrow
	CMP.W	#6,ArrowRepCounter
	BPL.B	MoveOneDown
	RTS

ShiftDownArrow
	CMP.W	#3,ArrowRepCounter
	BPL.B	MoveOneDown
	RTS

AltDownArrow
	CMP.W	#1,ArrowRepCounter
	BPL.B	MoveOneDown
	RTS

MoveOneDown
	CLR.W	ArrowRepCounter
	MOVE.W	#$FFFF,ArrowPressed
	TST.L	RunMode
	BNE.W	Return1
	ADDQ.W	#1,ScrPattPos
	AND.W	#$003F,ScrPattPos
	BRA.W	SetScrPatternPos

EditMoveDown
	TST.L	RunMode
	BNE.W	Return1
	MOVE.W	EditMoveAdd(PC),D0
	ADD.W	D0,ScrPattPos
	AND.W	#$003F,ScrPattPos
	BRA.W	SetScrPatternPos

EditMoveAdd	dc.w 1

RightArrow
	TST.W	ArrowPressed
	BEQ.B	MoveOneRight
	ADDQ.W	#1,ArrowRepCounter
	CMP.W	#6,ArrowRepCounter
	BPL.B	MoveOneRight
	RTS

PatternOneUp
	ADDQ.L	#1,PatternNumber
	MOVE.L	PatternNumber,D0
	CMP.L	MaxPattern(PC),D0
	BLE.B	pouskip
	CLR.L	PatternNumber
pouskip
	;BSR.W	Wait_4000
	JMP	RedrawPattern

MoveOneRight
	CLR.W	ArrowRepCounter
	MOVE.W	#$FFFF,ArrowPressed
	ADDQ.W	#1,PattCurPos
	CMP.W	#24,PattCurPos
	BMI.B	morskip
	CLR.W	PattCurPos
morskip	BRA.B	UpdateCursorPos

LeftArrow
	TST.W	ArrowPressed
	BEQ.B	MoveOneLeft
	ADDQ.W	#1,ArrowRepCounter
	CMP.W	#6,ArrowRepCounter
	BPL.B	MoveOneLeft
	RTS

PatternOneDown
	SUBQ.L	#1,PatternNumber
	TST.L	PatternNumber
	BPL.B	podskip
	MOVE.L	MaxPattern(PC),PatternNumber
podskip
	;BSR.W	Wait_4000
	JMP	RedrawPattern

MoveOneLeft
	CLR.W	ArrowRepCounter
	MOVE.W	#$FFFF,ArrowPressed
	SUBQ.W	#1,PattCurPos
	TST.W	PattCurPos
	BPL.B	UpdateCursorPos
	MOVE.W	#23,PattCurPos
UpdateCursorPos
	TST.W	SamScrEnable
	BNE.W	Return1
	MOVE.W	PattCurPos,D0
	LEA	CursorPosTable,A0
	MOVE.B	(A0,D0.W),D0
	LSL.W	#3,D0
	ADD.W	#9,D0
	MOVE.W	#$BD,D1
	MOVEQ	#14,D2 ; 14 lines
	LEA	CursorSpriteData,A0
	JMP	SetSpritePos

ArrowKeys2
	MOVE.B	RawKeyCode,D0
	CMP.B	#76,D0
	BEQ.B	UpArrow2
	CMP.B	#77,D0
	BEQ.B	DownArrow2
	CMP.B	#79,D0
	BEQ.W	LeftArrow2
	CMP.B	#78,D0
	BEQ.W	RightArrow2
	RTS

UpArrow2
	CMP.W	#2,CurrScreen
	BEQ.W	HelpUp
	CMP.W	#3,CurrScreen
	BEQ.W	FilenameOneUp
	CMP.W	#4,CurrScreen
	BEQ.B	PED_OneUp2
	CMP.W	#6,CurrScreen
	BEQ.B	PLSTOneUp2
	CMP.W	#8,CurrScreen
	BEQ.W	POSED_OneUp
	RTS

PED_OneUp2	JMP	PED_OneUp
PLSTOneUp2	JMP	PLSTOneUp

DownArrow2
	CMP.W	#2,CurrScreen
	BEQ.W	HelpDown
	CMP.W	#3,CurrScreen
	BEQ.W	FilenameOneDown
	CMP.W	#4,CurrScreen
	BEQ.B	PED_OneDown2
	CMP.W	#6,CurrScreen
	BEQ.B	PLSTOneDown2
	CMP.W	#8,CurrScreen
	BEQ.W	POSED_OneDown
	RTS

PED_OneDown2	JMP	PED_OneDown
PLSTOneDown2	JMP	PLSTOneDown

LeftArrow2
	TST.W	ShiftKeyStatus
	BNE.W	PositionDown
	TST.W	AltKeyStatus
	BNE.W	PatternOneDown
	TST.W	CtrlKeyStatus
	BNE.W	SampleNumDown
	CMP.W	#2,CurrScreen
	BEQ.W	HelpLeft
	RTS

RightArrow2	TST.W	ShiftKeyStatus
	BNE.W	PositionUp
	TST.W	AltKeyStatus
	BNE.W	PatternOneUp
	TST.W	CtrlKeyStatus
	BNE.W	SampleNumUp
	CMP.W	#2,CurrScreen
	BEQ.W	HelpRight
	RTS
	
;---- Update Line Cursor Position ----

UpdateLineCurPos
	MOVE.W	LineCurX,D0
	MOVE.W	LineCurY,D1
	SUBQ.W	#1,D0
	MOVEQ	#2,D2
	LEA	LineCurSpriteData,A0
	JMP	SetSpritePos

;---- Scope Muting (with right mouse button) ----

CheckScopeMuting
	CMP.W	#1,CurrScreen
	BNE.B	csmRTS		; was not main screen
	TST.B	EdEnable
	BNE.B	csmRTS		; edit op. was shown
	TST.B	AboutScreenShown
	BNE.B	csmRTS		; about screen was shown
	TST.B	AnaScopFlag
	BEQ.B	csmRTS		; spectrum analyzer was shown
	TST.B	DisableScopeMuting
	BNE.B	csmRTS		; kludge/hack (hard to explain)
	MOVE.W	MouseY(PC),D0
	CMP.W	#56,D0
	BLO.B	csmRTS
	CMP.W	#88,D0
	BHI.B	csmRTS
	MOVE.W	MouseX(PC),D1	
csmcheck4
	CMP.W	#264,D1
	BLO.B	csmcheck3
	MOVEQ	#35,D0	; channel #4
	MOVEQ	#0,D6		; don't wait for mouse button up
	BSR.W	DoToggleMute
	BRA.B	csmRTS
csmcheck3
	CMP.W	#216,D1
	BLO.B	csmcheck2
	MOVEQ	#25,D0	; channel #3
	MOVEQ	#0,D6		; don't wait for mouse button up
	BSR.W	DoToggleMute
	BRA.B	csmRTS
csmcheck2
	CMP.W	#168,D1
	BLO.B	csmcheck1
	MOVEQ	#15,D0	; channel #2
	MOVEQ	#0,D6		; don't wait for mouse button up
	BSR.W	DoToggleMute
	BRA.B	csmRTS
csmcheck1
	CMP.W	#120,D1
	BLO.B	csmRTS
	MOVEQ	#0,D0	; channel #1
	MOVEQ	#0,D6	; don't wait for mouse button up
	BSR.W	DoToggleMute
csmRTS
	RTS
	
;---- Check Gadgets ----

CheckGadgets
	;BSR.W	UpdatePointerPos
	BSR.B	CheckGadgets2
	TST.B	GadgRepeat
	BNE.B	CgRepeat
	MOVEQ	#0,D0
cgloop	ADDQ.L	#1,D0
	CMP.L	#8,D0
	BEQ.B	CgRepeat
	BSR.W	Wait_4000
	BTST	#6,$BFE001	; left mouse button
	BEQ.B	cgloop
	CLR.W	UpOrDown
	BRA.W	StopInputLoop
CgRepeat
	ST	GadgRepeat
	BTST	#6,$BFE001	; left mouse button
	BEQ.B	CheckGadgets
	SF	GadgRepeat
	CLR.W	UpOrDown
	BRA.W	StopInputLoop

CheckGadgets2
	MOVE.W	MouseX(PC),MouseX2
	BNE.B	cgskip
	TST.W	MouseY
	BNE.B	cgskip
ChkQuit	LEA	QuitPTText,A0
	BSR.W	AreYouSure
	BEQ.W	ExitCleanup	; Quit PT!
	RTS
cgskip
	MOVE.W	MouseY(PC),MouseY2
	CMP.W	#4,CurrScreen
	BEQ.W	xCheckPresEdGadgs
DoCheckGadgets2
	MOVE.W	MouseX2,D0
	MOVE.W	MouseY2,D1
	CMP.W	#122,D1
	BHS.W	WantedPattGadg
	CMP.W	#111,D1
	BHS.W	CheckSmplNamOrLoad
	CMP.W	#100,D1
	BHS.W	TypeInSongName
	CMP.W	#120,D0
	BLO.B	cgskip2
	CMP.W	#6,CurrScreen
	BEQ.W	xCheckPLSTGadgs
	CMP.W	#8,CurrScreen
	BEQ.W	CheckPosEdGadgs
cgskip2	CMP.W	#2,CurrScreen
	BEQ.W	Return1
	CMP.W	#3,CurrScreen	; Screen 3 is DirScreen...
	BEQ.W	CheckDirGadgets
	CMP.W	#5,CurrScreen
	BEQ.W	CheckSetupGadgs
	CMP.W	#7,CurrScreen
	BEQ.W	CheckSetup2Gadgs
	CMP.W	#45,D1
	BHS.B	cgskip3
	CMP.W	#306,D0
	BHS.W	CheckToggle
	CMP.W	#244,D0
	BHS.B	MainMenu3
	CMP.W	#181,D0
	BHS.B	MainMenu2
	CMP.W	#120,D0
	BHS.W	MainMenu1
cgskip3	CMP.W	#120,D0
	BHS.B	cgskip4
	CMP.W	#109,D0
	BHS.W	DownGadgets
	CMP.W	#98,D0
	BHS.W	UpGadgets
	CMP.W	#62,D0
	BHS.W	EnterNumGadg
	CMP.W	#54,D0           ; The new 17-bit hex gadgets are wider and
	BHS.W	EnterNumGadgWide ; they need an extra check for the leftmost bit.
	BRA.W	PosInsDelGadgs
cgskip4	TST.B	EdEnable
	BNE.W	CheckEditOpGadgs
	BRA.W	ToggleAnaScope

xCheckPLSTGadgs		JMP	CheckPLSTGadgs

MainMenu3
	MOVE.W	MouseY2,D0
	CMP.W	#34,D0
	BHS.B	DPMGFIH
	CMP.W	#23,D0
	BHS.W	Setup
	CMP.W	#12,D0
	BHS.B	xPresetEditor
	TST.W	D0
	BHS.B	xPLST
	RTS

xPLST			JMP	PLST
xPresetEditor		JMP	PresetEditor
xCheckPresEdGadgs	JMP	CheckPresEdGadgs
DPMGFIH			JMP	SamplerScreen

MainMenu2
	MOVE.W	MouseY2,D0
	CMP.W	#3,CurrScreen
	BNE.B	mm2skip
	CMP.W	#44,D0
	BHS.W	CheckDirGadgets2
mm2skip	CMP.W	#45,D0
	BHS.W	Return1
	CMP.W	#34,D0
	BHS.W	ShowDirScreen
	CMP.W	#23,D0
	BHS.W	DoEditOp
	CMP.W	#12,D0
	BHS.W	ClearAll
	TST.W	D0
	BHS.W	StopIt
	RTS

MainMenu1
	MOVE.W	MouseY2,D0
	CMP.W	#3,CurrScreen
	BNE.B	mm1skip
	CMP.W	#44,D0
	BHS.W	CheckDirGadgets2
mm1skip	CMP.W	#45,D0
	BHS.W	Return1
	CMP.W	#34,D0
	BHS.W	RecordPattern
	CMP.W	#23,D0
	BHS.W	Edit
	CMP.W	#12,D0
	BHS.W	PlayPattern
	TST.W	D0
	BHS.W	PlaySong
	RTS
	
;---- Disk Format ----

DiskFormatGadg
	BSR.W	WaitForButtonUp
	BSR.W	Wait_4000
	BSR.W	ClearFileNames
	BSR.B	SwapFormatBox
	BSR.W	WaitForButtonUp
	LEA	AreYouSureText,A0
	JSR	ShowStatusText
fmtbuttonchk
	BSR.W	DoKeyBuffer
	MOVE.B	RawKeyCode,D0
	CMP.B	#69,D0		; ESC
	BEQ.B	fmtbend
	BSR.W	CheckPatternRedraw2
	BTST	#6,$BFE001	; left mouse button
	BNE.B	fmtbuttonchk
	MOVE.W	MouseX(PC),D0
	MOVE.W	MouseY(PC),D1
	CMP.W	#89,D0
	BLO.B	fmtbuttonchk
	CMP.W	#212,D0
	BHI.B	fmtbuttonchk
	CMP.W	#72,D1
	BLO.B	fmtbuttonchk
	CMP.W	#82,D1
	BHI.B	fmtbuttonchk
	CMP.W	#136,D0
	BLO.B	DiskFormat
	CMP.W	#166,D0
	BLO.B	fmtbuttonchk
fmtbend	BSR.B	SwapFormatBox
	BRA.W	SetErrorPtrCol

SwapFormatBox
	LEA	FormatBoxPos,A0
	LEA	FormatBoxData,A1
DoSwapBox
	MOVEQ	#39-1,D0
sfbloop1
	MOVEQ	#18-1,D1
sfbloop2
	MOVE.B	10240(A0),D2
	MOVE.B	702(A1),10240(A0)
	MOVE.B	D2,702(A1)
	MOVE.B	(A0),D2
	MOVE.B	(A1),(A0)+
	MOVE.B	D2,(A1)+
	DBRA	D1,sfbloop2
	LEA	$0016(A0),A0
	DBRA	D0,sfbloop1
	RTS

DiskFormat
	BSR.B	SwapFormatBox
	JSR	ShowAllRight
	BSR.W	ClearFileNames
	LEA	PlsEntNamText,A0
	MOVE.W	#2570,D1
	MOVEQ	#17,D0
	JSR	ShowText3
	LEA	OfVolumeText,A0
	MOVE.B	#'_',15(A0)
	MOVE.B	#'_',16(A0)
	MOVE.W	#2810,D1
	MOVEQ	#17,D0
	JSR	ShowText3
	BSR.W	SetWaitPtrCol
	MOVE.W	#2825,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.W	df_skip2
	MOVE.W	D0,D1
	LSR.W	#4,D0
	AND.W	#15,D1
	LEA	HexTable,A0
	MOVE.B	(A0,D0.W),DiskNumText1
	MOVE.B	(A0,D0.W),FormatDiskNum1
	MOVE.B	(A0,D1.W),DiskNumText2
	MOVE.B	(A0,D1.W),FormatDiskNum2
	BSR.W	ClearFileNames
	LEA	FormatAsText(PC),A0
	BSR.W	AreYouSure
	BNE.W	df_skip2
	MOVE.L	#5632,D0
	MOVEQ	#MEMF_CHIP,D1
	JSR	PTAllocMem
	MOVE.L	D0,FormatDataPtr
	BEQ.W	df_memerr
	BSR.W	DoShowFreeMem
	SUB.L	A1,A1
	MOVE.L	4.W,A6
	JSR	_LVOFindTask(A6)
	MOVE.L	D0,ProcessPtr
	LEA	TrackdiskPort,A1
	JSR	_LVOAddPort(A6)
	LEA	TrackdiskIOExtTD,A1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	LEA	TrackdiskName,A0
	JSR	_LVOOpenDevice(A6)
	MOVE.L	#TrackdiskPort,TDPortPtr
	CLR.W	CylinderNumber
	LEA	TrackdiskIOExtTD,A1
	MOVE.W	#TD_CHANGESTATE,IO_COMMAND(A1)
	JSR	_LVODoIO(A6)	; Check if disk in drive
	TST.L	IO_ACTUAL(A1)
	BEQ.B	df_indrive
	LEA	NoDiskInDriveText,A0
	JSR	ShowStatusText
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	BSR.W	SetErrorPtrCol
	BRA.W	df_cleanup

df_indrive
	LEA	TrackdiskIOExtTD,A1
	MOVE.W	#TD_PROTSTATUS,IO_COMMAND(A1)
	JSR	_LVODoIO(A6)	; Check write protect
	TST.L	IO_ACTUAL(A1)
	BEQ.B	df_noprot
	LEA	WriteProtectedText,A0
	JSR	ShowStatusText
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	BSR.W	SetErrorPtrCol
	BRA.W	df_cleanup

df_noprot
	LEA	DiskFormatText,A0
	MOVE.W	#2581-7,D1
	MOVEQ	#11,D0
	JSR	ShowText3
	LEA	InProgressText,A0
	MOVE.W	#2821-7,D1
	MOVEQ	#11,D0
	JSR	ShowText3
	CLR.L	FmtDiskOffset
	MOVE.L	FormatDataPtr,FmtDataPtr
	MOVE.L	#$00001600,FmtDataSize
	BSR.W	ClearCylinder
	BSR.W	SetDiskPtrCol
df_formatloop
	LEA	FormattingCylText,A0
	JSR	ShowStatusText
	MOVE.W	CylinderNumber,D0
	LSR.W	#1,D0
	MOVE.W	D0,WordNumber
	JSR	Print2DecDigits
	MOVE.L	4.W,A6
	LEA	TrackdiskIOExtTD,A1
	MOVE.W	#TD_FORMAT,IO_COMMAND(A1)
	JSR	_LVODoIO(A6)	; Format cylinder
	LEA	VerifyingText,A0
	JSR	ShowStatusText
	MOVE.W	CylinderNumber,D0
	LSR.W	#1,D0
	MOVE.W	D0,WordNumber
	JSR	Print2DecDigits
	MOVE.L	4.W,A6
	LEA	TrackdiskIOExtTD,A1
	MOVE.W	#CMD_READ,IO_COMMAND(A1)
	JSR	_LVODoIO(A6)	; Read cylinder to verify
	TST.B	Fmt_hmmm
	BEQ.B	df_verifyok
	LEA	VerifyErrText(PC),A0
	JSR	ShowStatusText
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	BSR.W	SetErrorPtrCol
	BRA.W	df_cleanup

VerifyErrText	dc.b "Verify error!",0
	EVEN

df_verifyok
	ADD.L	#$1600,FmtDiskOffset
	ADDQ.W	#1,CylinderNumber
	CMP.W	#160,CylinderNumber
	BNE.W	df_formatloop
	
	LEA	InitDiskText,A0
	JSR	ShowStatusText
	BSR.W	ClearCylinder
	LEA	TrackdiskIOExtTD,A1
	CLR.L	IO_OFFSET(A1)
	MOVE.L	FormatDataPtr,A2
	MOVE.L	#$444F5300,(A2) ; DOS\0
	MOVE.W	#$0370,10(A2)
	MOVE.L	#512,IO_LENGTH(A1)
	MOVE.W	#CMD_WRITE,IO_COMMAND(A1)
	MOVE.L	4.W,A6
	JSR	_LVODoIO(A6)	; Write bootblock
	MOVE.L	#DateStamp,D1
	MOVE.L	DOSBase,A6
	JSR	_LVODateStamp(A6)
	MOVE.L	FormatDataPtr,A2
	CLR.W	10(A2)
	MOVE.L	#2,(A2)
	MOVE.W	#$0048,14(A2)
	MOVE.L	#$FFFFFFFF,$0138(A2)
	MOVE.L	#$0553542D,$01B0(A2)
	MOVE.W	DiskNumText1,$01B4(A2)
	MOVE.W	#1,$01FE(A2)
	LEA	DateStamp,A0
	MOVE.L	(A0),D0
	MOVE.L	D0,$01A4(A2)
	MOVE.L	D0,$01E4(A2)
	MOVE.L	4(A0),D1
	MOVE.L	D1,$01A8(A2)
	MOVE.L	D1,$01E8(A2)
	MOVE.L	8(A0),D2
	MOVE.L	D2,$01AC(A2)
	MOVE.L	D2,$01EC(A2)
	MOVE.L	#$C00,D6
	MOVE.W	#$371,$013E(A2)
	MOVE.L	#$C000C037,$0200(A2)
	LEA	$0204(A2),A3
	MOVEQ	#55-1,D0
df_loop2
	MOVE.L	#$FFFFFFFF,(A3)+
	DBRA	D0,df_loop2
	MOVE.W	#$3FFF,$0272(A2)
	MOVE.W	#$3FFF,$02DC(A2)
	MOVE.L	A2,A3
	MOVE.L	A3,A4
	MOVEQ	#1,D7
df_loop3
	MOVEQ	#128-1,D1
	MOVEQ	#0,D0
	MOVE.L	D0,$0014(A4)
df_loop4
	SUB.L	(A3)+,D0
	DBRA	D1,df_loop4
	MOVE.L	D0,$0014(A4)
	LEA	$200(A4),A4
	DBRA	D7,df_loop3
	
	LEA	TrackdiskIOExtTD,A1
	MOVE.L	#$0006E000,IO_OFFSET(A1)
	MOVE.W	#CMD_WRITE,IO_COMMAND(A1)
	MOVE.L	#1024,IO_LENGTH(A1)
	MOVE.L	4.W,A6
	JSR	_LVODoIO(A6)
	LEA	TrackdiskIOExtTD,A1
	MOVE.W	#CMD_UPDATE,IO_COMMAND(A1)
	JSR	_LVODoIO(A6)	; Flush write buffer
df_cleanup
	LEA	TrackdiskIOExtTD,A1
	MOVE.W	#TD_MOTOR,IO_COMMAND(A1)
	CLR.L	IO_LENGTH(A1)
	JSR	_LVODoIO(A6)	; Turn off the motor
	MOVE.L	Fmt_tja,A0
	MOVE.L	$0024(A0),A0
	OR.B	#2,$0040(A0)
	LEA	TrackdiskIOExtTD,A1
	MOVE.L	4.W,A6
	JSR	_LVOCloseDevice(A6)
	LEA	TrackdiskPort,A1
	JSR	_LVORemPort(A6)
	MOVE.L	FormatDataPtr,A1
	MOVE.L	#5632,D0
	JSR	PTFreeMem
	CMP.W	#160,CylinderNumber
	BNE.W	df_skip2
	CMP.W	#'00',DiskNumText1
	BNE.W	df_skip2
	
	MOVE.L	DOSBase,A6
	MOVE.L	#150,D1	; Wait 3 sec
	JSR	_LVODelay(A6)
	
	MOVE.L	#LockNameDF0,D1
	MOVEQ	#-2,D2
	JSR	_LVOLock(A6)
	MOVE.L	D0,D6
	BEQ.B	df_skip2
	MOVE.L	D0,D1
	JSR	_LVOCurrentDir(A6)
	MOVE.L	D0,D7
	
	MOVE.L	#ModulesText,D1
	JSR	_LVOCreateDir(A6)
	MOVE.L	D0,D1
	JSR	_LVOUnLock(A6)
	
	MOVE.L	#SongsText,D1
	JSR	_LVOCreateDir(A6)
	MOVE.L	D0,D1
	JSR	_LVOUnLock(A6)
	
	MOVE.L	#SamplesText,D1
	JSR	_LVOCreateDir(A6)
	MOVE.L	D0,D1
	JSR	_LVOUnLock(A6)
	
	MOVE.L	#TracksText,D1
	JSR	_LVOCreateDir(A6)
	MOVE.L	D0,D1
	JSR	_LVOUnLock(A6)
	
	MOVE.L	#PatternsText,D1
	JSR	_LVOCreateDir(A6)
	MOVE.L	D0,D1
	JSR	_LVOUnLock(A6)
	MOVE.L	D7,D1
	JSR	_LVOCurrentDir(A6)
	MOVE.L	D6,D1
	JSR	_LVOUnLock(A6)
df_skip2
	BSR.W	SetNormalPtrCol
	JSR	ShowAllRight
	BSR.W	ClearFileNames
	ST	UpdateFreeMem
	RTS

df_memerr
	BSR.W	OutOfMemErr
	BRA.B	df_skip2

ClearCylinder
	MOVE.L	FormatDataPtr,A0
	MOVE.W	#1408-1,D0
	MOVEQ	#0,D1
ccloop	MOVE.L	D1,(A0)+
	DBRA	D0,ccloop
	RTS

FormatAsText	dc.b	'Format as ST-'
FormatDiskNum1	dc.b	$30
FormatDiskNum2	dc.b	$30
		dc.b	$3F
		dc.b	0
		dc.b	0
	
LockNameDF0	dc.b	"df0:",0
	EVEN
	
;---- Clear All Data ----

ClearAll
	ST	DisableScopeMuting
	ADDQ.L	#1,LaHeTx
	MOVE.B	DisableAnalyzer,SaveDA
	MOVE.B	ScopeEnable(PC),SaveScope
	SF	ScopeEnable
	LEA	PleaseSelectText,A0
	JSR	ShowStatusText
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	BSR.W	Wait_4000
	CMP.W	#1,CurrScreen
	BNE.B	clbskip
	TST.B	DisableAnalyzer
	BNE.B	clbskip
	ST	DisableAnalyzer
	BSR.W	ClearAnaHeights
	BSR.W	ClearRightArea
clbskip	LEA	ClearBoxData,A1
	BSR.W	SwapBoxMem
	BSR.W	WaitForButtonUp
	BSR.W	Wait_4000
clearbuttoncheck
	BTST	#2,$DFF016	; right mouse button
	BEQ.W	ClrCancel
	BSR.W	CheckPatternRedraw2
	BSR.W	DoKeyBuffer
	MOVE.B	RawKeyCode,D0
	CMP.B	#33,D0		; Pressed S
	BEQ.W	ClrSamples
	CMP.B	#24,D0		; Pressed O
	BEQ.W	ClrSong
	CMP.B	#32,D0		; Pressed A
	BEQ.W	ClrAll
	CMP.B	#51,D0		; Pressed C
	BEQ.W	ClrCancel
	CMP.B	#69,D0		; Pressed Esc
	BEQ.W	ClrCancel
	BTST	#6,$BFE001	; left mouse button
	BNE.B	clearbuttoncheck
	MOVE.W	MouseX(PC),D0
	MOVE.W	MouseY(PC),D1
	CMP.W	#166,D0
	BLO.B	clearbuttoncheck
	CMP.W	#257,D0
	BHI.B	clearbuttoncheck
	CMP.W	#58,D1
	BLO.B	clearbuttoncheck
	CMP.W	#84,D1
	BHI.B	clearbuttoncheck
	CMP.W	#204,D0
	BHS.B	samporcancel
	CMP.W	#198,D0
	BLS.B	songorall
	BRA.B	clearbuttoncheck

songorall
	CMP.W	#74,D1
	BHS.B	ClrAll
	CMP.W	#68,D1
	BLS.W	ClrSong
	BRA.W	clearbuttoncheck

samporcancel
	CMP.W	#74,D1
	BHS.B	ClrCancel
	CMP.W	#68,D1
	BLS.B	ClrSamples
	BRA.W	clearbuttoncheck

RemoveClearBox
	LEA	ClearBoxData,A1
	BSR.W	SwapBoxMem
	JSR	ShowAllRight
	BSR.W	ClearAnaHeights
	MOVE.B	SaveDA,DisableAnalyzer
	MOVE.B	SaveScope,ScopeEnable
	BSR.W	RestorePtrCol
	CLR.B	RawKeyCode
	RTS

ClrCancel
	BSR.B	RemoveClearBox
	BRA.W	SetErrorPtrCol

ClrAll	BSR.B	RemoveClearBox
	BSR.W	ClearPosEdNames
	BSR.W	DoClearSong
	BSR.W	StopIt
	BSR.B	ClrSampleInfo
	BSR.W	SetNormalPtrCol
	SF	EdEnable
	MOVE.W	#1,InsNum
	SF	DisableScopeMuting
	BRA.W	DisplayMainAll

ClrSamples
	BSR.B	RemoveClearBox
	BSR.W	StopIt
	BSR.B	ClrSampleInfo
	BSR.W	SetNormalPtrCol
	SF	EdEnable
	MOVE.W	#1,InsNum
	SF	DisableScopeMuting
	BRA.W	DisplayMainAll

ClrSong BSR.W	RemoveClearBox
	BSR.W	ClearPosEdNames
	BSR.B	DoClearSong
	BSR.W	SetNormalPtrCol
	SF	DisableScopeMuting
	BRA.W	DisplayMainAll

ClrSampleInfo
	MOVE.L	D1,-(SP)
	BSR.W	GiveBackInstrMem
	MOVE.L	SongDataPtr,A0
	LEA	sd_sampleinfo(A0),A0
	MOVE.W	#(31*30)-1,D0
csiloop	CLR.B	(A0)+
	DBRA	D0,csiloop
	MOVE.L	SongDataPtr,A1
	LEA	sd_sampleinfo(A1),A1
	MOVEQ	#31-1,D0
	MOVEQ	#1,D1
caloop2	MOVE.W	D1,28(A1)
	LEA	30(A1),A1
	DBRA	D0,caloop2
	LEA	SampleLengthAdd(PC),A3
	MOVEQ	#33-1,D0
	MOVEQ	#0,D1
csilop2	MOVE.W	D1,(A3)+
	DBRA	D0,csilop2
	MOVE.L	(SP)+,D1
	JMP	RedrawSample

DoClearSong
	BSR.W	StopIt
	CLR.B	RawKeyCode
	MOVE.L	SongDataPtr,A0
	MOVE.L	A0,A1
	MOVEQ	#20-1,D0
docla2x	CLR.B	(A0)+
	DBRA	D0,docla2x
	MOVE.L	A1,A2
	ADD.L	SongAllocSize(PC),A2
	LEA	950(A1),A1
	MOVEQ	#0,D0
caloop	MOVE.W	D0,(A1)+
	CMP.L	A1,A2
	BNE.B	caloop
	MOVE.L	SongDataPtr,A0
	MOVE.W	#$17F,sd_numofpatt(A0)
	MOVE.L	#'M.K.',sd_magicid(A0)  ; M.K. all the way...
	SF	EdEnable
	CLR.L	CurrPos
	CLR.L	SongPosition
	CLR.L	PatternPosition
	CLR.L	PlaybackSecs
	CLR.W	BlockMarkFlag
	CLR.B	MetroFlag
	MOVE.W	#1,EditMoveAdd
	MOVEQ	#0,D0
	MOVE.W	DefaultSpeed,D0
	MOVE.L	D0,CurrSpeed
	MOVE.W	Tempo,RealTempo
	BSR.W	SetTempo
	BSR.W	RestoreEffects2
	BSR.W	RestoreFKeyPos2
	BSR.B	UnmuteAll
	MOVE.W	#1,InsNum
	MOVE.L	#6,CurrSpeed
	CLR.L	PatternNumber
	CLR.W	ScrPattPos
	BSR.W	SetScrPatternPos
	JMP	RedrawPattern
	
UnmuteAll
	MOVE.W	#1,audchan1toggle
	MOVE.W	#1,audchan2toggle
	MOVE.W	#1,audchan3toggle
	MOVE.W	#1,audchan4toggle
	SF	n_muted+audchan1temp
	SF	n_muted+audchan2temp
	SF	n_muted+audchan3temp
	SF	n_muted+audchan4temp
	TST.L	RunMode
	BEQ.B	uaskip ; don't set back volumes if song is not playing
	BSR.W	SetBackCh1Vol
	BSR.W	SetBackCh2Vol
	BSR.W	SetBackCh3Vol
	BSR.W	SetBackCh4Vol
uaskip
	BRA.W	RedrawToggles

ToggleMute
	CLR.B	RawKeyCode
	TST.W	ShiftKeyStatus
	BEQ.B	tomuskp
	CLR.W	audchan1toggle
	CLR.W	audchan2toggle
	CLR.W	audchan3toggle
	CLR.W	audchan4toggle
	ST	n_muted+audchan1temp
	ST	n_muted+audchan2temp
	ST	n_muted+audchan3temp
	ST	n_muted+audchan4temp
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
tomuskp	MOVEQ	#0,D0
	MOVE.W	PattCurPos,D0
	DIVU.W	#6,D0
	MULU.W	#11,D0
	ADDQ.W	#4,D0
	MOVE.L	D6,-(SP)
	MOVEQ	#1,D6
	BSR.W	DoToggleMute
	MOVE.L	(SP)+,D6
	RTS
	
SetBackCh1Vol
	MOVE.L	A0,-(SP)
	MOVE.L	D0,-(SP)
	LEA	audchan1temp,A0
	MOVEQ	#0,D0
	MOVE.B	n_volume(A0),D0
	MOVE.W	D0,$DFF0A8
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTS
	
SetBackCh2Vol
	MOVE.L	A0,-(SP)
	MOVE.L	D0,-(SP)
	LEA	audchan2temp,A0
	MOVEQ	#0,D0
	MOVE.B	n_volume(A0),D0
	MOVE.W	D0,$DFF0B8
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTS
	
SetBackCh3Vol
	MOVE.L	A0,-(SP)
	MOVE.L	D0,-(SP)
	LEA	audchan3temp,A0
	MOVEQ	#0,D0
	MOVE.B	n_volume(A0),D0
	MOVE.W	D0,$DFF0C8
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTS
	
SetBackCh4Vol
	MOVE.L	A0,-(SP)
	MOVE.L	D0,-(SP)
	LEA	audchan4temp,A0
	MOVEQ	#0,D0
	MOVE.B	n_volume(A0),D0
	MOVE.W	D0,$DFF0D8
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTS

RestoreEffects
	MOVEQ	#0,D0
	MOVE.W	DefaultSpeed,D0
	MOVE.L	D0,CurrSpeed
	MOVE.W	Tempo,RealTempo
	BSR.W	SetTempo
	BSR.B	RestoreEffects2
	CLR.B	RawKeyCode
	LEA	EfxRestoredText(PC),A0
	JSR	ShowStatusText
	BSR.W	WaitALittle
	JMP	ShowAllRight

RestoreEffects2
	LEA	audchan1temp,A0
	BSR.B	reefsub
	LEA	audchan2temp,A0
	BSR.B	reefsub
	LEA	audchan3temp,A0
	BSR.B	reefsub
	LEA	audchan4temp,A0
reefsub	CLR.B	n_wavecontrol(A0)
	CLR.B	n_glissfunk(A0)
	CLR.B	n_finetune(A0)
	CLR.B	n_loopcount(A0)
	CLR.B	n_sampleoffset2(A0)	; used for quadrascope/sample pos line
	RTS

RestoreFKeyPos
	CLR.B	RawKeyCode
	LEA	PosRestoredText(PC),A0
	JSR	ShowStatusText
	BSR.W	WaitALittle
	JSR	ShowAllRight
RestoreFKeyPos2
	CLR.W	F6pos
	MOVE.W	#16,F7pos
	MOVE.W	#32,F8pos
	MOVE.W	#48,F9pos
	MOVE.W	#63,F10pos
	RTS

EfxRestoredText	dc.b 'efx restored !',0
PosRestoredText	dc.b 'pos restored !',0
	EVEN

GiveBackInstrMem
	MOVEQ	#1,D7
gbimloop
	MOVE.W	D7,D2
	LSL.W	#2,D2
	LEA	SamplePtrs,A0
	MOVE.L	(A0,D2.W),D1
	BEQ.B	gbimskip
	MOVE.L	124(A0,D2.W),D0
	CLR.L	(A0,D2.W)
	CLR.L	124(A0,D2.W)
	MOVE.L	D1,A1
	JSR	PTFreeMem
gbimskip
	ADDQ.W	#1,D7
	CMP.W	#32,D7
	BNE.B	gbimloop
	ST	UpdateFreeMem
	JMP	FreeCopyBuf

;---- Setup ----

Setup	CMP.W	#7,LastSetupScreen
	BEQ.W	Setup2
	CLR.W	LastSetupScreen
	BSR.W	WaitForButtonUp
	MOVE.W	#5,CurrScreen
	ST	DisableAnalyzer
	ST	NoSampleInfo
	BSR.W	Clear100Lines
	BSR.W	ShowSetupScreen
	BEQ.W	ExitSetup
RefreshSetup
	BSR.B	AdjustVuSprites
	BSR.W	UpdateCursorPos
	BSR.W	UpdateSysReq
	BSR.W	SetScreenColors
	BSR.W	Show_MS
	CMP.W	#5,CurrScreen
	BNE.W	Return1
	BSR.W	MarkColor
	BSR.W	ShowSetupToggles
	BSR.W	ShowSplit
	BSR.W	ShowPrintPath
	BSR.W	ShowKeyRepeat
	BSR.W	ShowExtCommand
	BSR.W	ShowMultiSetup
	BSR.W	ShowConfigNumber
	BRA.W	ShowAccidental ; Always last (redraws pattern) !

AdjustVuSprites
	LEA	CopperList1+2,A0
	TST.B	ScreenAdjustFlag
	BEQ.B	avusskip
	MOVE.W	#$2C71,(A0)
	MOVE.W	#$2CB1,4(A0)
	MOVE.W	#$0030,8(A0)
	MOVE.W	#$00C8,12(A0)
	MOVE.W	#$E953,VUSpriteData1
	MOVE.W	#$E977,VUSpriteData2
	MOVE.W	#$E99B,VUSpriteData3
	MOVE.W	#$E9BF,VUSpriteData4
	RTS
avusskip
	MOVE.W	#$2C81,(A0)
	MOVE.W	#$2CC1,4(A0)
	MOVE.W	#$0038,8(A0)
	MOVE.W	#$00D0,12(A0)
	MOVE.W	#$E95B,VUSpriteData1
	MOVE.W	#$E97F,VUSpriteData2
	MOVE.W	#$E9A3,VUSpriteData3
	MOVE.W	#$E9C7,VUSpriteData4
	RTS

ShowSetupScreen
	MOVE.L	SetupMemPtr(PC),D0
	BNE.W	DecompactSetup
	BSR.B	SaveMainPic
	TST.L	SetupMemPtr
	BEQ.W	Return1
	BRA.W	DecompactSetup

SaveMainPic
	MOVE.L	#8000,D0
	MOVEQ	#MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,SetupMemPtr
	BEQ.W	OutOfMemErr
	MOVE.L	D0,A1
	LEA	BitplaneData,A0
	MOVEQ	#2-1,D2		; two bitplanes
sssloop1
	MOVE.W	#1000-1,D0	; 100 scanlines
sssloop2
	MOVE.L	(A0)+,(A1)+
	DBRA	D0,sssloop2
	LEA	6240(A0),A0
	DBRA	D2,sssloop1
	RTS

RestoreMainPic
	MOVE.L	SetupMemPtr(PC),D0
	BEQ.B	ssxexit
	MOVE.L	D0,A1
	LEA	BitplaneData,A0
	MOVEQ	#2-1,D2		; two bitplanes
ssxloop1
	MOVE.W	#1000-1,D0	; 100 scanlines
ssxloop2
	MOVE.L	(A1)+,(A0)+
	DBRA	D0,ssxloop2
	LEA	6240(A0),A0
	DBRA	D2,ssxloop1
ssxfree
	MOVE.L	SetupMemPtr(PC),A1
	CLR.L	SetupMemPtr
	MOVE.L	#8000,D0
	JSR	PTFreeMem
ssxexit	RTS

	CNOP 0,4
SetupMemPtr	dc.l 0

DecompactSetup2
	LEA	Setup2Data+4,A0
	MOVE.L	#Setup2Size-4-8,D0
	BRA.B	decoset

DecompactSetup
	LEA	SetupScreenData+4,A0
	MOVE.L	#SetupScreenSize-4-8,D0
decoset	LEA	BitplaneData,A1
	MOVE.L	A1,A2
	LEA	4000(A2),A2
	MOVEM.L	D3/D4,-(SP)
	MOVEQ	#-75,D3	; 181 signed (compactor code)
	MOVEQ	#-1,D4
dcsloop	MOVE.B	(A0)+,D1
	CMP.B	D3,D1
	BEQ.B	DecodeIt2
	MOVE.B	D1,(A1)+
	CMP.L	A2,A1
	BLO.B	dcslop2
	LEA	6240(A1),A1
	MOVE.L	D4,A2
dcslop2
	SUBQ.L	#1,D0
	BGT.B	dcsloop
	MOVEM.L	(SP)+,D3/D4
	MOVEQ	#-1,D0
	RTS

DecodeIt2
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
dcdlop2	MOVE.B	D2,(A1)+
	CMP.L	A2,A1
	BLO.B	dcdskp2
	LEA	6240(A1),A1
	MOVE.L	D3,A2
dcdskp2	DBRA	D1,dcdlop2
	SUBQ.L	#2,D0
	BRA.B	dcslop2
	
; Gadgets

CheckSetupGadgs
	TST.L	SplitAddress
	BEQ.B	csgskip
	CLR.L	SplitAddress
	BSR.W	ShowSplit
csgskip
	MOVE.W	MouseX2,D0
	MOVE.W	MouseY2,D1
	CMP.W	#210,D0
	BHS.W	SetupMenu3
	CMP.W	#108,D0
	BHS.B	SetupMenu2
;---- Menu 1 ----
	CMP.W	#11,D1
	BLS.W	LoadConfig
	CMP.W	#22,D1
	BLS.W	SaveConfig
	CMP.W	#33,D1
	BLS.W	ResetAll
	CMP.W	#44,D1
	BLS.W	ExtCommand
	CMP.W	#55,D1
	BLS.W	MultiSetup
	CMP.W	#66,D1
	BLS.W	SetRed
	CMP.W	#77,D1
	BLS.W	SetGreen
	CMP.W	#88,D1
	BLS.W	SetBlue
	CMP.W	#99,D1
	BLS.W	ColorGadgets
	RTS

SetupMenu2
	CMP.W	#11,D1
	BLS.B	sm2exit
	CMP.W	#55,D1
	BLS.W	SetSplit
	CMP.W	#66,D1
	BLS.W	SetKeyRepeat
	CMP.W	#77,D1
	BLS.W	ToggleAccidental
	CMP.W	#88,D1
	BLS.W	PrintSong
	CMP.W	#99,D1
	BLS.W	EnterPrintPath
sm2exit	RTS

SetupMenu3
	CMP.W	#11,D1
	BLS.B	ExitOrClear
	CMP.W	#22,D1
	BLS.W	ToggleSplit
	CMP.W	#33,D1
	BLS.W	ToggleFilter
	CMP.W	#44,D1
	BLS.W	ToggleTransDel
	CMP.W	#55,D1
	BLS.W	ToggleShowDec
	CMP.W	#66,D1
	BLS.W	ToggleAutoDir
	CMP.W	#77,D1
	BLS.W	ToggleAutoExit
	CMP.W	#88,D1
	BLS.W	ToggleModOnly
	CMP.W	#99,D1
	BLS.W	ToggleMIDI
	RTS

ExitOrClear
	CMP.W	#263,D0
	BLS.W	ClearSplit
	CMP.W	#306,D0
	BHS.W	Setup2
ExitSetup
	BSR.W	WaitForButtonUp
	CMP.W	#7,CurrScreen
	BNE.B	exsetupskip
	TST.B	SwitchTogglesFlag
	BEQ.B	exsetupskip
	BSR.W	Setup2SwitchToggles
exsetupskip
	MOVE.W	CurrScreen,LastSetupScreen
	CLR.B	RawKeyCode
	CLR.L	SplitAddress
	BSR.W	RestoreMainPic
	SF	NoSampleInfo
	BSR.W	SetupVUCols
	BSR.W	SetupAnaCols
	BSR.W	Clear100Lines
	BRA.W	DisplayMainAll

LastSetupScreen	dc.w 0

ToggleSplit
	EOR.B	#1,SplitFlag
	BRA.W	ShowSetupToggles

ToggleFilter
	BCHG	#1,$BFE001
	BRA.W	ShowSetupToggles

ToggleTransDel
	EOR.B	#1,TransDelFlag
	BRA.B	ShowSetupToggles

ToggleShowDec
	EOR.B	#1,ShowDecFlag
	ST	UpdateFreeMem
	BRA.B	ShowSetupToggles

ToggleAutoDir
	EOR.B	#1,AutoDirFlag
	BRA.B	ShowSetupToggles

ToggleAutoExit
	EOR.B	#1,AutoExitFlag
	BRA.B	ShowSetupToggles

ToggleModOnly
	EOR.B	#1,ModOnlyFlag
	LEA	FileNamesPtr(PC),A0
	CLR.L	4(A0)
	BRA.B	ShowSetupToggles

ToggleMIDI
	EOR.B	#1,MIDIFlag
	BSR.B	ShowSetupToggles
tstmidi	TST.B	MIDIFlag
	BNE.B	xOpenMidi
	JMP	CloseMIDI

xOpenMidi	JMP	OpenMIDI

ClearSplit
	BSR.W	WaitForButtonUp
	LEA	ClearSplitText,A0
	BSR.W	AreYouSure
	BNE.B	clspexit
	LEA	SplitData,A0
	MOVEQ	#16-1,D0
clsploop
	CLR.B	(A0)+
	DBRA	D0,clsploop
	BRA.B	ShowSplit
clspexit	RTS
	
ShowSetupToggles
	CLR.B	RawKeyCode
	BSR.W	Show_MS
	CMP.W	#5,CurrScreen
	BNE.B	clspexit
	MOVE.B	$BFE001,D0
	LSR.B	#1,D0
	AND.B	#1,D0
	EOR.B	#1,D0
	MOVE.B	D0,FilterFlag
	LEA	SplitFlag,A4
	MOVE.W	#3,TextLength
	MOVEQ	#8-1,D7
	MOVE.W	#636,D6
sstloop
	MOVE.W	D6,TextOffset
	LEA	ToggleOFFText(PC),A0
	TST.B	(A4)+
	BEQ.B	sstskip
	LEA	ToggleONText(PC),A0
sstskip
	JSR	ShowText2
	ADD.W	#440,D6
	DBRA	D7,sstloop
	BRA.W	WaitForButtonUp

ToggleONText2	dc.b	' '
ToggleONText	dc.b	'on '
ToggleOFFText	dc.b	'off '
ToggleCURText	dc.b	'cur '
ToggleBUFText	dc.b	'buf '
	EVEN

ShowSplit
	BSR.B	CalculateSplit
	CMP.W	#5,CurrScreen
	BNE.B	shspexit
	LEA	SplitData,A3
	MOVE.L	NoteNamesPtr,A4
	MOVEQ	#0,D5
	MOVE.W	#614,D6
	CLR.W	WordNumber
shsploop
	MOVE.W	D6,TextOffset
	MOVE.B	(A3,D5.W),WordNumber+1 ; instr
	JSR	PrintHexByte
	ADDQ.W	#4,D6
	MOVE.W	D6,D1
	MOVEQ	#0,D0
	MOVE.B	1(A3,D5.W),D0 ; note
	LSL.W	#2,D0
	LEA	(A4,D0.W),A0
	MOVEQ	#4,D0
	JSR	ShowText3
	ADDQ.L	#5,D6
	MOVE.W	D6,D1
	MOVEQ	#0,D0
	MOVE.B	2(A3,D5.W),D0 ; trans
	LSL.W	#2,D0
	LEA	(A4,D0.W),A0
	MOVEQ	#4,D0
	JSR	ShowText3
	ADD.W	#431,D6
	ADDQ.W	#4,D5
	CMP.W	#16,D5
	BNE.B	shsploop
shspexit
	RTS

CalculateSplit
	LEA	SplitTransTable,A0
	LEA	SplitInstrTable,A1
	LEA	SplitData,A2
	MOVEQ	#0,D0
casploop
	MOVE.B	D0,(A0,D0.W)
	CLR.B	(A1,D0.W)
	ADDQ.W	#1,D0
	CMP.W	#37,D0
	BLS.B	casploop
	
	MOVE.B	1(A2),-(SP)
	MOVE.B	1+4(A2),-(SP)
	MOVE.B	1+8(A2),-(SP)
	MOVE.B	1+12(A2),-(SP) ; note
	
	MOVEQ	#4-1,D4
caspbigloop
	MOVEQ	#127,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
casploop2
	CMP.B	1(A2,D1.W),D0 ; note
	BLS.B	caspskip
	MOVE.L	D1,D2
	MOVE.B	1(A2,D1.W),D0 ; note
caspskip
	ADDQ.W	#4,D1
	CMP.W	#16,D1
	BNE.B	casploop2
	
	MOVEQ	#0,D0
	MOVE.B	1(A2,D2.W),D0 ; note
	MOVE.B	#127,1(A2,D2.W) ; note
	MOVE.B	2(A2,D2.W),D1 ; trans
casploop3
	MOVE.B	D1,(A0,D0.W)
	MOVE.B	(A2,D2.W),(A1,D0.W) ; instr
	ADDQ.W	#1,D1
	CMP.W	#36,D1
	BLO.B	caspskip2
	MOVEQ	#35,D1
caspskip2
	ADDQ.W	#1,D0
	CMP.W	#36,D0
	BLO.B	casploop3
	DBRA	D4,caspbigloop
	
	MOVE.B	(SP)+,1+12(A2)
	MOVE.B	(SP)+,1+8(A2)
	MOVE.B	(SP)+,1+4(A2)
	MOVE.B	(SP)+,1(A2) ; note
	RTS

SetSplit
	LEA	SplitData,A2
	AND.L	#$FFFF,D1
	SUBQ.W	#1,D1
	DIVU.W	#11,D1
	SUBQ.W	#1,D1
	MOVE.W	D1,D7
	LSL.W	#2,D7
	MULU.W	#440,D1
	ADD.W	#600,D1
	CMP.W	#176,D0
	BHS.B	SetSplitTranspose
	CMP.W	#136,D0
	BHS.B	SetSplitNote
	ADD.W	#14,D1
	MOVE.W	D1,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.W	ShowSplit
	CMP.B	#$1F,D0
	BLS.B	setskip
	MOVEQ	#$1F,D0
setskip	MOVE.B	D0,(A2,D7.W) ; instr
	BRA.W	ShowSplit

SetSplitNote
	MOVE.L	D1,-(SP)
	BSR.W	ShowSplit
	MOVE.L	(SP)+,D1
	ADD.W	#18,D1
	MOVEQ	#3,D0
	LEA	SpcNoteText,A0
	JSR	ShowText3
	LEA	1(A2,D7.W),A0 ; note
	MOVE.L	A0,SplitAddress
	BRA.W	WaitForButtonUp

SetSplitTranspose
	MOVE.L	D1,-(SP)
	BSR.W	ShowSplit
	MOVE.L	(SP)+,D1
	ADD.W	#$17,D1
	MOVEQ	#3,D0
	LEA	SpcNoteText,A0
	JSR	ShowText3
	LEA	2(A2,D7.W),A0 ; trans
	MOVE.L	A0,SplitAddress
	BRA.W	WaitForButtonUp

SetKeyRepeat
	CMP.W	#188,D0
	BHS.B	skrep2
	MOVE.W	#2381,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	ShowKeyRepeat
	MOVE.B	D0,KeyRepDelay+1
	BRA.B	ShowKeyRepeat
skrep2	MOVE.W	#2384,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	ShowKeyRepeat
	MOVE.B	D0,KeyRepSpeed+1
ShowKeyRepeat
	MOVE.W	#2381,TextOffset
	MOVE.W	KeyRepDelay,WordNumber
	JSR	PrintHexByte
	ADDQ.W	#1,TextOffset
	MOVE.W	KeyRepSpeed,WordNumber
	JMP	PrintHexByte

ToggleAccidental
	MOVE.L	#NoteNames1,NoteNamesPtr
	EOR.B	#1,Accidental
	BEQ.B	ShowAccidental
	MOVE.L	#NoteNames2,NoteNamesPtr
ShowAccidental
	LEA	AccidentalText(PC),A0
	TST.B	Accidental
	BEQ.B	shacskp
	LEA	AccidentalText+1(PC),A0
shacskp	MOVEQ	#1,D0
	MOVE.W	#2824,D1
	JSR	ShowText3
	BRA	RedrawPattern

AccidentalText	dc.b '#¡'
	EVEN

Return5
	RTS
	
LoadConfigOnStartup
	BRA.W	DoLoadConfig
	
LoadConfig
	CMP.W	#84,D0
	BHS.W	SetConfigNumber
	LEA	LoadConfigText,A0
	BSR.W	AreYouSure
	BNE.B	Return5
	BSR.W	WaitForButtonUp
	LEA	LoadingCfgText(PC),A0
	BSR.W	ShowStatusText
DoLoadConfig
	BSR.W	StorePtrCol
	BSR.W	PutConfigNumber	
	MOVE.L	#ConfigName,D1
	MOVE.L	#1005,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,D7
	BNE.B	cfgopok
	LEA	PTPath,A0
	BSR.W	CopyPath
	LEA	ConfigName(PC),A0
	MOVEQ	#13-1,D0
cfgnlop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,cfgnlop
	MOVE.L	#FileName,D1
	MOVE.L	#1005,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,D7
	BEQ.W	ConfigErr
cfgopok	BSR.W	SetDiskPtrCol
	MOVE.L	D7,D1
	CLR.L	ConfigID
	CLR.L	ConfigID2
	MOVE.L	#ConfigID,D2
	MOVEQ	#8,D3
	JSR	_LVORead(A6)
	CMP.L	#"PT2.",ConfigID
	BNE.B	cfgerr2
	CMP.L	#"3 Co",ConfigID2
	BNE.B	cfgerr2
	LEA	SetupData+8,A0
	MOVE.L	D7,D1
	MOVE.L	A0,D2
	MOVE.L	#ConfigFileSize-8,D3
	JSR	_LVORead(A6)
lcfgend	MOVE.L	D7,D1
	JSR	_LVOClose(A6)
	BSR.W	ShowAllRight
	BSR.W	RestorePtrCol
cfgupda
	BSR.W	CopyCfgData
	BSR.W	tstmidi
	JSR	ChangeCopList
	MOVE.L	#NoteNames1,NoteNamesPtr
	TST.B	Accidental
	BEQ.B	cfgoskip
	MOVE.L	#NoteNames2,NoteNamesPtr
cfgoskip
	BSR.W	RedrawPattern
	BRA.W	RefreshSetup

ConfigErr
	BSET	#2,InitError
	LEA	FileNotFoundText(PC),A0
cferr	BSR	ShowStatusText
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	BRA	ErrorRestoreCol

cfgerr2	BSR.B	ConfigErr2
	BRA.B	lcfgend

ConfigErr2
	BSET	#3,InitError
	LEA	NotAConfFileText(PC),A0
	BRA.B	cferr

ConfigErr3
	LEA	CantCreateFiText(PC),A0
	BRA.B	cferr

FileNotFoundText	dc.b "config not found!",0
NotAConfFileText	dc.b "not a config file",0
CantCreateFiText	dc.b "can't create file",0
	EVEN

SaveConfig
	CMP.W	#84,D0
	BHS.W	SetConfigNumber
	LEA	SaveConfigText,A0
	BSR.W	AreYouSure
	BNE.W	cfglrts
	BSR.W	StorePtrCol
	BSR.W	SetDiskPtrCol
	BSR.W	PutConfigNumber
	LEA	SavingCfgText(PC),A0
	BSR.W	ShowStatusText
	MOVE.L	DOSBase,A6
	LEA	PTPath,A0
	BSR.W	CopyPath
	LEA	TrackPath2,A0
	LEA	TrackPath,A2
	MOVEQ	#8-1,D0
cfgllop1	MOVE.L	(A0)+,(A2)+
	DBRA	D0,cfgllop1
	LEA	PattPath2,A0
	LEA	PattPath,A2
	MOVEQ	#8-1,D0
cfgllop2	MOVE.L	(A0)+,(A2)+
	DBRA	D0,cfgllop2
	LEA	ConfigName(PC),A0
	MOVEQ	#13-1,D0
cfgllop3	MOVE.B	(A0)+,(A1)+
	DBRA	D0,cfgllop3
	MOVE.L	#FileName,D1
	MOVE.L	#1006,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,D7
	BEQ.W	ConfigErr3
	MOVE.L	D0,D1
	MOVE.L	#SetupData,D2
	MOVE.W	#ConfigFileSize,D3
	JSR	_LVOWrite(A6)
	CMP.L	#ConfigFileSize,D3
	BEQ.B	cfglskip
	JSR	CantSaveFile
cfglskip
	MOVE.L	D7,D1
	JSR	_LVOClose(A6)
	BSR.W	ShowAllRight
	BRA.W	RestorePtrCol
cfglrts
	RTS
	
SetConfigNumber
	MOVE.W	#611,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	ShowConfigNumber
	MOVE.W	D0,ConfigNumber
ShowConfigNumber
	MOVE.W	#611,TextOffset
	MOVE.W	ConfigNumber(PC),WordNumber
	BRA.W	PrintHexByte

PutConfigNumber
	MOVE.W	ConfigNumber(PC),D0
	LEA	ConfigName+12(PC),A0
	JMP	IntToHex2

	CNOP 0,4
ConfigNumber	dc.w 0
ConfigID	dc.l 0
ConfigID2	dc.l 0
ConfigName	dc.b 'PT.Config-00',0
LoadingCfgText	dc.b 'loading config',0
SavingCfgText	dc.b 'saving config',0
	EVEN

ResetAll
	LEA	ResetAllText,A0
	BSR.W	AreYouSure
	BNE.W	Return2
DoResetAll
	LEA	DefaultSetupData,A0
	LEA	SetupData,A1
	MOVE.W	#ConfigFileSize-1,D0
rsaloop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,rsaloop
	BRA.W	cfgupda

ExtCommand
	CMP.W	#11,D0
	BLO.B	excolab
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	ExtCommands,A6
	MOVEQ	#0,D1
	MOVE.B	ExtCmdNumber(PC),D1
	LSL.B	#5,D1
	ADD.L	D1,A6
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#31,TextEndPtr
	MOVE.W	#11,TextLength
	MOVE.W	#1482,A4
	BSR.W	GetTextLine
	BRA.W	RestorePtrCol

ShowExtCommand
	LEA	ExtCommands,A0
	MOVEQ	#0,D1
	MOVE.B	ExtCmdNumber(PC),D1
	LSL.B	#5,D1
	ADD.L	D1,A0
	MOVEQ	#11,D0
	MOVE.W	#1482,D1
	BRA.W	ShowText3

excolab	BTST	#2,$DFF016	; right mouse button
	BEQ.B	excorun
	ADDQ.B	#1,ExtCmdNumber
	AND.B	#7,ExtCmdNumber
	BSR.B	ShowExtCommand
	BSR.W	Wait_4000
	BSR.W	Wait_4000
	BRA.W	Wait_4000

excorun LEA	ExtCommands,A0
	MOVEQ	#0,D1
	MOVE.B	ExtCmdNumber(PC),D1
	LSL.B	#5,D1
	ADD.L	D1,A0
	TST.B	(A0)
	BEQ.W	Return2
	MOVE.L	A0,ExtCmdAddress
	MOVE.L	IntuitionBase,A6
	JSR	_LVOOpenWorkbench(A6)
	JSR	_LVOWBenchToFront(A6)
	MOVE.L	#ExtCmdConsole,D1
	MOVE.L	#1005,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,ExtCmdWindow
	BEQ.B	winderr
	LSL.L	#2,D0
	MOVE.L	D0,A0
	MOVE.L	PTProcess,A1
	MOVE.L	8(A0),$A4(A1)
	BSR.W	GotoCLI
	MOVE.L	ExtCmdWindow(PC),D1
	BEQ.W	Return2
	MOVE.L	DOSBase,A6
	JSR	_LVOClose(A6)
	CLR.L	ExtCmdWindow
	RTS

winderr	LEA	ConsoleErrText(PC),A0
	BSR.W	ShowStatusText
	BRA.W	SetErrorPtrCol

	CNOP 0,4
ExtCmdAddress	dc.l 0
ExtCmdWindow	dc.l 0
ExtCmdConsole	dc.b "CON:0/0/640/150/ProTracker Output Window",0
ConsoleErrText	dc.b "Can't open window",0
ExtCmdNumber	dc.b 0
	EVEN

MultiSetup
	CMP.W	#44,D0
	BLO.W	Return2
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	MOVE.W	#1,GetLineFlag
	SUB.W	#44,D0
	LSR.W	#4,D0
	MOVE.B	D0,musepos
museset	MOVEQ	#0,D0
	MOVE.B	musepos(PC),D0
	MOVE.L	D0,D1
	LSL.W	#4,D1
	MOVE.W	#52,LineCurX
	MOVE.W	#53,LineCurY
	ADD.W	D1,LineCurX
	LEA	MultiModeNext,A1
	LEA	(A1,D0.W),A1
	BSR.W	UpdateLineCurPos
muselop	BSR.W	GetHexKey
	CMP.B	#128,D1
	BEQ.B	musenul
	TST.B	D1
	BEQ.B	musenul
	CMP.B	#4,D1
	BHI.B	muselop
	MOVE.B	D1,(A1)
	BSR.B	ShowMultiSetup
	MOVEQ	#1,D0
musenul	TST.B	D0
	BEQ.B	museabo
	ADD.B	D0,musepos
	AND.B	#3,musepos
	BSR.W	Wait_4000
	BSR.W	Wait_4000
	BSR.W	Wait_4000
	BRA.B	museset

museabo	BSR.W	RestorePtrCol
	CLR.W	GetLineFlag
	CLR.W	LineCurX
	MOVE.W	#270,LineCurY
	BSR.W	UpdateLineCurPos
ShowMultiSetup
	MOVE.W	#1926,TextOffset
	MOVE.B	MultiModeNext,D0
	BSR.W	PrintHexDigit
	MOVE.W	#1928,TextOffset
	MOVE.B	MultiModeNext+1,D0
	BSR.W	PrintHexDigit
	MOVE.W	#1930,TextOffset
	MOVE.B	MultiModeNext+2,D0
	BSR.W	PrintHexDigit
	MOVE.W	#1932,TextOffset
	MOVE.B	MultiModeNext+3,D0
	BRA.W	PrintHexDigit

musepos	dc.b 0
	EVEN

SetRed	CMP.W	#82,D0
	BHS.W	SelectColor
setr2	BSR.W	GetColPos
	AND.W	#$0F00,D2
	LSR.W	#8,D2
	CMP.B	D2,D0
	BEQ.B	setrskp
	AND.W	#$00FF,D1
	LSL.W	#8,D0
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	ShowColSliders
	BSR.W	SetScreenColors
setrskp	BTST	#6,$BFE001	; left mouse button
	BEQ.B	setr2
	RTS

SetGreen	CMP.W	#82,D0
	BHS.W	SelectColor
setg2	BSR.B	GetColPos
	AND.W	#$00F0,D2
	LSR.W	#4,D2
	CMP.B	D2,D0
	BEQ.B	setgskp
	AND.W	#$0F0F,D1
	LSL.W	#4,D0
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	ShowColSliders
	BSR.W	SetScreenColors
setgskp	BTST	#6,$BFE001	; left mouse button
	BEQ.B	setg2
	RTS

SetBlue	CMP.W	#82,D0
	BHS.W	SelectColor
setb2	BSR.B	GetColPos
	AND.W	#$000F,D2
	CMP.B	D2,D0
	BEQ.B	setbskp
	AND.W	#$0FF0,D1
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.B	ShowColSliders
	BSR.W	SetScreenColors
setbskp	BTST	#6,$BFE001	; left mouse button
	BEQ.B	setb2
	RTS

GetColPos
	MOVEQ	#0,D0
	MOVE.W	MouseX(PC),D0
	CMP.W	#26,D0
	BHS.B	gcpskp2
	MOVEQ	#0,D0
	BRA.B	gcpskip
gcpskp2 SUB.W	#26,D0
	AND.L	#$FFFF,D0
	DIVU.W	#3,D0
	AND.L	#$FF,D0
	CMP.W	#15,D0
	BLS.B	gcpskip
	MOVEQ	#15,D0
gcpskip	CMP.W	#7,CurrScreen
	BEQ.W	GetColAddr
	LEA	ColorTable,A0
	MOVE.W	CurrColor(PC),D1
	ADD.W	D1,D1
	LEA	(A0,D1.W),A0
	MOVE.W	(A0),D1
	MOVE.W	D1,D2
	RTS

ShowColSliders
	LEA	ColSliders(PC),A2
	LEA	TextBitplane+3282,A1
	BSR.B	gcpskip
	AND.W	#$000F,D1
	BSR.B	ShowOneSlider
	LEA	TextBitplane+2842,A1
	BSR.B	gcpskip
	AND.W	#$00F0,D1
	LSR.W	#4,D1
	BSR.B	ShowOneSlider
	LEA	TextBitplane+2402,A1
	BSR.B	gcpskip
	AND.W	#$0F00,D1
	LSR.W	#8,D1
ShowOneSlider
	CLR.L	(A1)
	CLR.L	4(A1)
	CLR.L	40(A1)
	CLR.L	44(A1)
	CLR.L	80(A1)
	CLR.L	84(A1)
	MOVE.W	D1,D3
	ADD.W	D3,D3
	ADD.W	D3,D3
	MOVE.W	2(A2,D3.W),D4
	MOVE.B	(A2,D3.W),(A1,D4.W)
	MOVE.B	1(A2,D3.W),1(A1,D4.W)
	MOVE.B	(A2,D3.W),40(A1,D4.W)
	MOVE.B	1(A2,D3.W),41(A1,D4.W)
	MOVE.B	(A2,D3.W),80(A1,D4.W)
	MOVE.B	1(A2,D3.W),81(A1,D4.W)
ColorRTS
	RTS

ColSliders
	dc.w %0000000001111100,0
	dc.w %0000111110000000,1
	dc.w %0000000111110000,1
	dc.w %0000000000111110,1
	dc.w %0000011111000000,2
	dc.w %0000000011111000,2
	dc.w %0000000000011111,2
	dc.w %0000001111100000,3
	dc.w %0000000001111100,3
	dc.w %0000111110000000,4
	dc.w %0000000111110000,4
	dc.w %0000000000111110,4
	dc.w %0000011111000000,5
	dc.w %0000000011111000,5
	dc.w %0000000000011111,5
	dc.w %0000001111100000,6

SelectColor
	CMP.W	#84,D1
	BHS.B	ColorRTS
	LEA	TextBitplane+2410,A0
	MOVEQ	#25-1,D2
slcloop	CLR.L	(A0)
	LEA	40(A0),A0	
	DBRA	D2,slcloop
	
	AND.L	#$FFFF,D0
	AND.L	#$FFFF,D1
	SUB.W	#82,D0
	DIVU.W	#13,D0
	SUB.W	#60,D1
	DIVU.W	#6,D1
	MOVE.W	D0,D2
	LSL.W	#2,D2
	ADD.W	D1,D2
	MOVE.W	D2,CurrColor
MarkColor
	BSR.W	gcpskip
	MOVE.L	A0,UndoColAddr
	MOVE.W	D1,UndoCol
	BSR.W	ShowColSliders
	BSR.B	BlockColors
	MOVE.W	CurrColor(PC),D0
	MOVE.W	D0,D1
	AND.W	#$0003,D1
	MULU.W	#6*40,D1
	LEA	TextBitplane,A0
	ADD.W	D1,A0
	LEA	2410(A0),A0
	BTST	#2,D0
	BNE.B	slcskip
	MOVE.W	#$3FF0,(A0)
	MOVE.W	#$3FF0,240(A0)
	MOVEQ	#5-1,D0
slclop2	LEA	40(A0),A0
	MOVE.W	#$2010,(A0)
	DBRA	D0,slclop2
	BRA.W	WaitForButtonUp

slcskip	MOVE.L	#$0001FF80,(A0)
	MOVE.L	#$0001FF80,240(A0)
	MOVEQ	#5-1,D0
slclop3	LEA	40(A0),A0
	MOVE.L	#$0001FF80,(A0)
	DBRA	D0,slclop3
	BRA.W	WaitForButtonUp

BlockColors
	LEA	TextBitplane+2452,A0
	MOVEQ	#4-1,D1
suploop2
	MOVEQ	#5-1,D0
suploop3
	MOVE.B	#$FF,(A0)
	LEA	40(A0),A0
	DBRA	D0,suploop3
	LEA	40(A0),A0
	DBRA	D1,suploop2
	RTS

ColorGadgets
	CMP.W	#79,D0
	BHS.W	SetDefaultCol
	CMP.W	#33,D0
	BHS.B	CancelCol
	MOVE.L	UndoColAddr(PC),A0
	MOVE.W	UndoCol(PC),D0
	MOVE.W	(A0),UndoCol
	MOVE.W	D0,(A0)
	BSR.W	ShowColSliders
	BRA.W	SetScreenColors

CancelCol
	LEA	CanCols(PC),A0
	LEA	ColorTable,A1
	MOVEQ	#8-1,D0
cacolop	MOVE.W	(A0)+,(A1)+
	DBRA	D0,cacolop
	BSR.W	ShowColSliders
	BRA.W	SetScreenColors

CopyCfgData
	LEA	ColorTable,A0
	LEA	CanCols(PC),A1
	MOVEQ	#8-1,D0
cocclop	MOVE.W	(A0)+,(A1)+
	DBRA	D0,cocclop
	LEA	TrackPath2,A0
	MOVE.W	#128-1,D0
cocclp2	CLR.B	(A0)+
	DBRA	D0,cocclp2
	LEA	ModulesPath2,A0
	MOVE.W	#196-1,D0
cocclp3	CLR.B	(A0)+
	DBRA	D0,cocclp3
	LEA	ModulesPath,A0
	LEA	ModulesPath2,A1
	BSR.B	cocclp4
	LEA	SongsPath,A0
	LEA	SongsPath2,A1
	BSR.B	cocclp4
	LEA	TrackPath,A0
	LEA	TrackPath2,A1
	BSR.B	cocclp4
	LEA	PattPath,A0
	LEA	PattPath2,A1
	BSR.B	cocclp4
	LEA	SamplePath,A0
	LEA	SamplePath2,A1
cocclp4	MOVE.B	(A0)+,(A1)+
	BNE.B	cocclp4
	LEA	VUmeterColors,A0
	LEA	SaveColors,A1
	MOVEQ	#(40+48)-1,D0
cocclp5	MOVE.W	(A0)+,(A1)+
	DBRA	D0,cocclp5
	RTS

	CNOP 0,4
UndoColAddr	dc.l 0
CanCols		dc.w 0,0,0,0,0,0,0,0
UndoCol		dc.w 0

SetDefaultCol
	LEA	DefCol,A0
	LEA	ColorTable,A1
	MOVEQ	#8-1,D0
sdcloop	MOVE.W	(A0)+,(A1)+
	DBRA	D0,sdcloop
	BSR.W	ShowColSliders
SetScreenColors
	JSR	SetupAnaCols
SetScreenColors2
	LEA	ColorTable,A0
	LEA	CopCol0,A1
	MOVE.W	(A0),(A1)
	MOVE.W	2(A0),4(A1)
	MOVE.W	4(A0),8(A1)
	MOVE.W	6(A0),12(A1)
	MOVE.W	8(A0),16(A1)
	MOVE.W	10(A0),20(A1)
	MOVE.W	12(A0),24(A1)
	MOVE.W	14(A0),28(A1)
	MOVE.W	14(A0),D0
	TST.W	SamScrEnable
	BEQ.B	sscnosc
	MOVE.W	8(A0),D0
sscnosc	MOVE.W	D0,NoteCol
	MOVE.W	10(A0),D0
	MOVE.W	D0,D4
	MOVE.W	#3,FadeX
	BSR.B	FadeCol
	MOVE.W	D0,56(A1)
	MOVE.W	D4,48(A1)
	MOVE.W	D4,D0
	MOVE.W	#-3,FadeX
	BSR.B	FadeCol
	MOVE.W	D0,52(A1)
	RTS

FadeCol	MOVE.W	D0,D1
	MOVE.W	D0,D2
	MOVE.W	D0,D3
	LSR.W	#8,D1
	ADD.W	FadeX(PC),D1
	BPL.B	redskp
	MOVEQ	#0,D1
redskp	CMP.W	#15,D1
	BLS.B	redskp2
	MOVEQ	#15,D1
redskp2	AND.W	#$00F0,D2
	LSR.W	#4,D2
	ADD.W	FadeX(PC),D2
	BPL.B	grnskp
	MOVEQ	#0,D2
grnskp	CMP.W	#15,D2
	BLS.B	grnskp2
	MOVEQ	#15,D2
grnskp2	AND.W	#$000F,D3
	ADD.W	FadeX(PC),D3
	BPL.B	bluskp
	MOVEQ	#0,D3
bluskp	CMP.W	#15,D3
	BLS.B	bluskp2
	MOVEQ	#15,D3
bluskp2	MOVE.W	D3,D0
	LSL.W	#4,D2
	OR.W	D2,D0
	LSL.W	#8,D1
	OR.W	D1,D0
	RTS

CurrColor	dc.w	0
FadeX		dc.w	-3

EnterPrintPath
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	PrintPath,A6
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#31,TextEndPtr
	MOVE.W	#12,TextLength
	MOVE.W	#3694,A4
	BSR.W	GetTextLine
	BRA.W	RestorePtrCol

ShowPrintPath
	LEA	PrintPath,A0
	MOVE.W	#3694,D1
	MOVEQ	#12,D0
	BRA.W	ShowText3
	
; Print Song

PrintSong
	LEA	PrintSongText,A0
	BSR.W	AreYouSure
	BNE.W	PrintSongRTS
	BSR.W	StorePtrCol
	MOVE.L	#PrintPath,D1
	MOVE.L	#1006,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.W	CantOpenFile
	BSR.W	SetDiskPtrCol
	LEA	PrintingSongText,A0
	BSR.W	ShowStatusText
	MOVE.L	FileHandle,D1
	MOVE.L	#SongDumpText,D2
	MOVEQ	#68,D3
	MOVE.L	DOSBase,A6
	JSR	_LVOWrite(A6)
	MOVE.L	FileHandle,D1
	MOVE.L	SongDataPtr,D2
	MOVEQ	#20,D3
	JSR	_LVOWrite(A6)
	BSR.W	PrintCRLF
	BSR.W	PrintCRLF
	BSR.B	PrintSong2
	BSR.W	PrintCRLF
	BSR.W	PrintSong4
	BSR.W	PrintFormFeed
	MOVE.L	SongDataPtr,A0
	MOVEQ	#0,D0
	MOVE.B	sd_numofpatt(A0),D0
	LEA	sd_pattpos(A0),A0
	MOVEQ	#0,D7
ps_loop	CMP.B	(A0,D0.W),D7
	BGT.B	ps_skip
	MOVE.B	(A0,D0.W),D7
ps_skip	SUBQ.W	#1,D0
	BPL.B	ps_loop
	MOVEQ	#0,D1
ps_loop2
	MOVEM.L	D1-D7/A0-A6,-(SP)
	BSR.W	PrintPattern
	MOVEM.L	(SP)+,D1-D7/A0-A6
	TST.L	D0
	BNE.B	ps_skip2
	MOVEM.L	D1/D7,-(SP)
	BSR.W	PrintFormFeed
	MOVEM.L	(SP)+,D1/D7
	ADDQ.W	#1,D1
	CMP.W	D7,D1
	BLE.B	ps_loop2
ps_skip2
	MOVE.L	DOSBase,A6
	MOVE.L	FileHandle,D1
	JSR	_LVOClose(A6)
	BSR.W	ShowAllRight
	BRA.W	RestorePtrCol

PrintSong2
	MOVEQ	#1,D7
ps2_2	MOVE.L	D7,D0
	LSR.B	#4,D0
	CMP.B	#9,D0
	BLS.B	spujk
	ADDQ.B	#7,D0
spujk	ADD.B	#'0',D0
	MOVE.B	D0,PattXText1
	MOVE.B	D7,D0
	AND.B	#$0F,D0
	CMP.B	#9,D0
	BLS.B	spujk2
	ADDQ.B	#7,D0
spujk2	ADD.B	#'0',D0
	MOVE.B	D0,PattXText2
	
	MOVE.L	SongDataPtr,A0
	MOVE.W	D7,D0
	MULU.W	#30,D0
	LEA	-10(A0,D0.W),A0
	LEA	PpText,A1
	MOVEQ	#22-1,D0
ps2_loop
	MOVE.B	#' ',(A1)+
	DBRA	D0,ps2_loop
	LEA	PpText,A1
	
	MOVE.L	A0,SavIt
ps2_loop2
	MOVE.B	(A0)+,D0
	BEQ.B	PrintSong3
	MOVE.B	D0,(A1)+
	BRA.B	ps2_loop2

	CNOP 0,4
SavIt	dc.l 0

PrintSong3
	MOVE.L	D7,-(SP) ; pattnum
	MOVE.L	SavIt(PC),A0
	MOVE.W	22(A0),D0
	ADD.W	D0,D0
	LEA	Prafs+2+4,A0
	JSR	IntToHexASCII
	MOVE.L	SavIt(PC),A0
	MOVE.W	26(A0),D0
	ADD.W	D0,D0
	LEA	Prafs+8+4,A0
	JSR	IntToHexASCII
	MOVE.L	SavIt(PC),A0
	MOVE.W	28(A0),D0
	ADD.W	D0,D0
	LEA	Prafs+14+4,A0
	JSR	IntToHexASCII
	MOVE.L	DOSBase,A6
	MOVE.L	FileHandle,D1
	MOVE.L	#PtotText,D2
	MOVEQ	#52,D3
	JSR	_LVOWrite(A6)
	MOVE.L	(SP)+,D7
	ADDQ.W	#1,D7
	CMP.W	#$0020,D7
	BNE.W	ps2_2
PrintSongRTS
	RTS

PrintSong4
	MOVE.L	SongDataPtr,A0
	MOVEQ	#0,D7
	MOVE.B	sd_numofpatt(A0),D7
	LEA	sd_pattpos(A0),A0
	MOVEQ	#0,D5
ps4_loop1
	MOVEQ	#0,D6
ps4_loop2
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.L	D0,D6
	DIVU.W	#10,D6
	ADD.B	#$30,D6
	MOVE.B	D6,D1
	SWAP	D6
	ADD.B	#$30,D6
	MOVE.B	D6,D0
	
	LEA	PnText,A1
	MOVE.B	D1,(A1)+
	MOVE.B	D0,(A1)
	MOVEM.L	D5-D7/A0,-(SP)
	MOVE.L	DOSBase,A6
	MOVE.L	FileHandle,D1
	MOVE.L	#PnText,D2
	MOVEQ	#4,D3
	JSR	_LVOWrite(A6)
	MOVEM.L	(SP)+,D5-D7/A0
	ADDQ.W	#1,D5
	CMP.W	D5,D7
	BEQ.W	Return2
	ADDQ.W	#1,D6
	CMP.W	#$0010,D6
	BNE.B	ps4_loop2
	MOVEM.L	D5-D7/A0,-(SP)
	BSR.B	PrintCRLF
	MOVEM.L	(SP)+,D5-D7/A0
	BRA.B	ps4_loop1

PrintCRLF
	MOVE.L	DOSBase,A6
	MOVE.L	FileHandle,D1
	MOVE.L	#CRLF_Text,D2
	MOVEQ	#2,D3
	JSR	_LVOWrite(A6)
	RTS

PrintFormFeed
	MOVE.L	DOSBase,A6
	MOVE.L	FileHandle,D1
	MOVE.L	#FF_Text,D2
	MOVEQ	#1,D3
	JSR	_LVOWrite(A6)
	RTS

PrintPattern
	MOVE.L	D1,D6 ; D1=pattern number
	DIVU.W	#10,D6
	ADD.B	#'0',D6
	MOVE.B	D6,PattNumText1
	SWAP	D6
	ADD.B	#'0',D6
	MOVE.B	D6,PattNumText2
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	FileHandle,D1
	MOVE.L	#PatternNumText,D2
	MOVEQ	#18,D3
	MOVE.L	DOSBase,A6
	JSR	_LVOWrite(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	
	MOVE.L	D1,D6
	MOVE.L	SongDataPtr,A6
	LEA	sd_patterndata(A6),A6
	LSL.L	#8,D6
	LSL.L	#2,D6
	ADD.L	D6,A6
	CLR.W	PPattPos
	MOVEQ	#0,D6
pp_posloop
	MOVEQ	#0,D7
	MOVE.W	#2,TextLength
	MOVEQ	#0,D1
	MOVE.W	PPattPos,D1
	LEA	PattPosText,A5
	DIVU.W	#10,D1
	ADD.B	#'0',D1
	MOVE.B	D1,(A5)+
	CLR.W	D1
	SWAP	D1
	ADD.B	#'0',D1
	MOVE.B	D1,(A5)+
	ADDQ	#5,A5
pp_noteloop
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	#3,TextLength
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	PeriodTable,A0
pp_findloop
	CMP.W	(A0,D0.L),D1
	BEQ.B	PrintNote
	ADDQ.L	#2,D0
	BRA.B	pp_findloop

PrintNote
	ADD.L	D0,D0
	ADD.L	NoteNamesPtr,D0
	MOVE.L	D0,A0
	MOVE.L	(A0),(A5)+
	CMP.B	#'¡',-3(A5)
	BNE.B	prnoxyz
	MOVE.B	#'b',-3(A5)
prnoxyz	ADDQ	#1,A5
	MOVEQ	#0,D0
	MOVE.W	(A6),D0
	AND.W	#$F000,D0
	LSR.W	#8,D0
	LSL.L	#1,D0
	LEA	FastHexTable,A0
	ADD.L	D0,A0
	MOVE.B	(A0),(A5)+
	MOVEQ	#0,D0
	MOVE.B	2(A6),D0
	ADD.L	D0,D0
	LEA	FastHexTable,A0
	ADD.L	D0,A0
	MOVE.W	(A0),(A5)+
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ADD.L	D0,D0
	LEA	FastHexTable,A0
	ADD.L	D0,A0
	MOVE.W	(A0),(A5)+
	ADDQ	#4,A5
	ADDQ	#4,A6
	ADDQ.W	#1,D7
	CMP.L	#4,D7
	BNE.W	pp_noteloop
	ADDQ.W	#1,PPattPos
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	DOSBase,A6
	MOVE.L	FileHandle,D1
	MOVE.L	#PnText2,D2
	MOVEQ	#68,D3
	JSR	_LVOWrite(A6)
	BSR.W	PrintCRLF
	MOVEM.L	(SP)+,D0-D7/A0-A6
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	NegativeReturn
	ADDQ.L	#1,D6
	CMP.L	#64,D6
	BNE.W	pp_posloop
	MOVEQ	#0,D0
	RTS

NegativeReturn
	MOVEQ	#-1,D0
	RTS

;---- Setup2 ----

Setup2	BSR.W	WaitForButtonUp
	MOVE.W	#7,CurrScreen
	CLR.W	LastSetupScreen
	ST	DisableAnalyzer
	ST	NoSampleInfo
	BSR.W	Clear100Lines
	MOVE.L	SetupMemPtr(PC),D0
	BNE.B	set2skp
	BSR.W	SaveMainPic
	BEQ.W	ExitSetup
set2skp	BSR.W	DecompactSetup2
	BSR.W	SetScreenColors
refrsh2	BSR.W	ShowIntMode
	JSR	ShowTempo
	BSR.W	ShowSpeed
	BSR.W	ShowColEdit
	BSR.W	ShowRainbow
	BSR.W	GetColPos
	BSR.W	ShowColSliders
	BSR.W	ShowS2Modules
	BSR.W	ShowS2Songs
	BSR.W	ShowS2Samples
	BSR.W	ShowS2PTPath
	BSR.W	ShowS2MaxPLST
	BSR.W	ShowS2TuneNote
	BSR.W	ShowS2VUStyle
	BRA.W	ShowS2T

CheckSetup2Gadgs
	MOVE.W	MouseX2,D0
	MOVE.W	MouseY2,D1
	CMP.W	#210,D0
	BHS.W	Setup2Menu3
	CMP.W	#108,D0
	BHS.B	Setup2Menu2
;---- Menu 1 ----
	CMP.W	#11,D1
	BLS.W	ToggleIntMode
	CMP.W	#22,D1
	BLS.B	xChangeTempo
	CMP.W	#33,D1
	BLS.W	ChangeSpeed
	CMP.W	#44,D1
	BLS.W	ToggleColEdit
	CMP.W	#55,D1
	BLS.W	RotOrSpread
	CMP.W	#66,D1
	BLS.W	SetRed2
	CMP.W	#77,D1
	BLS.W	SetGreen2
	CMP.W	#88,D1
	BLS.W	SetBlue2
	CMP.W	#99,D1
	BLS.W	ColorGadgets2
	RTS

xChangeTempo	JMP	ChangeTempo

Setup2Menu2
	CMP.W	#11,D1
	BLS.W	Set2ModPath
	CMP.W	#22,D1
	BLS.W	Set2SongPath
	CMP.W	#33,D1
	BLS.W	Set2SamPath
	CMP.W	#44,D1
	BLS.W	Set2PTPath
	CMP.W	#55,D1
	BLS.W	SetS2MaxPLST
	CMP.W	#66,D1
	BLS.W	SetS2TuneNote
	CMP.W	#77,D1
	BLS.W	SetS2VUStyle
	;CMP.W	#88,D1
	;BLS.W	Setup2NotImpl
	CMP.W	#99,D1
	BLS.B	Setup2SwitchToggles
	RTS

SwitchTogglesFlag	dc.b 0
	EVEN
	
Setup2SwitchToggles
	EOR.B	#1,SwitchTogglesFlag
	LEA	Setup2Menus,A0
	LEA	Setup2ToggleData,A1
	MOVEQ	#1,D3
s2stloop1	MOVEQ	#88-1,D2
s2stloop2	MOVE.W	#7-1,D0
s2stloop3	MOVE.W	(A0),D4
	MOVE.W	(A1),(A0)+
	MOVE.W	D4,(A1)+
	DBRA	D0,s2stloop3
	LEA	26(A0),A0
	DBRA	D2,s2stloop2
	LEA	6720(A0),A0
	DBRA	D3,s2stloop1
	BSR.W	ShowS2T
	RTS

Setup2Menu3
	TST.B	SwitchTogglesFlag
	BNE.B	Setup2Menu4
	CMP.W	#11,D1
	BLS.W	ExitOrDefault
	CMP.W	#22,D1
	BLS.W	ToggleOverride
	CMP.W	#33,D1
	BLS.W	ToggleNosamples
	CMP.W	#44,D1
	BLS.W	ToggleBlankZero
	CMP.W	#55,D1
	BLS.W	ToggleShowDirs
	CMP.W	#66,D1
	BLS.W	ToggleShowPublic
	CMP.W	#77,D1
	BLS.W	ToggleCutToBuf
	CMP.W	#88,D1
	BLS.W	ToggleIFFLoop
	CMP.W	#99,D1
	BLS.W	ToggleSysReq
	RTS

Setup2Menu4
	CMP.W	#11,D1
	BLS.B	ExitOrDefault
	CMP.W	#22,D1
	BLS.W	ToggleSalvage
	CMP.W	#33,D1
	BLS.W	Toggle100Patts
	CMP.W	#44,D1
	BLS.W	ToggleSaveIcons
	CMP.W	#55,D1
	BLS.W	ToggleLoadNames
	CMP.W	#66,D1
	BLS.W	ToggleSaveNames
	CMP.W	#77,D1
	BLS.W	ToggleLoadPLST
	CMP.W	#88,D1
	BLS.W	ToggleScreenAdjust
	CMP.W	#99,D1
	BLS.W	ToggleSamplePack
	RTS

ExitOrDefault
	CMP.W	#263,D0
	BLS.B	SetS2Default
	CMP.W	#306,D0
	BHS.B	eodskip
	BRA.W	ExitSetup
eodskip
	TST.B	SwitchTogglesFlag
	BEQ.B	eodskip2
	BSR.W	Setup2SwitchToggles
eodskip2
	BRA.W	Setup

SetS2Default
	LEA	SetDefaultsText(PC),A0
	BSR.W	AreYouSure
	BNE.W	Return2
	LEA	DefaultSetupData,A0
	LEA	SongsPath-SetupData(A0),A2
	LEA	SongsPath,A1
	MOVEQ	#96-1,D0
ss2dela	MOVE.B	(A2)+,(A1)+
	DBRA	D0,ss2dela
	LEA	PTPath-SetupData(A0),A2
	LEA	PTPath,A1
	MOVEQ	#32-1,D0
ss2delb	MOVE.B	(A2)+,(A1)+
	DBRA	D0,ss2delb
	LEA	MaxPLSTEntries-SetupData(A0),A2
	MOVE.W	(A2),MaxPLSTEntries
	LEA	DMAWait-SetupData(A0),A2
	MOVE.W	(A2),DMAWait
	LEA	TuneNote-SetupData(A0),A2
	MOVE.L	(A2),TuneNote
	LEA	SalvageAddress-SetupData(A0),A2
	LEA	SalvageAddress,A1
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2),(A1)
	BRA.W	refrsh2

SetDefaultsText	dc.b	'Set defaults?',0
	EVEN

ToggleIntMode
	JSR	ResetMusicInt
	EOR.B	#1,IntMode
	JSR	SetMusicInt
	JSR	SetTempo
	BSR.W	WaitForButtonUp
ShowIntMode
	LEA	VBlankText(PC),A0
	TST.B	IntMode
	BEQ.B	simskip
	LEA	CIAText(PC),A0
simskip	MOVEQ	#6,D0
	MOVE.W	#167,D1
	BRA.W	ShowText3

VBlankText	dc.b "VBLANK"
CIAText		dc.b " CIA  "
	EVEN

ChangeSpeed
	MOVEQ	#0,D1
	CMP.W	#97,D0
	BHS.B	SpeedDown
	CMP.W	#86,D0
	BHS.B	SpeedUp
	RTS

SpeedUp	MOVE.W	DefaultSpeed,D1
	ADDQ.B	#1,D1
	CMP.B	#$FF,D1
	BLS.B	spedup2
	MOVE.W	#$FF,D1
spedup2	MOVE.W	D1,DefaultSpeed
	MOVE.L	D1,CurrSpeed
	BSR.B	ShowSpeed
	BSR.W	Wait_4000
	BRA.W	Wait_4000
ShowSpeed
	MOVE.W	#608+440,TextOffset
	MOVE.W	DefaultSpeed,WordNumber
	BRA.W	PrintHexByte

SpeedDown
	MOVE.W	DefaultSpeed,D1
	SUBQ.B	#1,D1
	CMP.B	#1,D1
	BHS.B	spedup2
	MOVEQ	#1,D1
	BRA.B	spedup2
	

ToggleOverride
	EOR.B	#1,OverrideFlag
	BRA.B	ShowS2T
ToggleNosamples
	EOR.B	#1,NosamplesFlag
	BRA.B	ShowS2T
ToggleBlankZero
	EOR.B	#1,BlankZeroFlag
	BSR.B	ShowS2T
	BRA.W	RedrawPattern
ToggleShowDirs
	EOR.B	#1,ShowDirsFlag
	BRA.B	ShowS2T
ToggleShowPublic
	EOR.B	#1,ShowPublicFlag
	ST	UpdateFreeMem
	BRA.B	ShowS2T
ToggleCutToBuf
	EOR.B	#1,CutToBufFlag
	BRA.B	ShowS2T
ToggleIFFLoop
	EOR.B	#1,IFFLoopFlag
	BRA.B	ShowS2T
ToggleSysReq
	EOR.B	#1,SysReqFlag
	BSR.W	UpdateSysReq
	
ShowS2T	CLR.B	RawKeyCode
	CMP.W	#7,CurrScreen
	BNE.W	Return2
	LEA	OverrideFlag,A4
	TST.B	SwitchTogglesFlag
	BEQ.B	sstskip4
	LEA	SalvageFlag,A4
	MOVE.W	#3,TextLength
	MOVEQ	#7-1,D7
	MOVE.W	#636,D6
sstloop2
	MOVE.W	D6,TextOffset
	LEA	ToggleOFFText(PC),A0
	TST.B	(A4)+
	BEQ.B	sstskip2
	LEA	ToggleONText(PC),A0
sstskip2
	BSR.W	ShowText2
	ADD.W	#440,D6
	DBRA	D7,sstloop2
	MOVE.W	D6,TextOffset
	LEA	RAWText(PC),A0
	TST.B	(A4)+
	BEQ.B	sstskip3
	LEA	IFFText(PC),A0
sstskip3
	BSR.W	ShowText2
	ADD.W	#440,D6
	BRA.W	WaitForButtonUp

sstskip4
	MOVE.W	#3,TextLength
	MOVEQ	#8-1,D7
	MOVE.W	#636,D6
sstloop3
	MOVE.W	D6,TextOffset
	LEA	ToggleOFFText(PC),A0
	TST.B	(A4)+
	BEQ.B	sstskip5
	LEA	ToggleONText(PC),A0
sstskip5
	BSR.W	ShowText2
	ADD.W	#440,D6
	DBRA	D7,sstloop3
	BRA.W	WaitForButtonUp
	
	CNOP 0,4
SongAllocSize	dc.l SONG_SIZE_64PAT
MaxPattern	dc.l 64-1

ToggleSalvage
	BRA.W	ShowNotImpl
Toggle100Patts
	BSR.W	WaitForButtonUp
	LEA	AreYouSureText,A0
	BSR.W	AreYouSure
	BNE.W	Return2
t100ploop
	MOVE.L	SongDataPtr,D1
	BEQ.B	t100pskip
	MOVE.L	D1,A1
	MOVE.L	SongAllocSize(PC),D0
	JSR	PTFreeMem
t100pskip
	BSR.W	ClrSampleInfo
	EOR.B	#1,OneHundredPattFlag
	MOVE.L	#SONG_SIZE_64PAT,SongAllocSize
	MOVE.L	#64-1,MaxPattern
	TST.B	OneHundredPattFlag
	BEQ.B	t100pskip2
	MOVE.L	#SONG_SIZE_100PAT,SongAllocSize
	MOVE.L	#100-1,MaxPattern
t100pskip2
	MOVE.L	SongAllocSize(PC),D0
	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,SongDataPtr
	BNE.B	t100pskip3
	BSR.W	OutOfMemErr
	BRA.B	t100ploop
t100pskip3
	BSR.W	DoClearSong
	BSR.W	ShowSampleInfo
	BSR.W	ShowSongName
	BRA.W	ShowS2T
ToggleSaveIcons
	EOR.B	#1,SaveIconsFlag
	BRA.W	ShowS2T
ToggleLoadNames
	EOR.B	#1,LoadNamesFlag
	BRA.W	ShowS2T
ToggleSaveNames
	EOR.B	#1,SaveNamesFlag
	BRA.W	ShowS2T
ToggleLoadPLST
	EOR.B	#1,LoadPLSTFlag
	BRA.W	ShowS2T
ToggleScreenAdjust
	EOR.B	#1,ScreenAdjustFlag
	BSR.W	ShowS2T
	BSR.W	AdjustVuSprites
	BSR.W	UpdateCursorPos
	JSR	SetLoopSprites
	BSR.W	RedrawPattern
	BRA.W	WaitForButtonUp
ToggleSamplePack
	EOR.B	#1,SamplePackFlag
	BRA.W	ShowS2T
	
UpdateSysReq
	MOVE.L	PTProcess,A0
	TST.B	SysReqFlag
	BEQ.B	lbC00956E
	MOVE.L	PTProcessTmp,184(A0)
	RTS
lbC00956E
	MOVE.L	#$FFFFFFFF,184(A0)
	RTS

ShowS2Modules
	MOVE.W	#177,D1
	LEA	ModulesPath,A0
s2path	MOVEQ	#9,D0
	BRA.W	ShowText3

ShowS2Songs
	MOVE.W	#177+440,D1
	LEA	SongsPath,A0
	BRA.B	s2path

ShowS2Samples
	MOVE.W	#177+880,D1
	LEA	SamplePath,A0
	BRA.B	s2path

ShowS2PTPath
	MOVE.W	#177+1320,D1
	LEA	PTPath,A0
	BRA.B	s2path


Set2ModPath
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	ModulesPath,A6
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#31,TextEndPtr
	MOVE.W	#9,TextLength
	MOVE.W	#177,A4
	BSR.W	GetTextLine
	BRA.W	RestorePtrCol

Set2SongPath
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	SongsPath,A6
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#31,TextEndPtr
	MOVE.W	#9,TextLength
	MOVE.W	#177+440,A4
	BSR.W	GetTextLine
	BRA.W	RestorePtrCol

Set2SamPath
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	SamplePath,A6
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#31,TextEndPtr
	MOVE.W	#9,TextLength
	MOVE.W	#177+880,A4
	BSR.W	GetTextLine
	BRA.W	RestorePtrCol

Set2PTPath
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	PTPath,A6
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#31,TextEndPtr
	MOVE.W	#9,TextLength
	MOVE.W	#177+1320,A4
	BSR.W	GetTextLine
	BRA.W	RestorePtrCol

SetS2MaxPLST
	CMP.W	#199,D0
	BHS.B	S2PLSTd
	CMP.W	#188,D0
	BHS.B	S2PLSTu
	RTS
S2PLSTu	MOVE.W	MaxPLSTEntries,D0
	ADD.W	#100,D0
	CMP.W	#9999,D0
	BLS.B	s2pu
	MOVE.W	#9999,D0
s2pu	MOVE.W	D0,MaxPLSTEntries
	BSR.B	ShowS2MaxPLST
	BRA.W	Wait_4000

S2PLSTd	MOVEQ	#0,D0
	MOVE.W	MaxPLSTEntries,D0
	ADDQ.W	#1,D0
	DIVU.W	#100,D0
	SUBQ.W	#1,D0
	BPL.B	s2pd
	MOVEQ	#0,D0
	BRA.B	s2pu
s2pd	MULU.W	#100,D0
	BRA.B	s2pu

ShowS2MaxPLST
	MOVE.W	MaxPLSTEntries,WordNumber
	MOVE.W	#1939,TextOffset
	BRA.W	Print4DecDigits

SetS2TuneNote
	CMP.W	#187,D0
	BHS.B	ss2tvol
	MOVE.W	#2380,D1
	MOVEQ	#3,D0
	LEA	SpcNoteText,A0
	BSR.W	ShowText3
	MOVE.W	#3,SamNoteType
	MOVE.L	#TuneNote,SplitAddress
	BRA.W	WaitForButtonUp

ShowS2TuneNote
	CMP.W	#7,CurrScreen
	BNE.W	Return2
	MOVE.L	NoteNamesPtr,A4
	MOVE.W	TuneNote,D0
	LSL.W	#2,D0
	LEA	(A4,D0.W),A0
	MOVEQ	#4,D0
	MOVE.W	#2380,D1
	BSR.W	ShowText3
	MOVE.W	TToneVol,WordNumber
	MOVE.W	#2384,TextOffset
	BRA.W	PrintHexByte

ss2tvol	MOVE.W	#2384,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	ShowS2TuneNote
	CMP.B	#64,D0
	BLS.B	ss2tvolset
	MOVE.B	#64,D0
ss2tvolset	MOVE.W	D0,TToneVol
	BRA.B	ShowS2TuneNote
	
SetS2VUStyle
	EOR.B	#1,RealVUMetersFlag
	BSR.W	WaitForButtonUp
ShowS2VUStyle
	CMP.W	#7,CurrScreen
	BNE.W	Return2
	TST.B	RealVUMetersFlag
	BNE.B	ss2vureal
	LEA	VUStyleFakeText(PC),A0
	BRA.B	sst2vushow
ss2vureal
	LEA	VUStyleRealText(PC),A0
sst2vushow
	MOVEQ	#4,D0
	MOVE.W	#2382+440,D1
	BRA.W	ShowText3
	
VUStyleFakeText dc.b	"FAKE",0
VUStyleRealText dc.b	"REAL",0
	EVEN

Setup2NotImpl	BRA.W	ShowNotImpl

ToggleColEdit
	CMP.W	#79,D0
	BHS.W	SelectColor2
	CLR.W	SpreadFlag
	LEA	VUmeterColors,A0
	MOVEQ	#48,D0
	CMP.L	TheRightColors(PC),A0
	BNE.B	tced2
	LEA	AnalyzerColors,A0
	MOVEQ	#36,D0
tced2	MOVE.L	A0,TheRightColors
	MOVE.W	D0,ColorsMax
	CMP.W	RainbowPos(PC),D0
	BHI.B	tced3
	CLR.W	RainbowPos
tced3	BSR.W	ShowRainbow
	BSR.W	ShowColSliders	; PT2.3D bugfix: update sliders
	BSR.B	ShowColEdit
	BRA.W	WaitForButtonUp
ShowColEdit
	LEA	cedtxt1(PC),A0
	LEA	VUmeterColors,A1
	CMP.L	TheRightColors(PC),A1
	BEQ.B	shcoed
	LEA	cedtxt2(PC),A0
shcoed	MOVEQ	#6,D0
	MOVE.W	#1483,D1
	BRA.W	ShowText3

cedtxt1	dc.b "VU-MTR"
cedtxt2	dc.b "ANALYZ"
	EVEN

RotOrSpread
	CMP.W	#16,D0
	BLO.B	RotColUp
	CMP.W	#32,D0
	BLO.B	RotColDown
	CMP.W	#79,D0
	BHS.W	SelectColor2
	BRA.B	SpreadColors

RotColUp
	CLR.W	SpreadFlag
	MOVE.L	TheRightColors(PC),A0
	MOVE.W	(A0),D0
	MOVE.W	ColorsMax(PC),D1
	SUBQ.W	#2,D1
rocoup1	MOVE.W	2(A0),(A0)+
	DBRA	D1,rocoup1
	MOVE.W	D0,(A0)
rocoup2
	BSR.W	Wait_4000
	BSR.W	GetColPos
	BSR.W	ShowColSliders
	BSR.W	ShowRainbow
	JMP	SetupVUCols

RotColDown
	CLR.W	SpreadFlag
	MOVE.L	TheRightColors(PC),A0
	MOVE.W	ColorsMax(PC),D1
	ADD.W	D1,A0
	ADD.W	D1,A0
	MOVE.W	-(A0),D0
	SUBQ.W	#2,D1
rocodn1	MOVE.W	-2(A0),(A0)
	SUBQ.L	#2,A0
	DBRA	D1,rocodn1
	MOVE.W	D0,(A0)
	BRA.B	rocoup2

SpreadColors
	MOVE.W	RainbowPos(PC),SpreadFrom
	MOVE.W	#1,SpreadFlag
	RTS

SpreadFrom	dc.w 0
SpreadFlag	dc.w 0

ColorGadgets2
	CLR.W	SpreadFlag
	CMP.W	#79,D0
	BHS.B	SetDefaultCol2
	CMP.W	#33,D0
	BHS.B	CancelCol2
	MOVE.L	UndoColAddr(PC),A0
	MOVE.W	UndoCol(PC),D1
	MOVE.W	(A0),UndoCol
	MOVE.W	D1,(A0)
	BRA.B	rocoup2

SetDefaultCol2
	MOVE.L	TheRightColors(PC),A0
	MOVE.L	A0,A1
	SUB.L	#SetupData,A1
	ADD.L	#DefaultSetupData,A1
sedeco4	MOVE.W	ColorsMax(PC),D0
	BRA.B	sedeco3
sedeco2	MOVE.W	(A1)+,(A0)+
sedeco3	DBRA	D0,sedeco2
	BRA.W	rocoup2

CancelCol2
	MOVE.L	TheRightColors(PC),A0
	MOVE.L	A0,A1
	SUB.L	#VUmeterColors,A1
	ADD.L	#SaveColors,A1
	BRA.B	sedeco4

GetColAddr
	MOVE.L	TheRightColors(PC),A0
	MOVE.W	RainbowPos(PC),D1
	ADD.W	D1,D1
	LEA	(A0,D1.W),A0
	MOVE.W	(A0),D1
	MOVE.W	D1,D2
	RTS

SetRed2	CMP.W	#79,D0
	BHS.W	SelectColor2
set2r2	BSR.W	GetColPos
	AND.W	#$0F00,D2
	LSR.W	#8,D2
	CMP.B	D2,D0
	BEQ.B	setrsk2
	AND.W	#$00FF,D1
	LSL.W	#8,D0
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	ShowColSliders
	BSR.W	ShowRainbow
	JSR	SetupVUCols
setrsk2	BTST	#6,$BFE001	; left mouse button
	BEQ.B	set2r2
	RTS

SetGreen2
	CMP.W	#79,D0
	BHS.B	SelectColor2
set2g2	BSR.W	GetColPos
	AND.W	#$00F0,D2
	LSR.W	#4,D2
	CMP.B	D2,D0
	BEQ.B	setgsk2
	AND.W	#$0F0F,D1
	LSL.W	#4,D0
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	ShowColSliders
	BSR.W	ShowRainbow
	JSR	SetupVUCols
setgsk2	BTST	#6,$BFE001	; left mouse button
	BEQ.B	set2g2
	RTS

SetBlue2
	CMP.W	#79,D0
	BHS.B	SelectColor2
set2b2	BSR.W	GetColPos
	AND.W	#$000F,D2
	CMP.B	D2,D0
	BEQ.B	setbsk2
	AND.W	#$0FF0,D1
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	ShowColSliders
	BSR.W	ShowRainbow
	JSR	SetupVUCols
setbsk2	BTST	#6,$BFE001	; left mouse button
	BEQ.B	set2b2
	RTS

SelectColor2
	MOVEQ	#0,D7
setcolp	BTST	#6,$BFE001	; left mouse button
	BNE.B	ChkSpread
	MOVE.W	ColorsMax(PC),D0
	MOVE.W	MouseY(PC),D1
	CMP.W	D7,D1
	BEQ.B	setcolp
	MOVE.W	D1,D7
	CMP.W	#37,D1
	BHS.B	setcoly
	MOVEQ	#37,D1
setcoly	SUB.W	#37,D1
	CMP.W	D0,D1
	BLT.B	setcol2
	MOVE.W	D0,D1
	SUBQ.W	#1,D1
setcol2	MOVE.W	D1,RainbowPos
	BSR.W	ShowRainbow
	BSR.W	GetColPos
	MOVE.L	A0,UndoColAddr
	MOVE.W	D1,UndoCol
	BSR.W	ShowColSliders
	BRA.B	setcolp

ChkSpread
	TST.W	SpreadFlag
	BEQ.W	Return2
	CLR.W	SpreadFlag
	BSR.W	GetColPos
	MOVE.W	SpreadFrom(PC),D0
	MOVE.W	RainbowPos(PC),D1
	CMP.W	D1,D0
	BLO.B	chkspr2
	EXG	D0,D1
chkspr2	MOVE.W	D1,D4
	SUB.W	D0,D4
	CMP.W	#1,D4
	BLS.W	Return2
	MOVE.L	D4,A2
	ADD.W	D4,D4
	MOVE.L	TheRightColors(PC),A0
	MOVE.L	A0,A1
	ADD.W	D0,D0
	ADD.W	D1,D1
	LEA	(A0,D0.W),A0	; 1st col
	MOVE.W	(A0),D2
	LEA	(A1,D1.W),A1	; 2nd col
	MOVE.W	(A1),D3
	MOVEQ	#0,D5
	
sprdlop	MOVE.W	D2,D0 ; red
	LSR.W	#8,D0
	MOVE.W	D3,D1
	LSR.W	#8,D1
	BSR.B	ColCrossfade
	LSL.W	#8,D0
	MOVE.W	D0,D7
	MOVE.W	D2,D0 ; green
	LSR.W	#4,D0
	AND.W	#$000F,D0
	MOVE.W	D3,D1
	LSR.W	#4,D1
	AND.W	#$000F,D1
	BSR.B	ColCrossfade
	LSL.W	#4,D0
	OR.W	D0,D7
	MOVE.W	D2,D0 ; blue
	AND.W	#$000F,D0
	MOVE.W	D3,D1
	AND.W	#$000F,D1
	BSR.B	ColCrossfade
	OR.W	D0,D7
	ADDQ.W	#2,D5
	MOVE.W	D7,(A0)+
	CMP.L	A1,A0
	BLO.B	sprdlop
	BRA.W	rocoup2

ColCrossfade
	MOVE.W	D4,D6
	SUB.W	D5,D6
	MULU.W	D6,D0
	ADD.L	A2,D0
	MULU.W	D5,D1
	ADD.W	D1,D0
	DIVU.W	D4,D0
	CMP.W	#15,D0
	BLS.W	Return2
	MOVEQ	#15,D0
	RTS

ShowRainbow
	LEA.L	TextBitplane+1490,A0
	MOVEQ	#0,D1
	MOVE.L	#$00FFE000,D2
	MOVE.W	RainbowPos(PC),D3
rainlop	MOVE.L	D2,D0
	CMP.W	D3,D1
	BNE.S	rainsk1
	MOVE.L	#$1EFFEF00,D0
rainsk1	MOVE.L	D0,(A0)
	LEA	40(A0),A0
	ADDQ.W	#1,D1
	CMP.W	#48,D1
	BLO.S	rainlop
	LEA	CopListAnalyzer,A0
	MOVE.L	TheRightColors(PC),A1
	MOVE.W	#$5107,D0
	MOVEQ	#48-1,D1
	MOVEQ	#0,D2
rainlp2	MOVE.W	D0,(A0)+
	MOVE.W	#$FFFE,(A0)+
	MOVE.W	#$018E,(A0)+
	CMP.W	ColorsMax(PC),D2
	BLO.S	rainsk2
	CLR.W	(A0)+
	BRA.S	rainsk3
rainsk2	MOVE.W	(A1)+,(A0)+
rainsk3	ADD.W	#$0100,D0
	ADDQ.W	#1,D2
	DBRA	D1,rainlp2
	MOVEQ	#64-1,D0
rainlp3	MOVE.L	#$01B80000,(A0)+
	DBRA	D0,rainlp3
	RTS
	
	CNOP 0,4
TheRightColors	dc.l	0
RainbowPos	dc.w	0
ColorsMax	dc.w	48

;---- PT Decompacter ----

Decompact
	MOVE.L	A0,CompPtr
	MOVE.L	D0,CompLen
	BSR.B	FreeDecompMem
	MOVE.L	CompPtr(PC),A0
	MOVE.L	(A0),D0
	MOVE.L	D0,DecompMemSize
	MOVEQ	#MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,DecompMemPtr
	BEQ.W	OutOfMemErr
	MOVE.L	D0,A1
	MOVE.L	CompPtr(PC),A0
	MOVE.L	CompLen(PC),D0
	ADDQ	#4,A0
	SUBQ.L	#4,D0
	MOVE.L	D3,-(SP)
	MOVEQ	#-75,D3	; 181 signed (compactor code)
dcmloop	MOVE.B	(A0)+,D1
	CMP.B	D3,D1
	BEQ.B	DecodeIt
	MOVE.B	D1,(A1)+
decom2	SUBQ.L	#1,D0
	BGT.B	dcmloop
	MOVE.L	(SP)+,D3
	MOVE.L	DecompMemPtr,A1
	MOVEQ	#-1,D0
	RTS

DecodeIt
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
dcdloop	MOVE.B	D2,(A1)+
	DBRA	D1,dcdloop
	SUBQ.L	#2,D0
	BRA.S	decom2

FreeDecompMem
	MOVE.L	DecompMemPtr,D0
	BEQ.W	Return2
	MOVE.L	D0,A1
	MOVE.L	DecompMemSize,D0
	JSR	PTFreeMem
	CLR.L	DecompMemPtr
	RTS

	CNOP 0,4
CompPtr	dc.l 0
CompLen	dc.l 0

;---- Position Insert/Delete Gadgets ----

PosInsDelGadgs
	MOVE.W	MouseY2,D0
	CMP.W	#11,D0
	BHS.W	Return2
	MOVE.W	MouseX2,D0
	CMP.W	#62,D0
	BHS.W	Return2
	CMP.W	#51,D0
	BHS.W	PosDelete
	CMP.W	#40,D0
	BHS.W	PosInsert
	BRA.B	PosEd
	RTS
	
;---- Position Editor (POSED) ----

PosEd
	CMP.W	#8,CurrScreen
	BEQ.W	ExitPLST
	CMP.W	#1,CurrScreen
	BNE.W	Return2
	BSR.W	WaitForButtonUp
	MOVE.W	#8,CurrScreen
	BSR.W	ClearRightArea
	JSR	ClearAnalyzerColors
	BSR.B	DrawPosEdScreen
	BEQ.W	ExitPLST
	BSR.B	RefreshPosEd
	RTS
	
DrawPosEdScreen   
	LEA	PosEdData,A0
	MOVE.L	#PosEdSize,D0
	BRA.W	DecompactPLST
	
RefreshPosEd
	CMP.W	#8,CurrScreen
	BNE.W	Return2
	TST.B	AskBoxShown	; --PT2.3D bug fix: don't update posed if ask dialog shown
	BNE.W	Return2		; --
	MOVE.L	CurrPos,D7
	MOVE.L	SongDataPtr,A0
	CMP.B	sd_numofpatt(A0),D7
	BLO.B	rpedskip
	MOVE.B	sd_numofpatt(A0),D7
	SUBQ.L	#1,D7
rpedskip
	MOVE.L	D7,PosEdCurrPos
	MOVE.W	#976,A5
	MOVEQ	#11,D6
	MOVEQ	#5,D5
	CMP.L	#5,D7
	BGE.B	rpedskip2
	NEG.L	D7
	ADDQ.L	#4,D7
rpedloop1
	LEA	240(A5),A5
	SUBQ.L	#1,D6
	SUBQ.L	#1,D5
	DBRA	D7,rpedloop1
rpedskip2
	MOVE.L	PosEdCurrPos,D7
	SUB.L	D5,D7
	MOVE.L	SongDataPtr,A1
	MOVEQ	#0,D4
	MOVE.B	sd_numofpatt(A1),D4
	LEA	sd_pattpos(A1),A1
	MOVE.W	#145,D0
	BSR.W	WaitForVBlank
	BSR.W	ClearRightArea
rpedloop2
	MOVE.L	D7,D0
	MOVEQ	#0,D1
	MOVE.B	(A1,D0.W),D1
	MOVE.L	D1,D2
	LSL.W	#4,D2
	LEA	PosEdNames,A2
	ADD.L	D2,A2
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.W	A5,TextOffset
	MOVE.W	D0,WordNumber
	BSR.W	Print3DecDigits
	MOVEM.L	(SP)+,D0-D7/A0-A6
	ADDQ.W	#1,TextOffset
	MOVE.W	D1,WordNumber
	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	Print2DecDigits
	MOVEM.L	(SP)+,D0-D7/A0-A6
	ADDQ.W	#1,TextOffset
	MOVE.L	A2,ShowTextPtr
	MOVE.W	#15,TextLength
	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	ShowText
	MOVEM.L	(SP)+,D0-D7/A0-A6
	ADDQ.L	#1,D7
	CMP.L	D4,D7
	BEQ.B	PosEdRTS
	LEA	240(A5),A5
	DBRA	D6,rpedloop2
PosEdRTS
	RTS

CheckPosEdGadgs
	MOVE.W	MouseX2,D0
	MOVE.W	MouseY2,D1
	CMP.W	#$78,D0
	BLO.W	Return2
	CMP.W	#$17,D1
	BHS.B	lbC009DAF
	CMP.W	#12,D1
	BHS.B	lbC009DAA
	CMP.W	#$10C,D0
	BHS.W	PlaySong
	CMP.W	#$AC,D0
	BHS.W	StopIt
	BRA.W	PosInsert
lbC009DAA
	CMP.W	#$10C,D0
	BHS.W	lbC009F6C
	CMP.W	#$AC,D0
	BHS.W	StopIt
	BRA.W	PosDelete
lbC009DAF
	CMP.W	#$18,D1
	BLO.W	Return2
	CMP.W	#$134,D0
	BHS.W	lbC009EAC
	CMP.W	#$5F,D1
	BHI.W	Return2
	TST.L	RunMode
	BNE.W	Return2
	CMP.W	#$B4,D0
	BHS.B	lbC009E30
	MOVE.W	#$A4,LineCurX
	MOVE.W	#$3B,LineCurY
	MOVE.W	#$884,TextOffset
	BSR.W	GetDecByte
	TST.W	AbortDecFlag
	BNE.W	POSED_Update
	CMP.B	MaxPattern+3(PC),D0
	BLS.B	lbC009E1A
	MOVE.L	MaxPattern(PC),D0
lbC009E1A
	MOVE.L	SongDataPtr,A0
	LEA	sd_pattpos(A0),A0
	ADD.L	CurrPos,A0
	MOVE.B	D0,(A0)
	BRA.W	POSED_Update
lbC009E30
	BSR.W	WaitForButtonUp
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	CLR.L	EditMode
	MOVE.L	SongDataPtr,A1
	LEA	sd_pattpos(A1),A1
	MOVE.L	PosEdCurrPos,D0
	MOVEQ	#0,D1
	MOVE.B	(A1,D0.W),D1
	LSL.W	#4,D1
	LEA	PosEdNames,A6
	ADD.L	D1,A6
	MOVE.L	A6,-(SP)
	MOVE.L	A6,TextEndPtr
	MOVE.L	A6,ShowTextPtr
	ADD.L	#15,TextEndPtr
	MOVE.W	#15,TextLength
	MOVE.W	#$887,A4
	BSR.W	GetTextLine
	CLR.L	TextEndPtr
	BSR.W	RestorePtrCol
	MOVE.L	(SP)+,A0
	MOVEQ	#16-1,D0
lbC009E9C
	TST.B	(A0)+
	BNE.B	lbC009EA6
	MOVE.B	#' ',-1(A0)
lbC009EA6
	DBRA	D0,lbC009E9C
	BRA.B	POSED_Update
lbC009EAC
	CMP.W	#$63,D1
	BHI.W	Return2
	CMP.W	#$59,D1
	BHS.B	POSED_Bottom
	CMP.W	#$4E,D1
	BHS.B	POSED_OneDown
	CMP.W	#$2D,D1
	BHS.W	ExitPLST
	CMP.W	#$22,D1
	BHS.B	POSED_OneUp
POSED_Top
	CLR.L	SongPosition
POSED_Update
	MOVE.L	SongPosition,CurrPos
	BSR.W	ShowPosition
	BRA.W	RefreshPosEd
	
POSED_OneUp
	ST	SetSignalFlag
	MOVE.L	SongPosition,D0
	SUBQ.L	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	peouskip
	SUBQ.L	#3,D0		; reduced from 9 to 3 in PT2.3E
peouskip
	TST.L	D0
	BPL.B	peouskip2
	MOVEQ	#0,D0
peouskip2
	MOVE.L	D0,SongPosition
	BSR.B	POSED_ScrollDelay
	BRA.B	POSED_Update
	
POSED_Bottom
	MOVE.L	SongDataPtr,A0
	MOVEQ	#0,D7
	MOVE.B	sd_numofpatt(A0),D7
	SUBQ.B	#1,D7
	MOVE.L	D7,SongPosition
	BRA.B	POSED_Update
	
POSED_OneDown	; --PT2.3D bug fix: could overflow
	ST	SetSignalFlag
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D1
	MOVE.L	SongDataPtr,A0
	MOVE.B	sd_numofpatt(A0),D1	
	MOVE.L	SongPosition,D0
	ADDQ.W	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	peodskip
	ADDQ.W	#3,D0		; reduced from 9 to 3 in PT2.3E
peodskip
	CMP.W	D1,D0
	BLT.B	peodok
	MOVE.W	D1,D0
	SUBQ.W	#1,D0
peodok
	MOVE.L	D0,SongPosition
	MOVE.L	(SP)+,D1
	BSR.B	POSED_ScrollDelay
	BRA.W	POSED_Update
	
	; added in PT2.3E to prevent insanely fast scroll on faster Amigas
POSED_ScrollDelay
	MOVEM.L	A0/D0-D1,-(SP)
	LEA	$DFF006,A0
	MOVE.W	#(255*3)-1,D0
.L0	MOVE.B	(A0),D1
.L1	CMP.B	(A0),D1
	BEQ.B	.L1
	DBRA	D0,.L0
	MOVEM.L	(SP)+,A0/D0-D1
	RTS
	
lbC009F6C
	MOVE.L	SongDataPtr,A1
	LEA	sd_pattpos(A1),A1
	MOVE.L	PosEdCurrPos,D0
	MOVE.B	(A1,D0.W),PatternNumber+3
	BSR.W	RedrawPattern
	BRA.W	ppskip

PosInsert
	TST.L	RunMode
	BNE.W	Return2
	MOVE.L	SongDataPtr,A0
	LEA	sd_pattpos+126(A0),A0
	MOVEQ	#127,D0
	MOVE.L	CurrPos,D1
	AND.L	#127,D1
piloop	MOVE.B	(A0),1(A0)
	SUBQ.L	#1,A0
	SUBQ.B	#1,D0
	CMP.B	D1,D0
	BHI.B	piloop
	CLR.B	1(A0)
	BSR.W	ShowPosition
	CLR.W	UpOrDown
	BSR.W	SongLengthGadg
	BRA.W	WaitForButtonUp

PosDelete
	TST.L	RunMode
	BNE.W	Return2
	MOVE.L	SongDataPtr,A0
	LEA	sd_pattpos(A0),A0
	MOVE.L	CurrPos,D0
	AND.L	#127,D0
	ADD.L	D0,A0
pdloop	MOVE.B	1(A0),(A0)
	ADDQ	#1,A0
	ADDQ.B	#1,D0
	CMP.B	#127,D0
	BLS.B	pdloop
	CLR.B	-1(A0)
	BSR.W	ShowPosition
	MOVE.W	#$FFFF,UpOrDown
	BSR.W	SongLengthGadg
	BRA.W	WaitForButtonUp
	
EnterNumGadgWide
	MOVE.W	MouseY2,D1
	CMP.W	#66,D1
	BLS.B	engwend
	CMP.W	#77,D1
	BLS.W	EnterSLengthGadg
	CMP.W	#88,D1
	BLS.W	EnterSRepeatGadg
	CMP.W	#99,D1
	BLS.W	EnterSReplenGadg
engwend	BRA.W	PosInsDelGadgs	; yes, also test these
	RTS

EnterNumGadg
	MOVE.W	MouseY2,D1
	CMP.W	#11,D1
	BLS.B	EnterSongPos
	CMP.W	#22,D1
	BLS.W	EnterPattGadg
	CMP.W	#33,D1
	BLS.W	EnterLenGadg
	CMP.W	#55,D1
	BLS.B	engrts
	CMP.W	#66,D1
	BLS.W	EnterSVolGadg
	CMP.W	#77,D1
	BLS.W	EnterSLengthGadg
	CMP.W	#88,D1
	BLS.W	EnterSRepeatGadg
	CMP.W	#99,D1
	BLS.W	EnterSReplenGadg
engrts	RTS

EnterSongPos
	TST.L	RunMode
	BNE.W	Return2
	CLR.B	RawKeyCode
	MOVEQ	#0,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	espxskip
	BRA.B	espok
espxskip
	MOVE.W	#$4C,LineCurX
	MOVE.W	#9,LineCurY
	MOVE.W	#$A9,TextOffset
	BSR.W	GetDec3Dig
	TST.W	AbortDecFlag
	BNE.W	pogskip
	CMP.W	#$7F,D0
	BLS.B	espok
	MOVEQ	#$7F,D0
espok	MOVE.L	D0,CurrPos
	BRA.W	pogskip

EnterPattGadg
	TST.L	RunMode
	BNE.W	Return2
	CLR.B	RawKeyCode
	MOVEQ	#0,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	epgskip
	BRA.B	epgok
epgskip	MOVE.W	#84,LineCurX
	MOVE.W	#20,LineCurY
	MOVE.W	#610,TextOffset
	BSR.W	GetDecByte
	TST.W	AbortDecFlag
	BNE.W	pogskip
	CMP.B	MaxPattern+3(PC),D0
	BLS.B	epgok
	MOVE.L	MaxPattern(PC),D0
epgok	MOVE.L	SongDataPtr,A0
	LEA	sd_pattpos(A0),A0
	ADD.L	CurrPos,A0
	MOVE.B	D0,(A0)
	BRA.W	pogskip

EnterLenGadg
	TST.L	RunMode
	BNE.W	Return2
	CLR.B	RawKeyCode
	MOVEQ	#0,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	elengskip
	BRA.B	elengok
elengskip
	MOVE.W	#76,LineCurX
	MOVE.W	#31,LineCurY
	MOVE.W	#1049,TextOffset
	BSR.W	GetDec3Dig
	TST.W	AbortDecFlag
	BNE.W	ShowSongLength
	CMP.W	#127,D0 ; --PT2.3D bug fix: 127 instead of 128--
	BLS.B	elengok
	MOVE.B	#127,D0 ; --PT2.3D bug fix: 127 instead of 128--
elengok	TST.B	D0
	BNE.B	elengskip2
	MOVE.B	#1,D0
elengskip2
	MOVE.L	SongDataPtr,A0
	LEA	sd_numofpatt(A0),A0
	MOVE.B	D0,(A0)
	BSR.W	RefreshPosEd ; --PT2.3D bug fix: update Pos-Ed--
	BRA.W	ShowSongLength

EnterSVolGadg
	CLR.B	RawKeyCode
	MOVE.W	InsNum,D1
	BEQ.W	NotSampleNull
	MOVEQ	#0,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	esvolgskip
	BRA.B	esvolsgok
esvolgskip
	MOVE.W	#2370,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.W	ftuskip
	CMP.B	#$40,D0
	BLS.B	esvolsgok
	MOVEQ	#$40,D0
esvolsgok
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVE.W	InsNum,D1
	BEQ.W	Return2
	MULU.W	#30,D1
	ADD.L	D1,A0
	MOVE.B	D0,3(A0)
	BRA.W	ftuskip

EnterSLengthGadg
	CLR.B	RawKeyCode
	MOVE.W	InsNum,D1
	BEQ.W	NotSampleNull
	MOVEQ	#0,D7
	BTST	#2,$DFF016  ; right mouse button
	BNE.B	eslengskip
	BRA.B	eslengskip2
eslengskip
	MOVE.W	#2807,TextOffset
	BSR.W	GetHexNybble
	TST.W	AbortHexFlag
	BNE.W	eslengok
	SWAP	D0
	AND.L	#$10000,D0
	MOVE.L	D0,D7
	MOVE.W	#2808,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	eslengok
	LSL.W	#8,D0
	OR.W	D0,D7
	MOVE.W	#2810,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	eslengok
	OR.B	D0,D7
	CMP.L	#$1FFFF,D7
	BLS.B	eslengskip4
	MOVE.L	#$1FFFF,D7
eslengskip4	
	LSR.L	#1,D7
eslengskip2
	MOVE.W	#1,SampleLengthFlag
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVEQ	#0,D0
	MOVE.W	InsNum,D0
	BEQ.W	ShowSampleInfo
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVE.W	4(A0),D1
	ADD.W	6(A0),D1
	MOVE.W	D7,(A0)
	CMP.W	#$FFFF,(A0)
	BLO.B	eslengskip3
	MOVE.W	#$FFFF,(A0)
eslengskip3
	CMP.W	D7,D1
	BLS.B	eslengok
	CLR.W	(A0)
	CMP.W	#1,D1
	BEQ.B	eslengok
	MOVE.W	D1,(A0)
eslengok
	BRA.W	ShowSampleInfo
	
EnterSRepeatGadg
	CLR.B	RawKeyCode
	MOVE.W	InsNum,D1
	BEQ.W	NotSampleNull
	MOVEQ	#0,D7
	BTST	#2,$DFF016	; right mouse button
	BNE.B	esrepegskip
	BRA.B	esrepegskip2
esrepegskip
	MOVE.W	#3247,TextOffset
	BSR.W	GetHexNybble
	TST.W	AbortHexFlag
	BNE.B	esrepegok
	SWAP	D0
	AND.L	#$10000,D0
	MOVE.L	D0,D7
	MOVE.W	#3248,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	esrepegok
	LSL.W	#8,D0
	OR.W	D0,D7
	MOVE.W	#3250,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	esrepegok
	OR.B	D0,D7
	CMP.L	#$1FFFF,D7
	BLS.B	esrepegskip3
	MOVE.L	#$1FFFF,D7
esrepegskip3	
	LSR.L	#1,D7
esrepegskip2
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVEQ	#0,D0
	MOVE.W	InsNum,D0
	BEQ.W	ShowSampleInfo
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVE.W	(A0),D0
	BEQ.B	esrepegok
	SUB.W	6(A0),D0
	MOVE.W	D0,4(A0)
	CMP.W	D7,D0
	BLO.B	esrepegok
	MOVE.W	D7,4(A0)
esrepegok
	BSR.W	ShowSampleInfo
	BSR.W	UpdateRepeats
	JMP	SetLoopSprites2

EnterSReplenGadg
	CLR.B	RawKeyCode
	MOVE.W	InsNum,D1
	BEQ.W	NotSampleNull
	MOVEQ	#0,D7
	BTST	#2,$DFF016	; right mouse button
	BNE.B	esreplgskip
	BRA.B	esreplgskip2
esreplgskip
	MOVE.W	#3687,TextOffset
	BSR.W	GetHexNybble
	TST.W	AbortHexFlag
	BNE.W	esreplgok
	SWAP	D0
	AND.L	#$10000,D0
	MOVE.L	D0,D7
	MOVE.W	#3688,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	esreplgok
	LSL.W	#8,D0
	OR.W	D0,D7
	MOVE.W	#3690,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	esreplgok
	OR.B	D0,D7
	CMP.L	#$1FFFF,D7
	BLS.B	esreplgskip3
	MOVE.L	#$1FFFF,D7
esreplgskip3	
	LSR.L	#1,D7
esreplgskip2
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVEQ	#0,D0
	MOVE.W	InsNum,D0
	BEQ.W	ShowSampleInfo
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVE.W	(A0),D0
	BEQ.B	esreplgok
	SUB.W	4(A0),D0
	MOVE.W	D0,6(A0)
	CMP.W	D7,D0
	BLO.B	esreplgok
	MOVE.W	#1,6(A0)
	TST.W	D7
	BEQ.B	esreplgok
	MOVE.W	D7,6(A0)
esreplgok
	BSR.W	ShowSampleInfo
	BSR.W	UpdateRepeats
	JMP	SetLoopSprites2

GetDec3Dig
	MOVE.W	#1,AbortDecFlag
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	BSR.W	UpdateLineCurPos
	BSR.W	GetKey0_9
	CMP.W	#68,D1
	BEQ.B	gd3exit
	MOVE.W	D1,D0
	MULU.W	#100,D0
	MOVE.W	D0,gd3temp
	BSR.W	ShowOneDigit
	ADDQ.W	#8,LineCurX
	BSR.W	UpdateLineCurPos
	BSR.W	GetKey0_9
	CMP.B	#68,D1
	BEQ.B	gd3exit
	MOVE.W	D1,D0
	MULU.W	#10,D0
	ADD.W	D0,gd3temp
	BSR.W	ShowOneDigit
	ADDQ.W	#8,LineCurX
	BSR.W	UpdateLineCurPos
	BSR.W	GetKey0_9
	CMP.B	#68,D1
	BEQ.B	gd3exit
	ADD.W	D1,gd3temp
	CLR.W	AbortDecFlag
gd3exit	CLR.W	LineCurX
	MOVE.W	#270,LineCurY
	BSR.W	UpdateLineCurPos
	BSR.W	RestorePtrCol
	MOVEQ	#0,D0
	MOVE.W	gd3temp(PC),D0
	RTS

gd3temp	dc.w	0

;----  Up/Down Gadgets ----

DownGadgets
	ST	UpdateFreeMem
	MOVE.W	#-1,UpOrDown
	BRA.B	ug2

UpGadgets
	ST	UpdateFreeMem
	CLR.W	UpOrDown
ug2	MOVE.W	MouseY2,D0
	CMP.W	#100,D0
	BHS.W	Return2
	CMP.W	#89,D0
	BHS.W	RepLenGadg
	CMP.W	#78,D0
	BHS.W	RepeatGadg
	CMP.W	#67,D0
	BHS.W	SampleLengthGadg
	CMP.W	#56,D0
	BHS.W	VolumeGadg
	CMP.W	#45,D0
	BHS.W	SampleNumGadg
	CMP.W	#34,D0
	BHS.W	FineTuneGadg
	CMP.W	#23,D0
	BHS.W	SongLengthGadg
	CMP.W	#12,D0
	BHS.W	PatternGadg
	TST.W	MouseY2
	BHS.B	PositionGadg
	RTS

PositionGadg
	TST.W	UpOrDown
	BMI.B	PositionDown
PositionUp
	ADDQ.L	#1,CurrPos
	BTST	#2,$DFF016	; right mouse button
	BNE.B	pogskp2
	ADD.L	#9,CurrPos
pogskp2	CMP.L	#127,CurrPos
	BLS.B	pogskip
	MOVE.L	#127,CurrPos
pogskip	MOVE.L	CurrPos,SongPosition
	BSR.W	ShowPosition
	BSR.W	RefreshPosEd
	BSR.W	Wait_4000
	BSR.W	Wait_4000
	BRA.W	Wait_4000

PositionDown
	SUBQ.L	#1,CurrPos
	BTST	#2,$DFF016	; right mouse button
	BNE.B	pogskp3
	SUB.L	#9,CurrPos
pogskp3	TST.L	CurrPos
	BPL.B	pogskip
	CLR.L	CurrPos
	BRA.B	pogskip

PatternGadg
	MOVE.L	SongDataPtr,A0
	LEA	sd_pattpos(A0),A0
	TST.W	UpOrDown
	BMI.B	PatternDown
PatternUp
	ADD.L	CurrPos,A0
	ADDQ.B	#1,(A0)
	BTST	#2,$DFF016	; right mouse button
	BNE.B	pagaskp
	ADD.B	#9,(A0)
pagaskp	MOVE.B	(A0),D0
	CMP.B	MaxPattern+3(PC),D0
	BLS.B	pogskip
	MOVE.B	MaxPattern+3(PC),(A0)
	BRA.W	pogskip

PatternDown
	ADD.L	CurrPos,A0
	SUBQ.B	#1,(A0)
	BTST	#2,$DFF016	; right mouse button
	BNE.B	padoskp
	SUB.B	#9,(A0)
padoskp	TST.B	(A0)
	BPL.W	pogskip
	CLR.B	(A0)
	BRA.W	pogskip


SongLengthGadg
	MOVE.L	SongDataPtr,A0
	LEA	sd_numofpatt(A0),A0
	TST.W	UpOrDown
	BMI.B	SongLengthDown
SongLengthUp
	ADDQ.B	#1,(A0)
	BTST	#2,$DFF016	; right mouse button
	BNE.B	slupskp
	ADD.B	#9,(A0)
slupskp	CMP.B	#128,(A0)	; --PT2.3D bugfix: was 127
	BMI.B	solgskip
	MOVE.B	#128,(A0)	; --PT2.3D bugfix: was 127
solgskip	BSR.W	ShowSongLength
	BSR.W	RefreshPosEd
	BSR.W	Wait_4000
	BSR.W	Wait_4000
	BRA.W	Wait_4000

SongLengthDown
	SUBQ.B	#1,(A0)
	BTST	#2,$DFF016	; right mouse button
	BNE.B	sldoskp
	SUB.B	#9,(A0)
sldoskp	CMP.B	#1,(A0)
	BGE.B	solgskip
	MOVE.B	#1,(A0)
	BRA.B	solgskip


SampleNumGadg
	BTST	#2,$DFF016	; right mouse button
	BNE.B	SampleNum2
	TST.W	InsNum
	BEQ.W	ShowSampleInfo
	MOVE.W	InsNum,LastInsNum
	CLR.W	InsNum
	BRA.W	ShowSampleInfo

SampleNum2
	TST.W	UpOrDown
	BMI.B	SampleNumDown
SampleNumUp
	ADDQ.W	#1,InsNum
	CMP.W	#31,InsNum
	BMI.B	snuskip
	MOVE.W	#31,InsNum
snuskip	BSR.W	redrsam
	BSR.W	Wait_4000
	BRA.W	Wait_4000
	RTS
	
SampleNumDown
	TST.W	InsNum
	BEQ.B	snuskip
	SUBQ.W	#1,InsNum
	CMP.W	#1,InsNum
	BPL.B	snuskip
	MOVE.W	#1,InsNum
	BRA.B	snuskip

FineTuneGadg
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVE.W	InsNum,D0
	BEQ.W	Return2
	MULU.W	#30,D0
	ADD.L	D0,A0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	ftgskip
	CLR.B	2(A0)
	BRA.B	ftuskip
ftgskip TST.W	UpOrDown
	BMI.B	FineTuneDown
	AND.B	#15,2(A0)
	CMP.B	#7,2(A0)
	BEQ.B	ftuskip
	ADDQ.B	#1,2(A0)
	AND.B	#15,2(A0)
ftuskip	BSR.W	ShowSampleInfo
	BSR.W	Wait_4000
	BRA.W	Wait_4000

FineTuneDown
	AND.B	#$0F,2(A0)
	CMP.B	#8,2(A0)
	BEQ.B	ftuskip
	SUBQ.B	#1,2(A0)
	AND.B	#$0F,2(A0)
	BRA.B	ftuskip


VolumeGadg
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVE.W	InsNum,D0
	BEQ.W	Return2
	MULU.W	#30,D0
	ADD.L	D0,A0
	TST.W	UpOrDown
	BMI.B	VolumeDown
VolumeUp
	ADDQ.B	#1,3(A0)
	BTST	#2,$DFF016	; right mouse button
	BNE.B	voupskp
	ADD.B	#15,3(A0)
voupskp	CMP.B	#$40,3(A0)
	BLS.B	ftuskip
	MOVE.B	#$40,3(A0)
	BRA.B	ftuskip

VolumeDown
	SUBQ.B	#1,3(A0)
	BTST	#2,$DFF016	; right mouse button
	BNE.B	vodoskp
	SUB.B	#15,3(A0)
vodoskp	TST.B	3(A0)
	BPL.W	ftuskip
	CLR.B	3(A0)
	BRA.W	ftuskip

SampleLengthGadg
	MOVE.W	#1,SampleLengthFlag
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVEQ	#0,D0
	MOVE.W	InsNum,D0
	BEQ.W	ShowSampleInfo
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	TST.W	UpOrDown
	BMI.B	SampleLengthDown
SampleLengthUp
	ADDQ.L	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	sluskip
	CMP.L	#$0000FFF0,D0
	BHS.B	sluskip
	ADDQ.L	#7,D0
sluskip	JSR	GUIDelay
sluskip2
	CMP.L	#$FFFF,D0
	BLS.W	sluskip3
	MOVE.L	#$FFFF,D0
	BRA.W	ShowSampleInfo
sluskip3
	MOVE.W	D0,(A0)
	BRA.W	ShowSampleInfo

SampleLengthDown
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	4(A0),D0
	ADD.W	6(A0),D0
	MOVE.W	(A0),D1
	SUBQ.L	#1,D1
	BTST	#2,$DFF016	; right mouse button
	BNE.B	sldskip
	SUBQ.L	#7,D1
sldskip
	BMI.B	sldskip2
	CMP.L	D1,D0
	BLS.W	sldskip3
	MOVE.W	D0,(A0)
	CMP.L	#1,D0
	BEQ.B	sldskip2
	BRA.B	sldskip5
sldskip2
	CLR.W	(A0)
	BRA.B	sldskip5
sldskip3
	MOVE.W	D1,(A0)
sldskip5
	JSR	GUIDelay
sldskip4
	BRA.W	ShowSampleInfo

SampleLengthFlag	dc.w 0

CheckSampleLength
	TST.W	SampleLengthFlag
	BEQ.W	Return2
	CLR.W	SampleLengthFlag
	MOVEQ	#0,D0
	MOVE.W	InsNum,D0
	BEQ.W	Return2
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVE.L	D0,D1
	LSL.W	#2,D1
	MULU.W	#30,D0
	ADD.L	D0,A0
	LEA	SongDataPtr,A1
	LEA	(A1,D1.W),A1
	MOVE.L	A0,PlaySamPtr
	MOVE.L	A1,RealSamPtr
	MOVE.L	124(A1),D0
	LSR.L	#1,D0
	MOVE.W	(A0),D1
	CMP.W	D0,D1
	BHI.B	ItsTooMuch
	RTS

ItsTooMuch
	LEA	AddWorkSpaceText(PC),A0
	BSR.W	AreYouSure
	BNE.B	RestoreLength
	BSR.W	TurnOffVoices
	MOVE.L	PlaySamPtr(PC),A0
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	ADD.L	D0,D0
	MOVE.L	D0,SamAllocLen
	MOVE.L	#MEMF_CHIP!MEMF_CLEAR,D1
	JSR	PTAllocMem
	MOVE.L	D0,SamAllocPtr
	BEQ.B	RestoreLength
	MOVE.L	D0,A1
	MOVE.L	RealSamPtr(PC),A0
	MOVE.L	(A0),D0
	BEQ.B	nosamth
	MOVE.L	D0,A2
	MOVE.L	124(A0),D1
	BEQ.B	nosamth
	SUBQ.L	#1,D1
cpsalop	MOVE.B	(A2)+,(A1)+
	DBRA	D1,cpsalop
	MOVE.L	(A0),A1
	MOVE.L	124(A0),D0
	JSR	PTFreeMem
nosamth	MOVE.L	RealSamPtr(PC),A0
	MOVE.L	SamAllocPtr(PC),(A0)
	MOVE.L	SamAllocLen(PC),124(A0)
	BSR.W	ShowSampleInfo
	JSR	RedrawSample
	JSR	DoShowFreeMem
	BRA.W	WaitForButtonUp

RestoreLength
	MOVE.L	PlaySamPtr(PC),A0
	MOVE.L	RealSamPtr(PC),A1
	MOVE.L	124(A1),D0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)
	BRA.W	ShowSampleInfo

	CNOP 0,4
PlaySamPtr	dc.l 0
RealSamPtr	dc.l 0
SamAllocPtr	dc.l 0
SamAllocLen	dc.l 0

AddWorkSpaceText	dc.b 'add workspace ?',0
	EVEN

RepeatGadg
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.W	InsNum,D0
	BEQ.W	ShowSampleInfo
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVE.W	4(A0),D2
	TST.W	UpOrDown
	BMI.B	RepeatDown
RepeatUp
	ADDQ.L	#1,D2
	BTST	#2,$DFF016	; right mouse button
	BNE.B	ruskip
	ADDQ.L	#7,D2
ruskip
	MOVE.W	(A0),D0		; Length
	BEQ.B	ruskip4
	MOVE.W	6(A0),D1	; RepLen
	SUB.L	D1,D0		; Length - RepLen
	CMP.L	D2,D0
	BHI.B	ruskip2
	MOVE.W	D0,4(A0)
	BRA.B	repdone
ruskip2
	MOVE.W	D2,4(A0)
repdone	JSR	GUIDelay
ruskip3
	BSR.W	ShowSampleInfo
	BSR.W	UpdateRepeats
	JMP	SetLoopSprites2
ruskip4
	CLR.W	4(A0)
	BRA.B	repdone

RepeatDown
	SUBQ.L	#1,D2
	BTST	#2,$DFF016	; right mouse button
	BNE.B	rdskip
	SUBQ.L	#7,D2
rdskip	TST.L	D2
	BPL.B	ruskip2
	MOVEQ	#0,D2
	BRA.B	ruskip2

RepLenGadg
	MOVE.L	SongDataPtr,A0
	LEA	12(A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.W	InsNum,D0
	BEQ.W	ShowSampleInfo
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVE.W	6(A0),D2
	TST.W	UpOrDown
	BMI.B	RepLenDown
RepLenUp
	ADDQ.L	#1,D2
	BTST	#2,$DFF016	; right mouse button
	BNE.B	rluskip
	ADDQ.L	#7,D2
rluskip
	MOVE.W	(A0),D0		;   Length
	BEQ.B	rlupskip4
	MOVE.W	4(A0),D1
	SUB.L	D1,D0
	CMP.L	D2,D0
	BHI.W	rlupskip3	
	CMP.L	#1,D0
	BGE.B	rlupskip2
	MOVEQ	#1,D0
rlupskip2
	MOVE.W	D0,6(A0)
	BRA.W	repdone
	
rlupskip3
	MOVE.W	D2,6(A0)
	BRA.W	repdone
	
rlupskip4
	MOVE.W	#$0001,6(A0)
	BRA.W	repdone


RepLenDown
	MOVEQ	#0,D0
	MOVE.W	6(A0),D0
	SUBQ.L	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	rldskip
	SUBQ.L	#7,D0
rldskip	CMP.L	#1,D0
	BGE.B	rldskp2
	MOVEQ	#1,D0
rldskp2	MOVE.W	D0,6(A0)
	BRA.W	repdone

Wait_4000
	MOVEM.L	D0/D1/A0/A1/A6,-(SP)
	MOVE.L	DOSBase,A6
	MOVEQ	#1,D1
	JSR	_LVODelay(A6)
	MOVEM.L	(SP)+,D0/D1/A0/A1/A6
	RTS

UpdateRepeats
	; 8bitbubsy: just in case...
	MOVE.L	SongDataPtr,A0
	MOVE.W	InsNum,D0
	BEQ.W	upreRTS
	MULU.W	#30,D0
	LEA	12(A0,D0.W),A0
	; --------------------------
	MOVE.L	A4,-(SP)
	LEA	audchan1temp,A1
	LEA	$DFF0A0,A2
	LEA	ScopeInfo+(ScopeInfoSize*0),A3
	BSR.B	upre2
	LEA	audchan2temp,A1
	LEA	$DFF0B0,A2
	LEA	ScopeInfo+(ScopeInfoSize*1),A3
	BSR.B	upre2
	LEA	audchan3temp,A1
	LEA	$DFF0C0,A2
	LEA	ScopeInfo+(ScopeInfoSize*2),A3
	BSR.B	upre2
	LEA	audchan4temp,A1
	LEA	$DFF0D0,A2
	LEA	ScopeInfo+(ScopeInfoSize*3),A3
	BSR.B	upre2
	MOVE.L	(SP)+,A4
	RTS	

upre2	MOVE.W	InsNum,D0
	CMP.B	n_samplenum(A1),D0	; channel sample == selected GUI sample?
	BNE.B	upreRTS			; nope, don't update loops
	MOVE.L	n_start(A1),A4
	CMP.L	#0,A4			; ch->n_start == NULL?
	BEQ.B	upreRTS			; yep, don't update loops
	MOVEQ	#0,D0
	MOVE.W	4(A0),D0		; repeat
	ADD.L	D0,A4
	ADD.L	D0,A4
	MOVE.W	6(A0),D0		; replen
	; ----------------------------
	; PT2.3D bugfix: also update replayer vars
	MOVE.L	A4,n_loopstart(A1)
	MOVE.W	D0,n_replen(A1)
	MOVE.L	A4,n_wavestart(A1)
	; ----------------------------
	MOVE.L	A4,0(A2)		; set Paula DAT
	MOVE.W	D0,4(A2)		; set Paula LEN
	; ----------------------------
	MOVE.L	A4,ns_repeatptr(A3)	; quadrascope
	ADD.L	D0,A4
	ADD.L	D0,A4
	MOVE.L	A4,ns_rependptr(A3)
upreRTS	RTS

SetPatternPos
	MOVE.L	PatternPosition,D0
	LSR.L	#4,D0
	BRA.B	ssppskip

SetScrPatternPos
	MOVE.W	ScrPattPos,D0
ssppskip
	TST.W	SamScrEnable
	BNE.B	Return2
	MOVE.W	D0,PlayFromPos
	MULU.W	#7*40,D0
	ADD.L	#TextBitplane+5560,D0
	MOVE.L	CopListBpl4Ptr,A1
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)
Return2
	RTS

PlayFromPos	dc.w 0

xTempoGadg	JMP	TempoGadg

WantedPattGadg
	TST.W	SamScrEnable
	BNE.W	CheckSamGadgets
TypeInWantedPatt
	CMP.W	#138,D1
	BHI.B	tiwp2
	CMP.W	#25,D0
	BHI.B	xTempoGadg
tiwp2	CMP.L	#'patp',RunMode	; not if a song is playing... 
	BEQ.B	Return2
	CLR.B	RawKeyCode
	MOVE.W	#12,LineCurX
	MOVE.W	#$0085,LineCurY
	MOVE.W	#5121,TextOffset
	BSR.W	GetDecByte
	TST.W	AbortDecFlag
	BNE.B	twexit
	MOVE.B	D0,PatternNumber+3
	MOVE.L	PatternNumber,D0
	CMP.L	MaxPattern(PC),D0
	BLS.B	twexit
	MOVE.L	MaxPattern(PC),PatternNumber
twexit	BRA.W	RedrawPattern

GetKey0_9
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	gk_ret
	JSR	CheckPatternRedraw2
	MOVEQ	#0,D0
	JSR	DoKeyBuffer
	MOVE.B	RawKeyCode,D0
	BEQ.B	GetKey0_9
	CLR.B	RawKeyCode
	CMP.B	#68,D0
	BEQ.B	gk_ret
	CMP.B	#69,D0
	BEQ.B	gk_ret
	CMP.B	#10,D0
	BEQ.B	gk_end
	BHI.B	GetKey0_9
	CMP.B	#1,D0
	BLO.B	GetKey0_9
	MOVE.L	D0,D1
	RTS

gk_end	MOVEQ	#0,D1
	RTS

gk_ret	MOVEQ	#68,D1
	RTS

ShowOneDigit
	ADD.B	#'0',D1
	MOVE.B	D1,NumberText
	CLR.W	D1
	SWAP	D1
	MOVE.W	#1,TextLength
	MOVE.L	#NumberText,ShowTextPtr
	BSR.W	ShowText
	CLR.L	NumberText
	CLR.W	WordNumber
	RTS
	
;---- Get Text Line ----

GetTextLine
	MOVEQ	#0,D0
	MOVE.W	A4,D0
	DIVU.W	#40,D0
	ADDQ.W	#5,D0
	MOVE.W	D0,LineCurY
	SWAP	D0
	LSL.W	#3,D0
	ADDQ.W	#4,D0
	MOVE.W	D0,LineCurX
	BSR.W	UpdateLineCurPos
	MOVE.L	ShowTextPtr,DSTPtr
	CLR.L	DSTOffset
	CLR.L	DSTPos
	MOVE.W	#1,GetLineFlag
	MOVE.W	#0,AbortStrFlag
	MOVE.L	A4,A5
	MOVE.W	LineCurX,D5
	CLR.B	RawKeyCode
	BSR.W	UpdateText
WaitForKey
	BTST	#2,$DFF016	; right mouse button
	BEQ.W	AbortGetLine
	BTST	#6,$BFE001	; left mouse button
	BEQ.W	LineClicked
	JSR	CheckPatternRedraw2
	JSR	DoKeyBuffer
	MOVEQ	#0,D1
	MOVE.B	RawKeyCode,D1
	BEQ.B	WaitForKey
	CMP.B	#78,D1	; Left
	BEQ.W	MoveCharRight
	CMP.B	#79,D1	; Right
	BEQ.W	MoveCharLeft
	CMP.B	#70,D1	; DEL
	BEQ.W	DeleteChar
	CMP.B	#65,D1	; Backspace
	BEQ.W	BackspaceChar
	CMP.B	#68,D1	; Return
	BEQ.W	GetLineReturn
	CMP.B	#69,D1	; ESC
	BEQ.W	GetLineReturn
	BTST	#7,D1
	BNE.B	WaitForKey
	LEA	UnshiftedKeymap,A4
	TST.W	ShiftKeyStatus
	BEQ.B	gtlskip
	LEA	ShiftedKeymap,A4
gtlskip	AND.W	#$007F,D1
	CMP.B	#64,D1
	BHI.W	WaitForKey
	MOVE.B	(A4,D1.W),D1
	BEQ.W	WaitForKey
	TST.B	EnterTextFlag
	BEQ.B	TextLineKey
	CMP.B	#'0',D1
	BLO.W	WaitForKey
	CMP.B	#'f',D1
	BHI.W	WaitForKey
	CMP.B	#'a',D1
	BHS.B	TextLineKey
	CMP.B	#'9',D1
	BHI.W	WaitForKey
TextLineKey
	CMP.L	TextEndPtr,A6
	BEQ.W	WaitForKey
	MOVE.L	TextEndPtr,A4
tlkloop	MOVE.B	-(A4),1(A4)
	CMP.L	A4,A6
	BNE.B	tlkloop
	MOVE.L	TextEndPtr,A4
	CLR.B	(A4)
	MOVE.B	D1,(A6)+
	BSR.B	PosMoveRight
	BSR.W	UpdateText
	CLR.B	RawKeyCode
	BRA.W	WaitForKey

LineClicked
	MOVE.W	MouseY(PC),D1
	SUB.W	LineCurY,D1
	CMP.W	#2,D1
	BGT.W	GetLineReturn
	CMP.W	#-8,D1
	BLT.W	GetLineReturn
	MOVE.W	MouseX(PC),D1
	SUB.W	LineCurX,D1
	ADDQ.W	#4,D1
	ASR.W	#3,D1
	BEQ.W	WaitForKey
	BPL.B	linclri
	
	CMP.L	DSTPtr(PC),A6
	BEQ.W	WaitForKey
	SUBQ.L	#1,A6
	BSR.B	PosMoveLeft
upwake2	BSR.W	UpdateText
	BRA.W	WaitForKey

linclri	CMP.L	TextEndPtr,A6
	BEQ.W	WaitForKey
	TST.B	(A6)
	BEQ.W	WaitForKey
	ADDQ	#1,A6
	BSR.B	PosMoveRight
	BRA.B	upwake2

PosMoveRight
	MOVE.L	DSTPos(PC),D0
	MOVEQ	#0,D1
	MOVE.W	TextLength,D1
	TST.B	EnterTextFlag
	BNE.B	pmrskip
	SUBQ.W	#1,D1
pmrskip	CMP.L	D1,D0
	BLO.B	posrok
	ADDQ.L	#1,DSTOffset
	BRA.W	UpdateLineCurPos
posrok	ADDQ.L	#1,DSTPos
	ADDQ.W	#8,LineCurX
	BRA.W	UpdateLineCurPos

PosMoveLeft
	TST.L	DSTPos
	BNE.B	poslok
	SUBQ.L	#1,DSTOffset
	BRA.W	UpdateLineCurPos
poslok	SUBQ.L	#1,DSTPos
	SUBQ.W	#8,LineCurX
	BRA.W	UpdateLineCurPos

BackspaceChar
	CMP.L	DSTPtr(PC),A6
	BEQ.W	WaitForKey
	SUBQ.L	#1,A6
	MOVE.L	A6,A4
dobaloop
	MOVE.B	1(A4),(A4)+
	CMP.L	TextEndPtr,A4
	BNE.B	dobaloop
	BSR.B	PosMoveLeft
upwake	BSR.W	UpdateText
	BSR.W	Wait_4000
	BSR.W	Wait_4000
	BSR.W	Wait_4000
	BRA.W	WaitForKey

DeleteChar
	MOVE.L	A6,A4
dechloop
	MOVE.B	1(A4),(A4)+
	CMP.L	TextEndPtr,A4
	BLO.B	dechloop
	BRA.B	upwake

MoveCharRight
	CMP.L	TextEndPtr,A6
	BEQ.W	WaitForKey
	TST.B	(A6)
	BEQ.W	WaitForKey
	ADDQ	#1,A6
	BSR.W	PosMoveRight
	BRA.B	upwake

MoveCharLeft
	CMP.L	DSTPtr(PC),A6
	BEQ.W	WaitForKey
	SUBQ.L	#1,A6
	BSR.W	PosMoveLeft
	BRA.B	upwake

GetLineReturn
	MOVE.L	DSTPtr(PC),A6
	CMP.B	#1,EnterTextFlag
	BNE.B	gtl_rskip
	TST.B	DiskNumText2
	BEQ.W	WaitForKey
gtl_rskip
	CMP.B	#3,EnterTextFlag
	BNE.B	gtl_rskip2
	TST.B	SndDiskNum1
	BEQ.W	WaitForKey
gtl_rskip2
	MOVE.L	A6,A4
dlrloop	TST.B	(A4)+
	BNE.B	dlrloop
	SUBQ.L	#1,A4
dlrloop2
	CMP.L	TextEndPtr,A4
	BHS.B	dlrexit
	CLR.B	(A4)+
	BRA.B	dlrloop2

dlrexit	CLR.W	LineCurX
	MOVE.W	#270,LineCurY
	BSR.W	UpdateLineCurPos
	CLR.W	GetLineFlag
	MOVE.B	RawKeyCode,MixChar
	CLR.B	RawKeyCode
	CLR.L	DSTOffset
	BSR.B	UpdateText
	BRA.W	WaitForButtonUp

AbortGetLine
	MOVE.W	#1,AbortStrFlag
	MOVE.L	DSTPtr(PC),A6
	MOVE.L	A6,A4
clliloop
	CLR.B	(A4)+
	CMP.L	TextEndPtr,A4
	BNE.B	clliloop
	BSR.B	UpdateText
	BRA.W	GetLineReturn

UpdateText
	MOVE.W	A5,TextOffset
	MOVE.L	DSTPtr(PC),A0
	ADD.L	DSTOffset(PC),A0
	BRA.W	ShowText2

	CNOP 0,4
DSTPtr		dc.l 0
DSTPos		dc.l 0
DSTOffset	dc.l 0


;----

TypeInSongName
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	CLR.L	EditMode
	MOVE.L	SongDataPtr,A6
	MOVE.L	A6,TextEndPtr
	MOVE.L	A6,ShowTextPtr
	ADD.L	#19,TextEndPtr
	MOVE.W	#20,TextLength
	MOVE.W	#4133,A4
	BSR.W	GetTextLine
	CLR.L	TextEndPtr
	BRA.W	RestorePtrCol

CheckSmplNamOrLoad
	CMP.W	#$11F,MouseX2
	BHS.W	LoadNamedSample
	BSR.W	StorePtrCol
TypeInSampleName
	BSR.W	SetWaitPtrCol
	CLR.L	EditMode
	MOVE.L	SongDataPtr,A6
	LEA	-10(A6),A6
	MOVE.W	InsNum,D7
	BNE.B	tisnskip
	MOVE.W	LastInsNum,D7
tisnskip
	MULU.W	#30,D7
	ADD.L	D7,A6
	MOVE.L	A6,TextEndPtr
	MOVE.L	A6,ShowTextPtr
	ADD.L	#21,TextEndPtr
	MOVE.W	#22,TextLength
	MOVE.W	#4573,A4
	BSR.W	GetTextLine
	CLR.L	TextEndPtr
	BRA.W	RestorePtrCol

LoadSample
	TST.W	InsNum
	BEQ.W	NotSampleNull
	BSR.W	StorePtrCol
	LEA	SamplePath2,A0
	BSR.W	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
lsloop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,lsloop
	MOVE.L	SongDataPtr,A0
	MOVE.W	InsNum,D0
	MULU.W	#30,D0
	LEA	-10(A0),A0
	ADD.L	D0,A0
	LEA	DirInputName,A1
	MOVEQ	#22-1,D0
lsloop2	MOVE.B	(A1)+,(A0)+
	DBRA	D0,lsloop2
	BSR.W	SetDiskPtrCol
	MOVE.L	#FileName,D1
	BSR.W	ExamineAndAlloc
	BEQ.W	ErrorRestoreCol
	MOVE.L	#FileName,D1
	BRA.W	lnssec2

CheckForIFF2 ; load loop
	MOVEQ	#-1,D2
	BRA.B	ciff2
CheckForIFF
	MOVEQ	#0,D2
ciff2	MOVEQ	#0,D1
	CMP.L	#'FORM',(A0)
	BNE.B	wiskip
	CMP.L	#'8SVX',8(A0)
	BNE.B	wiskip
	MOVE.L	A0,A2
	MOVE.L	A1,D0
	ADD.L	A0,A1
	TST.L	D2
	BEQ.B	cfiloop
	BSR.W	CheckIFFLoop
cfiloop	CMP.L	#'BODY',(A0)
	BEQ.B	WasIFF
	ADDQ	#2,A0
	CMP.L	A1,A0
	BLS.B	cfiloop
	RTS

WasIFF	ADDQ	#8,A0
	ADD.L	A2,D0
	SUB.L	A0,D0
wiloop	MOVE.B	(A0)+,(A2)+
	CMP.L	A1,A0
	BLS.B	wiloop
	MOVE.L	SampleInstrSave(PC),A3
	CMP.L	#$1FFFE,D0	; overflow fix
	BLS.B	wiok
	MOVE.L	#$1FFFE,D0
wiok	LSR.L	#1,D0
	MOVE.W	22(A3),D1
	SUB.W	D0,D1
	MOVE.W	D0,22(A3)
wiskip	LEA	SampleLengthAdd(PC),A3
	MOVE.W	InsNum,D0
	ADD.W	D0,D0
	MOVE.W	D1,(A3,D0.W)
	RTS

CheckIFFLoop
	MOVEM.L	D0-D3/A0,-(SP)
	TST.B	IFFLoopFlag
	BEQ.W	wDisL
cilloop	CMP.L	#'VHDR',(A0)
	BEQ.B	wasvhdr
	ADDQ	#2,A0
	CMP.L	A1,A0
	BLS.B	cilloop
cilend
	MOVEM.L	(SP)+,D0-D3/A0
	RTS

; 8bitbubsy: modified to safely disable overflown loop points
wasvhdr	MOVE.L	SampleInstrSave(PC),A3
	MOVEQ	#0,D0
	MOVE.W	22(A3),D0	
	ADD.L	D0,D0		; D0 = allocated sample length (in bytes)	
	MOVE.L	8(A0),D1	; D1 = IFF repeat
	MOVE.L	12(A0),D2	; D2 = IFF replen
	
	CMP.L	#2,D2		; IFF replen >= 2 ?
	BLO.B	wDisL		; nope, disable loop
	
	MOVE.L	D1,D3
	ADD.L	D2,D3		; D3 = IFF repend

	CMP.L	D0,D3		; IFF repend <= allocated sample length ?
	BHI.B	wDisL		; nope, disable loop

	LSR.L	#1,D1
	MOVE.W	D1,26(A3)	; store repeat	
	LSR.L	#1,D2
	MOVE.W	D2,28(A3)	; store replen
	BRA.B	cilend
	
wDisL	MOVE.L	SampleInstrSave(PC),A3
	CLR.W	26(A3)		; disable sample loop
	MOVE.W	#1,28(A3)
	BRA.B	cilend

	CNOP 0,4
SampleInstrSave	dc.l 0
SampleLengthAdd	dcb.w 32+1,0

ExamineAndAlloc	; fixed in PT2.3E to be 128kB compatible
	MOVEQ	#-2,D2
	MOVE.L	DOSBase,A6
	JSR	_LVOLock(A6)
	MOVE.L	D0,FileLock
	BEQ.W	CantFindFile
	MOVE.L	D0,D1
	MOVE.L	#FileInfoBlock,D2
	JSR	_LVOExamine(A6)
	TST.L	FIB_EntryType
	BPL.W	CantExamFile
	MOVE.L	FileLock,D1
	JSR	_LVOUnLock(A6)
	MOVE.L	FIB_FileSize,D0
	BEQ.W	FileIsEmpty
	BSR.W	TurnOffVoices
	BSR.W	FreeSample
	MOVE.L	FIB_FileSize,D0
	CMP.L	#$1FFFE,D0	; 8bitbubsy: add padding for header
	BLS.B	exalloc
	MOVE.L	#$1FFFE,D0	; 8bitbubsy: add padding for header
exalloc	LEA	SongDataPtr,A4
	MOVEQ	#0,D1
	MOVE.W	InsNum,D1
	LSL.W	#2,D1
	ADD.L	D1,A4
	MOVE.L	D0,124(A4)
	MOVE.L	D0,DiskDataLength
	MOVE.L	#MEMF_CHIP!MEMF_CLEAR,D1
	JSR	PTAllocMem
	MOVE.L	D0,DiskDataPtr
	MOVE.L	D0,(A4)
	BEQ.W	OutOfMemErr
	LEA	LoadingSampleText,A0
	BSR.W	ShowStatusText
SampleAllocOK
	MOVE.L	SongDataPtr,A0
	MOVE.W	InsNum,D0
	MULU.W	#30,D0
	LEA	-10(A0),A0
	ADD.L	D0,A0
	MOVE.L	A0,SampleInstrSave
	MOVE.L	DiskDataLength,D0
	CMP.L	#$1FFFE,D0
	BLS.B	.skip
	MOVE.L	#$1FFFE,D0
.skip	LSR.L	#1,D0
	MOVE.W	D0,22(A0)
	MOVE.L	#$00400000,24(A0)
	MOVE.W	#1,28(A0)
	BSR.W	ShowSampleInfo
	MOVEQ	#-1,D0
	RTS

LoadNamedSample
	TST.W	InsNum
	BEQ.W	NotSampleNull
	BSR.W	StorePtrCol
	BSR.W	CreateSampleName
	BSR.W	SetDiskPtrCol
	MOVE.L	FileNamePtr,D1
	BSR.W	ExamineAndAlloc
	BEQ.W	Return2
	MOVE.L	FileNamePtr,D1
lnssec2	MOVE.L	DOSBase,A6
	MOVE.L	#1005,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,D7
	BEQ.W	CantOpenFile
	MOVE.L	D0,D1
	MOVE.L	DiskDataPtr,D2
	MOVE.L	DiskDataLength,D3
	JSR	_LVORead(A6)
	MOVE.L	D7,D1
	JSR	_LVOClose(A6)
	MOVE.L	DiskDataPtr,A0
	MOVE.L	DiskDataLength,A1
	CMP.L	#"PP20",(A0)
	BEQ.W	LoadCrunchedSample
	CMP.L	#"PX20",(A0)
	BEQ.W	LoadCrunchedSample
LoadSampleOK
	BSR.W	CheckForIFF2
	BSR.W	ValidateLoops
	BSR.W	ShowSampleInfo
	MOVE.L	DiskDataPtr,A0
	CLR.W	(A0)
	JSR	RedrawSample
	CLR.L	SavSamInf
	BSR.W	ShowAllRight
	BRA.W	RestorePtrCol

CreateSampleName
	LEA	SampleFileName,A0
	MOVEQ	#28-1,D0
csnloop	CLR.B	(A0)+
	DBRA	D0,csnloop
	MOVE.L	SongDataPtr,A0
	MOVE.W	InsNum,D0
	MULU.W	#30,D0
	LEA	-10(A0),A0
	ADD.L	D0,A0
	MOVE.L	A0,SampleInstrSave
	MOVEQ	#0,D0
	MOVE.W	22(A0),D0
	ADD.L	D0,D0
	MOVE.L	D0,DiskDataLength
	MOVE.L	D0,IFFBODY+4
	ADD.L	#IFFEND-IFFFORM-8,D0
	MOVE.L	D0,IFFFORM+4
	
	MOVEQ	#0,D0
	MOVE.W	22(A0),D0
	ADD.L	D0,D0
	MOVEQ	#0,D1
	MOVE.W	28(A0),D1
	CMP.W	#1,D1
	BLS.B	csnskp2
	ADD.L	D1,D1
	MOVEQ	#0,D0
	MOVE.W	26(A0),D0
	ADD.L	D0,D0
	BRA.B	csnskp3
csnskp2	MOVEQ	#0,D1
csnskp3	MOVE.L	D0,IFFVHDR+8
	MOVE.L	D1,IFFVHDR+12
	
	LEA	SampleFileName,A1
	LEA	IFFNAME+8(PC),A2
	MOVEQ	#22-1,D0
csnloop2
	MOVE.B	(A0),(A1)+
	MOVE.B	(A0)+,(A2)+
	DBRA	D0,csnloop2
	MOVE.L	#SampleFileName,D1
	MOVE.L	D1,FileNamePtr
	BSR.B	FindColon
	BEQ.B	CheckOverride
	LEA	SamplePath2,A0
	BSR.W	CopyPath
	LEA	SampleFileName,A0
csnloop3
	MOVE.B	(A0)+,(A1)+
	BNE.B	csnloop3
	MOVE.L	#FileName,FileNamePtr
	RTS

FindColon
	MOVE.L	D1,A0
fcloop	MOVE.B	(A0)+,D0
	BEQ.B	FindColonFail
	CMP.B	#':',D0
	BEQ.B	FindColonSuccess
	BRA.B	fcloop

FindColonFail
	MOVEQ	#-1,D0
	RTS

FindColonSuccess
	MOVEQ	#0,D0
	RTS


CheckOverride
	TST.B	OverrideFlag
	BEQ.W	Return2
	LEA	SampleFileName,A0
	MOVE.L	A0,A1
	LEA	21(A1),A1
	MOVE.L	A1,A2
chkovlp	MOVE.B	-(A1),D0
	CMP.B	#':',D0
	BEQ.B	chkovok
	CMP.B	#'/',D0
	BEQ.B	chkovok
	MOVE.L	A1,A2
	CMP.L	A0,A1
	BHI.B	chkovlp
chkovok	LEA	SamplePath2,A0
	BSR.W	CopyPath
chkovl2	MOVE.B	(A2)+,(A1)+
	BNE.B	chkovl2
	MOVE.L	#FileName,FileNamePtr
	RTS

ValidateLoops
	MOVE.L	SongDataPtr,A0
	LEA	sd_sampleinfo(A0),A0
	MOVEQ	#31-1,D0
valolop	MOVE.W	22(A0),D1
	MOVE.W	26(A0),D2
	MOVE.W	28(A0),D3
	CMP.W	D1,D2
	BHS.B	valosk1
	ADD.W	D2,D3
	CMP.W	D1,D3
	BHI.B	valosk2
valoque	TST.W	28(A0)
	BNE.B	valosk3
	MOVE.W	#1,28(A0)
valosk3	LEA	30(A0),A0
	DBRA	D0,valolop
	RTS
valosk2	SUB.W	D2,D1
	MOVE.W	D1,28(A0)
	BRA.B	valoque
valosk1	MOVEQ	#1,D1
	MOVE.L	D1,26(A0)
	BRA.B	valoque

LoadPreset
	CLR.B	RawKeyCode
	TST.W	InsNum
	BEQ.W	NotSampleNull
	BSR.W	TurnOffVoices
	BSR.W	FreeSample
	BSR.W	CreateSampleName
	MOVE.L	FileNamePtr,A0
	TST.B	(A0)
	BEQ.W	Return2
	MOVE.L	DiskDataLength,D0
	BEQ.W	Return2
	MOVE.L	DiskDataLength,D0
	BSR.B	AllocSample
	MOVE.L	DiskDataPtr,D0
	BEQ.B	loprerr
	BSR.W	ShowSampleInfo
	BSR.W	DoLoadData
	BSR.W	ShowAllRight
	MOVE.L	DiskDataPtr,A0
	MOVE.L	DiskDataLength,A1
	BSR.W	CheckForIFF
	BSR.W	ValidateLoops
	BSR.W	ShowSampleInfo
	MOVE.L	DiskDataPtr,A0
	CLR.W	(A0)
	JSR	RedrawSample
	ST	UpdateFreeMem
	RTS

loprerr	BSR.W	StorePtrCol
	BSR.W	OutOfMemErr
	BSR.W	RestorePtrCol
	JMP	RedrawSample

AllocSample
	MOVE.L	D0,-(SP)
	MOVE.L	#MEMF_CHIP!MEMF_CLEAR,D1
	JSR	PTAllocMem
	MOVE.L	D0,DiskDataPtr
	LEA	SamplePtrs,A0
	MOVE.W	InsNum,D1
	LSL.W	#2,D1
	LEA	(A0,D1.W),A0
	MOVE.L	DiskDataPtr,(A0)
	MOVE.L	(SP)+,124(A0)
	RTS

FreeSample
	LEA	SamplePtrs,A0
	MOVE.W	InsNum,D0
	BEQ.W	Return2
	LSL.W	#2,D0
	LEA	(A0,D0.W),A0
	MOVE.L	(A0),D1
	BEQ.W	Return2
	CLR.L	(A0)
	MOVE.L	124(A0),D0
	CLR.L	124(A0)
	MOVE.L	D1,A1
	JSR	PTFreeMem
	RTS

NotSampleNull
	LEA	NotSample0Text(PC),A0
	BSR.W	ShowStatusText
	BRA.W	SetErrorPtrCol

NotSample0Text	dc.b 'not sample 0 !',0
	EVEN
;----

xxDeleteSongGadg	JMP	DeleteSongGadg

DeleteSong
	LEA	DeleteSongText,A0
	BSR.W	AreYouSure
	BNE.B	xxDeleteSongGadg
	LEA	DeletingSongText,A0
	BSR.W	ShowStatusText
	LEA	SongsPath2,A0
	JSR	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
dsloop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,dsloop
	MOVE.W	#1,Action
Delete3	MOVE.L	#FileName,FileNamePtr
	MOVE.L	DOSBase,A6
	MOVE.L	FileNamePtr,D1
	MOVE.L	D1,A0
	JSR	_LVODeleteFile(A6)
	BSR.W	ClearFileNames
	BSR.W	ShowAllRight
	BSR.W	SetNormalPtrCol
	BSR.W	StorePtrCol
	JMP	DoAutoDir

DeleteModule
	LEA	DeleteModuleText,A0
	BSR.W	AreYouSure
	BNE.B	xxDeleteModuleGadg
	LEA	DeletingModuleText,A0
	BSR.W	ShowStatusText
	LEA	ModulesPath2,A0
	JSR	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
dmdloop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,dmdloop
	MOVE.W	#3,Action
	BRA.B	Delete3

xxDeleteModuleGadg	JMP	DeleteModuleGadg

DeleteSample
	LEA	DeleteSampleText,A0
	BSR.W	AreYouSure
	BNE.B	xxDeleteSampleGadg
	LEA	DeletingSampleText,A0
	BSR.W	ShowStatusText
	LEA	SamplePath2,A0
	JSR	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
dsaloop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,dsaloop
	MOVE.W	#5,Action
	BRA.W	Delete3
	
xxDeleteSampleGadg	JMP	DeleteSampleGadg

RenameFile
	LEA	RenamingFileText,A0
	BSR.W	ShowStatusText
	LEA	DirInputName,A0
	LEA	NewInputName,A1
	MOVEQ	#24-1,D0
rnfloop	MOVE.B	(A0)+,(A1)+
	BNE.B	rnfskip
	SUBQ.L	#1,A0
rnfskip	DBRA	D0,rnfloop
	BSR.W	StorePtrCol
	BSR.W	SetWaitPtrCol
	LEA	NewInputName,A6
	MOVE.L	A6,ShowTextPtr
	MOVE.L	A6,TextEndPtr
	ADD.L	#23,TextEndPtr
	MOVE.W	#24,TextLength
	MOVE.W	FileNameScrollPos+2(PC),D0
	MULU.W	#240,D0
	MOVE.W	#1888,A4
	ADD.W	D0,A4
	BSR.W	GetTextLine
	TST.B	NewInputName
	BEQ.B	rnfend
	CMP.B	#69,MixChar
	BEQ.B	rnfend
	
	MOVE.L	PathPtr,A0
	JSR	CopyPath
	LEA	NewInputName,A0
	MOVEQ	#24-1,D0
rnfloop2	MOVE.B	(A0)+,(A1)+
	DBRA	D0,rnfloop2
	
	LEA	FileName,A0
	LEA	NewFileName,A1
rnfloop3	MOVE.B	(A0)+,(A1)+
	BNE.B	rnfloop3
	
	MOVE.L	PathPtr,A0
	JSR	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
rnfloop4
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,rnfloop4
	
	MOVE.L	#FileName,D1
	MOVE.L	#NewFileName,D2
	MOVE.L	DOSBase,A6
	JSR	_LVORename(A6)
	
rnfend	BSR.W	ClearFileNames
	CLR.W	Action
	BSR.W	RestorePtrCol
	BSR.W	ShowAllRight
	JMP	DoAutoDir

LoadSong	CLR.W	OutOfMemoryFlag
lbC00B62A	MOVE.W	#1,LoadInProgress
	BSR.W	DoClearSong
	BSR.W	ClrSampleInfo
	LEA	SongsPath2,A0
	JSR	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
losoloop2
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,losoloop2
	MOVE.L	SongDataPtr,DiskDataPtr
	MOVE.L	#FileName,FileNamePtr
	MOVE.L	SongAllocSize(PC),DiskDataLength
	LEA	LoadingSongText,A0
	BSR.W	ShowStatusText
	BSR.W	DoLoadData
	BEQ.W	lososkip3
	MOVE.L	SongDataPtr,A0
	CMP.L	#"PP20",(A0)
	BEQ.W	PowerPacked
	CMP.L	#"PX20",(A0)
	BEQ.W	PowerPacked
	MOVE.L	SongDataPtr,A0
	CMP.L	#"PAKK",(A0)
	BNE.W	lbC00B756
	TST.W	OutOfMemoryFlag
	BNE.W	lbC00B746
	TST.B	OneHundredPattFlag
	BNE.W	lbC00B75E
lbC00B6C2	MOVE.L	SongDataPtr,D1
	BEQ.B	lbC00B6DC
	MOVE.L	D1,A1
	MOVE.L	SongAllocSize(PC),D0
	JSR	PTFreeMem
lbC00B6DC	EOR.B	#1,OneHundredPattFlag
	MOVE.L	#SONG_SIZE_64PAT,SongAllocSize
	MOVE.L	#63,MaxPattern
	TST.B	OneHundredPattFlag
	BEQ.B	lbC00B714
	MOVE.L	#SONG_SIZE_100PAT,SongAllocSize
	MOVE.L	#99,MaxPattern
lbC00B714	MOVE.L	SongAllocSize(PC),D0
	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,SongDataPtr
	BNE.B	lbC00B742
	BSR.W	OutOfMemErr
	MOVE.W	#1,OutOfMemoryFlag
	BRA.B	lbC00B6C2

lbC00B742	BRA.W	lbC00B62A

lbC00B746	BSR.W	OutOfMemErr
	BSR.W	DoClearSong
	BRA.W	ClrSampleInfo

lbC00B756	CMP.L	#"PACK",(A0)
	BNE.B	lbC00B796
lbC00B75E	MOVE.L	4(A0),CrunchedSongLength
	MOVE.L	8(A0),RealSongLength
	MOVE.L	SongDataPtr,D0
	ADD.L	SongAllocSize(PC),D0
	SUB.L	RealSongLength(PC),D0
	MOVE.L	D0,EndOfSongPtr
	LEA	DecrunchingText,A0
	BSR.W	ShowStatusText
	BSR.W	Decruncher
	BSR.W	ShowAllRight
lbC00B796
	MOVE.L	SongDataPtr,A0
	CMP.L	#'M!K!',sd_magicid(A0)
	BNE.W	lososkip
	TST.W	OutOfMemoryFlag
	BNE.W	lososkip2
	TST.B	OneHundredPattFlag
	BNE.W	lososkip2
lbC00B7BC	MOVE.L	SongDataPtr,D1
	BEQ.B	lbC00B7D6
	MOVE.L	D1,A1
	MOVE.L	SongAllocSize(PC),D0
	JSR	PTFreeMem
lbC00B7D6	EOR.B	#1,OneHundredPattFlag
	MOVE.L	#SONG_SIZE_64PAT,SongAllocSize
	MOVE.L	#64-1,MaxPattern
	TST.B	OneHundredPattFlag
	BEQ.B	lbC00B80E
	MOVE.L	#SONG_SIZE_100PAT,SongAllocSize
	MOVE.L	#100-1,MaxPattern
lbC00B80E	MOVE.L	SongAllocSize(PC),D0
	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,SongDataPtr
	BNE.B	lbC00B83C
	BSR.W	OutOfMemErr
	MOVE.W	#1,OutOfMemoryFlag
	BRA.B	lbC00B7BC

lbC00B83C	BRA.W	lbC00B62A

lososkip
	CMP.L	#'M.K.',sd_magicid(A0)
	BEQ.B	lososkip2
	BSR.W	NotMKFormat
lososkip2
	LEA	LoadingSongText,A0
	BSR.W	ShowStatusText
	BSR.W	CheckAbort
	BEQ.B	lososkip3
	TST.B	AutoExitFlag
	BEQ.B	NoSongAutoExit
	JSR	ExitFromDir
NoSongAutoExit	BSR.W	ShowSongName
	CLR.L	PatternNumber
	CLR.L	CurrPos
	BSR.W	RedrawPattern
	CLR.W	ScrPattPos
	BSR.W	SetScrPatternPos
	BSR.W	SortDisks
	LEA	SampleSortList,A0
	MOVEQ	#31-1,D0
losoloop3
	TST.B	NosamplesFlag
	BNE.B	lososkip3
	BSR.W	CheckAbort
	BEQ.B	lososkip3
	MOVE.W	InsNum,TuneUp
	JSR	DoShowFreeMem
	MOVE.L	(A0)+,D1
	MOVE.W	D1,InsNum
	MOVEM.L	D0/D1/A0,-(SP)
	BSR.W	LoadPreset
	BSR.W	ShowSampleInfo
	MOVEM.L	(SP)+,D0/D1/A0
	DBRA	D0,losoloop3
lososkip3
	TST.B	OneHundredPattFlag
	BNE.B	lososkip5
	LEA	NoteDataClippedText(PC),A0
	BSR.W	ShowStatusText
	BSR.W	WaitALittle
	MOVE.L	SongDataPtr,A0
	LEA	sd_pattpos(A0),A0
	MOVEQ	#0,D0
	MOVE.B	-1(A0),D0
	MOVEQ	#$3F,D3
losoloop4	CMP.B	(A0)+,D3
	BHI.B	lososkip4
	MOVE.B	D3,-1(A0)
lososkip4
	DBRA	D0,losoloop4
lososkip5
	MOVE.W	#1,InsNum
	MOVE.L	#6,CurrSpeed
	CLR.W	LoadInProgress
	BSR.W	ShowAllRight
	BSR.W	SetNormalPtrCol
	JSR	DoShowFreeMem
	BSR.W	CheckInstrLengths
	BSR.W	ShowSampleInfo
	JMP	RedrawSample

SortDisks
	MOVEM.L	D0-D4/A0/A1,-(SP)
	MOVE.L	SongDataPtr,A0
	LEA	23(A0),A0
	LEA	SampleSortList,A1
	MOVEQ	#1,D0
losoloop5
	MOVE.B	(A0)+,(A1)+	; ST-(0)1
	MOVE.B	(A0),(A1)+	; ST-0(1)
	MOVE.W	D0,(A1)+	; insnum
	LEA	29(A0),A0
	ADDQ.L	#1,D0
	CMP.L	#32,D0
	BLO.B	losoloop5
losoloop6
	CLR.W	MoreInstrFlag
	LEA	SampleSortList,A0
	MOVEQ	#30-1,D2
losoloop7
	MOVE.W	(A0),D0
	MOVE.W	4(A0),D1
	CMP.W	D0,D1 ; if next disk greater
	BHS.B	loso2_2
	MOVE.W	#1,MoreInstrFlag
	MOVE.L	(A0),D3 ; swap disks
	MOVE.L	4(A0),D4
	MOVE.L	D4,(A0)
	MOVE.L	D3,4(A0)
loso2_2	ADDQ	#4,A0
	DBRA	D2,losoloop7
	TST.W	MoreInstrFlag
	BNE.B	losoloop6
	LEA	SampleSortList,A0
	MOVEQ	#31-1,D0
losoloop8
	CLR.W	(A0)
	ADDQ	#4,A0
	DBRA	D0,losoloop8
	MOVEM.L	(SP)+,D0-D4/A0/A1
	RTS

NotMKFormat
	LEA	Loadas31Text(PC),A0
	BSR.W	AreYouSure
	BEQ.B	putmk
	MOVE.L	SongDataPtr,A0	; convert 15 samples to M.K. 31 samples format
	LEA	466(A0),A1
	ADD.L	#66006,A0
makloop	MOVE.L	(A0),484(A0)
	CLR.L	(A0)
	SUBQ.L	#4,A0
	CMP.L	A0,A1
	BNE.B	makloop
	MOVE.L	SongDataPtr,A0
	LEA	sd_magicid(A0),A1
	LEA	sd_numofpatt(A0),A0
makloop2
	MOVE.W	4(A0),(A0)+
	CMP.L	A0,A1
	BNE.B	makloop2
	MOVE.L	#'M.K.',(A0)	; M.K. again!
	MOVEQ	#0,D0
	RTS

putmk
	MOVE.L	SongDataPtr,A0
	MOVE.L	#'M.K.',sd_magicid(A0)
	MOVEQ	#-1,D0
	RTS

Loadas31Text	dc.b	"Load as 31 instr?",0

CheckInstrLengths
	MOVE.L	SongDataPtr,A0
	LEA	20(A0),A0
	MOVEQ	#31-1,D1
xilloop	MOVE.W	26(A0),D0
	ADD.W	28(A0),D0
	CMP.W	22(A0),D0
	BLS.B	xilSkip
	MOVE.W	26(A0),D0
	LSR.W	#1,D0
	MOVE.W	D0,26(A0)
xilSkip
	; --PT2.3D bug fix: zero loop lens + beep fix
	TST.W	28(A0)
	BNE.B	xilSkip2
	MOVE.W	#1,28(A0)
xilSkip2
	; --END OF FIX-------------------------------
	LEA	30(A0),A0
	DBRA	D1,xilloop
	RTS
	
	; Mouse variables have been moved here
	; to be mostly PC-addressing capable.

	CNOP 0,4
MouseX		dc.w 0	; do not change order
MouseY		dc.w 0	; do not change order
MouseXFrac	dc.w 0
MouseYFrac	dc.w 0

CheckAbort
	BTST	#2,$DFF016	; right mouse button
	BNE.W	Return2
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	AbortLoadingText,A0
	BSR.W	AreYouSure
	BNE.B	chabno
	MOVEM.L	(SP)+,D0-D7/A0-A6
	MOVEQ	#0,D7
	RTS
chabno
	MOVEM.L	(SP)+,D0-D7/A0-A6
	MOVEQ	#-1,D7
	RTS

StopIt
	BSR.B	DoStopIt
	CLR.W	$DFF0A8	; clear voice #1 volume
	CLR.W	$DFF0B8	; clear voice #2 volume
	CLR.W	$DFF0C8	; clear voice #3 volume
	CLR.W	$DFF0D8	; clear voice #4 volume
TurnOffVoices
	MOVE.L	A0,-(SP)
	MOVE.L	A1,-(SP)
	MOVE.W	#$000F,$DFF096	; turn off voice DMAs
	CLR.B	RawKeyCode
	LEA	ScopeInfo,A0
	LEA	BlankSample,A1
	MOVE.L	A1,ns_sampleptr+(ScopeInfoSize*0)(A0)
	MOVE.L	A1,ns_sampleptr+(ScopeInfoSize*1)(A0)
	MOVE.L	A1,ns_sampleptr+(ScopeInfoSize*2)(A0)
	MOVE.L	A1,ns_sampleptr+(ScopeInfoSize*3)(A0)
	MOVE.L	(SP)+,A1
	MOVE.L	(SP)+,A0
	RTS

DoStopIt
	TST.W	TempPPFileFlag
	BNE.B	dsiskip
	BSR.W	SetNormalPtrCol
dsiskip
	CLR.L	EditMode
	CLR.L	RunMode
	CLR.B	PattDelayTime
	CLR.B	PattDelayTime2
	BRA.W	RestoreEffects2

UsePreset
	BSR.W	StorePtrCol
	TST.L	PLSTmem
	BEQ.B	upend
	TST.W	InsNum
	BEQ.B	upend
	CLR.B	RawKeyCode
	MOVE.W	CurrentPreset,D0
	SUBQ.W	#1,D0
	MULU.W	#30,D0
	MOVE.L	PLSTmem,A0
	ADD.L	D0,A0
	MOVE.W	InsNum,D0
	MULU.W	#30,D0
	MOVE.L	SongDataPtr,A1
	LEA	-10(A1,D0.W),A1
	MOVE.L	A1,A2
	MOVEQ	#30-1,D0
uploop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,uploop
	MOVE.L	(A2),D0
	AND.L	#$DFDFFFFF,D0
	CMP.L	#$53540000,D0 ;ST__
	BNE.B	upok
	CLR.W	(A2)
	CLR.L	22(A2)
	MOVE.L	#$00000001,26(A2)
upok	BSR.W	LoadPreset
upend	BSR.W	ShowSampleInfo
	BRA.W	RestorePtrCol
	
;---- Edit ----

Edit	TST.W	SamScrEnable
	BNE.W	Return2
	BSR.W	StopIt
	CLR.B	RawKeyCode
	BSR.W	SetEditPtrCol
	BSR.W	SetScrPatternPos
	MOVE.L	#'edit',EditMode
	BRA.W	WaitForButtonUp
	
;---- Edit Op. ----

DoEditOp
	CLR.B	RawKeyCode
	CMP.W	#1,CurrScreen
	BNE.W	Return2
	TST.B	EdEnable
	BEQ.B	EditOp
	ADDQ.B	#1,EdScreen
	CMP.B	#4,EdScreen
	BLO.B	EditOp
	MOVE.B	#1,EdScreen
EditOp	BSR.W	WaitForButtonUp
	ST	EdEnable
	ST	DisableAnalyzer
	JSR	ClearAnalyzerColors
	BSR.W	ClearRightArea
	BRA.B	DrawEditMenu

EdEnable	dc.b	0
EdScreen	dc.b	1
	EVEN

DrawEditMenu
	CMP.B	#1,EdScreen
	BNE.B	demskip
	MOVE.L	#EditOpText1,ShowTextPtr
	LEA	Edit1Data,A0
	MOVE.L	#Edit1Size,D0
	BRA.B	demit
demskip
	CMP.B	#2,EdScreen
	BNE.B	demskip2
	MOVE.L	#EditOpText2,ShowTextPtr
	LEA	Edit2Data,A0
	MOVE.L	#Edit2Size,D0
	BRA.B	demit
demskip2
	CMP.B	#3,EdScreen
	BNE.B	demskip3
	MOVE.L	#EditOpText3,ShowTextPtr
	LEA	Edit3Data,A0
	MOVE.L	#Edit3Size,D0
	BRA.B	demit
demskip3
	CMP.B	#4,EdScreen
	BNE.W	Return2
	MOVE.L	#EditOpText4,ShowTextPtr
	LEA	Edit4Data,A0
	MOVE.L	#Edit4Size,D0
demit   BSR.W	Decompact
	BEQ.W	ExitEditOp
	LEA	SpectrumAnaPos,A0
	MOVEQ	#55-1,D0
demloop1
	MOVEQ	#25-1,D1
demloop2
	MOVE.B	1430(A1),10240(A0)
	MOVE.B	(A1)+,(A0)+
	DBRA	D1,demloop2
	LEA	15(A0),A0
	ADDQ	#1,A1
	DBRA	D0,demloop1
	BSR.W	FreeDecompMem
	MOVE.W	#1936,TextOffset
	MOVE.W	#22,TextLength
	BSR.W	ShowText
	CMP.B	#1,EdScreen
	BEQ.W	ShowSampleAll
	CMP.B	#2,EdScreen
	BNE.B	demskip4
	BSR.W	ShowTrackPatt
	BSR.W	ShowFrom
	BSR.W	ShowTo
	BSR.W	ShowRecordMode
	BSR.W	ShowQuantize
	BSR.W	ShowMetronome
	BRA.W	ShowMultiMode
demskip4
	CMP.B	#3,EdScreen
	BNE.B	demskip5
	BSR.W	ShowHalfClip
	BSR.W	ShowPos
	BSR.W	ShowMod
	BRA.W	ShowVol
demskip5
	CMP.B	#4,EdScreen
	BNE.W	Return2
	BSR.W	ShowNewOld
	BSR.W	ShowChordLength
	BRA.W	DisplayChordNotes

EditOpText1	dc.b	'  track      pattern  '
EditOpText2	dc.b	'  record     samples  '
EditOpText3	dc.b	'    sample editor     '
EditOpText4	dc.b	' sample chord editor  '
	EVEN

CheckEditOpGadgs
	MOVE.W	PattCurPos,D0
	BSR.B	GetPositionPtr
	MOVE.W	MouseX2,D0
	MOVE.W	MouseY2,D1
	CMP.W	#306,D0
	BHS.B	CheckEdSwap
	CMP.B	#1,EdScreen
	BEQ.W	CheckEdGadg1
	CMP.B	#2,EdScreen
	BEQ.W	CheckEdGadg2
	CMP.B	#3,EdScreen
	BEQ.W	CheckEdGadg3
	CMP.B	#4,EdScreen
	BEQ.W	CheckEdGadg4
	RTS

GetPositionPtr
	MOVE.L	SongDataPtr,A0
	LEA	sd_patterndata(A0),A0
	MOVE.L	PatternNumber,D2
	LSL.L	#8,D2
	LSL.L	#2,D2
	ADD.L	D2,A0
	MOVEQ	#0,D2
	MOVE.B	D0,D2
	DIVU.W	#6,D2
	LSL.W	#2,D2
	ADD.W	D2,A0
	RTS

CheckEdSwap
	CMP.W	#55,D1
	BLS.W	Return2
	MOVEQ	#1,D2
	CMP.W	#66,D1
	BLS.B	SetEditOpScreen
	MOVEQ	#2,D2
	CMP.W	#77,D1
	BLS.B	SetEditOpScreen
	MOVEQ	#3,D2
	CMP.W	#88,D1
	BLS.B	SetEditOpScreen
	CMP.W	#99,D1
	BLS.B	ExitEditOp
	RTS

SetEditOpScreen
	MOVE.B	D2,EdScreen
	BRA.W	EditOp

ExitEditOp
	SF	EdEnable
	CLR.B	RawKeyCode
	BRA.W	DisplayMainScreen

CheckEdGadg1
	CMP.W	#55,D1
	BLS.W	ToggleSampleAll
	CMP.W	#66,D1
	BLS.W	NoteUp
	CMP.W	#77,D1
	BLS.W	NoteDown
	CMP.W	#88,D1
	BLS.W	OctaveUp
	CMP.W	#99,D1
	BLS.W	OctaveDown
	RTS

CheckEdGadg2
	CMP.W	#55,D1
	BLS.W	ToggleTrackPatt
	CMP.W	#212,D0
	BLS.B	ceg2left
	CMP.W	#66,D1
	BLS.W	DeleteOrKill
	CMP.W	#77,D1
	BLS.W	ExchangeOrCopy
	CMP.W	#88,D1
	BLS.W	SetSampleFrom
	CMP.W	#99,D1
	BLS.W	SetSampleTo
	RTS

ceg2left
	CMP.W	#66,D1
	BLS.W	ToggleRecordMode
	CMP.W	#77,D1
	BLS.W	SetQuantize
	CMP.W	#88,D1
	BLS.W	SetMetronome
	CMP.W	#99,D1
	BLS.W	ToggleMultiMode
	RTS

CheckEdGadg3
	MOVE.L	SongDataPtr,A5
	LEA	-10(A5),A5
	MOVE.W	InsNum,D2
	BNE.B	ceg3skip
	MOVE.W	LastInsNum,D2
ceg3skip
	MULU.W	#30,D2
	ADD.L	D2,A5
	CMP.W	#55,D1
	BLS.W	ToggleHalfClip
	CMP.W	#212,D0
	BLS.B	ceg3mid
	CMP.W	#66,D1
	BLS.W	SetSamplePos
	CMP.W	#77,D1
	BLS.W	SetModSpeed
	CMP.W	#88,D1
	BLS.W	CutBeg
	CMP.W	#99,D1
	BLS.W	ChangeVolume
	RTS

ceg3mid	CMP.W	#165,D0
	BLS.B	ceg3left
	CMP.W	#66,D1
	BLS.W	Echo
	CMP.W	#77,D1
	BLS.W	Filter
	CMP.W	#88,D1
	BLS.W	Backwards
	CMP.W	#99,D1
	BLS.W	DownSample
	RTS

ceg3left
	CMP.W	#66,D1
	BLS.W	Mix
	CMP.W	#77,D1
	BLS.W	Boost
	CMP.W	#88,D1
	BLS.W	XFade
	CMP.W	#99,D1
	BLS.W	Upsample
	RTS

ToggleSampleAll
	BSR.W	WaitForButtonUp
	EOR.B	#1,SampleAllFlag
ShowSampleAll
	LEA	BitplaneData+1838,A1
	LEA	S_BoxData,A2
	TST.B	SampleAllFlag
	BEQ.B	xrtdoit
	LEA	A_BoxData,A2
xrtdoit	JMP	rtdoit

OctaveUp
	MOVE.W	#24,NoteShift
	BRA.B	nup2

NoteUp	MOVE.W	#2,NoteShift
nup2	BSR.W	SaveUndo
	CMP.W	#212,D0
	BLS.B	nup3
	MOVEQ	#0,D0
	BSR.W	GetPositionPtr
	BSR.B	SampleNoteUp
	MOVEQ	#6,D0
	BSR.W	GetPositionPtr
	BSR.B	SampleNoteUp
	MOVEQ	#12,D0
	BSR.W	GetPositionPtr
	BSR.B	SampleNoteUp
	MOVEQ	#18,D0
	BSR.W	GetPositionPtr
nup3	BSR.B	SampleNoteUp
	BRA.W	RedrawPattern

SampleNoteUp
	MOVEQ	#63,D6
	MOVE.L	A0,A3
	MOVE.W	InsNum,D3
	TST.B	SampleAllFlag
	BEQ.B	sanulo2
	MOVEQ	#0,D3
sanulo2	MOVE.L	D6,D0
	MOVE.L	A3,A0
sanuloop
	MOVE.B	2(A0),D1
	LSR.B	#4,D1
	MOVE.B	(A0),D2
	AND.B	#$F0,D2
	OR.B	D2,D1
	CMP.B	D3,D1
	BNE.B	sanuskip
	MOVE.W	(A0),D1
	MOVE.W	D1,D2
	AND.W	#$F000,D2
	AND.W	#$0FFF,D1
	BEQ.B	sanuskip
	BSR.W	CheckPeriod
	BNE.B	sanuskip
	ADD.W	NoteShift(PC),D5
	CMP.W	#$0048,D5
	BLO.B	sanuok
	TST.B	TransDelFlag
	BEQ.B	sanuskip
	AND.L	#$00000FFF,(A0)
	BRA.B	sanuskip
sanuok	MOVE.W	(A2,D5.W),D1
	OR.W	D2,D1
	MOVE.W	D1,(A0)
sanuskip
	LEA	16(A0),A0
	DBRA	D0,sanuloop
	TST.B	SampleAllFlag
	BEQ.W	Return2
	ADDQ.W	#1,D3
	CMP.W	#32,D3
	BLO.B	sanulo2
	RTS

OctaveDown
	MOVE.W	#24,NoteShift
	BRA.B	ndown2

NoteDown
	MOVE.W	#2,NoteShift
ndown2	BSR.W	SaveUndo
	CMP.W	#212,D0
	BLS.B	ndown3
	MOVEQ	#0,D0
	BSR.W	GetPositionPtr
	BSR.B	SampleNoteDown
	MOVEQ	#6,D0
	BSR.W	GetPositionPtr
	BSR.B	SampleNoteDown
	MOVEQ	#12,D0
	BSR.W	GetPositionPtr
	BSR.B	SampleNoteDown
	MOVEQ	#18,D0
	BSR.W	GetPositionPtr
ndown3	BSR.B	SampleNoteDown
	BRA.W	RedrawPattern

SampleNoteDown
	MOVEQ	#64-1,D6
	MOVE.L	A0,A3
	MOVE.W	InsNum,D3
	TST.B	SampleAllFlag
	BEQ.B	sandlo2
	MOVEQ	#0,D3
sandlo2	MOVE.W	D6,D0
	MOVE.L	A3,A0
sandloop
	MOVE.B	2(A0),D1
	LSR.B	#4,D1
	MOVE.B	(A0),D2
	AND.B	#$F0,D2
	OR.B	D2,D1
	CMP.B	D1,D3
	BNE.B	sandskip
	MOVE.W	(A0),D1
	MOVE.W	D1,D2
	AND.W	#$F000,D2
	AND.W	#$0FFF,D1
	BEQ.B	sandskip
	BSR.B	CheckPeriod
	BNE.B	sandskip
	SUB.W	NoteShift(PC),D5
	BPL.B	sandok
	TST.B	TransDelFlag
	BEQ.B	sandskip
	AND.L	#$00000FFF,(A0)
	BRA.B	sandskip
sandok	MOVE.W	(A2,D5.W),D1
	OR.W	D2,D1
	MOVE.W	D1,(A0)
sandskip
	LEA	16(A0),A0
	DBRA	D0,sandloop
	TST.B	SampleAllFlag
	BEQ.W	Return2
	ADDQ.W	#1,D3
	CMP.W	#$20,D3
	BLO.B	sandlo2
	RTS

NoteShift	dc.w	0

CheckPeriod
	LEA	PeriodTable,A2
	MOVEQ	#-2,D5
chpeloop
	ADDQ.L	#2,D5
	MOVE.W	(A2,D5.W),D4
	BEQ.B	PeriodNotOk
	CMP.W	D4,D1
	BEQ.B	PeriodOk
	BRA.B	chpeloop

PeriodOk
	MOVEQ	#0,D4
	RTS

PeriodNotOk
	MOVEQ	#-1,D4
	RTS

ToggleTrackPatt
	BSR.W	WaitForButtonUp
	ADDQ.B	#1,TrackPattFlag
	CMP.B	#3,TrackPattFlag
	BLO.B	ShowTrackPatt
	CLR.B	TrackPattFlag
ShowTrackPatt
	LEA	BitplaneData+1838,A1
	LEA	T_BoxData,A2
	TST.B	TrackPattFlag
	BNE.B	ttrpattskip
DoShowTrackpatt
	JMP	rtdoit
ttrpattskip
	LEA	P_BoxData,A2
	CMP.B	#1,TrackPattFlag
	BEQ.B	DoShowTrackpatt
	LEA	S_BoxData,A2
	JMP	rtdoit

KillInstrTrack
	BSR.W	SaveUndo
	MOVE.W	PattCurPos,D0
	BSR.W	GetPositionPtr
	BRA.B	dst2

DeleteOrKill
	CMP.W	#260,D0
	BHS.B	KillSample
	BSR.W	SaveUndo
	TST.B	TrackPattFlag
	BEQ.B	dst2
	MOVEQ	#0,D0
	BSR.W	GetPositionPtr
	BSR.B	dstdoit
	MOVEQ	#6,D0
	BSR.W	GetPositionPtr
	BSR.B	dstdoit
	MOVEQ	#12,D0
	BSR.W	GetPositionPtr
	BSR.B	dstdoit
	MOVEQ	#18,D0
	BSR.W	GetPositionPtr
dst2	BSR.B	dstdoit
	BRA.W	RedrawPattern

dstdoit	CLR.B	RawKeyCode
	MOVEQ	#64-1,D0
	MOVE.W	InsNum,D3
	BEQ.W	NotSampleNull
ksloop	MOVE.B	2(A0),D1
	LSR.B	#4,D1
	MOVE.B	(A0),D2
	AND.B	#$F0,D2
	OR.B	D2,D1
	CMP.B	D1,D3
	BNE.B	ksskip
	CLR.L	(A0)
ksskip	LEA	16(A0),A0
	DBRA	D0,ksloop
	RTS

KillSample
	LEA	KillSampleText,A0
	JSR	AreYouSure
	BNE.W	Return2
Destroy	BSR.W	StorePtrCol
	MOVE.W	InsNum,D0
	BEQ.W	ErrorRestoreCol
	BSR.W	TurnOffVoices
	BSR.W	FreeSample
	MOVE.L	SongDataPtr,A0
	MOVE.W	InsNum,D0
	MULU.W	#30,D0
	LEA	-10(A0),A0
	ADD.L	D0,A0
	MOVE.L	A0,A1
	MOVEQ	#30-1,D0
kisalop	CLR.B	(A0)+
	DBRA	D0,kisalop
	MOVE.W	#1,28(A1)
	BSR.W	ShowSampleInfo
	BSR.W	RedrawSample
	BRA.W	RestorePtrCol

ExchangeOrCopy
	MOVEQ	#-1,D4
	CMP.W	#260,D0
	CMP.W	#260,D0
	BHS.B	CopySampleTrack
ExchSampleTrack
	CMP.B	#2,TrackPattFlag
	BEQ.W	ExchSamples
	MOVEQ	#0,D4
	BRA.B	mstskip
CopySampleTrack
	CMP.B	#2,TrackPattFlag
	BEQ.W	CopySamples
mstskip	TST.B	TrackPattFlag
	BEQ.B	mst2
	MOVEQ	#0,D0
	BSR.W	GetPositionPtr
	BSR.B	mstdoit
	MOVEQ	#6,D0
	BSR.W	GetPositionPtr
	BSR.B	mstdoit
	MOVEQ	#12,D0
	BSR.W	GetPositionPtr
	BSR.B	mstdoit
	MOVEQ	#18,D0
	BSR.W	GetPositionPtr
mst2	BSR.B	mstdoit
	BRA.W	RedrawPattern

mstdoit	MOVEQ	#64-1,D0
esloop	MOVE.B	2(A0),D1
	LSR.B	#4,D1
	MOVE.B	(A0),D2
	AND.B	#$F0,D2
	OR.B	D2,D1
	CMP.B	SampleFrom(PC),D1
	BNE.B	esskip2
	AND.L	#$FFF0FFF,(A0)
	MOVE.B	SampleTo(PC),D2
	MOVE.B	D2,D3
	AND.B	#$F0,D2
	OR.B	D2,(A0)
	LSL.B	#4,D3
	OR.B	D3,2(A0)
	BRA.B	esskip3
esskip2	TST.B	D4
	BNE.B	esskip3
	CMP.B	SampleTo(PC),D1
	BNE.B	esskip3
	AND.L	#$FFF0FFF,(A0)
	MOVE.B	SampleFrom(PC),D2
	MOVE.B	D2,D3
	AND.B	#$F0,D2
	OR.B	D2,(A0)
	LSL.B	#4,D3
	OR.B	D3,2(A0)
esskip3	LEA	16(A0),A0
	DBRA	D0,esloop
	RTS

ExchSamples
	BSR.W	StorePtrCol
	MOVEQ	#0,D0
	MOVE.B	SampleFrom(PC),D0
	BEQ.W	ErrorRestoreCol
	MOVEQ	#0,D1
	MOVE.B	SampleTo(PC),D1
	BEQ.W	ErrorRestoreCol
	MOVE.W	D0,D2
	MOVE.W	D1,D3
	LEA	SampleLengthAdd+2(PC),A2
	ADD.W	D2,D2
	ADD.W	D3,D3
	LEA	(A2,D2.W),A0
	LEA	(A2,D3.W),A1
	MOVE.W	(A0),D4
	MOVE.W	(A1),(A0)
	MOVE.W	D4,(A1)
	LEA	SongDataPtr,A2
	ADD.W	D2,D2
	ADD.W	D3,D3
	LEA	(A2,D2.W),A0
	LEA	(A2,D3.W),A1
	MOVE.L	(A0),D4
	MOVE.L	(A1),(A0)
	MOVE.L	D4,(A1)
	MOVE.L	124(A0),D4
	MOVE.L	124(A1),124(A0)
	MOVE.L	D4,124(A1)
	SUBQ.W	#1,D0
	SUBQ.W	#1,D1
	MULU.W	#30,D0
	MULU.W	#30,D1
	MOVE.L	SongDataPtr,A2
	LEA	sd_sampleinfo(A2),A2
	LEA	(A2,D0.W),A0
	LEA	(A2,D1.W),A1
	MOVEQ	#30-1,D0
exsalop	MOVE.B	(A0),D1
	MOVE.B	(A1),(A0)+
	MOVE.B	D1,(A1)+
	DBRA	D0,exsalop
	BSR.W	ShowSampleInfo
	BSR.W	RedrawSample
	BRA.W	RestorePtrCol

CopySamples
	BSR.W	StorePtrCol
	MOVEQ	#0,D0
	MOVE.B	SampleFrom(PC),D0
	BEQ.W	ErrorRestoreCol
	MOVEQ	#0,D1
	MOVE.B	SampleTo(PC),D1
	BEQ.W	ErrorRestoreCol
	; --PT2.3D bug fix: fix crash when copying sample to itself
	CMP.B   D0,D1
	BEQ.W	ErrorRestoreCol
	; ---------------------------------------------------------
	LEA	SongDataPtr,A2
	LSL.W	#2,D0
	LSL.W	#2,D1
	LEA	(A2,D0.W),A3
	LEA	(A2,D1.W),A4
	MOVE.L	(A3),D0
	BEQ.W	ErrorRestoreCol
	MOVE.L	124(A3),D0
	MOVEQ	#MEMF_CHIP,D1
	JSR	PTAllocMem
	TST.L	D0
	BEQ.W	OutOfMemErr
	MOVE.L	D0,A5
	MOVEQ	#0,D0
	MOVE.B	SampleTo(PC),D0
	MOVE.W	D0,InsNum
	BSR.W	Destroy
	MOVE.L	A5,(A4)
	MOVE.L	124(A3),D0
	MOVE.L	D0,124(A4)
	MOVE.L	(A3),A0
cosalp2	MOVE.B	(A0)+,(A5)+
	SUBQ.L	#1,D0
	BNE.B	cosalp2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	SampleFrom(PC),D0
	MOVE.B	SampleTo(PC),D1
	MOVE.W	D1,InsNum
	MULU.W	#30,D0
	MULU.W	#30,D1
	MOVE.L	SongDataPtr,A2
	LEA	-10(A2),A2
	LEA	(A2,D0.W),A0
	LEA	(A2,D1.W),A1
	MOVEQ	#30-1,D0
cosalop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,cosalop
	BSR.W	ShowSampleInfo
	BSR.W	RedrawSample
	BRA.W	RestorePtrCol

SetSampleFrom
	MOVE.W	InsNum,D2
	CMP.W	#283,D0
	BLS.B	sesfskip
	MOVE.B	SampleFrom(PC),D2
	CMP.W	#294,D0
	BLS.B	sesfup
	SUBQ.B	#1,D2
	BPL.B	sesfskip
	MOVEQ	#0,D2
sesfskip
	MOVE.B	D2,SampleFrom
	BSR.W	Wait_4000
	BRA.B	ShowFrom
sesfup	ADDQ.B	#1,D2
	CMP.B	#$1F,D2
	BLS.B	sesfskip
	MOVE.B	#$1F,SampleFrom
ShowFrom
	MOVE.W	#$CC9,TextOffset
	CLR.W	WordNumber
	MOVE.B	SampleFrom(PC),WordNumber+1
	BRA.W	PrintHexByte

SetSampleTo
	MOVE.W	InsNum,D2
	CMP.W	#283,D0
	BLS.B	sestskip
	MOVE.B	SampleTo(PC),D2
	CMP.W	#294,D0
	BLS.B	sestup
	SUBQ.B	#1,D2
	BPL.B	sestskip
	MOVEQ	#0,D2
sestskip
	MOVE.B	D2,SampleTo
	BSR.W	Wait_4000
	BRA.B	ShowTo
sestup	ADDQ.B	#1,D2
	CMP.B	#$1F,D2
	BLS.B	sestskip
	MOVE.B	#$1F,SampleTo
ShowTo	MOVE.W	#3713,TextOffset
	CLR.W	WordNumber
	MOVE.B	SampleTo(PC),WordNumber+1
	BRA.W	PrintHexByte

SampleFrom	dc.b 0
SampleTo	dc.b 0
	EVEN

ToggleRecordMode
	JSR	WaitForButtonUp
	EOR.B	#1,RecordMode
ShowRecordMode
	MOVE.W	#2382,D1
	LEA	PattText(PC),A0
	TST.B	RecordMode
	BEQ.B	srmskip
	LEA	SongText(PC),A0
srmskip	MOVEQ	#4,D0
	BRA.W	ShowText3
	
AbortDecFlag	dc.w 0
AbortHexFlag	dc.w 0
AbortStrFlag	dc.w 0
PattText	dc.b 'patt'
SongText	dc.b 'song'
RecordMode	dc.b 0
QuantizeValue	dc.b 1
MetroSpeed	dc.b 4
MetroChannel	dc.b 0
MultiFlag	dc.b 0
SampleAllFlag	dc.b 0
TrackPattFlag	dc.b 0
ChordUseOldSmpFlag	dc.b 0
	EVEN

GetDecByte
	MOVE.W	#1,AbortDecFlag
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	BSR.W	UpdateLineCurPos
	BSR.W	GetKey0_9
	CMP.B	#68,D1
	BEQ.B	gdbexit
	MOVE.B	D1,D0
	MULU.W	#10,D0
	MOVE.B	D0,GetDecTemp
	BSR.W	ShowOneDigit
	ADDQ.W	#8,LineCurX
	BSR.W	UpdateLineCurPos
	BSR.W	GetKey0_9
	CMP.B	#68,D1
	BEQ.B	gdbexit
	ADD.B	D1,GetDecTemp
	CLR.W	AbortDecFlag
gdbexit	CLR.W	LineCurX
	MOVE.W	#270,LineCurY
	BSR.W	UpdateLineCurPos
	JSR	RestorePtrCol
	MOVE.B	GetDecTemp,D0
	RTS

SetQuantize
	CLR.B	RawKeyCode
	MOVE.W	#196,LineCurX
	MOVE.W	#75,LineCurY
	MOVE.W	#2824,TextOffset
	BSR.W	GetDecByte
	TST.W	AbortDecFlag
	BNE.B	ShowQuantize
	CMP.B	#63,D0
	BLS.B	tqskip
	MOVE.B	#63,D0
tqskip	MOVE.B	D0,QuantizeValue
ShowQuantize	MOVE.W	#2824,TextOffset
	CLR.W	WordNumber
	MOVE.B	QuantizeValue(PC),WordNumber+1
	BRA.W	Print2DecDigits

SetMetronome
	CLR.B	RawKeyCode
	CMP.W	#188,D0
	BHS.B	smchan
	MOVE.W	#3261,TextOffset
	MOVE.W	#172,LineCurX
	MOVE.W	#86,LineCurY
	BSR.W	GetDecByte
	TST.W	AbortDecFlag
	BNE.B	ShowMetronome
	CMP.B	#64,D0
	BLS.B	smexit
	MOVE.B	#64,D0
smexit	MOVE.B	D0,MetroSpeed
	BRA.B	ShowMetronome

smchan	MOVE.W	#3264,TextOffset
	MOVE.W	#196,LineCurX
	MOVE.W	#86,LineCurY
	BSR.W	GetDecByte
	TST.W	AbortDecFlag
	BNE.B	ShowMetronome
	CMP.W	#4,D0
	BLS.B	smexit2
	MOVEQ	#4,D0
smexit2	MOVE.B	D0,MetroChannel
ShowMetronome	MOVE.W	#3261,TextOffset
	CLR.W	WordNumber
	MOVE.B	MetroSpeed(PC),WordNumber+1
	BSR.W	Print2DecDigits
	MOVE.W	#$CC0,TextOffset
	CLR.W	WordNumber
	MOVE.B	MetroChannel(PC),WordNumber+1
	BRA.W	Print2DecDigits

ToggleMultiMode
	JSR	WaitForButtonUp
	CLR.B	RawKeyCode
	EOR.B	#1,MultiFlag
ShowMultiMode
	BSR.B	Show_MS
	CMP.W	#1,CurrScreen
	BNE.W	Return3
	CMP.B	#2,EdScreen
	BNE.W	Return3
	TST.B	EdEnable
	BEQ.W	Return3
	MOVE.W	#3700,D1
	LEA	SingleText(PC),A0
	TST.B	MultiFlag
	BEQ.B	smmskip
	LEA	MultiText(PC),A0
smmskip	MOVEQ	#6,D0
	BRA.W	ShowText3

SingleText	dc.b	'single'
MultiText	dc.b	' multi'
	EVEN

Show_MS	CMP.W	#4,CurrScreen
	BEQ.W	Return3
	MOVE.B	#' ',D3
	TST.B	MetroFlag
	BEQ.B	smsskp1
	MOVE.B	#'M',D3
smsskp1	MOVE.B	#' ',D0
	TST.B	MultiFlag
	BEQ.B	smsskp2
	MOVE.B	#'M',D0
smsskp2	MOVE.B	#' ',D1
	TST.B	SplitFlag
	BEQ.B	smsskp3
	MOVE.B	#'S',D1
smsskp3	MOVE.B	D3,mstext
	MOVE.B	D0,mstext+2
	MOVE.B	D1,mstext+1
	MOVE.W	EditMoveAdd(PC),D2
	ADD.B	#48,D2
	MOVE.B	D2,mstext+3
	MOVE.W	#4120,D1
	MOVEQ	#4,D0
	LEA	mstext(PC),A0
	BSR.W	ShowText3
	BRA.W	ShowAutoInsert

mstext	dc.b '____'
	EVEN

;---- Edit Op. 3 ----

ToggleHalfClip
	JSR	WaitForButtonUp
	EOR.B	#1,HalfClipFlag
ShowHalfClip
	LEA	BitplaneData+1838,A1
	LEA	H_BoxData,A2
	TST.B	HalfClipFlag
	BEQ.B	DoShowHalfClip
	LEA	C_BoxData,A2
DoShowHalfClip	JMP	rtdoit

SetSamplePos
	MOVE.L	SamplePos(PC),D2
	CMP.W	#237,D0
	BLS.W	Return3
	CMP.W	#283,D0
	BLS.W	EnterSamplePos
	CMP.W	#294,D0
	BLS.B	shpoup
	SUBQ.L	#1,D2
	BTST	#2,$DFF016	; right mouse button
	BNE.B	shposkip
	SUB.L	#15,D2
shposkip
	BPL.B	shposkip2
	MOVEQ	#0,D2
shposkip2
	JSR	GUIDelay
shposkip4
	MOVE.L	D2,SamplePos
	BRA.B	ShowPos
shpoup	ADDQ.L	#1,D2
	BTST	#2,$DFF016	; right mouse button
	BNE.B	shposkip3
	ADD.L	#15,D2
shposkip3
	MOVEQ	#0,D3
	MOVE.W	22(A5),D3
	ADD.L	D3,D3
	CMP.L	D3,D2
	BLS.B	shposkip2
	MOVE.L	D3,SamplePos
ShowPos

	CMP.W	#1,CurrScreen
	BNE.W	Return3
	TST.B	EdEnable
	BEQ.W	Return3
	CMP.B	#3,EdScreen
	BNE.W	Return3
	MOVE.W	#2390,TextOffset
	MOVE.L	SamplePos(PC),LongWordNumber
	BRA.W	Print5HexDigits

EnterSamplePos
	CLR.B	RawKeyCode
	MOVEQ	#0,D7
	BTST	#2,$DFF016	; right mouse button
	BNE.B	espskip
	BRA.B	espskip2
espskip
	MOVE.W	#2390,TextOffset
	BSR.W	GetHexNybble
	TST.W	AbortHexFlag
	BNE.B	espskip3
	LSL.L	#8,D0
	LSL.L	#8,D0
	OR.L	D0,D7
	MOVE.W	#2391,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	espskip3
	LSL.W	#8,D0
	OR.W	D0,D7
	MOVE.W	#2393,TextOffset
	BSR.W	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	espskip3
	OR.B	D0,D7
	EXT.L	D7
espskip2
	MOVE.L	D7,SamplePos
	MOVEQ	#0,D3
	MOVE.W	22(A5),D3
	ADD.L	D3,D3
	CMP.L	D3,D7
	BLS.B	espskip3
	MOVE.L	D3,SamplePos
espskip3
	BRA.W	ShowPos

SetModSpeed
	CMP.W	#243,D0
	BLS.W	DoMod
	CMP.W	#283,D0
	BLS.W	semoRTS
	MOVEQ	#0,D2
	MOVE.B	ModSpeed(PC),D2
	CMP.W	#294,D0
	BLS.B	semoup
	SUBQ.B	#1,D2
	CMP.B	#127,D2
	BNE.B	semoskp
	MOVE.B	#128,D2
	BRA.B	semoskp6
semoskp
	BTST	#2,$DFF016	; right mouse button
	BNE.B	semoskp2
	MOVEQ	#9-1,D0
semodown
	SUBQ.B	#1,D2
	CMP.B	#127,D2
	BEQ.B	semoskp2
	DBRA	D0,semodown
semoskp2
	CMP.B	#127,D2
	BNE.B	semoskp6
	MOVE.B	#128,D2
	BRA.B	semoskp6
semoup
	ADDQ.B	#1,D2
	CMP.B	#128,D2
	BNE.B	semoskp3
	MOVEQ	#127,D2
	BRA.B	semoskp6
semoskp3
	BTST	#2,$DFF016	; right mouse button
	BNE.B	semoskp5
	MOVEQ	#9-1,D0
semoskp4
	ADDQ.B	#1,D2
	CMP.B	#128,D2
	BEQ.B	semoskp5
	DBRA	D0,semoskp4
semoskp5
	CMP.B	#128,D2
	BNE.B	semoskp6
	MOVEQ	#127,D2
semoskp6
	MOVE.B	D2,ModSpeed
	BSR.W	Wait_4000
ShowMod	LEA	PlusMinusText(PC),A0
	MOVEQ	#0,D6
	MOVE.B	ModSpeed(PC),D6
	BPL.B	semoskp7
	NEG.B	D6
	ADDQ	#1,A0
semoskp7	MOVEQ	#1,D0
	MOVE.W	#2831,D1
	BSR.W	ShowText3
	MOVE.W	D6,WordNumber
	BRA.W	Print3DecDigits

semoRTS
	MOVEQ	#0,D2
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	semoskp6
	RTS

PlusMinusText	dc.b ' -'
	EVEN

DoMod	; fixed in PT2.3E to be 128kB compatible
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVEQ	#0,D2
	MOVE.W	SampleInfo,D2
	BEQ.W	bwErrorRestoreCol
	ADD.L	D2,D2
	;SUBQ.L	#1,D2
	MOVE.L	si_pointer,D0
	BEQ.W	bwErrorRestoreCol
	BSR.W	AllocBuffer
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	MOVE.L	A1,A4
	ADD.L	D2,A3
	CLR.L	ModOffset
	CLR.L	ModPos
dmoloop	CMP.L	A3,A2
	BHS.B	dmoskip
	MOVE.B	(A1),(A2)+
	BSR.B	UpdateMod
	BRA.B	dmoloop
dmoskip	MOVE.L	si_pointer,A1
	CLR.W	(A1)
	BSR.W	FreeBuffer
	JSR	RestorePtrCol
	BRA.W	DisplaySample

UpdateMod
	MOVEQ	#0,D0
	MOVE.B	ModSpeed(PC),D0
	BEQ.B	upmplus
	EXT.W	D0
	EXT.L	D0
	MOVE.L	ModPos(PC),D1
	ADD.L	D0,D1
	MOVE.L	D1,ModPos
	ASR.L	#8,D1
	ASR.L	#4,D1
	MOVE.L	D1,D3
	AND.W	#$1F,D1
	LEA	VibratoTable,A0
	MOVEQ	#0,D0
	MOVE.B	(A0,D1.W),D0
	LSR.B	#2,D0
	MOVE.L	ModOffset(PC),D1
	BTST	#5,D3
	BEQ.B	upmskip
	SUB.L	D0,D1
	BRA.B	upmskp2
upmskip	ADD.L	D0,D1
upmskp2	ADD.L	#$800,D1
	MOVE.L	D1,ModOffset
	ASR.L	#8,D1
	ASR.L	#3,D1
	BPL.B	upmskp3
	MOVEQ	#0,D1
upmskp3	CMP.L	D2,D1
	BLO.B	upmskp4
	MOVE.L	D2,D1
upmskp4	MOVE.L	A4,A1
	ADD.L	D1,A1
	RTS
upmplus	ADDQ	#1,A1
	RTS

CutBeg
	CMP.W	#287,D0
	BHI.W	FadeDown
	CMP.W	#269,D0
	BHI.B	FadeUp
	CMP.W	#230,D0
	BHI.W	DrawEditOp4
	
	; fixed in PT2.3E to be 128kB compatible
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVEQ	#0,D3
	MOVE.W	SampleInfo,D3
	BEQ.W	bwErrorRestoreCol
	ADD.L	D3,D3
	SUBQ.L	#1,D3
	MOVE.L	si_pointer,D0
	BEQ.W	bwErrorRestoreCol
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	ADD.L	SamplePos(PC),A2
	ADD.L	D3,A3
cbeloop	CMP.L	A3,A2
	BHS.B	cbeskip
	MOVE.B	(A2),D0
	CLR.B	(A2)+
	MOVE.B	D0,(A1)+
	BRA.B	cbeloop
cbeskip	MOVE.L	si_pointer,A2
	CLR.W	(A2)
	SUB.L	A2,A1
	MOVE.L	A1,D0
	LSR.L	#1,D0
	ADDQ.L	#1,D0
	AND.L	#$FFFF,D0
	MOVE.W	D0,22(A5)
	BSR.W	ShowSampleInfo
	JSR	RestorePtrCol
	BRA.W	DisplaySample

	; 128kB compatible and faster, by 8bitbubsy
FadeUp
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	TST.W	SampleInfo
	BEQ.W	bwErrorRestoreCol
	MOVE.L	SamplePos(PC),D5
	BEQ.W	bwErrorRestoreCol
	MOVE.L	si_pointer,D0
	BEQ.W	bwErrorRestoreCol
	MOVE.L	D0,A0
	; --------------------
	MOVE.L	#32768<<16,D0
	MOVE.L	D5,D1
	JSR	DIVU32
	MOVE.L	D0,D3		; 16.16fp delta
	; --------------------
	MOVEQ	#0,D2
	MOVEQ	#0,D4
	; --------------------
fuloop	MOVE.L	D2,D1
	SWAP	D1
	MOVE.B	(A0),D0
	EXT.W	D0
	MULS.W	D1,D0
	SWAP	D0
	ROL.L	#1,D0
	MOVE.B	D0,(A0)+	
	ADD.L	D3,D2
	ADDQ.L	#1,D4
	CMP.L	D5,D4
	BLO.B	fuloop
	; --------------------
	JSR	RestorePtrCol
	BRA.W	DisplaySample

	; 128kB compatible and faster, by 8bitbubsy
FadeDown
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVEQ	#0,D3
	MOVE.W	SampleInfo,D3
	BEQ.W	bwErrorRestoreCol
	ADD.L	D3,D3
	SUBQ.L	#1,D3 ;Length-1
	MOVE.L	SamplePos(PC),D5
	CMP.L	D3,D5
	BHS.W	bwErrorRestoreCol
	MOVE.L	D3,D4 ; Copy length to D4
	SUB.L	D5,D3 ; Length-pos
	MOVE.L	D3,D5 ; Copy offset to D2
	MOVE.L	si_pointer,D0
	BEQ.W	bwErrorRestoreCol
	MOVE.L	D0,A0
	LEA	(A0,D4.L),A0 ;Start at end of sample
	MOVE.L	D5,D3
	; --------------------
	MOVE.L	#32768<<16,D0
	MOVE.L	D5,D1
	JSR	DIVU32
	MOVE.L	D0,D3		; 16.16fp delta
	; --------------------
	MOVEQ	#0,D2
	MOVEQ	#0,D4
	; --------------------
fdloop	MOVE.L	D2,D1
	SWAP	D1
	MOVE.B	(A0),D0
	EXT.W	D0
	MULS.W	D1,D0
	SWAP	D0
	ROL.L	#1,D0
	MOVE.B	D0,(A0)
	ADD.L	D3,D2
	ADDQ.L	#1,D4
	SUBQ.L	#1,A0
	CMP.L	D5,D4
	BLO.B	fdloop
	; --------------------
	JSR	RestorePtrCol
	BRA.W	DisplaySample

ChangeVolume
	MOVE.W	SampleVol(PC),D2
	CMP.W	#$F3,D0
	BLS.W	DoChangeVol
	CMP.W	#$11B,D0
	BLS.B	shvoskip4
	CMP.W	#$126,D0
	BLS.B	shvoup
	SUBQ.W	#1,D2
	BTST	#2,$DFF016	; right mouse button
	BNE.B	shvoskip
	SUB.W	#9,D2
shvoskip
	BPL.B	shvoskip2
	MOVEQ	#0,D2
shvoskip2
	MOVE.W	D2,SampleVol
	BSR.W	Wait_4000
	BRA.B	ShowVol
shvoup	ADDQ.L	#1,D2
	BTST	#2,$DFF016	; right mouse button
	BNE.B	shvoskip3
	ADD.W	#9,D2
shvoskip3
	CMP.W	#999,D2
	BLS.B	shvoskip2
	MOVE.W	#999,SampleVol
	BSR.W	Wait_4000
ShowVol	MOVE.W	#3711,TextOffset
	MOVE.W	SampleVol(PC),WordNumber
	BSR.W	Print3DecDigits
	LEA	PercentText(PC),A0
	MOVE.W	#1,TextLength
	BRA.W	ShowText2

shvoskip4
	CLR.B	RawKeyCode
	MOVEQ	#100,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	shvoskip5
	BRA.B	shvoskip6
shvoskip5
	MOVEQ	#0,D0
	MOVE.W	#252,LineCurX
	MOVE.W	#97,LineCurY
	MOVE.W	#3711,TextOffset
	BSR.W	GetDec3Dig
	TST.W	AbortDecFlag
	BNE.B	ShowVol
shvoskip6
	MOVE.W	D0,SampleVol
	BRA.B	ShowVol

PercentText	dc.b	'%',0
	EVEN

	; 128kB compatible and much faster, by 8bitbubsy.
dcvrts	RTS
DoChangeVol	
	JSR	WaitForButtonUp

	CMP.W	#100,SampleVol	; volume change needed (vol != 100)?
	BEQ.B	dcvrts		; nope, don't do anything

	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVEQ	#0,D3
	MOVE.W	SampleInfo,D3
	BEQ.W	bwErrorRestoreCol
	ADD.L	D3,D3
	SUBQ.L	#1,D3
	MOVE.L	si_pointer,D0
	BEQ.W	bwErrorRestoreCol
	MOVE.L	D0,A1
	
	; 8bb:
	; Instead of doing a full loop of MUL+ASR, let's precalc
	; a 256 byte long conversion LUT instead. This is
	; dramatically faster.

	; create amp conversion LUT
	MOVEQ	#0,D0
	MOVE.W	SampleVol(PC),D0
	MOVEQ	#11,D6		; max bits for 0..999 range
	LSL.L	D6,D0		; rescale volume range (for DIV -> bitshift)	
        DIVU.W	#100,D0		; vol 0..999/100 --> 0..20459
        LEA	SmpConvLUT,A0
        MOVEQ	#127,D4		; clip values
        MOVEQ	#-128,D5	;
        MOVEQ	#0,D2
dcvll	MOVE.B	D2,D1
	EXT.W	D1
	MULS.W	D0,D1
	SWAP	D1
	ROL.L	#5,D1
	CMP.W	D4,D1
	BGT.B	dcvhi
	CMP.W	D5,D1
	BLT.B	dcvlo
	MOVE.B	D1,(A0)+
dcvnext	ADDQ.B	#1,D2
	BCC.B	dcvll
	BRA.B	dcvdone
dcvhi	MOVE.B	D4,(A0)+
	BRA.B	dcvnext
dcvlo	MOVE.B	D5,(A0)+
	BRA.B	dcvnext
dcvdone

	; do actual volume change
	LEA	SmpConvLUT,A0
	MOVEQ	#0,D0
dcvloop	MOVE.B	(A1),D0
	MOVE.B	(A0,D0.W),(A1)+
	SUBQ.L	#1,D3
	BPL.B	dcvloop

	; done!
	MOVE.L	si_pointer,A1
	CLR.W	(A1)
	JSR	RestorePtrCol
	BRA.W	DisplaySample

Mix
	BTST	#2,$DFF016	; right mouse button
	BEQ.W	OldMix
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVE.W	#1,GetLineFlag
	MOVE.W	#4,MixCurPos
mixlopx	BSR.W	DisplayMix
	BSR.W	GetHexKey
	TST.B	D0
	BNE.B	mixnzro
	CMP.B	#68,MixChar
	BEQ.W	Mix2
	CMP.B	#69,MixChar
	BEQ.W	EndMix
	BTST	#2,$DFF016	; right mouse button
	BEQ.W	EndMix
	LEA	MixText(PC),A0
	LEA	FastHexTable+1,A1
	ADD.W	D1,D1
	MOVE.W	MixCurPos(PC),D0
	MOVE.B	(A1,D1.W),(A0,D0.W)
MixMoveRight
	MOVE.W	MixCurPos(PC),D0
	ADDQ.W	#1,D0
	CMP.W	#6,D0
	BEQ.B	mmrp1
	CMP.W	#9,D0
	BEQ.B	mmrp2
	CMP.W	#15,D0
	BHS.B	mmrp3
mmrok	MOVE.W	D0,MixCurPos
	BRA.B	mixlopx
mmrp1	MOVEQ	#7,D0
	BRA.B	mmrok
mmrp2	MOVEQ	#13,D0
	BRA.B	mmrok
mmrp3	MOVEQ	#14,D0
	BRA.B	mmrok

mixnzro	CMP.B	#1,D0
	BEQ.B	MixMoveRight
MixMoveLeft
	MOVE.W	MixCurPos(PC),D0
	SUBQ.W	#1,D0
	CMP.W	#4,D0
	BLO.B	mmlp1
	CMP.W	#6,D0
	BEQ.B	mmlp2
	CMP.W	#12,D0
	BEQ.B	mmlp3
	BRA.B	mmrok
mmlp1	MOVEQ	#4,D0
	BRA.B	mmrok
mmlp2	MOVEQ	#5,D0
	BRA.B	mmrok
mmlp3	MOVEQ	#8,D0
	BRA.B	mmrok

DisplayMix
	MOVE.W	#53,LineCurY
	MOVE.W	MixCurPos(PC),D0
	LSL.W	#3,D0
	ADD.W	#132,D0
	MOVE.W	D0,LineCurX
	BSR.W	UpdateLineCurPos
	LEA	MixText(PC),A0
	MOVE.W	#1936,D1
	MOVEQ	#22,D0
	BSR.W	ShowText3
	BSR.W	Wait_4000
	BSR.W	Wait_4000
	BRA.W	Wait_4000

	CNOP 0,4
FromPtr1	dc.l 0
FromPtr2	dc.l 0
ToPtr		dc.l 0
MixPtr		dc.l 0
MixLength	dc.l 0
MixCurPos	dc.w 0
ToSam		dc.w 0
MixText		dc.b 'mix 01+02 to 03       ',0
MixChar		dc.b 0
	EVEN

EndMix	CLR.B	RawKeyCode
	BSR.B	RestoreMix
	JMP	RestorePtrCol

RestoreMix
	CLR.W	GetLineFlag
	MOVE.W	#270,LineCurY
	CLR.W	LineCurX
	BSR.W	UpdateLineCurPos
	LEA	EditOpText3(PC),A0
	MOVE.W	#1936,D1
	MOVEQ	#22,D0
	BRA.W	ShowText3

	; 128kB compatible and optimized by 8bitbubsy
Mix2	
	BSR.B	RestoreMix
	BSR.W	TurnOffVoices
	LEA	SongDataPtr,A2
	MOVEQ	#0,D0
	LEA	MixText+4(PC),A0
	BSR.W	HexToInteger2
	TST.W	D0
	BEQ.W	SamOutOfRange
	CMP.W	#$1F,D0
	BHI.W	SamOutOfRange
	LSL.W	#2,D0
	LEA	(A2,D0.W),A3
	MOVE.L	A3,FromPtr1
	
	MOVEQ	#0,D0
	LEA	MixText+7(PC),A0
	BSR.W	HexToInteger2
	TST.W	D0
	BEQ.W	SamOutOfRange
	CMP.W	#$1F,D0
	BHI.W	SamOutOfRange
	LSL.W	#2,D0
	LEA	(A2,D0.W),A3
	MOVE.L	A3,FromPtr2
	
	MOVEQ	#0,D0
	LEA	MixText+13(PC),A0
	BSR.W	HexToInteger2
	MOVE.W	D0,ToSam
	BEQ.W	SamOutOfRange
	CMP.W	#$1F,D0
	BHI.W	SamOutOfRange
	LSL.W	#2,D0
	LEA	(A2,D0.W),A3
	MOVE.L	A3,ToPtr
	
	MOVE.L	FromPtr1(PC),A1
	MOVE.L	FromPtr2(PC),A2
	MOVE.L	124(A1),D1
	MOVE.L	124(A2),D2
	CMP.L	D1,D2
	BLO.B	mixnswp
	EXG	D1,D2
	EXG	A1,A2
mixnswp	MOVE.L	(A1),A1
	MOVE.L	(A2),A2	
	; A1/D1 = longest running (or same as A2/D2)
	
	TST.L	D1
	BEQ.W	SamEmptyError ; Both samples had length=0
	MOVE.L	D1,D0
	AND.L	#$1FFFE,D0
	MOVE.L	D0,MixLength
	MOVE.L	D1,-(SP)
	MOVE.L	#MEMF_CHIP,D1
	JSR	PTAllocMem
	MOVE.L	(SP)+,D1
	MOVE.L	D0,MixPtr
	BEQ.W	SamMemError ; No memory for new sample...
	
	LEA	mixingtext(PC),A0
	BSR.W	ShowStatusText
	
	LEA	(A1,D1.L),A4	; A4 = end of A1
	LEA	(A2,D2.L),A5	; A5 = end of A2
	MOVE.L	MixPtr(PC),A3
	
	TST.B	HalfClipFlag
	BEQ.B	mixhalf

	MOVEQ	#127,D2
	MOVEQ	#-128,D3

	; clipped mixing
mixlop2	MOVE.B	(A1)+,D0
	CMP.L	A5,A2		; at end of smp2?
	BHS.B	.set		; yes, no mixing needed
	EXT.W	D0
	MOVE.B	(A2)+,D1
	EXT.W	D1
	ADD.W	D1,D0
	CMP.W	D2,D0
	BGT.B	.hi
	CMP.W	D3,D0
	BLT.B	.lo
.set	MOVE.B	D0,(A3)+
	CMP.L	A4,A1
	BLO.B	mixlop2
	BRA.B	mixdone
	
.hi	MOVE.L	D2,D0
	BRA.B	.set
.lo	MOVE.L	D3,D0
	BRA.B	.set

	; halved mixing
mixhalf	MOVE.B	(A1)+,D0
	EXT.W	D0
	CMP.L	A5,A2		; at end of smp2?
	BHS.B	.set		; yes, no mixing needed
	MOVE.B	(A2)+,D1
	EXT.W	D1
	ADD.W	D1,D0
.set	ASR.W	#1,D0
	MOVE.B	D0,(A3)+
	CMP.L	A4,A1
	BLO.B	mixhalf
	
mixdone	
	MOVE.W	ToSam(PC),InsNum
	BSR.W	FreeSample
	MOVE.L	ToPtr(PC),A0
	MOVE.L	MixPtr(PC),A1
	CLR.W	(A1)
	MOVE.L	A1,(A0)
	MOVE.L	MixLength(PC),124(A0)
	MOVE.L	SongDataPtr,A0
	MOVE.W	ToSam(PC),D0
	SUBQ.W	#1,D0
	MULU.W	#30,D0
	LEA	sd_sampleinfo(A0,D0.W),A0
	MOVE.L	MixLength(PC),D0
	LSR.L	#1,D0
	MOVE.W	D0,22(A0)
	MOVE.W	#$0040,24(A0)		; finetune:$00   volume:$40
	MOVE.L	#$00000001,26(A0)	; repeat:$0000   replen:$0001
	JSR	RestorePtrCol
	BSR.W	ShowAllRight
	BSR.W	ShowSampleInfo
	BSR.W	DisplaySample
	BRA.W	RedrawSample

SamOutOfRange
	LEA	mixerrtext1(PC),A0
	BSR.W	ShowStatusText
	JMP	ErrorRestoreCol
SamEmptyError
	LEA	mixerrtext2(PC),A0
	BSR.W	ShowStatusText
	JMP	ErrorRestoreCol
SamMemError
	LEA	mixerrtext3(PC),A0
	BSR.W	ShowStatusText
	JMP	ErrorRestoreCol
OutOfMemErr
	LEA	mixerrtext3(PC),A0
	BSR.W	ShowStatusText
	JSR	SetErrorPtrCol
	MOVEQ	#0,D0
	RTS

mixerrtext1	dc.b 'not range 01-1F !',0
mixerrtext2	dc.b 'empty samples !!!',0
mixerrtext3	dc.b 'out of memory !!!',0
mixingtext	dc.b 'mixing samples...',0
	EVEN

	; 128kB compatible and optimized by 8bitbubsy
OldMix
	MOVE.L	SamplePos(PC),D6
	BEQ.W	bwErrorRestoreCol
	MOVEQ	#0,D2
	MOVE.W	SampleInfo,D2 ; 22(A0)
	BEQ.W	bwErrorRestoreCol
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	ADD.L	D2,D2
	CMP.L	D6,D2
	BEQ.W	bwErrorRestoreCol
	MOVE.L	si_pointer,D0
	BEQ.W	bwErrorRestoreCol
	BSR.W	AllocBuffer
	MOVE.L	D0,A2
				; A1 = copy of sample
	LEA	(A2,D2.L),A3	; A3 = end of original sample (A2)
	ADD.L	D6,A2		; A2 = mix pos in original sample
	
	CMP.L	A3,A2
	BHS.B	omixdone

	TST.B	HalfClipFlag
	BEQ.B	omixhalf

	MOVEQ	#127,D2
	MOVEQ	#-128,D3

	; clipped mixing
omixloop
	MOVE.B	(A2),D0
	EXT.W	D0
	MOVE.B	(A1)+,D1
	EXT.W	D1	
	ADD.W	D1,D0
	CMP.W	D2,D0
	BGT.B	.hi
	CMP.W	D3,D0
	BLT.B	.lo
.set	MOVE.B	D0,(A2)+
	CMP.L	A3,A2
	BLO.B	omixloop
	BRA.B	omixdone

.hi	MOVE.L	D2,D0
	BRA.B	.set
.lo	MOVE.L	D3,D0
	BRA.B	.set
		
	; halved mixing
omixhalf
	MOVE.B	(A2),D0
	EXT.W	D0
	MOVE.B	(A1)+,D1
	EXT.W	D1
	ADD.W	D1,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A2)+
	CMP.L	A3,A2
	BLO.B	omixhalf

omixdone
	MOVE.L	si_pointer,A1
	CLR.W	(A1)
	BSR.B	FreeBuffer
	JSR	RestorePtrCol
	JSR	WaitForButtonUp
	BRA.W	DisplaySample

AllocBuffer	; fixed in PT2.3E to be 128kB compatible
	MOVE.L	D0,D7
	MOVE.L	D2,D0
	MOVE.L	D2,BufMemSize
	MOVE.L	#MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,BufMemPtr
	BEQ.W	OutOfMemErr
	MOVE.L	D7,A0
	MOVE.L	D0,A1
	MOVE.L	BufMemSize(PC),D0
	SUBQ.L	#1,D0
albloop	MOVE.B	(A0)+,(A1)+
	SUBQ.L	#1,D0
	BPL.B	albloop

	MOVE.L	BufMemPtr(PC),A1
	MOVE.L	D7,D0
	RTS

FreeBuffer
	MOVE.L	BufMemPtr(PC),D0
	BEQ.W	Return3
	MOVE.L	D0,A1
	MOVE.L	BufMemSize(PC),D0
	JSR	PTFreeMem
	CLR.L	BufMemPtr
	RTS

Echo	; fixed in PT2.3E to be 128kB compatible
	MOVE.L	SamplePos(PC),FlangePos
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVEQ	#0,D2
	MOVE.W	SampleInfo,D2 ; 22(A0)
	BEQ.W	bwErrorRestoreCol
	ADD.L	D2,D2
	MOVE.L	si_pointer,D0
	BEQ.W	bwErrorRestoreCol
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	MOVE.L	D0,A4
	ADD.L	D2,A3
	ADD.L	FlangePos(PC),A2
	CLR.L	ModOffset
	CLR.L	ModPos
flaloop	CMP.L	A3,A2
	BHS.B	flaskip
	MOVE.B	(A2),D0
	EXT.W	D0
	MOVE.B	(A1),D1
	EXT.W	D1
	ADD.W	D1,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A2)+
	BSR.W	UpdateMod
	BRA.B	flaloop
flaskip	MOVE.L	si_pointer,A1
	CLR.W	(A1)
	JSR	RestorePtrCol
	TST.B	HalfClipFlag
	BEQ.W	DisplaySample
	MOVE.W	SampleVol(PC),-(SP)
	MOVE.W	#200,SampleVol
	BSR.W	DoChangeVol
	MOVE.W	(SP)+,SampleVol
	BRA.W	DisplaySample

	; 128kB compatible and optimized by 8bitbubsy
Filter
	TST.W	SampleInfo
	BEQ.W	bwErrorRestoreCol
	CLR.B	RawKeyCode
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	LEA	FilteringText(PC),A0
	BSR.W	ShowStatusText
	MOVEQ	#0,D3
	MOVE.W	SampleInfo,D3
	BEQ.B	.end
	ADD.L	D3,D3
	SUBQ.L	#1,D3
	MOVE.L	si_pointer,D0
	BEQ.B	.end
	MOVE.L	D0,A1
	MOVE.L	MarkStartOfs(PC),D0
	BMI.B	.loop
	MOVE.L	MarkEndOfs(PC),D1
	SUB.L	D0,D1
	BEQ.B	.loop
	MOVE.L	D1,D3
	MOVE.L	SamStart(PC),A1
	ADD.L	D0,A1
	; ------------------------
.loop	MOVE.B	(A1),D0
	EXT.W	D0
	MOVE.B	1(A1),D1
	EXT.W	D1
	ADD.W	D1,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A1)+
	SUBQ.L	#1,D3
	BPL.B	.loop
	; ------------------------
	MOVE.L	si_pointer,A1
	CLR.W	(A1)
.end	BSR.W	ShowAllRight
	JSR	RestorePtrCol
	BRA.W	DisplaySample

	; 128kB compatible, and very lightly optimized
Boost
	MOVE.W	SampleInfo,D3
	BEQ.W	bwErrorRestoreCol
	CLR.B	RawKeyCode
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	LEA	BoostingText(PC),A0
	BSR.W	ShowStatusText
	MOVEQ	#0,D3
	MOVE.W	SampleInfo,D3
	BEQ.B	.end
	ADD.L	D3,D3
	SUBQ.L	#1,D3
	MOVE.L	si_pointer,D0
	BEQ.B	.end
	MOVE.L	D0,A1
	MOVE.L	MarkStartOfs(PC),D0
	BMI.B	.L0
	MOVE.L	MarkEndOfs(PC),D1
	SUB.L	D0,D1
	BEQ.B	.L0
	MOVE.L	D1,D3
	MOVE.L	SamStart(PC),A1
	ADD.L	D0,A1
.L0	; ------------------------
	MOVEQ	#0,D0
	MOVEQ	#127,D4
	MOVEQ	#-128,D5
	; ------------------------
.loop	MOVE.B	(A1),D1
	EXT.W	D1
	MOVE.W	D1,D2
	SUB.W	D0,D1
	MOVE.W	D2,D0
	TST.W	D1
	BMI.B	.neg
	ASR.W	#2,D1
	ADD.W	D1,D2
	BRA	.L1
.neg	NEG.W	D1
	ASR.W	#2,D1
	SUB.W	D1,D2
.L1	CMP.W	D4,D2
	BGT.B	.hi
	CMP.W	D5,D2
	BLT.B	.lo
.set	MOVE.B	D2,(A1)+
	SUBQ.L	#1,D3
	BPL.B	.loop
	; ------------------------
	MOVE.L	si_pointer,A1
	CLR.W	(A1)
.end	BSR.W	ShowAllRight
	JSR	RestorePtrCol
	BRA.W	DisplaySample
	; ------------------------
.hi	MOVE.L	D4,D2
	BRA.B	.set
.lo	MOVE.L	D5,D2
	BRA.B	.set
		
FilteringText	dc.b 'filtering',0
BoostingText	dc.b 'boosting',0
	EVEN

	; fixed in PT2.3E to be 128kB compatible
XFade	
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVEQ	#0,D2
	MOVE.W	SampleInfo,D2 ; 22(A0)
	BEQ.B	xfErrorRestoreCol
	ADD.L	D2,D2
	MOVE.L	si_pointer,D0
	BEQ.B	xfErrorRestoreCol
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	ADD.L	D2,A2
		
	TST.B	HalfClipFlag
	BEQ.B	xfahalf	
	
	MOVEQ	#127,D2
	MOVEQ	#-127,D3

	; clipped mixing
xfaloop	MOVE.B	(A1),D0
	EXT.W	D0
	MOVE.B	-(A2),D1
	EXT.W	D1
	ADD.W	D1,D0
	CMP.W	D2,D0
	BGT.B	.hi
	CMP.W	D3,D0
	BLT.B	.lo
.set	MOVE.B	D0,(A1)+
	MOVE.B	D0,(A2)
	CMP.L	A2,A1
	BLO.B	xfaloop
	BRA.B	xfadone
	
.hi	MOVE.L	D2,D0
	BRA.B	.set
.lo	MOVE.L	D3,D0
	BRA.B	.set
	
	; halved mixing
xfahalf	MOVE.B	(A1),D0
	EXT.W	D0
	MOVE.B	-(A2),D1
	EXT.W	D1
	ADD.W	D1,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A1)+
	MOVE.B	D0,(A2)
	CMP.L	A2,A1
	BLO.B	xfahalf
	
xfadone
	
	MOVE.L	si_pointer,A1
	CLR.W	(A1)
	JSR	RestorePtrCol
	BRA.W	DisplaySample

xfErrorRestoreCol	JMP	ErrorRestoreCol

Backwards
	JSR	WaitForButtonUp
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVEQ	#0,D2
	MOVE.W	22(A5),D2
	BEQ.B	bwErrorRestoreCol
	MOVE.L	si_pointer,D0
	BEQ.B	bwErrorRestoreCol
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	ADD.L	D2,D2
	ADD.L	D2,A2
	MOVE.L	MarkStartOfs(PC),D0
	BMI.B	bacloop
	MOVE.L	MarkEndOfs(PC),D1
	SUB.L	D0,D1
	BEQ.B	bacloop
	MOVE.L	SamStart(PC),A1
	ADD.L	D0,A1
	MOVE.L	A1,A2
	ADD.L	D1,A2
bacloop	MOVE.B	(A1),D0
	MOVE.B	-(A2),(A1)+
	MOVE.B	D0,(A2)
	CMP.L	A2,A1
	BLO.B	bacloop
	MOVE.L	si_pointer,A1
	CLR.W	(A1)
	JSR	RestorePtrCol
	BRA.W	DisplaySample

bwErrorRestoreCol	JMP	ErrorRestoreCol

Upsample
	JSR	WaitForButtonUp
	LEA	UpsampleText(PC),A0
	JSR	AreYouSure
	BNE.W	Return3
	BSR.W	TurnOffVoices
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVE.W	InsNum,D0
	LSL.W	#2,D0
	LEA	SongDataPtr,A0
	LEA	(A0,D0.W),A0
	MOVE.L	124(A0),D3
	CMP.L	#2,D3
	BLS.B	bwErrorRestoreCol
	MOVE.L	(A0),D0
	BEQ.B	bwErrorRestoreCol
	MOVE.L	D0,A2
	MOVE.L	D0,A4
	MOVE.L	D3,D4
	LSR.L	#1,D3
	BCLR	#0,D3	; even'ify
	MOVE.L	D3,D0
	MOVEQ	#MEMF_CHIP,D1
	JSR	PTAllocMem
	TST.L	D0
	BEQ.B	upserro
	MOVE.L	D0,A3
	MOVE.L	D0,D2
	MOVE.L	D3,D5
	SUBQ.L	#1,D3
upsloop	MOVE.B	(A2)+,(A3)+
	ADDQ	#1,A2
	DBRA	D3,upsloop
	MOVE.L	A4,A1
	MOVE.L	D4,D0
	JSR	PTFreeMem
	MOVE.W	InsNum,D0
	LSL.W	#2,D0
	LEA	SongDataPtr,A0
	LEA	(A0,D0.W),A0
	MOVE.L	D2,(A0)
	MOVE.L	D5,124(A0)
	MOVE.L	D2,A0
	CLR.W	(A0)
	MOVE.W	22(A5),D0
	LSR.W	#1,D0
	MOVE.W	D0,22(A5)
	MOVE.W	26(A5),D0
	LSR.W	#1,D0
	MOVE.W	D0,26(A5)
	MOVE.W	28(A5),D0
	LSR.W	#1,D0
	BNE.B	upsskip2
	MOVEQ	#1,D0
upsskip2
	MOVE.W	D0,28(A5)
	BSR.W	ShowSampleInfo
	JSR	WaitForButtonUp
	JSR	RestorePtrCol
	BRA.W	RedrawSample

upserro	JSR	RestorePtrCol
	BRA.W	OutOfMemErr

DownSample	; fixed in PT2.3E to be 128kB compatible
	JSR	WaitForButtonUp
	TST.W	InsNum
	BEQ.W	NotSampleNull
	LEA	DownSampleText(PC),A0
	JSR	AreYouSure
	BNE.W	Return3
	BSR.W	TurnOffVoices
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVE.L	si_pointer,D0
	BEQ.W	dsErrorRestoreCol
	MOVEQ	#0,D0
	MOVE.W	SampleInfo,D0
	BEQ.W	dsErrorRestoreCol
	ADD.L	D0,D0	; real size
	ADD.L	D0,D0	; multiply by two to get new size
	CMP.L	#$1FFFE,D0
	BLS.B	dnsskip
	MOVE.L	#$1FFFE,D0
dnsskip	MOVE.L	D0,BufMemSize
	MOVEQ	#MEMF_CHIP,D1
	JSR	PTAllocMem
	MOVE.L	D0,BufMemPtr
	BEQ.W	SamMemError
	MOVE.L	si_pointer,A1
	MOVE.L	D0,A2
	MOVE.L	BufMemSize(PC),D3
	LSR.L	#1,D3
	SUBQ.L	#1,D3
dnsloop	MOVE.B	(A1)+,D0
	MOVE.B	D0,(A2)+
	MOVE.B	D0,(A2)+
	SUBQ.L	#1,D3
	BPL.B	dnsloop
	BSR.W	FreeSample
	LEA	SongDataPtr,A0
	MOVE.W	InsNum,D0
	LSL.W	#2,D0
	MOVE.L	BufMemPtr(PC),(A0,D0.W)
	MOVE.L	BufMemSize(PC),124(A0,D0.W)
	MOVEQ	#0,D0
	MOVE.W	22(A5),D0
	ADD.L	D0,D0
	CMP.L	#$FFFF,D0
	BLS.B	dnsok1
	MOVE.L	#$FFFF,D0
dnsok1	MOVE.W	D0,22(A5)
	MOVEQ	#0,D0
	MOVE.W	26(A5),D0
	ADD.L	D0,D0
	CMP.L	#$FFFF,D0
	BLS.B	dnsok2
	MOVE.L	#$FFFF,D0
dnsok2	MOVE.W	D0,26(A5)
	MOVEQ	#0,D0
	MOVE.W	28(A5),D0
	CMP.W	#1,D0
	BEQ.B	dnsok3
	ADD.L	D0,D0
	CMP.L	#$FFFF,D0
	BLS.B	dnsok3
	MOVE.L	#$FFFF,D0
dnsok3	MOVE.W	D0,28(A5)
	BSR.W	ShowSampleInfo
	JSR	WaitForButtonUp
	JSR	RestorePtrCol
	BRA.W	RedrawSample

dsErrorRestoreCol	JMP	ErrorRestoreCol

	CNOP 0,4
SamplePos	dc.l	0
FlangePos	dc.l	0
ModPos		dc.l	0
ModOffset	dc.l	0
BufMemPtr	dc.l	0
BufMemSize	dc.l	0
SampleVol	dc.w	100
ModSpeed	dc.b	0
HalfClipFlag	dc.b	0
	EVEN

; -----------------------------------------------------------------------------
;                              SAMPLE CHORD EDITOR
;
; Rewritten by 8bitbubsy to generate better samples (normalized gain), and use
; way less RAM.
; -----------------------------------------------------------------------------

CheckEdGadg4
	CMP.W	#55,D1
	BLS.W	ToggleNewOld
	CMP.W	#204,D0
	BLS.W	ChordMenu2
	CMP.W	#251,D0
	BLS.B	ChordMenu3
	CMP.W	#283,D0
	BLS.B	ChordMenu4
	CMP.W	#294,D0
	BLS.B	ChordMenu5
ChordMenu6
	CMP.W	#66,D1
	BLS.W	ChordNote1Down
	CMP.W	#77,D1
	BLS.W	ChordNote2Down
	CMP.W	#88,D1
	BLS.W	ChordNote3Down
	CMP.W	#99,D1
	BLS.W	ChordNote4Down
	RTS
ChordMenu5
	CMP.W	#66,D1
	BLS.W	ChordNote1Up
	CMP.W	#77,D1
	BLS.W	ChordNote2Up
	CMP.W	#88,D1
	BLS.W	ChordNote3Up
	CMP.W	#99,D1
	BLS.W	ChordNote4Up
	RTS
ChordMenu4
	CMP.W	#66,D1
	BLS.W	ChordNote1Gadget
	CMP.W	#77,D1
	BLS.W	ChordNote2Gadget
	CMP.W	#88,D1
	BLS.W	ChordNote3Gadget
	CMP.W	#99,D1
	BLS.W	ChordNote4Gadget
	RTS
ChordMenu3
	CMP.W	#66,D1
	BLS.W	ChordMajor7
	CMP.W	#77,D1
	BLS.W	ChordMinor7
	CMP.W	#88,D1
	BLS.W	ChordMajor6
	CMP.W	#99,D1
	BLS.W	ChordMinor6
	RTS
ChordMenu2
	CMP.W	#165,D0
	BLS.B	ChordMenu1
	CMP.W	#66,D1
	BLS.W	ChordMajor
	CMP.W	#77,D1
	BLS.W	ChordMinor
	CMP.W	#88,D1
	BLS.W	ChordSus4
	RTS
ChordMenu1
	CMP.W	#66,D1
	BLS.W	ChordMake
	CMP.W	#77,D1
	BLS.W	ChordReset
	CMP.W	#88,D1
	BLS.W	ChordUndo
	RTS

DrawEditOp4
	MOVE.B	#4,EdScreen
	JSR	WaitForButtonUp
	JSR	ClearRightArea
	MOVE.L	#EditOpText4,ShowTextPtr
	LEA	Edit4Data,A0
	MOVE.L	#Edit4Size,D0
	BSR.W	demit
	BRA.W	CalculateChordLen

ToggleNewOld
	JSR	WaitForButtonUp
	EOR.B	#1,ChordUseOldSmpFlag
ShowNewOld
	LEA	BitplaneData+1838,A1
	LEA	N_BoxData,A2
	TST.B	ChordUseOldSmpFlag
	BEQ.B	DoDrawNewOld
	LEA	O_BoxData,A2
DoDrawNewOld	JMP	rtdoit

	;  Input: D0.B (chord note)
	; Output: D0.L (16.16fp delta)
GetDeltaFromChordNote
	CMP.B	#36,D0
	BHS.B	.err
	; -----------------------
	MOVEM.L	D1/D2/A0,-(SP)
	; -----------------------
	MOVE.L	SongDataPtr,A0
	MOVE.W	ChordSrcSmpNum(PC),D2
	MULU.W	#30,D2
	MOVEQ	#0,D1
	MOVE.B	14(A0,D2.W),D1	; finetune
	AND.B	#$0F,D1
	LSL.B	#2,D1
	LEA	ftunePerTab(PC),A0
	MOVE.L	(A0,D1.W),A0	; A0 = finetuned section in period table
	MOVEQ	#0,D1
	AND.W	#$FF,D0
	ADD.W	D0,D0
	MOVEQ	#0,D1
	MOVE.W	(A0,D0.W),D1	; D1.L = dst. period
	; -----------------------
	LEA	PeriodTable,A0
	MOVEQ	#0,D0
	MOVE.W	TuneNote,D0
	ADD.W	D0,D0
	MOVE.W	(A0,D0.W),D0	; D0.L = ref. period
	SWAP	D0
	CLR.W	D0
	JSR	DIVU32
	; -----------------------
	MOVEM.L	(SP)+,D1/D2/A0
	RTS
.err	MOVEQ	#0,D0
	RTS

	;  Input: D0.B (chord note)
	; Output: D0.L (new sample length, in bytes)
GetSmpLenFromChordNote
	MOVEM.L	D1/D2/A0/A1,-(SP)
	; -----------------------
	MOVE.L	SongDataPtr,A0
	MOVE.W	InsNum,D2
	BNE.B	.L0
	MOVE.W	LastInsNum,D2
.L0	MULU.W	#30,D2
	MOVEQ	#0,D1
	MOVE.B	14(A0,D2.W),D1	; finetune
	AND.B	#$0F,D1
	LSL.B	#2,D1
	LEA	ftunePerTab(PC),A1
	MOVE.L	(A1,D1.W),A1
	AND.W	#$FF,D0
	ADD.W	D0,D0
	MOVE.W	(A1,D0.W),D1	; D1.L = dst. period
	; -----------------------	
	MOVEQ	#0,D0
	MOVE.W	12(A0,D2.W),D0	; length
	ADD.L	D0,D0
	JSR	MULU32
	MOVEQ	#0,D1
	MOVE.W	TuneNote,D1
	ADD.W	D1,D1
	LEA	PeriodTable(PC),A1
	MOVE.W	(A1,D1.W),D1	; D1.L = ref. period
	JSR	DIVU32
	BCLR	#0,D0
	CMP.L	#$1FFFE,D0
	BLS.B	.L1
	MOVE.L	#$1FFFE,D0
.L1	; -----------------------
	MOVEM.L	(SP)+,D1/D2/A0/A1
	RTS

CalculateChordLen
	CMP.W	#1,CurrScreen
	BNE.W	Return3
	TST.B	EdEnable
	BEQ.W	Return3
	CMP.B	#4,EdScreen
	BNE.W	Return3
	; -----------------------
	MOVE.W	ChordNote1(PC),D1
	MOVE.W	ChordNote2(PC),D2
	MOVE.W	ChordNote3(PC),D3
	MOVE.W	ChordNote4(PC),D4
	MOVEQ	#36,D6
	CMP.W	D6,D1
	BNE.B	.L0
	CMP.W	D6,D2
	BNE.B	.L0
	CMP.W	D6,D3
	BNE.B	.L0
	CMP.W	D6,D4
	BNE.B	.L0
	CLR.L	ChordLen
	BRA.W	ShowChordLength
.L0	; -----------------------
	; get highest chord note (min length)
	; -----------------------
	MOVEQ	#0,D0
	CMP.W	D6,D1	; note empty?
	BEQ.B	.L6	; yes
	CMP.W	D1,D0
	BHS.B	.L6
	MOVE.W	D1,D0
.L6	CMP.W	D6,D2	; note empty?
	BEQ.B	.L7	; yes
	CMP.W	D2,D0
	BHS.B	.L7
	MOVE.W	D2,D0
.L7	CMP.W	D6,D3	; note empty?
	BEQ.B	.L8	; yes
	CMP.W	D3,D0
	BHS.B	.L8
	MOVE.W	D3,D0
.L8	CMP.W	D6,D4	; note empty?
	BEQ.B	.L9	; yes
	CMP.W	D4,D0	
	BHS.B	.L9
	MOVE.W	D4,D0
.L9	; -----------------------
	BSR.W	GetSmpLenFromChordNote
	MOVE.L	D0,ChordLen
	; -----------------------
	; fall-through

ShowChordLength
	CMP.W	#1,CurrScreen
	BNE.W	Return3
	TST.B	EdEnable
	BEQ.W	Return3
	CMP.B	#4,EdScreen
	BNE.W	Return3
	; -----------------------
	MOVE.W	#3700,TextOffset
	MOVE.L	ChordLen(PC),D7
	MOVE.L	D7,LongWordNumber
	BRA.W	Print5HexDigits
	
DisplayChordNotes
	CMP.W	#1,CurrScreen
	BNE.W	Return3
	TST.B	EdEnable
	BEQ.W	Return3
	CMP.B	#4,EdScreen
	BNE.W	Return3
	MOVE.L	NoteNamesPtr,A4
	; -----------------------
	MOVE.W	#2392,TextOffset
	MOVE.W	ChordNote1(PC),D0
	LSL.W	#2,D0
	LEA	(A4,D0.W),A0
	MOVE.L	A0,ShowTextPtr
	MOVE.W	#3,TextLength
	BSR.W	ShowText
	; -----------------------
	MOVE.W	#2832,TextOffset
	MOVE.W	ChordNote2(PC),D0
	LSL.W	#2,D0
	LEA	(A4,D0.W),A0
	MOVE.L	A0,ShowTextPtr
	MOVE.W	#3,TextLength
	BSR.W	ShowText
	; -----------------------
	MOVE.W	#3272,TextOffset
	MOVE.W	ChordNote3(PC),D0
	LSL.W	#2,D0
	LEA	(A4,D0.W),A0
	MOVE.L	A0,ShowTextPtr
	MOVE.W	#3,TextLength
	BSR.W	ShowText
	; -----------------------
	MOVE.W	#3712,TextOffset
	MOVE.W	ChordNote4(PC),D0
	LSL.W	#2,D0
	LEA	(A4,D0.W),A0
	MOVE.L	A0,ShowTextPtr
	MOVE.W	#3,TextLength
	BRA.W	ShowText
	
ChordNote1Down
	MOVE.W	ChordNote1(PC),D0
	LEA	ChordNote1(PC),A0
	BRA.B	ChordNoteDown
ChordNote2Down
	MOVE.W	ChordNote2(PC),D0
	LEA	ChordNote2(PC),A0
	BRA.B	ChordNoteDown
ChordNote3Down
	MOVE.W	ChordNote3(PC),D0
	LEA	ChordNote3(PC),A0
	BRA.B	ChordNoteDown
ChordNote4Down
	MOVE.W	ChordNote4(PC),D0
	LEA	ChordNote4(PC),A0	
ChordNoteDown
	SUBQ.W	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	.L0
	SUBQ.W	#8,D0
	SUBQ.W	#3,D0
.L0	TST.W	D0
	BPL.B	.L1
	CLR.W	D0
.L1	MOVE.W	D0,(A0)
	CLR.L	SplitAddress	
	BSR.W	Wait_4000
	;BSR.W	Wait_4000	
	BSR.W	CalculateChordLen
	BRA.W	DisplayChordNotes
	
ChordNote1Up
	MOVE.W	ChordNote1(PC),D0
	LEA	ChordNote1(PC),A0
	BRA.B	ChordNoteUp

ChordNote2Up
	MOVE.W	ChordNote2(PC),D0
	LEA	ChordNote2(PC),A0
	BRA.B	ChordNoteUp

ChordNote3Up
	MOVE.W	ChordNote3(PC),D0
	LEA	ChordNote3(PC),A0
	BRA.B	ChordNoteUp

ChordNote4Up
	MOVE.W	ChordNote4(PC),D0
	LEA	ChordNote4(PC),A0
ChordNoteUp
	ADDQ.W	#1,D0
	BTST	#2,$DFF016	; right mouse button
	BNE.B	.L0
	ADDQ.W	#8,D0
	ADDQ.W	#3,D0
.L0	CMP.W	#36,D0
	BLS.B	.L1
	MOVE.W	#36,D0
.L1	MOVE.W	D0,(A0)
	CLR.L	SplitAddress
	BSR.W	Wait_4000
	;BSR.W	Wait_4000
	BSR.W	CalculateChordLen
	BRA.W	DisplayChordNotes
	
ChordNote1Gadget
	BSR.W	SetUndoNotes
	BTST	#2,$DFF016	; right mouse button
	BNE.B	.L0
	MOVE.W	#36,ChordNote1
	BRA.W	DisplayChordNotes
.L0	MOVE.W	#2392,TextOffset
	MOVE.W	#3,TextLength
	MOVE.L	#SpcNoteText,ShowTextPtr
	BSR.W	ShowText
	MOVE.W	#5,SamNoteType
	MOVE.L	#ChordNote1,SplitAddress
	LEA	SelectNoteText,A0
	BSR.W	ShowStatusText
	JMP	WaitForButtonUp

ChordNote2Gadget
	BSR.W	SetUndoNotes
	BTST	#2,$DFF016	; right mouse button
	BNE.B	.L0
	MOVE.W	#36,ChordNote2
	BRA.W	DisplayChordNotes
.L0	MOVE.W	#2832,TextOffset
	MOVE.W	#3,TextLength
	MOVE.L	#SpcNoteText,ShowTextPtr
	BSR.W	ShowText
	MOVE.W	#5,SamNoteType
	MOVE.L	#ChordNote2,SplitAddress
	LEA	SelectNoteText,A0
	BSR.W	ShowStatusText
	JMP	WaitForButtonUp

ChordNote3Gadget
	BSR.W	SetUndoNotes
	BTST	#2,$DFF016	; right mouse button
	BNE.B	.L0
	MOVE.W	#36,ChordNote3
	BRA.W	DisplayChordNotes
.L0	MOVE.W	#3272,TextOffset
	MOVE.W	#3,TextLength
	MOVE.L	#SpcNoteText,ShowTextPtr
	BSR.W	ShowText
	MOVE.W	#5,SamNoteType
	MOVE.L	#ChordNote3,SplitAddress
	LEA	SelectNoteText,A0
	BSR.W	ShowStatusText
	JMP	WaitForButtonUp

ChordNote4Gadget
	BSR.W	SetUndoNotes
	BTST	#2,$DFF016	; right mouse button
	BNE.B	.L0
	MOVE.W	#36,ChordNote4
	BRA.W	DisplayChordNotes
.L0	MOVE.W	#3712,TextOffset
	MOVE.W	#3,TextLength
	MOVE.L	#SpcNoteText,ShowTextPtr
	BSR.W	ShowText
	MOVE.W	#5,SamNoteType
	MOVE.L	#ChordNote4,SplitAddress
	LEA	SelectNoteText,A0
	BSR.W	ShowStatusText
	JMP	WaitForButtonUp

ChordMajor7
	BSR.W	SetUndoNotes
	MOVE.W	ChordNote1(PC),D0
	CMP.W	#36,D0
	BEQ.W	BaseNoteError
	ADDQ.W	#4,D0
	MOVE.W	D0,ChordNote2
	ADDQ.W	#3,D0
	MOVE.W	D0,ChordNote3
	ADDQ.W	#4,D0	; --PT2.3D bug fix: fixed major7 chord (was #3)
	MOVE.W	D0,ChordNote4
	; fall-through

CheckOctaves3
	CMP.W	#35,ChordNote2
	BLS.B	.L0
	SUB.W	#12,ChordNote2
.L0	CMP.W	#35,ChordNote3
	BLS.B	.L1
	SUB.W	#12,ChordNote3
.L1	CMP.W	#35,ChordNote4
	BLS.B	.L2
	SUB.W	#12,ChordNote4
.L2	BSR.W	CalculateChordLen
	BRA.W	DisplayChordNotes
	
ChordMinor7
	BSR.W	SetUndoNotes
	MOVE.W	ChordNote1(PC),D0
	CMP.W	#36,D0
	BEQ.W	BaseNoteError
	ADDQ.W	#3,D0
	MOVE.W	D0,ChordNote2
	ADDQ.W	#4,D0
	MOVE.W	D0,ChordNote3
	ADDQ.W	#3,D0
	MOVE.W	D0,ChordNote4
	BRA.B	CheckOctaves3
	
ChordMajor6
	BSR.W	SetUndoNotes
	MOVE.W	ChordNote1(PC),D0
	CMP.W	#36,D0
	BEQ.W	BaseNoteError
	ADDQ.W	#4,D0
	MOVE.W	D0,ChordNote2
	ADDQ.W	#3,D0
	MOVE.W	D0,ChordNote3
	ADDQ.W	#2,D0
	MOVE.W	D0,ChordNote4
	BRA.W	CheckOctaves3
	
ChordMinor6
	BSR.W	SetUndoNotes
	MOVE.W	ChordNote1(PC),D0
	CMP.W	#36,D0
	BEQ.W	BaseNoteError
	ADDQ.W	#3,D0
	MOVE.W	D0,ChordNote2
	ADDQ.W	#4,D0
	MOVE.W	D0,ChordNote3
	ADDQ.W	#2,D0
	MOVE.W	D0,ChordNote4
	BRA.W	CheckOctaves3
	
ChordMajor
	BSR.W	SetUndoNotes
	MOVE.W	ChordNote1(PC),D0
	CMP.W	#36,D0
	BEQ.W	BaseNoteError
	ADDQ.W	#4,D0
	MOVE.W	D0,ChordNote2
	ADDQ.W	#3,D0
	MOVE.W	D0,ChordNote3
	MOVE.W	#36,ChordNote4
	
CheckOctaves2
	CMP.W	#35,ChordNote2
	BLS.B	.L0
	SUB.W	#12,ChordNote2
.L0	CMP.W	#35,ChordNote3
	BLS.B	.L1
	SUB.W	#12,ChordNote3
.L1	BRA.W	DisplayChordNotes
	
ChordMinor
	BSR.W	SetUndoNotes
	MOVE.W	ChordNote1(PC),D0
	CMP.W	#36,D0
	BEQ.W	BaseNoteError
	ADDQ.W	#3,D0
	MOVE.W	D0,ChordNote2
	ADDQ.W	#4,D0
	MOVE.W	D0,ChordNote3
	MOVE.W	#36,ChordNote4
	BRA.B	CheckOctaves2
	
ChordSus4
	BSR.W	SetUndoNotes
	MOVE.W	ChordNote1(PC),D0
	CMP.W	#36,D0
	BEQ.W	BaseNoteError
	ADDQ.W	#5,D0
	MOVE.W	D0,ChordNote2
	ADDQ.W	#2,D0
	MOVE.W	D0,ChordNote3
	MOVE.W	#36,ChordNote4
	BRA.W	CheckOctaves2
	
ChordReset
	BSR.B	SetUndoNotes
	MOVEQ	#36,D0
	MOVE.W	D0,ChordNote1
	MOVE.W	D0,ChordNote2
	MOVE.W	D0,ChordNote3
	MOVE.W	D0,ChordNote4
	CLR.L	ChordLen
RedrawNotes
	BSR.W	ShowChordLength
	BRA.W	DisplayChordNotes
	
ChordUndo
	MOVE.W	ChordNote1Old(PC),ChordNote1
	MOVE.W	ChordNote2Old(PC),ChordNote2
	MOVE.W	ChordNote3Old(PC),ChordNote3
	MOVE.W	ChordNote4Old(PC),ChordNote4
	MOVE.L	ChordLenOld(PC),ChordLen
	BRA.B	RedrawNotes
	
SetUndoNotes
	MOVE.W	ChordNote1(PC),ChordNote1Old
	MOVE.W	ChordNote2(PC),ChordNote2Old
	MOVE.W	ChordNote3(PC),ChordNote3Old
	MOVE.W	ChordNote4(PC),ChordNote4Old
	MOVE.L	ChordLen(PC),ChordLenOld
	RTS

ChordMake
	LEA	MakeChordText(PC),A0
	JSR	AreYouSure
	BNE.W	Return2
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	; ---------------------
	; sort note list...
	; ---------------------
	MOVEQ	#2-1,D7
	MOVEQ	#36,D5
.loop	MOVE.W	ChordNote1(PC),D1
	MOVE.W	ChordNote2(PC),D2
	MOVE.W	ChordNote3(PC),D3
	MOVE.W	ChordNote4(PC),D4
	CMP.W	D5,D1
	BEQ.W	BaseNoteError
	CMP.W	D5,D2
	BNE.B	.L0
	MOVE.W	D3,D2
	MOVE.W	D4,D3
	MOVE.W	D5,D4
.L0	CMP.W	D5,D3
	BNE.B	.L1
	MOVE.W	D4,D3
	MOVE.W	D5,D4
.L1	CMP.W	D2,D1
	BNE.B	.L2
	MOVE.W	D3,D2
	MOVE.W	D4,D3
	MOVE.W	D5,D4
	BRA.B	.L1
.L2	CMP.W	D3,D1
	BNE.B	.L3
	MOVE.W	D4,D3
	MOVE.W	D5,D4
	BRA.B	.L1
.L3	CMP.W	D4,D1
	BNE.B	.L4
	MOVE.W	D5,D4
	BRA.B	.L1
.L4	CMP.W	D3,D2
	BNE.B	.L5
	MOVE.W	D4,D3
	MOVE.W	D5,D4
	CMP.W	D5,D2
	BEQ.B	.L5
	BRA.B	.L1
.L5	CMP.W	D4,D2
	BNE.B	.L6
	MOVE.W	D5,D4
	CMP.W	D5,D2
	BEQ.B	.L6
	BRA.B	.L1
.L6	CMP.W	D4,D3
	BNE.B	.L7
	MOVE.W	D5,D4
	CMP.W	D5,D3
	BEQ.B	.L7
	BRA.B	.L1
.L7	MOVE.W	D1,ChordNote1
	MOVE.W	D2,ChordNote2
	MOVE.W	D3,ChordNote3
	MOVE.W	D4,ChordNote4
	DBRA	D7,.loop
	; ---------------------
ResetLocalLabels
	; ---------------------
	BSR.W	DisplayChordNotes
	; ---------------------
	CMP.W	#36,ChordNote2
	BEQ.W	OneNoteError
	; ---------------------
	CMP.L	#2,ChordLen
	BLO.W	LenTooSmallError
	; ---------------------
	MOVE.W	InsNum,D0
	BNE.B	.L0
	MOVE.W	LastInsNum,D0
.L0	MOVE.W	D0,ChordSrcSmpNum
	MOVEQ	#0,D1
	MOVE.W	D0,D1
	SUBQ.W	#1,D0
	LSL.W	#2,D0
	MULU.W	#30,D1
	MOVE.L	SongDataPtr(PC),A2
	MOVE.W	12(A2,D1.W),D1
	ADD.L	D1,D1
	MOVE.L	D1,ChordSrcSmpLen
	LEA	SampleStarts(PC),A0
	LEA	SampleLengths(PC),A1
	MOVE.L	(A0,D0.W),ChordSrcSmpPtr
	MOVE.L	(A1,D0.W),ChordSrcSmpAllocLen
	; ---------------------
	; get destination sample number
	; ---------------------
	TST.B	ChordUseOldSmpFlag
	BEQ.B 	.new
	MOVE.W	InsNum,D0
	BNE.B	.L1
	MOVE.W	LastInsNum,D0
	BRA.B	.L1
.new	; find first available sample slot
	LEA	SampleStarts,A2
	MOVEQ	#1,D0
.loop0	TST.L	(A2)+
	BEQ.B	.L1
	ADDQ.B	#1,D0
	CMP.B	#31,D0
	BLS.B	.loop0
	MOVEQ	#0,D0
.L1	MOVE.W	D0,ChordDstSmpNum
	BEQ.W	NoEmptySampleError
	; ---------------------
	; set voice datas
	; ---------------------
	LEA	ChordVoices(PC),A6
	LEA	ChordNote1(PC),A0
	MOVEQ	#4-1,D7
	MOVEQ	#0,D2
.loop1	MOVE.W	(A0)+,D0	; D0.W = current note
	CMP.W	#36,D0		; do we have a note set?
	BHS.B	.nextv		; nope, go to next note
	CLR.L	cv_pos(A6)
	CLR.W	cv_frac(A6)
	BSR.W	GetDeltaFromChordNote
	MOVE.W	D0,cv_deltalo(A6)
	CLR.W	D0
	SWAP	D0		; D0.L = resampling delta integer
	MOVE.L	D0,cv_deltahi(A6)	
	ADDQ.W	#1,D2
	LEA	CV_SIZE(A6),A6
.nextv	DBRA	D7,.loop1
	CMP.W	#2,D2
	BLO.W	OneNoteError
	MOVE.W	D2,ChordNumVoices	
	; ---------------------
	; allocate sample data
	; ---------------------
	MOVE.L	ChordLen(PC),D0
	MOVE.L	#MEMF_CHIP,D1
	JSR	PTAllocMem
	MOVE.L	D0,ChordDstSmpPtr
	BEQ.W	ChordOutOfMemory
	; ---------------------
	; scan mix peak
	; ---------------------
	LEA	PeakScanText(PC),A0
	BSR.W	ShowStatusText
	; ---------------------
	MOVE.L	ChordLen(PC),D7
	LEA	ChordVoices(PC),A4
	MOVE.L	ChordSrcSmpPtr(PC),A0
	MOVE.W	ChordNumVoices(PC),D2
	SUBQ.W	#2,D2
	LSL.W	#2,D2
	LEA	ChordScanPeakFunc(PC),A3
	MOVE.L	(A3,D2.W),A3
	JSR	(A3)
	TST.W	D0			; D0.W = mix peak (0 .. 128*4)
	BNE.B	.L2
	MOVEQ	#1,D0
.L2	MOVE.L	#256*127,D1
	DIVU.W	D0,D1
	MOVE.W	D1,ChordNormalizeMul
	; ---------------------
	; do resampling+mixing...
	; ---------------------
	LEA	MakingChordText(PC),A0
	BSR.W	ShowStatusText
	; ---------------------
	LEA	ChordVoices(PC),A4
	CLR.L	cv_pos+(CV_SIZE*0)(A4)
	CLR.W	cv_frac+(CV_SIZE*0)(A4)
	CLR.L	cv_pos+(CV_SIZE*1)(A4)
	CLR.W	cv_frac+(CV_SIZE*1)(A4)
	CLR.L	cv_pos+(CV_SIZE*2)(A4)
	CLR.W	cv_frac+(CV_SIZE*2)(A4)
	CLR.L	cv_pos+(CV_SIZE*3)(A4)
	CLR.W	cv_frac+(CV_SIZE*3)(A4)
	MOVE.L	ChordSrcSmpPtr(PC),A0
	MOVE.L	ChordDstSmpPtr(PC),A1
	MOVE.L	ChordLen(PC),D7
	MOVE.W	ChordNormalizeMul(PC),D0
	MOVE.L	ChordSrcSmpLen(PC),A2	; length of original sample
	SUBQ	#1,A2
	MOVE.W	ChordNumVoices(PC),D2
	SUBQ.W	#2,D2
	LSL.W	#2,D2
	LEA	ChordMixFunc(PC),A3
	MOVE.L	(A3,D2.W),A3
	JSR	(A3)
	; ---------------------
	BSR.W	TurnOffVoices
	; ---------------------
	; free memory (if needed)
	; ---------------------
	TST.B	ChordUseOldSmpFlag
	BEQ.B	.L3
	MOVE.L	ChordSrcSmpPtr(PC),A1
	MOVE.L	ChordSrcSmpAllocLen(PC),D0
	JSR	PTFreeMem
.L3	; ---------------------
	; set last sample text char to '!'
	; ---------------------
	MOVE.W	ChordDstSmpNum(PC),D0
	MOVE.W	D0,InsNum		; set current sample
	MOVE.W	D0,D1			; copy for code below
	MULU.W	#30,D1
	MOVE.L	SongDataPtr(PC),A2
	LEA	-10(A2,D1.W),A1
	MOVE.B	#'!',21(A1)
	; ---------------------
	; update sample attributes
	; ---------------------
	LEA	SampleStarts(PC),A0
	LEA	SampleLengths(PC),A1
	SUBQ.W	#1,D0
	LSL.W	#2,D0
	MOVE.L	ChordDstSmpPtr(PC),(A0,D0.W)
	MOVE.L	ChordLen(PC),D2
	MOVE.L	D2,(A1,D0.W)
	LEA	12(A2,D1.W),A0
	LSR.L	#1,D2
	MOVE.W	D2,(A0)			; length
	MOVE.L	#$00000001,4(A0)	; repeat:$0000   replen:$0001
	TST.B	ChordUseOldSmpFlag	; if we used a new smp, edit more stuff
	BNE.B	.L4
	MOVE.W	#$0040,2(A0)		; finetune:$00   volume:$40
	LEA	-10(A2,D1.W),A0		; copy over sample text
	MOVE.W	ChordSrcSmpNum(PC),D0
	MULU.W	#30,D0
	LEA	-10(A2,D0.W),A1
	MOVEQ	#21-1,D0
.loop2	MOVE.B	(A1)+,(A0)+
	DBRA	D0,.loop2	
.L4	; ---------------------
	JSR	RestorePtrCol
	JSR	ClearSamStarts
	BSR.W	ShowAllRight
	BSR.W	ShowSampleInfo
	BSR.W	RedrawSample
	BRA.W	DisplaySample
	
CVMIX1_M	MACRO
	MOVE.L	cv_pos(A6),D2
	MOVE.W	cv_frac(A6),D3
	MOVE.B	(A0,D2.L),D6
	EXT.W	D6
	MOVE.B	1(A0,D2.L),D4
	EXT.W	D4
	SUB.W	D6,D4
	MOVE.W	D3,D5
	LSR.W	#1,D5
	MULS.W	D5,D4
	SWAP	D4
	ROL.L	#1,D4
	ADD.W	D4,D6
	MOVE.W	D6,D1
	MOVE.L	cv_deltahi(A6),D6
	ADD.W	cv_deltalo(A6),D3
	ADDX.L	D6,D2
	MOVE.L	D2,cv_pos(A6)
	MOVE.W	D3,cv_frac(A6)
	ENDM
	
CVMIX2_M	MACRO
	MOVE.L	cv_pos(A6),D2
	MOVE.W	cv_frac(A6),D3
	MOVE.B	(A0,D2.L),D6
	EXT.W	D6
	MOVE.B	1(A0,D2.L),D4
	EXT.W	D4
	SUB.W	D6,D4
	MOVE.W	D3,D5
	LSR.W	#1,D5
	MULS.W	D5,D4
	SWAP	D4
	ROL.L	#1,D4
	ADD.W	D4,D6
	ADD.W	D6,D1
	MOVE.L	cv_deltahi(A6),D6
	ADD.W	cv_deltalo(A6),D3
	ADDX.L	D6,D2
	MOVE.L	D2,cv_pos(A6)
	MOVE.W	D3,cv_frac(A6)
	ENDM	


ChordMix2Voices
	MOVE.L	A4,A6
	CVMIX1_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	; ---------------------
	MULS.W	D0,D1
	ASR.L	#8,D1
	MOVE.B	D1,(A1)+
	; ---------------------
	SUBQ.L	#1,D7
	BNE.B	ChordMix2Voices
	RTS

ChordMix3Voices
	MOVE.L	A4,A6
	CVMIX1_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	; ---------------------
	MULS.W	D0,D1
	ASR.L	#8,D1
	MOVE.B	D1,(A1)+
	; ---------------------
	SUBQ.L	#1,D7
	BNE.W	ChordMix3Voices
	RTS

ChordMix4Voices
	MOVE.L	A4,A6
	CVMIX1_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	; ---------------------
	MULS.W	D0,D1
	ASR.L	#8,D1
	MOVE.B	D1,(A1)+
	; ---------------------
	SUBQ.L	#1,D7
	BNE.W	ChordMix4Voices
	RTS
	
ChordScanPeak2Voices
	MOVEQ	#0,D0		; peak
	; ---------------------
.loop	MOVE.L	A4,A6
	CVMIX1_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	; ---------------------
	TST.W	D1
	BPL.B	.L0
	NEG.W	D1
.L0	CMP.W	D1,D0
	BLO.B	.setNewPeak
	; ---------------------
.next	SUBQ.L	#1,D7
	BNE.B	.loop
	RTS

.setNewPeak
	MOVE.W	D1,D0
	BRA.B	.next

ChordScanPeak3Voices
	MOVEQ	#0,D0		; peak
	; ---------------------
.loop	MOVE.L	A4,A6
	CVMIX1_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	; ---------------------
	TST.W	D1
	BPL.B	.L0
	NEG.W	D1
.L0	CMP.W	D1,D0
	BLO.B	.setNewPeak
	; ---------------------
.next	SUBQ.L	#1,D7
	BNE.W	.loop
	RTS

.setNewPeak
	MOVE.W	D1,D0
	BRA.B	.next

ChordScanPeak4Voices
	MOVEQ	#0,D0		; peak
	; ---------------------
.loop	MOVE.L	A4,A6
	CVMIX1_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	LEA	CV_SIZE(A6),A6
	CVMIX2_M
	; ---------------------
	TST.W	D1
	BPL.B	.L0
	NEG.W	D1
.L0	CMP.W	D1,D0
	BLO.B	.setNewPeak
	; ---------------------
.next	SUBQ.L	#1,D7
	BNE.W	.loop
	RTS

.setNewPeak
	MOVE.W	D1,D0
	BRA.B	.next
	
BaseNoteError
	LEA	NoBaseNoteText(PC),A0
	BSR.W	ShowStatusText
	JMP	SetErrorPtrCol

NoEmptySampleError
	LEA	NoEmptySampleText(PC),A0
	BSR.W	ShowStatusText
	JMP	ErrorRestoreCol
	
OneNoteError
	LEA	OnlyOneNoteText(PC),A0
	BSR.W	ShowStatusText
	JMP	ErrorRestoreCol
	
LenTooSmallError
	LEA	LenTooSmallText(PC),A0
	BSR.W	ShowStatusText
	JMP	ErrorRestoreCol

ChordOutOfMemory
	LEA	mixerrtext3(PC),A0
	BSR.W	ShowStatusText
	JMP	ErrorRestoreCol
	
cv_deltahi		EQU  0 ; L
cv_pos			EQU  4 ; L
cv_deltalo		EQU  8 ; W
cv_frac			EQU 10 ; W
CV_SIZE			EQU 12 ; must be a multiple of 4!

	CNOP 0,4
ChordMixFunc
	dc.l ChordMix2Voices, ChordMix3Voices, ChordMix4Voices

ChordScanPeakFunc
	dc.l ChordScanPeak2Voices, ChordScanPeak3Voices, ChordScanPeak4Voices

ChordVoices		dcb.b CV_SIZE*4,0
ChordSrcSmpPtr		dc.l 0
ChordSrcSmpLen		dc.l 0
ChordSrcSmpAllocLen	dc.l 0
ChordDstSmpPtr		dc.l 0
ChordLen		dc.l 0
ChordLenOld		dc.l 0
ChordNormalizeMul	dc.w 0
ChordNote1		dc.w 36 ; do not change the order of these!
ChordNote2		dc.w 36 ; --
ChordNote3		dc.w 36 ; --
ChordNote4		dc.w 36 ; --
ChordNote1Old		dc.w 36
ChordNote2Old		dc.w 36
ChordNote3Old		dc.w 36
ChordNote4Old		dc.w 36
ChordSrcSmpNum		dc.w 0
ChordDstSmpNum		dc.w 0
ChordNumVoices		dc.w 0
MakeChordText		dc.b 'Make chord?',0
PeakScanText		dc.b 'Scanning peak...',0
MakingChordText		dc.b 'Making chord...',0
NoBaseNoteText		dc.b 'No base note!',0
NoEmptySampleText	dc.b 'No empty sample!',0
OnlyOneNoteText		dc.b 'Only one note!',0
LenTooSmallText		dc.b 'Length too small!',0
	EVEN

;---- Save Song ----

SaveSong
	BSR.W	StopIt
	CLR.B	RawKeyCode
	MOVE.L	SongDataPtr(PC),A0
	LEA	SampleLengthAdd(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#2,D1
sadloop	MOVE.W	(A1,D1.W),D2
	ADD.W	D2,42(A0,D0.W)
	ADD.W	#$1E,D0
	ADDQ.W	#2,D1
	CMP.W	#$3E,D1
	BNE.B	sadloop
	
	LEA	sd_pattpos(A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	CLR.W	HighPattNum
ssloop	MOVE.B	(A0,D0.W),D1
	ADDQ.W	#1,D0
	CMP.W	#128,D0
	BHI.B	DoSaveSong
	MOVE.W	HighPattNum(PC),D2
	CMP.W	D2,D1
	BLS.B	ssloop
	MOVE.W	D1,HighPattNum
	BRA.B	ssloop

DoSaveSong
	LEA	SongsPath2,A0
	JSR	CopyPath
	MOVE.L	SongDataPtr(PC),A0
	MOVEQ	#20-1,D0
dssoloop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,dssoloop
	MOVE.L	#FileName,FileNamePtr
	MOVE.L	SongDataPtr(PC),A0
	MOVE.L	A0,DiskDataPtr
	MOVE.L	#1084,DiskDataLength
	MOVEQ	#0,D0
	MOVE.W	HighPattNum(PC),D0
	ADDQ.L	#1,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	ADD.L	D0,DiskDataLength
	MOVE.B	#$7F,951(A0)
	MOVE.L	#'M.K.',sd_magicid(A0)
	CMP.W	#$40,HighPattNum
	BLO.B	lbC00E82C
	MOVE.L	#'M!K!',sd_magicid(A0)
lbC00E82C	MOVE.B	PackMode,D0
	BTST	#0,D0
	BEQ.B	lbC00E852
	LEA	CrunchingText(PC),A0
	BSR.W	ShowStatusText
	BSR.B	Cruncher
	CMP.W	#$40,HighPattNum
	BLO.B	lbC00E852
	MOVE.L	#$50414B4B,(A0)
lbC00E852	BSR.W	DoSaveData
	MOVE.B	PackMode,D0
	BTST	#0,D0
	BEQ.B	lbC00E86E
	LEA	DecrunchingText(PC),A0
	BSR.W	ShowStatusText
	BSR.W	Decruncher
lbC00E86E	MOVE.L	SongDataPtr(PC),A0
	LEA	SampleLengthAdd(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#2,D1
lbC00E87A	MOVE.W	(A1,D1.W),D2
	SUB.W	D2,42(A0,D0.W)
	ADD.W	#$1E,D0
	ADDQ.W	#2,D1
	CMP.W	#$3E,D1
	BNE.B	lbC00E87A
	BSR.W	ShowAllRight
	JSR	SetNormalPtrCol
	JMP	DoAutoDir

Cruncher
	JSR	SetNormalPtrCol
	MOVE.L	SongDataPtr(PC),A0
	MOVE.L	A0,A1
	LEA	12(A1),A1
	MOVE.L	A1,SongPlus12Ptr
	MOVE.L	A0,A1
	ADD.L	SongAllocSize(PC),A1
	MOVE.L	A1,SongPlus70kPtr
	MOVE.L	A0,A1
	ADD.L	SongAllocSize(PC),A1
	SUB.L	DiskDataLength(PC),A1
	MOVE.L	A1,EndOfSongPtr
	MOVE.L	DiskDataLength(PC),RealSongLength
	MOVE.L	SongDataPtr(PC),A0
	ADD.L	DiskDataLength(PC),A0
	MOVE.L	SongDataPtr(PC),A1
	ADD.L	SongAllocSize(PC),A1
	MOVE.L	DiskDataLength(PC),D0
cloop	MOVE.B	-(A0),-(A1)
	SUBQ.L	#1,D0
	BNE.B	cloop
	BSR.B	DoCrunch
	SUB.L	SongPlus12Ptr(PC),A2
	MOVE.L	A2,D0
	MOVE.L	D0,CrunchedSongLength
	MOVE.L	D0,D1
	ADD.L	SongPlus12Ptr(PC),D1
	MOVE.L	SongDataPtr(PC),A0
	MOVE.L	#'PACK',(A0)
	MOVE.L	CrunchedSongLength(PC),4(A0)
	MOVE.L	RealSongLength(PC),8(A0)
	MOVE.L	SongDataPtr(PC),DiskDataPtr
	MOVE.L	CrunchedSongLength(PC),D0
	ADD.L	#12,D0
	MOVE.L	D0,DiskDataLength
	RTS

	CNOP 0,4
EndOfSongPtr		dc.l 0
SongPlus70kPtr		dc.l 0
RealSongLength		dc.l 0
SongPlus12Ptr		dc.l 0
CrunchedSongLength	dc.l 0

DoCrunch
	MOVE.L	EndOfSongPtr(PC),A0
	MOVE.L	SongPlus70kPtr(PC),A1
	MOVE.L	SongPlus12Ptr(PC),A2
	MOVEQ	#1,D2
	CLR.W	D1
dcloop	BSR.B	DoCrunch2
	TST.B	D0
	BEQ.B	dcskip
	ADDQ.W	#1,D1
	CMP.W	#$0108,D1
	BNE.B	dcskip
	BSR.W	DoCrunch6
dcskip	CMP.L	A0,A1
	BGT.B	dcloop
	BSR.W	DoCrunch6
	BRA.W	DoCrunch8

DoCrunch2
	MOVE.L	A0,A3
	LEA	127(A3),A3
	CMP.L	A1,A3
	BLE.B	dc2skip
	MOVE.L	A1,A3
dc2skip	MOVEQ	#1,D5
	MOVE.L	A0,A5
	ADDQ	#1,A5
dc2_1	MOVE.B	(A0),D3
	MOVE.B	1(A0),D4
	MOVE.W	D3,$DFF1A2
dc2loop	CMP.B	(A5)+,D3
	BNE.B	dc2skip2
	CMP.B	(A5),D4
	BEQ.B	DoCrunch3
dc2skip2	CMP.L	A5,A3
	BGT.B	dc2loop
	BRA.B	dc4_3

DoCrunch3
	SUBQ.L	#1,A5
	MOVE.L	A0,A4
dc3loop	MOVE.B	(A4)+,D3
	CMP.B	(A5)+,D3
	BNE.B	dc3skip
	CMP.L	A5,A3
	BGT.B	dc3loop
dc3skip	MOVE.L	A4,D3
	SUB.L	A0,D3
	SUBQ.L	#1,D3
	CMP.L	D3,D5
	BGE.B	dc4_2
	MOVE.L	A5,D4
	SUB.L	A0,D4
	SUB.L	D3,D4
	SUBQ.L	#1,D4
	CMP.L	#4,D3
	BLE.B	DoCrunch4
	MOVEQ	#6,D6
	CMP.L	#$00000101,D3
	BLT.B	dc3skip2
	MOVE.W	#$0100,D3
dc3skip2
	BRA.B	dc4_1

DoCrunch4	MOVE.W	D3,D6
	SUBQ.W	#2,D6
	ADD.W	D6,D6
dc4_1	LEA	CrunchData3(PC),A6
	CMP.W	(A6,D6.W),D4
	BGE.B	dc4_2
	MOVE.L	D3,D5
	MOVE.L	D4,CrunchData1
	MOVE.B	D6,CrunchData2
dc4_2	CMP.L	A5,A3
	BGT.B	dc2_1
dc4_3	CMP.L	#1,D5
	BEQ.B	DoCrunch5
	BSR.B	DoCrunch6
	MOVE.B	CrunchData2(PC),D6
	MOVE.L	CrunchData1(PC),D3
	MOVE.W	8(A6,D6.W),D0
	BSR.W	DoCrunch7
	MOVE.W	$10(A6,D6.W),D0
	BEQ.B	dc4skip
	MOVE.L	D5,D3
	SUBQ.W	#1,D3
	BSR.W	DoCrunch7
dc4skip	MOVE.W	$18(A6,D6.W),D0
	MOVE.W	$20(A6,D6.W),D3
	BSR.B	DoCrunch7
	ADDQ.W	#1,$28(A6,D6.W)
	ADD.L	D5,A0
	CLR.B	D0
	RTS

DoCrunch5
	MOVE.B	(A0)+,D3
	MOVEQ	#8,D0
	BSR.B	DoCrunch7
	MOVEQ	#1,D0
	RTS

	CNOP 0,4
CrunchData1	dc.l 0
CrunchData2	dc.b 0,0
CrunchData3	dc.w $0100,$0200,$0400,$1000,8,9,10,8
		dc.w 0,0,0,8,2,3,3,3,1,4,5,6,0,0,0,0
CrunchData4	dc.w 0
CrunchData5	dc.w 0

DoCrunch6
	TST.W	D1
	BEQ.W	Return3
	MOVE.W	D1,D3
	CLR.W	D1
	CMP.W	#9,D3
	BGE.B	dc6_2
	ADDQ.W	#1,CrunchData4
	SUBQ.W	#1,D3
	MOVEQ	#5,D0
	BRA.B	DoCrunch7

dc6_2	ADDQ.W	#1,CrunchData5
	SUB.W	#9,D3
	OR.W	#$700,D3
	MOVEQ	#12-1,D0
DoCrunch7
	SUBQ.W	#1,D0
dc7loop	LSR.L	#1,D3
	ROXL.L	#1,D2
	BCS.B	dc8_2
	DBRA	D0,dc7loop
	RTS

DoCrunch8
	CLR.W	D0
dc8_2	MOVE.L	D2,(A2)+
	MOVEQ	#1,D2
	DBRA	D0,dc7loop
	RTS


Decruncher
	MOVE.L	SongDataPtr(PC),A0
	LEA	12(A0),A0
	MOVE.L	EndOfSongPtr(PC),A1
	MOVE.L	CrunchedSongLength(PC),D0
	MOVE.L	RealSongLength(PC),D1
	BSR.B	DoDecrunch
	MOVE.L	EndOfSongPtr(PC),A0
	MOVE.L	SongDataPtr(PC),A1
	MOVE.L	RealSongLength(PC),D0
ddcloop	MOVE.B	(A0)+,(A1)+
	SUBQ.L	#1,D0
	BNE.B	ddcloop
	MOVE.L	SongDataPtr(PC),A0
	ADD.L	SongAllocSize(PC),A0
	MOVE.L	SongDataPtr(PC),A1
	ADD.L	RealSongLength(PC),A1
	SUB.L	A1,A0
	MOVE.L	A0,D0
ddcloop2
	CLR.B	(A1)+
	SUBQ.L	#1,D0
	BNE.B	ddcloop2
	RTS

DoDecrunch
	ADD.L	D0,A0
	MOVE.L	D1,A2
	ADD.L	A1,A2
	MOVE.L	-(A0),D0
dec_1	LSR.L	#1,D0
	BNE.B	decskip
	BSR.B	dec5
decskip	BLO.B	dec3
	MOVEQ	#8,D1
	MOVEQ	#1,D3
	LSR.L	#1,D0
	BNE.B	decskip2
	BSR.B	dec5
decskip2
	BCS.B	dec4_1
	MOVEQ	#3,D1
	CLR.W	D4
dec_2	BSR.B	dec6
	MOVE.W	D2,D3
	ADD.W	D4,D3
decloop1
	MOVEQ	#8-1,D1
decloop2
	LSR.L	#1,D0
	BNE.B	decskip3
	BSR.B	dec5
decskip3
	ROXL.L	#1,D2
	DBRA	D1,decloop2
	MOVE.B	D2,-(A2)
	DBRA	D3,decloop1
	BRA.B	dec4_3

dec2	MOVEQ	#8,D1
	MOVEQ	#8,D4
	BRA.B	dec_2

dec3	MOVEQ	#2,D1
	BSR.B	dec6
	CMP.B	#2,D2
	BLT.B	dec4
	CMP.B	#3,D2
	BEQ.B	dec2
	MOVEQ	#8,D1
	BSR.B	dec6
	MOVE.W	D2,D3
	MOVE.W	#8,D1
	BRA.B	dec4_1

dec4	MOVE.W	#9,D1
	ADD.W	D2,D1
	ADDQ.W	#2,D2
	MOVE.W	D2,D3
dec4_1	BSR.B	dec6
dec4_2	SUBQ	#1,A2
	MOVE.B	(A2,D2.W),(A2)
	DBRA	D3,dec4_2
dec4_3	CMP.L	A2,A1
	BLT.B	dec_1
	RTS

dec5	MOVE.L	-(A0),D0
	MOVE.W	D0,$DFF1A2
	MOVE.W	#$10,CCR
	ROXR.L	#1,D0
	RTS

dec6	SUBQ.W	#1,D1
	CLR.W	D2
dec6loop
	LSR.L	#1,D0
	BNE.B	dec6skip
	MOVE.L	-(A0),D0
	MOVE.W	D0,$DFF1A2
	MOVE.W	#$10,CCR
	ROXR.L	#1,D0
dec6skip
	ROXL.L	#1,D2
	DBRA	D1,dec6loop
	RTS
	
OutOfMemoryFlag	dc.w	0
NoteDataClippedText	dc.b 'NoteData Clipped!',0
	EVEN

LoadModule
	CLR.W	OutOfMemoryFlag
	CLR.W	TempPPFileFlag
LoadModule2
	MOVE.W	#1,LoadInProgress
	BSR.W	DoClearSong
	BSR.W	ClrSampleInfo
	JSR	SetDiskPtrCol
	JSR	StorePtrCol
	BSR.W	CheckForPosEdNames
	JSR	RestorePtrCol
	LEA	ModulesPath2,A0
	JSR	CopyPath
	LEA	DirInputName,A0
	MOVEQ	#DirNameLength-1,D0
lmloop2	MOVE.B	(A0)+,(A1)+
	DBRA	D0,lmloop2
	LEA	LoadingModuleText(PC),A0
	BSR.W	ShowStatusText
LoadModule3
	MOVE.L	DOSBase(PC),A6
	MOVE.L	#FileName,D1
	MOVE.L	#1005,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.W	CantOpenFile
	MOVE.L	D0,D1
	MOVE.L	SongDataPtr(PC),D2
	MOVE.L	#1084,D3
	JSR	_LVORead(A6)
	MOVE.L	SongDataPtr(PC),A0
	CMP.L	#'PP20',(A0)
	BEQ.W	UnpackPPFile
	CMP.L	#'PX20',(A0)
	BEQ.W	UnpackPPFile
	; --PT2.3D fix: clamp song length to 128
	CMP.B	#128,sd_numofpatt(A0)
	BLS.B	songLenOK
	MOVE.B	#128,sd_numofpatt(A0)
songLenOK
	MOVE.B	#127,sd_numofpatt+1(A0) ; Set repeatstart to 127
	CMP.L	#'M!K!',sd_magicid(A0)
	BNE.W	lm64Patts
	
	; 100 patterns MOD (M!K!)
	TST.W	OutOfMemoryFlag
	BNE.W	lbC00ED4A
	TST.B	OneHundredPattFlag
	BNE.W	lbC00ED4A
lbC00EC9A
	MOVE.L	SongDataPtr(PC),D1
	BEQ.B	lbC00ECB4
	MOVE.L	D1,A1
	MOVE.L	SongAllocSize(PC),D0
	JSR	PTFreeMem
lbC00ECB4
	EOR.B	#1,OneHundredPattFlag
	MOVE.L	#SONG_SIZE_64PAT,SongAllocSize
	MOVE.L	#64-1,MaxPattern
	TST.B	OneHundredPattFlag
	BEQ.B	lbC00ECEC
	MOVE.L	#SONG_SIZE_100PAT,SongAllocSize
	MOVE.L	#100-1,MaxPattern
lbC00ECEC
	MOVE.L	SongAllocSize(PC),D0
	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,SongDataPtr
	BNE.B	lbC00ED1A
	BSR.W	OutOfMemErr
	MOVE.W	#1,OutOfMemoryFlag
	BRA.B	lbC00EC9A
lbC00ED1A
	MOVE.L	FileHandle(PC),D1
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOClose(A6)
	BRA.W	LoadModule2
	
	; 64 patterns MOD (M.K.)
lm64Patts
	CMP.L	#'M.K.',sd_magicid(A0)
	BEQ.B	lbC00ED4A
	BSR.W	NotMKFormat
	BNE.B	lbC00ED4A
	MOVE.L	FileHandle(PC),D1
	MOVE.L	#600,D2
	MOVEQ	#-1,D3
	JSR	_LVOSeek(A6)
lbC00ED4A
	LEA	LoadingModuleText(PC),A0
	BSR.W	ShowStatusText
	MOVEQ	#0,D4	
	MOVE.L	SongDataPtr(PC),A0
	LEA	sd_pattpos(A0),A0
	MOVEQ	#0,D0
	MOVE.B	-1(A0),D0

	MOVEQ	#0,D3
lbC00ED68
	CMP.B	(A0)+,D3
	BHI.B	lbC00ED70
	MOVE.B	-1(A0),D3
lbC00ED70
	DBRA	D0,lbC00ED68
	ADDQ.W	#1,D3
	CMP.W	#64,D3
	BLE.B	lbC00EDC8
	TST.B	OneHundredPattFlag
	BNE.B	lbC00EDC8
	MOVE.W	D3,D4
	SUB.W	#64,D4
	MULU.W	#1024,D4
	MOVE.L	SongDataPtr(PC),A0
	LEA	sd_pattpos(A0),A0
	MOVEQ	#0,D0
	MOVE.B	-1(A0),D0
	MOVEQ	#63,D3
lbC00ED9E
	CMP.B	(A0)+,D3
	BHI.B	lbC00EDA6
	MOVE.B	D3,-1(A0)
lbC00EDA6
	DBRA	D0,lbC00ED9E
	LEA	NoteDataClippedText(PC),A0
	BSR.W	ShowStatusText
	JSR	WaitALittle
	LEA	LoadingModuleText(PC),A0
	BSR.W	ShowStatusText
	MOVEQ	#64,D3
lbC00EDC8
	MULU.W	#1024,D3
	MOVE.L	FileHandle(PC),D1
	MOVE.L	SongDataPtr(PC),D2
	ADD.L	#1084,D2
	MOVE.L	DOSBase(PC),A6
	JSR	_LVORead(A6)
	MOVE.L	SongDataPtr(PC),A0
	MOVE.L	#'M.K.',sd_magicid(A0)
	TST.L	D4
	BEQ.B	lbC00EE2C
	MOVE.L	D4,D0
	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,D2
	BEQ.B	lbC00EE2C
	MOVE.L	D0,D7
	MOVE.L	D4,D3
	MOVE.L	FileHandle(PC),D1
	MOVE.L	DOSBase(PC),A6
	JSR	_LVORead(A6)
	MOVE.L	D7,D1
	BEQ.B	lbC00EE2C
	MOVE.L	D1,A1
	MOVE.L	D4,D0
	JSR	PTFreeMem
lbC00EE2C
	CLR.L	PatternNumber
	CLR.L	CurrPos
	BSR.W	RedrawPattern
	CLR.W	ScrPattPos
	BSR.W	SetScrPatternPos
	MOVE.W	#1,InsNum
	BSET	#1,$BFE001	; --PT2.3D fix: disable LED filter on module load
	BSR.W	CheckAbort
	BEQ.W	rmiend
	TST.B	AutoExitFlag
	BEQ.B	readinstrloop
	JSR	ExitFromDir
readinstrloop
	;JSR	ShowSongName
	TST.B	NosamplesFlag
	BNE.W	rmiend
	BSR.W	CheckAbort
	BEQ.W	rmiend
	BSR.W	ShowSampleInfo
	MOVE.W	InsNum(PC),TuneUp
	JSR	DoShowFreeMem
	BSR.W	TurnOffVoices
	MOVE.L	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D7
	MULU.W	#30,D7
	MOVEQ	#0,D0
	MOVE.W	12(A0,D7.W),D0	; sample length
	BEQ.B	rminext
	MOVE.W	18(A0,D7.W),D5	; sample loop length
	ADD.L	D0,D0
	MOVE.L	#MEMF_CHIP!MEMF_CLEAR,D1
	MOVE.L	D0,-(SP)
	JSR	PTAllocMem
	MOVE.L	(SP)+,D6
	TST.L	D0
	BNE.B	ReadModInstrument
	BSR.W	OutOfMemErr
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileHandle(PC),D1
	MOVE.L	D6,D2
	MOVEQ	#0,D3
	BRA.B	rminext
	
ReadModInstrument
	MOVE.W	InsNum(PC),D7
	LSL.W	#2,D7
	LEA	SongDataPtr(PC),A0
	MOVE.L	D0,(A0,D7.W)
	MOVE.L	D6,124(A0,D7.W)
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileHandle(PC),D1
	MOVE.L	D0,D2		; 'read to' address
	MOVE.L	D6,D3		; read length
	JSR	_LVORead(A6)
	
	; PT2.3D change: clear first 2 bytes of non-looping samples (prevent beep)
	CMP.W	#1,D5		; loop length
	BHI.B	rmiok		; loop deactivated, let's not modify!
	MOVE.L	D2,A0		; sample data address
	CLR.W	(A0)		; clear first two bytes...
rmiok
	; --END OF FIX------------------------------------------------------------
	
	BSR.W	RedrawSample
rminext	ADDQ.W	#1,InsNum
	CMP.W	#32,InsNum
	BNE.W	readinstrloop
rmiend	MOVE.L	FileHandle(PC),D1
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOClose(A6)
	TST.W	TempPPFileFlag		; was our loaded MOD a temp PowerPacker file ?
	BEQ.B	rmiskip			; no, skip
	MOVE.L	DOSBase(PC),A6
	MOVE.L	#FileName,D1
	MOVE.L	D1,A0
	JSR	_LVODeleteFile(A6)	; delete temp PowerPacker file 
rmiskip
	MOVE.W	#1,InsNum
	MOVE.L	#6,CurrSpeed
	CLR.W	LoadInProgress
	BSR.W	ShowAllRight
	JSR	SetNormalPtrCol
	BSR.W	CheckInstrLengths
	BSR.W	ShowSampleInfo
	BSR.W	RedrawSample
	CLR.W	TempPPFileFlag
	JMP	DoShowFreeMem
	
;---- PowerPacker routines -----

PowerPacked
	LEA	PowerPackedText(PC),A0
	BSR.W	ShowStatusText
	JSR	SetErrorPtrCol
	BSR.W	DoClearSong
	BSR.W	ClrSampleInfo
	BRA.W	rmiskip

UnpackPPFile
	MOVE.W	#1,TempPPFileFlag
	LEA	PowerPackedText(PC),A0
	BSR.W	ShowStatusText
	BSR.W	DoClearSong
	BSR.W	ClrSampleInfo
	JSR	DoShowFreeMem
	MOVE.L	FileHandle(PC),D1
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOClose(A6)
	MOVE.L	PPLibBase(PC),D0
	BNE.B	uppfskip
	LEA	PPLibName(PC),A1
	MOVE.L	4.W,A6
	MOVEQ	#0,D0
	JSR	_LVOOpenLibrary(A6)
	MOVE.L	D0,PPLibBase
	BNE.B	uppfskip
	LEA	PPLibErrorText(PC),A0
	BRA.W	uppferror
uppfskip
	MOVE.L	D0,A0
	CMP.W	#35,20(A0)
	BGE.B	uppfskip2
	LEA	MustHavePP35Text(PC),A0
	BRA.W	uppferror
uppfskip2
	LEA	FileName,A0
	MOVEQ	#2,D0
	MOVE.L	#MEMF_CLEAR!MEMF_CHIP,D1
	MOVEA.W	#-1,A3
	LEA	ppBufferPtr(PC),A1
	LEA	ppBufferLen(PC),A2
	MOVE.L	PPLibBase(PC),A6
	JSR	_LVOppLoadData(A6)
	TST.L	D0
	BEQ.B	uppfskip8
	CMP.L	#-1,D0
	BNE.B	uppfskip3
	LEA	CantOpenFileText(PC),A0
	BRA.B	uppferror
uppfskip3
	CMP.L	#-2,D0
	BNE.B	uppfskip4
	LEA	ReadErrorText(PC),A0
	BRA.B	uppferror
uppfskip4
	CMP.L	#-3,D0
	BNE.B	uppfskip5
	LEA	OutOfMemoryText(PC),A0
	BRA.B	uppferror
uppfskip5
	CMP.L	#-4,D0
	BNE.B	uppfskip6
	LEA	FileEncryptedText(PC),A0
	BRA.B	uppferror
uppfskip6
	CMP.L	#-6,D0
	BNE.B	uppfskip7
	LEA	WrongCruncherText(PC),A0
	BRA.B	uppferror
uppfskip7
	LEA	DecrunchErrorText(PC),A0
	BRA.B	uppferror
uppfskip8
	MOVE.L	DOSBase(PC),A6
	MOVE.L	#TempMODFileName,D1
	MOVE.L	#1006,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BNE.B	uppfok
	LEA	DecrunchErrorText(PC),A0
uppferror
	BSR.W	ShowStatusText
	JSR	SetErrorPtrCol
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	JSR	WaitALittle
	TST.B	AutoExitFlag
	BEQ.B	uppfskip9
	JSR	ExitFromDir
uppfskip9
	BRA.W	rmiskip
	
uppfok
	MOVE.L	FileHandle(PC),D1
	MOVE.L	ppBufferPtr(PC),D2
	MOVE.L	ppBufferLen(PC),D3
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOWrite(A6)
	CMP.L	ppBufferLen(PC),D3
	BEQ.B	uppfskip10
	LEA	DiskErrorText(PC),A0
	BSR.W	ShowStatusText
	;JSR	PTScreenToFront (8bitbubsy: this causes issues on exit!)
	JSR	SetErrorPtrCol
uppfskip10
	MOVE.L	FileHandle(PC),D1
	JSR	_LVOClose(A6)
	MOVE.L	ppBufferPtr(PC),A1
	MOVE.L	ppBufferLen(PC),D0
	MOVE.L	4.W,A6
	JSR	_LVOFreeMem(A6)
	LEA	TempMODFileName(PC),A0
	LEA	FileName,A1
	MOVEQ	#20-1,D0
uppfloop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,uppfloop
	BRA.W	LoadModule3

LoadCrunchedSample
	BSR.W	FreeSample
	LEA	PowerPackedText(PC),A0
	BSR.W	ShowStatusText
	MOVE.L	PPLibBase(PC),D0
	BNE.B	lbC00F168
	LEA	PPLibName(PC),A1
	MOVE.L	4.W,A6
	MOVEQ	#0,D0
	JSR	_LVOOpenLibrary(A6)
	MOVE.L	D0,PPLibBase
	BNE.B	lbC00F168
	LEA	PPLibErrorText(PC),A0
	BRA.W	lbC00F246
lbC00F168
	MOVE.L	D0,A0
	CMP.W	#35,20(A0)
	BGE.B	lbC00F17C
	LEA	MustHavePP35Text(PC),A0
	BRA.W	lbC00F246
lbC00F17C
	LEA	FileName,A0
	MOVEQ	#2,D0
	MOVE.L	#MEMF_CLEAR!MEMF_CHIP,D1
	MOVEA.W	#-1,A3
	LEA	ppBufferPtr(PC),A1
	LEA	ppBufferLen(PC),A2
	MOVE.L	PPLibBase(PC),A6
	JSR	_LVOppLoadData(A6)
	TST.L	D0
	BEQ.B	lbC00F204
	CMP.L	#-1,D0
	BNE.B	lbC00F1BC
	LEA	CantOpenFileText(PC),A0
	BRA.W	lbC00F246
lbC00F1BC
	CMP.L	#-2,D0
	BNE.B	lbC00F1CC
	LEA	ReadErrorText(PC),A0
	BRA.B	lbC00F246
lbC00F1CC
	CMP.L	#-3,D0
	BNE.B	lbC00F1DC
	LEA	OutOfMemoryText(PC),A0
	BRA.B	lbC00F246
lbC00F1DC
	CMP.L	#-4,D0
	BNE.B	lbC00F1EC
	LEA	FileEncryptedText(PC),A0
	BRA.B	lbC00F246
lbC00F1EC
	CMP.L	#-6,D0
	BNE.B	lbC00F1FC
	LEA	WrongCruncherText(PC),A0
	BRA.B	lbC00F246
lbC00F1FC   
	LEA	DecrunchErrorText(PC),A0
	BRA.B	lbC00F246
lbC00F204
	LEA	SongDataPtr(PC),A4
	MOVEQ	#0,D1
	MOVE.W	InsNum(PC),D1
	LSL.W	#2,D1
	ADD.L	D1,A4
	MOVE.L	ppBufferPtr(PC),D2
	MOVE.L	ppBufferLen(PC),D3
	MOVE.L	D2,(A4)
	MOVE.L	D3,124(A4)
	MOVE.L	D2,DiskDataPtr
	MOVE.L	D3,DiskDataLength
	BSR.W	SampleAllocOK
	MOVE.L	DiskDataPtr(PC),A0
	MOVE.L	DiskDataLength(PC),A1
	BRA.W	LoadSampleOK
lbC00F246
	BSR.W	ShowStatusText
	JSR	SetErrorPtrCol
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	JSR	WaitALittle
	RTS

; ---

CheckForPosEdNames
	TST.B	LoadNamesFlag
	BEQ.B	ClearPosEdNames
	LEA	LoadingNamesText(PC),A0
	BSR.W	ShowStatusText
	JSR	WaitALittle
	LEA	ModulesPath2,A0
	JSR	CopyPath
	LEA	DirInputName,A0
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	#$21,-1(A1)
	MOVEQ	#26-1,D0
cfpenloop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,cfpenloop
	MOVE.L	DOSBase(PC),A6
	MOVE.L	#FileName,D1
	MOVE.L	#1005,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.B	lbC00F2EC
	MOVE.L	D0,D1
	MOVE.L	#PosEdNames,D2
	MOVE.L	#16*100,D3
	JSR	_LVORead(A6)
	MOVE.L	FileHandle(PC),D1
	JSR	_LVOClose(A6)
	RTS

ClearPosEdNames
	LEA	PosEdNames(PC),A0
	MOVE.L	#(16*100)-1,D0
cpednloop	MOVE.B	#' ',(A0)+
	DBRA	D0,cpednloop
	RTS

lbC00F2EC
	BSR.B	ClearPosEdNames
	BRA.W	CantOpenFile
lbC00F2F2
	TST.B	SaveNamesFlag
	BEQ.W	Return2
	CMP.W	#1,makeExeModFlag
	BEQ.W	Return2
	LEA	SavingNamesText(PC),A0
	BSR.W	ShowStatusText
	JSR	WaitALittle
	LEA	ModulesPath2,A0
	JSR	CopyPath
	MOVE.B	#'m',(A1)+
	MOVE.B	#'o',(A1)+
	MOVE.B	#'d',(A1)+
	MOVE.B	#'!',(A1)+
	MOVE.L	SongDataPtr(PC),A0
	MOVEQ	#20-1,D0
lbC00F338
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,lbC00F338
	TST.B	ModPackMode
	BEQ.B	lbC00F362
	LEA	FileName,A0
lbC00F34C
	TST.B	(A0)+
	BNE.B	lbC00F34C
	MOVE.B	#'.',-1(A0)
	MOVE.B	#'p',(A0)+
	MOVE.B	#'p',(A0)+
	MOVE.B	#$00,(A0)
lbC00F362
	MOVE.L	DOSBase(PC),A6
	MOVE.L	#FileName,D1
	MOVE.L	#1006,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.W	CantOpenFile
	MOVE.L	D0,D1
	MOVE.L	#PosEdNames,D2
	MOVE.L	#16*100,D3
	JSR	_LVOWrite(A6)
	MOVE.L	FileHandle(PC),D1
	JSR	_LVOClose(A6)
	RTS

	CNOP 0,4
ppBufferPtr		dc.l 0
ppBufferLen		dc.l 0
TempPPFileFlag		dc.w 0
PowerPackedText		dc.b 'Powerpacked File!',0
PPLibErrorText		dc.b 'Cant open PP.lib!',0
MustHavePP35Text	dc.b 'Needs version 35+',0
OutOfMemoryText		dc.b 'Not Enough Memory',0
ReadErrorText		dc.b 'Read Error!      ',0
FileEncryptedText	dc.b 'File is encrypted',0
WrongCruncherText	dc.b 'Wrong Cruncher!  ',0
DecrunchErrorText	dc.b 'Decrunch Error!  ',0
PPLibName		dc.b 'libs:powerpacker.library',0
TempMODFileName		dc.b 'RAM:Mod.TempFile',0
IconPathText		dc.b 'Icons/Mod.'
IconExtText		dc.b '.info',0
LoadingNamesText	dc.b 'Loading names',0
SavingNamesText		dc.b 'Saving names',0
	EVEN

SaveModule
	JSR	StorePtrCol
	JSR	SetDiskPtrCol
	BSR.W	lbC00F2F2
	JSR	SetDiskPtrCol
	TST.W	lbW015B92
	BEQ.W	smoskip3
	CMP.W	#1,makeExeModFlag
	BEQ.W	smoskip3
	MOVE.L	#263,DiskDataLength
	MOVE.L	#exeDotInfoData,DiskDataPtr
	LEA	PTPath,A0
	JSR	CopyPath
	LEA	IconPathText(PC),A0
	MOVEQ	#10-1,D0
smoloop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,smoloop
	MOVE.L	SongDataPtr(PC),A0
	MOVEQ	#20-1,D0
smoloop2
	MOVE.B	(A0)+,D1
	BEQ.B	smoskip
	MOVE.B	D1,(A1)+
	DBRA	D0,smoloop2
smoskip
	TST.B	ModPackMode
	BEQ.B	smoskip2
	MOVE.B	#'.',(A1)+
	MOVE.B	#'p',(A1)+
	MOVE.B	#'p',(A1)+
smoskip2
	LEA	IconExtText(PC),A0
	MOVEQ	#6-1,D0
smoloop3
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,smoloop3
	LEA	SavingIconText(PC),A0
	BSR.W	ShowStatusText
	BSR.W	OpenModForWrite
	BNE.W	CantOpenFile
	BSR.W	WriteModuleData
	BNE.W	WriteModError
	BSR.W	CloseWriteMod
smoskip3
	MOVE.L	SongDataPtr(PC),A0
	LEA	sd_pattpos(A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	CLR.W	HighPattNum
smoloop4
	MOVE.B	(A0,D0.W),D1
	ADDQ.W	#1,D0
	CMP.W	#128,D0
	BHI.B	DoSaveModule
	MOVE.W	HighPattNum(PC),D2
	CMP.W	D2,D1
	BLS.B	smoloop4
	MOVE.W	D1,HighPattNum
	BRA.B	smoloop4

DoSaveModule
	LEA	ModulesPath2,A0
	JSR	CopyPath
	CMP.W	#1,makeExeModFlag
	BEQ.B	dsmskip1
	MOVE.B	#'m',(A1)+
	MOVE.B	#'o',(A1)+
	MOVE.B	#'d',(A1)+
	MOVE.B	#'.',(A1)+
dsmskip1	
	MOVE.L	SongDataPtr(PC),A0
	MOVEQ	#20-1,D0
dsmloop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,dsmloop
	MOVE.L	SongDataPtr(PC),A0
	MOVE.L	A0,DiskDataPtr
	MOVE.L	#1084,DiskDataLength
	MOVEQ	#0,D0
	MOVE.W	HighPattNum(PC),D0
	ADDQ.L	#1,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	ADD.L	D0,DiskDataLength	; Add 1024 x NumOfPatt
	MOVE.B	#127,sd_numofpatt+1(A0) ; Set maxpatt to 127
	MOVE.L	#'M.K.',sd_magicid(A0)	; M.K. again...
	CMP.W	#64,HighPattNum
	BLO.B	dsmskip2
	MOVE.L	#'M!K!',sd_magicid(A0) ; over 64 patterns...
dsmskip2
	CMP.W	#1,makeExeModFlag
	BEQ.W	WriteExeModule
	TST.B	ModPackMode
	BEQ.W	WriteModule
	
	; Module Crunch (PAK)
	LEA	FileName,A0
dsmgetend
	TST.B	(A0)+
	BNE.B	dsmgetend
	MOVE.B	#'.',-1(A0)
	MOVE.B	#'p',(A0)+
	MOVE.B	#'p',(A0)+
	MOVE.B	#$00,(A0)
ShowModCrunchBox
	JSR	ClearFileNames
	LEA	CrunchBoxData,A1
	LEA	FormatBoxPos,A0
	JSR	DoSwapBox
	BSR.W	ShowCrunchModeTexts
	LEA	AreYouSureText(PC),A0
	BSR.W	ShowStatusText
dsmloop3
	JSR	CheckPatternRedraw2
	JSR	DoKeyBuffer
	MOVE.B	RawKeyCode(PC),D0
	CMP.B	#69,D0	; ESC
	BEQ.B	AbortModCrunchBox
	BTST	#6,$BFE001	; left mouse button
	BNE.B	dsmloop3
	MOVE.W	MouseX(PC),D0
	MOVE.W	MouseY(PC),D1
	CMP.W	#89,D0
	BLO.B	dsmloop3
	CMP.W	#212,D0
	BHI.B	dsmloop3
	CMP.W	#72,D1
	BLO.B	ModCrunchSettings
	CMP.W	#82,D1
	BHI.B	dsmloop3
	CMP.W	#136,D0
	BLO.W	DoModCrunch
	CMP.W	#166,D0
	BLO.B	dsmloop3
AbortModCrunchBox
	LEA	CrunchBoxData,A1
	LEA	FormatBoxPos,A0
	JSR	DoSwapBox
	JSR	ClearFileNames
	LEA	CrunchAbortedText,A0
	BSR.W	ShowStatusText
	JMP	SetErrorPtrCol

ModCrunchSettings
	CMP.W	#54,D1
	BLO.B	dsmloop3
	CMP.W	#136,D0
	BLO.B	ToggleModCrunchSpeed
	CMP.W	#166,D0
	BLO.W	dsmloop3
	ADDQ.L	#1,CrunchBufferMode
	CMP.L	#3,CrunchBufferMode
	BNE.B	mcsskip
	CLR.L	CrunchBufferMode
mcsskip
	BSR.B	ShowCrunchModeTexts
	BRA.W	dsmloop3

ToggleModCrunchSpeed
	ADDQ.L	#1,CrunchSpeed
	CMP.L	#5,CrunchSpeed
	BNE.B	tmcsskip
	CLR.L	CrunchSpeed
tmcsskip
	BSR.B	ShowCrunchModeTexts
	BRA.W	dsmloop3

ShowCrunchModeTexts
	MOVE.L	CrunchSpeed(PC),D0
	LSL.L	#3,D0
	LEA	CrunchSpeedText(PC),A0
	ADD.L	D0,A0
	MOVEQ	#8,D0
	MOVE.W	#$A33,D1
	BSR.W	ShowText3
	MOVE.L	CrunchBufferMode(PC),D0
	MULU.W	#6,D0
	LEA	CrunchBufferSizeText(PC),A0
	ADD.L	D0,A0
	MOVEQ	#6,D0
	MOVE.W	#2621,D1
	BSR.W	ShowText3
	JSR	WaitForButtonUp
	RTS

CrunchSpeedText	dc.b	'  FAST  MEDIOCRE  GOOD  VERYGOOD  BEST  '
CrunchBufferSizeText	dc.b	'LARGE MEDIUMSMALL '
	EVEN

DoModCrunch
	LEA	CrunchBoxData,A1
	LEA	FormatBoxPos,A0
	JSR	DoSwapBox
	JSR	ClearFileNames
	CLR.L	CrunchInfoPtr
	MOVE.L	TuneMemory,D0
	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,CrunchBufferPtr
	BNE.B	casmskip
	BSR.W	OutOfMemErr
	BRA.W	ModCrunchCleanup
casmskip
	MOVE.L	SongDataPtr(PC),A0
	MOVE.L	CrunchBufferPtr,A1
	MOVE.L	DiskDataLength(PC),D0
	SUBQ.L	#1,D0
casmloop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,casmloop
	MOVEQ	#1,D6
	MOVE.L	D6,D0
casmloop2
	LSL.W	#2,D0
	LEA	SongDataPtr(PC),A0
	MOVE.L	(A0,D0.W),D1
	BEQ.B	casmskip2
	MOVE.L	124(A0,D0.W),D0
	BEQ.B	casmskip2
	MOVE.L	SongDataPtr(PC),A0
	LEA	12(A0),A0
	MOVE.W	D6,D0
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	ADD.L	D0,D0
	MOVE.L	D1,A0
	SUBQ.L	#1,D0
casmloop3
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,casmloop3
casmskip2
	ADDQ.L	#1,D6
	MOVE.L	D6,D0
	CMP.L	#32,D0
	BNE.B	casmloop2
	MOVE.L	PPLibBase(PC),D0
	BNE.B	casmskip3
	LEA	PPLibName(PC),A1
	MOVE.L	4.W,A6
	MOVEQ	#0,D0
	JSR	_LVOOpenLibrary(A6)
	MOVE.L	D0,PPLibBase
	BNE.B	casmskip3
	LEA	PPLibErrorText(PC),A0
	BRA.W	ModCrunchError
casmskip3
	MOVE.L	D0,A6
	CMP.W	#35,20(A6)
	BGE.B	casmskip4
	LEA	MustHavePP35Text(PC),A0
	BRA.W	ModCrunchError
casmskip4
	MOVE.L	CrunchSpeed(PC),D0
	MOVE.L	CrunchBufferMode(PC),D1
	LEA	CrunchInterrupt(PC),A0
	SUB.L	A1,A1
	MOVE.L	PPLibBase(PC),A6
	JSR	_LVOppAllocCrunchInfo(A6)
	MOVE.L	D0,CrunchInfoPtr
	BEQ.W	ModCrunchOutOfMemory
	LEA	CrunchingText(PC),A0
	CLR.L	12(A0)
	BSR.W	ShowStatusText
	MOVE.L	CrunchInfoPtr,A0
	MOVE.L	CrunchBufferPtr,A1
	MOVE.L	TuneMemory,D0
	MOVE.L	PPLibBase(PC),A6
	JSR	_LVOppCrunchBuffer(A6)
	LEA	CrunchAbortedText,A0
	TST.L	D0
	BEQ.W	ModCrunchError
	LEA	BufOverflowText,A0
	CMP.L	#-1,D0
	BEQ.W	ModCrunchError
	MOVE.L	D0,CrunchBufferLen
	MOVE.L	#FileName,D1
	MOVE.L	#1006,D2
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BNE.B	casmskip5
	LEA	CantOpenFileText(PC),A0
	BSR.W	ShowStatusText
	BRA.W	ModCrunchCleanup
casmskip5
	LEA	CrunchGainText(PC),A0
	BSR.W	ShowStatusText
	MOVE.L	CrunchBufferLen,D1
	MOVE.L	TuneMemory,D2
casmloop4
	CMP.L	#$FFFF,D2
	BLE.B	casmskip6
	LSR.L	#1,D2
	LSR.L	#1,D1
	BRA.B	casmloop4
casmskip6
	MULU.W	#100,D1
	DIVU.W	D2,D1
	NEG.W	D1
	ADD.W	#100,D1
	MOVE.W	D1,WordNumber
	MOVE.W	#5139,TextOffset
	BSR.W	Print3DecDigits
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	JSR	WaitALittle
	LEA	SavingModuleText(PC),A0
	BSR.W	ShowStatusText
	MOVE.L	FileHandle(PC),D0
	MOVE.L	CrunchSpeed(PC),D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.L	PPLibBase(PC),A6
	JSR	_LVOppWriteDataHeader(A6)
	MOVE.L	FileHandle(PC),D1
	MOVE.L	CrunchBufferPtr,D2
	MOVE.L	CrunchBufferLen,D3
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOWrite(A6)
	CMP.L	CrunchBufferLen,D3
	BEQ.B	casmskip7
	BSR.W	CantSaveFile
casmskip7
	MOVE.L	FileHandle(PC),D1
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOClose(A6)
ModCrunchCleanup
	TST.L	CrunchInfoPtr
	BEQ.B	mccskip
	MOVE.L	CrunchInfoPtr,A0
	MOVE.L	PPLibBase(PC),A6
	JSR	_LVOppFreeCrunchInfo(A6)
mccskip
	MOVE.L	CrunchBufferPtr,D1
	BEQ.B	mccskip2
	MOVE.L	D1,A1
	MOVE.L	TuneMemory,D0
	JSR	PTFreeMem
mccskip2
	JSR	SetNormalPtrCol
	BSR.W	ShowAllRight
	JMP	DoAutoDir

ModCrunchError
	BSR.W	ShowStatusText
	JSR	SetErrorPtrCol
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	JSR	WaitALittle
	BRA.B	ModCrunchCleanup
	
ModCrunchOutOfMemory
	LEA	NoBufMemText,A0
	BSR.W	ShowStatusText
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	JSR	WaitALittle
	LEA	ChooseSmallerText,A0
	BSR.W	ShowStatusText
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	JSR	WaitALittle
	MOVE.L	CrunchBufferPtr,D1
	BEQ.B	mcoomskip
	MOVE.L	D1,A1
	MOVE.L	TuneMemory,D0
	JSR	PTFreeMem
mcoomskip
	BRA.W	ShowModCrunchBox
	
CrunchInterrupt	; periodically called while crunching
	MOVEM.L	D0-D7/A0-A6,RegBackup
	MOVE.L	(SP)+,D4
	MOVEM.L	(SP),D0-D3
	MOVE.L	D4,-(SP)
cruiloop
	CMP.L	#$FFFF,D2
	BLE.B	cruiskip
	LSR.L	#1,D2
	LSR.L	#1,D1
	LSR.L	#1,D0
	BRA.B	cruiloop
cruiskip
	MULU.W	#100,D0
	DIVU.W	D2,D0
	MOVE.W	#5143,TextOffset
	MOVE.W	D0,WordNumber
	BSR.W	Print3DecDigits
	LEA	PercentText(PC),A0
	MOVE.W	#1,TextLength
	BSR.W	ShowText2
	MOVEQ	#-1,D0
	BTST	#6,$BFE001	; left mouse button
	BNE.B	cruiskip2
	LEA	CrunchingText(PC),A0
	CLR.L	12(A0)
	MOVEM.L	RegBackup(PC),D0-D7/A0-A6
	MOVEQ	#0,D0
	RTS
cruiskip2
	JSR	CheckPatternRedraw2
	MOVEM.L	RegBackup(PC),D0-D7/A0-A6
	RTS

	CNOP 0,4
RegBackup		dcb.l 15	; 8*4 + 7*4 [D0-D7/A0-A6]
CrunchSpeed		dc.l 0
CrunchBufferMode	dc.l 0
CrunchGainText		dc.b 'Gain...    %',0
	EVEN

WriteExeModule
	LEA	FileName,A0
seloop
	TST.B	(A0)+
	BNE.B	seloop
	MOVE.B	#'.',-1(A0)
	MOVE.B	#'e',(A0)+
	MOVE.B	#'x',(A0)+
	MOVE.B	#'e',(A0)+
	MOVE.B	#0,(A0)
	MOVE.L	SongDataPtr(PC),A0
	LEA	exeReplayData(PC),A1
	LEA	145(A1),A1
	MOVEQ	#19-1,D1
seloop2
	MOVE.B	(A0)+,(A1)+
	DBRA	D1,seloop2
	MOVE.L	SongDataPtr(PC),A0
	LEA	sd_sampleinfo(A0),A0
	LEA	exeReplayData(PC),A1
	LEA	175(A1),A1
	MOVEQ	#21-1,D1
seloop3
	MOVE.B	(A0)+,(A1)+
	DBRA	D1,seloop3
	LEA	exeReplayData(PC),A0
	MOVE.L	TuneMemory,D1
	ADD.L	#5080,D1
	MOVE.L	D1,D2
	LSR.L	#2,D1
	BTST	#1,D2
	BEQ.B	seskip
	ADDQ.L	#1,D1
	ADDQ.L	#2,DiskDataLength
seskip
	MOVE.L	D1,28(A0)
	ADD.L	#$40000000,D1
	MOVE.L	D1,sd_sampleinfo(A0)
	
WriteModule
	LEA	SavingModuleText(PC),A0
	BSR.W	ShowStatusText
	BTST	#2,$DFF016	; right mouse button
	BEQ.W	CantOpenFile
	BSR.W	OpenModForWrite
	BNE.W	CantOpenFile
	CMP.W	#1,makeExeModFlag
	BNE.B	wmskip1
	MOVE.L	FileHandle(PC),D1
	MOVE.L	#exeReplayData,D2
	MOVE.L	#5112,D3
	JSR	_LVOWrite(A6)
	CMP.L	#5112,D3
	BNE.W	WriteModError
wmskip1
	BSR.W	WriteModuleData
	BNE.B	WriteModError
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	WriteModError
	MOVE.W	InsNum(PC),SaveInstrNum
	MOVEQ	#1,D6
saveinstrloop
	MOVE.W	D6,InsNum
	BSR.W	ShowSampleInfo
	BSR.B	WriteInstrument
	TST.L	D0
	BNE.B	WriteModError
	ADDQ.B	#1,D6
	CMP.B	#32,D6
	BNE.B	saveinstrloop
	CMP.W	#1,makeExeModFlag
	BNE.B	wmskip2
	CLR.W	makeExeModFlag
	MOVE.L	FileHandle(PC),D1
	MOVE.L	#exeReplayRelocHunk,D2
	MOVE.L	#304,D3
	JSR	_LVOWrite(A6)
	CMP.L	#304,D3
	BNE.B	WriteModError
wmskip2
	BSR.W	CloseWriteMod
	MOVE.W	SaveInstrNum(PC),InsNum
	BSR.W	ShowSampleInfo
	BSR.W	ShowAllRight
	JSR	RestorePtrCol
	JMP	DoAutoDir

SaveInstrNum	dc.w 0

WriteModError
	BSR.W	CloseWriteMod
	BRA.W	CantSaveFile

WriteInstrument	
	MOVE.W	D6,D0
	LSL.W	#2,D0
	LEA	SamplePtrs(PC),A0
	MOVE.L	(A0,D0.W),D1
	BEQ.B	wrinskip
	MOVE.L	124(A0,D0.W),D0
	BEQ.W	Return3
	MOVE.L	D1,DiskDataPtr
	MOVE.L	SongDataPtr(PC),A0
	LEA	12(A0),A0
	MOVE.W	D6,D0
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	ADD.L	D0,D0
	MOVE.L	D0,DiskDataLength
	BNE.B	WriteModuleData
	RTS
wrinskip
	MOVEQ	#0,D0
	RTS

OpenModForWrite
	MOVE.L	DOSBase(PC),A6
	MOVE.L	#FileName,D1
	MOVE.L	#1006,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.B	wmfailed
	MOVEQ	#0,D0
	RTS

WriteModuleData
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileHandle(PC),D1
	MOVE.L	DiskDataPtr(PC),D2
	MOVE.L	DiskDataLength(PC),D3
	BEQ.B	.okok
	JSR	_LVOWrite(A6)
	CMP.L	DiskDataLength(PC),D3
	BNE.B	wmfailed
	MOVEQ	#0,D0
.okok	RTS

wmfailed
	MOVEQ	#-1,D0
	RTS

CloseWriteMod
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileHandle(PC),D1
	JMP	_LVOClose(A6)
	
;---- Load PLST ----

LoadPLST
	LEA	LoadPLSTText(PC),A0
	JSR	AreYouSure
	BNE.W	Return3
	JSR	WaitForButtonUp
	LEA	LoadingPLSTText(PC),A0
	BSR.W	ShowStatusText
DoLoadPLST
	JSR	StorePtrCol
	LEA	PTPath,A0
	JSR	CopyPath
	LEA	PLSTname(PC),A0
	MOVEQ	#5-1,D0
dlploop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,dlploop
	MOVE.L	#FileName,D1
	MOVE.L	#1005,D2
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,D7
	BEQ.W	PLSTOpenErr
	JSR	SetDiskPtrCol
	CLR.L	PresetTotal
	BSR.B	AllocPLST
	MOVE.L	PLSTmem(PC),D2
	BEQ.W	PLSTMemErr2
	MOVE.L	D7,D1
	MOVE.L	PLSTAllocSize(PC),D3
	MOVE.L	DOSBase(PC),A6
	JSR	_LVORead(A6)
	MOVE.L	D0,MaxPLSTOffset
	DIVU.W	#30,D0
	MOVE.W	D0,PresetTotal
cloplst	MOVE.L	D7,D1
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOClose(A6)
	BSR.W	PLSTCheckNum
	BSR.W	ShowAllRight
	JMP	RestorePtrCol

PLSTname	dc.b	'PLST',0
	EVEN

AllocPLST
	BSR.B	FreePLST
	MOVE.W	MaxPLSTEntries,D0
	BEQ.W	Return3
	MULU.W	#30,D0
	MOVE.L	D0,PLSTAllocSize
	MOVE.L	#MEMF_CLEAR,D1
	JSR	PTAllocMem
	MOVE.L	D0,PLSTmem
	MOVE.W	MaxPLSTEntries,MaxPLSTEntries2
	RTS

FreePLST
	CLR.W	MaxPLSTEntries2
	CLR.L	MaxPLSTOffset
	CLR.W	PresetTotal
	MOVE.L	PLSTmem(PC),D0
	BEQ.W	Return3
	MOVE.L	D0,A1
	MOVE.L	PLSTAllocSize(PC),D0
	JSR	PTFreeMem
	CLR.L	PLSTmem
	RTS

PLSTMemErr2
	BSR.B	PLSTMemErr
	BRA.W	cloplst

PLSTMemErr
	TST.W	MaxPLSTEntries
	BEQ.B	reptrco
	BSET	#0,InitError
	LEA	PLSTMemText(PC),A0
plster	BSR.W	ShowStatusText
	MOVE.W	#ERR_WAIT_TIME,WaitTime
	JMP	ErrorRestoreCol
reptrco	JMP	RestorePtrCol
PLSTOpenErr
	TST.W	MaxPLSTEntries
	BEQ.B	reptrco
	BSET	#1,InitError
	LEA	PLSTOpenText(PC),A0
	BRA.B	plster
	RTS
	
PLSTMemText	dc.b	'no mem for plst !',0
PLSTOpenText	dc.b	'plst not found ! ',0
	EVEN

ShowAllRight
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	AllRightText(PC),A0
	BSR.W	ShowStatusText
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

ShowStatusText
	MOVEM.L	D0/D1/A1,-(SP)
	LEA	TextBitplane+5131,A1
	MOVEQ	#5-1,D0
stloop1	MOVEQ	#17-1,D1
stloop2	CLR.B	(A1)+
	DBRA	D1,stloop2
	LEA	23(A1),A1
	DBRA	D0,stloop1
	MOVE.L	A0,A1
	MOVE.W	#5131,D1
	MOVEQ	#-1,D0
stloop3	ADDQ.W	#1,D0
	TST.B	(A1)+
	BNE.B	stloop3
	BSR.W	ShowText3
	MOVEM.L	(SP)+,D0/D1/A1
	RTS
	
;---- Redraw Pattern ----

RedrawPattern
	TST.W	SamScrEnable
	BNE.W	Return3
	SF	PattRfsh
	MOVE.W	#5121,TextOffset
	MOVE.W	PatternNumber+2(PC),WordNumber
	BSR.W	Print2DecDigits ; Print PatternNumber
	MOVE.L	SongDataPtr(PC),A6
	LEA	$043C(A6),A6
	MOVE.L	PatternNumber(PC),D6
	LSL.L	#8,D6
	LSL.L	#2,D6
	ADD.L	D6,A6
	MOVE.W	#7521,TextOffset
	CLR.W	PPattPos
	LEA	RedrawBuffer(PC),A3
	LEA	FastHexTable(PC),A4
	MOVE.L	NoteNamesPtr(PC),A5
	MOVE.L	#Period2Note,D4
	MOVE.B	BlankZeroFlag,D5

	MOVEQ	#64-1,D6	; row counter
rpnxpos	MOVEQ	#4-1,D7		; channel counter
	MOVE.W	PPattPos(PC),WordNumber
	ADDQ.W	#1,PPattPos
	BSR.W	Print2DecDigits ; Print PatternPosition
	ADDQ.W	#1,TextOffset
rploop	

	; convert period to note number string
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1	; D1.W = period
	BNE.B	rpfind
	MOVE.L	#'--- ',(A3)
	BRA.B	rpskip2
rpfind	MOVEQ	#0,D0
	SUB.W	#113,D1
	BLT.W	rplo
	CMP.W	#856-113,D1
	BHI.B	rpskip1
	MOVE.L	D4,A1		; A1 = Period2Note
	MOVE.B	(A1,D1.W),D0	; note*4, for NoteNamesPtr (A0) dword look-up
rpskip1	MOVE.L	(A5,D0.W),(A3)
rpskip2

	MOVE.B	(A6)+,D0
	LSR.B	#4,D0
	AND.B	#$01,D0	; --PT2.3D bug fix: mask high nybble of sample num for broken MODs
	ADD.B	#'0',D0
	MOVE.B	D0,3(A3)
	ADDQ	#1,A6	; skip byte
	MOVEQ	#0,D0
	MOVE.B	(A6)+,D0
	ADD.W	D0,D0
	MOVE.W	(A4,D0.W),4(A3)
	MOVEQ	#0,D0
	MOVE.B	(A6)+,D0
	ADD.W	D0,D0
	MOVE.W	(A4,D0.W),6(A3)

	TST.B	D5	; BlankZeroFlag set?
	BEQ.B	rpskp3
	CMP.B	#'0',3(A3)
	BNE.B	rpskp3
	MOVE.B	#' ',3(A3)
rpskp3

	; 8bitbubsy: print note data (slightly faster than calling ShowText)
	LEA	TextBitplane,A1
	ADD.W	TextOffset(PC),A1
	MOVE.L	#FontData,D2
	LEA	FontDataOffsets(PC),A0
	MOVE.L	A3,ShowTextPtr
	MOVEQ	#(8/2)-1,D1	; 2x loop unroll
rploop2	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	ADD.W	D0,D0
	MOVE.W	(A0,D0.W),A2
	ADD.L	D2,A2
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,40-1(A1)
	MOVE.B	(A2)+,80-1(A1)
	MOVE.B	(A2)+,120-1(A1)
	MOVE.B	(A2),160-1(A1)
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	ADD.W	D0,D0
	MOVE.W	(A0,D0.W),A2
	ADD.L	D2,A2
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,40-1(A1)
	MOVE.B	(A2)+,80-1(A1)
	MOVE.B	(A2)+,120-1(A1)
	MOVE.B	(A2),160-1(A1)
	DBRA	D1,rploop2
	ADD.W	#8+1,TextOffset
	SUBQ	#8,A3
	
	DBRA	D7,rploop  ; Next Channel
	ADD.W	#241,TextOffset
	DBRA	D6,rpnxpos ; Next PattPos
	
	RTS
	
rplo	MOVE.L	#'??? ',(A3)
	BRA.W    rpskip2

	CNOP 0,4
RedrawBuffer	dc.b	'---00000'
	EVEN

ShowPosition
	MOVE.L	SongDataPtr(PC),A0
	LEA	952(A0),A0
	ADD.L	CurrPos(PC),A0
	MOVEQ	#0,D1
	MOVE.B	(A0),D1
	MOVE.W	D1,WordNumber
	TST.W	CurrScreen
	BEQ.B	spokok
	CMP.W	#1,CurrScreen
	BEQ.B	spokok
	CMP.W	#6,CurrScreen
	BEQ.B	spokok
	CMP.W	#8,CurrScreen
	BEQ.B	spokok
	RTS

spokok	MOVE.W	#$260,TextOffset
	BSR.W	Print4DecDigits
	MOVE.W	CurrPos+2(PC),WordNumber
	MOVE.W	#$A8,TextOffset
	BRA.W	Print4DecDigits

ShowSongLength	CMP.W	#2,CurrScreen
	BEQ.B	ShowSongName
	CMP.W	#3,CurrScreen
	BEQ.B	ShowSongName
	CMP.W	#4,CurrScreen
	BEQ.W	Return3
	CMP.W	#5,CurrScreen
	BEQ.B	ShowSongName
	MOVE.L	SongDataPtr(PC),A0
	LEA	sd_numofpatt(A0),A0
	MOVE.L	A0,CurrCmds
	CLR.W	WordNumber
	MOVE.B	(A0),WordNumber+1
	MOVE.W	#$418,TextOffset
	BSR.W	Print4DecDigits
	MOVE.L	CurrCmds(PC),A0
ShowSongName	MOVE.L	SongDataPtr(PC),A0
	MOVE.W	#$1025,D1
	MOVEQ	#$14,D0
	BRA.W	ShowText3

ShowSampleInfo
	MOVEQ	#0,D0
	MOVE.W	InsNum(PC),D0
	MOVE.W	D0,PlayInsNum
	BNE.B	ssiskipit
	MOVE.W	LastInsNum(PC),D0
ssiskipit
	MOVE.W	D0,D1
	LSL.L	#2,D0
	LEA	SongDataPtr(PC),A0
	MOVE.L	(A0,D0.W),si_pointer
	MOVE.L	SongDataPtr(PC),A0
	LEA	-10(A0),A0
	MOVE.W	D1,D0
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVE.L	A0,CurrCmds
	MOVE.L	22(A0),SampleInfo
	MOVE.L	26(A0),si_long
	TST.B	NoSampleInfo
	BNE.W	ssiskip
	
	MOVE.L	A0,-(SP)
	MOVE.B	#' ',FineTuneSign
	MOVE.B	24(A0),D0
	BEQ.B	dopfitu
	MOVE.B	#'+',FineTuneSign
	BTST	#3,D0
	BEQ.B	dopfitu
	MOVE.B	#'-',FineTuneSign
	MOVEQ	#16,D1
	SUB.B	D0,D1
	MOVE.B	D1,D0
dopfitu	MOVE.W	#1491,TextOffset
	BSR.W	PrintHexDigit  ; FineTune
	LEA	FineTuneSign(PC),A0
	MOVE.W	#1490,D1
	MOVEQ	#1,D0
	BSR.W	ShowText3  ; FineTuneSign
	MOVE.L	(SP)+,A0
	
	CLR.W	WordNumber
	MOVE.B	25(A0),WordNumber+1
	MOVE.W	WordNumber(PC),VolumeEfx
	OR.W	#$0C00,VolumeEfx
	MOVE.W	#$940,TextOffset
	BSR.W	PrintHexWord  ; Volume
	
	MOVEQ	#0,D0
	MOVE.W	SampleInfo(PC),D0
	ADD.L	D0,D0
	MOVE.L	D0,LongWordNumber
	MOVE.L	SamplePos(PC),D2
	CMP.L	D0,D2
	BLS.B	ShowLen
	MOVE.L	D0,SamplePos
	BSR.W	ShowPos
	MOVEQ	#0,D0
	MOVE.W	SampleInfo(PC),D0
	ADD.L	D0,D0
	MOVE.L	D0,LongWordNumber
ShowLen	MOVE.W	#2807,TextOffset
	BSR.W	Print5HexDigits  ; Length
	BSR.W	CalculateChordLen
	
	MOVEQ	#0,D0
	MOVE.W	si_long(PC),D0
	ADD.L	D0,D0
	MOVE.L	D0,LongWordNumber
	MOVE.W	#3247,TextOffset
	BSR.W	Print5HexDigits  ; Repeat
	
	MOVEQ	#0,D0
	MOVE.W	si_long+2(PC),D0
	ADD.L	D0,D0
	MOVE.L	D0,LongWordNumber
	MOVE.W	#3687,TextOffset
	BSR.W	Print5HexDigits  ; RepLen
	
	BSR.W	ssiinst
	
ssiskip	TST.B	NoSampleInfo
	BEQ.B	ssiskp2
	CMP.W	#5,CurrScreen
	BEQ.B	ssiskp2
	CMP.W	#7,CurrScreen
	BEQ.B	ssiskp2
	CMP.W	#3,CurrScreen
	BNE.W	Return3
ssiskp2	MOVE.L	CurrCmds(PC),A0
	BSR.B	lbC010290
	MOVE.W	#4573,D1
	MOVEQ	#22,D0
	BRA.W	ShowText3  ; SampleName

lbC010290
	MOVE.L	A0,A1
	MOVEQ	#22-1,D7
lbC010298
	CMP.B	#'.',(A1)+
	BEQ.B	lbC0102A4
	DBRA	D7,lbC010298
	RTS

lbC0102A4
	TST.L	D7
	BEQ.B	lbC0102E6
	CMP.B	#'p',(A1)
	BNE.B	lbC0102EE
	ADDQ	#1,A1
	SUBQ.L	#1,D7
	TST.L	D7
	BEQ.B	lbC0102E0
	CMP.B	#'p',(A1)
	BNE.B	lbC0102EE
	ADDQ	#1,A1
	SUBQ.L	#1,D7
	TST.L	D7
	BEQ.B	lbC0102DA
	TST.B	(A1)
	BNE.B	lbC0102EE
lbC0102DA
	CLR.B	-3(A1)
lbC0102E0
	CLR.B	-2(A1)
lbC0102E6
	CLR.B	-1(A1)
	RTS
lbC0102EE
	SUBQ.L	#1,D7
	BEQ.W	Return2
	BRA.B	lbC010298

ssiinst
	TST.B	NoSampleInfo
	BNE.W	Return3
	MOVE.W	InsNum(PC),WordNumber
	MOVE.W	#1928,TextOffset
	BRA.W	PrintHexWord  ; SampleNumber

VolumeEfx	dc.w 0
FineTuneSign	dc.b ' '
	EVEN

;---- Print Decimal Digits ----

Print2DecDigits ; 8bb: optimized
	; we can safely trash D0/D1/A0/A1
	MOVE.L	A2,-(SP) 
	MOVE.W	WordNumber(PC),D0
	CMP.W	#99,D0
	BLS.B	.OK
	MOVEQ	#99,D0
.OK	ADD.W	D0,D0		; *2 for LUT index
	MOVEQ	#0,D1
	LEA	FontData,A2
	MOVE.B	(FastTwoDecTable+0,PC,D0.W),D1
	LEA	(A2,D1.W),A0
	MOVE.B	(FastTwoDecTable+1,PC,D0.W),D1
	LEA	(A2,D1.W),A1
	LEA	TextBitplane,A2
	ADD.W	TextOffset(PC),A2
	ADDQ.W	#2,TextOffset
	MOVE.B	(A0)+,(A2)+
	MOVE.B	(A0)+,40-1(A2)
	MOVE.B	(A0)+,80-1(A2)
	MOVE.B	(A0)+,120-1(A2)
	MOVE.B	(A0),160-1(A2)
	MOVE.B	(A1)+,(A2)+
	MOVE.B	(A1)+,40-1(A2)
	MOVE.B	(A1)+,80-1(A2)
	MOVE.B	(A1)+,120-1(A2)
	MOVE.B	(A1),160-1(A2)
	MOVE.L	(SP)+,A2
	RTS

	; (("00" .. "99" (split into two bytes)) - 32) * 8
FastTwoDecTable
        dc.w $8080,$8088,$8090,$8098,$80A0,$80A8,$80B0,$80B8
        dc.w $80C0,$80C8,$8880,$8888,$8890,$8898,$88A0,$88A8
        dc.w $88B0,$88B8,$88C0,$88C8,$9080,$9088,$9090,$9098
        dc.w $90A0,$90A8,$90B0,$90B8,$90C0,$90C8,$9880,$9888
        dc.w $9890,$9898,$98A0,$98A8,$98B0,$98B8,$98C0,$98C8
        dc.w $A080,$A088,$A090,$A098,$A0A0,$A0A8,$A0B0,$A0B8
        dc.w $A0C0,$A0C8,$A880,$A888,$A890,$A898,$A8A0,$A8A8
        dc.w $A8B0,$A8B8,$A8C0,$A8C8,$B080,$B088,$B090,$B098
        dc.w $B0A0,$B0A8,$B0B0,$B0B8,$B0C0,$B0C8,$B880,$B888
        dc.w $B890,$B898,$B8A0,$B8A8,$B8B0,$B8B8,$B8C0,$B8C8
        dc.w $C080,$C088,$C090,$C098,$C0A0,$C0A8,$C0B0,$C0B8
        dc.w $C0C0,$C0C8,$C880,$C888,$C890,$C898,$C8A0,$C8A8
        dc.w $C8B0,$C8B8,$C8C0,$C8C8

Print3DecDigits
	MOVE.W	#3,TextLength
	MOVEQ	#0,D1
	MOVE.W	WordNumber(PC),D1
	LEA	NumberText(PC),A0
	BRA.B	pdig100

Print4DecDigits
	MOVE.W	#4,TextLength
	MOVEQ	#0,D1
	MOVE.W	WordNumber(PC),D1
	LEA	NumberText(PC),A0
	DIVU.W	#1000,D1
	BSR.B	DoOneDigit
pdig100	DIVU.W	#100,D1
	BSR.B	DoOneDigit
pdig	DIVU.W	#10,D1
	BSR.B	DoOneDigit
	BSR.B	DoOneDigit
	LEA	NumberText(PC),A0
	BRA.W	ShowText2

DoOneDigit
	ADD.B	#'0',D1
	MOVE.B	D1,(A0)+
	CLR.W	D1
	SWAP	D1
	RTS

Print6DecDigits	; fixed in PT2.3E to display big numbers correctly
	LEA	NumberText(PC),A0
	
	; if number is zero, draw "     0"
	TST.L	D0
	BNE.B	p6ddskip
	MOVE.B	#'0',5(A0)
	MOVE.B	#' ',4(A0)
	MOVE.B	#' ',3(A0)
	MOVE.B	#' ',2(A0)
	MOVE.B	#' ',1(A0)
	MOVE.B	#' ',(A0)
	BRA.W	p6ddok
	
	; number is not zero, let's do some math!
p6ddskip
	MOVE.L	D0,D1
	CMP.L	#1000000,D1
	BHS.W	toobig

	; number is 0...999999
	MOVEQ	#0,D2
	DIVU.W	#1000,D1
	SWAP	D1
	MOVE.W	D1,D2
	CLR.W	D1
	SWAP	D1
	; D1 = first 3 digits
	; D2 = last 3 digits	

	DIVU.W	#10,D2	; sixth digit
	SWAP	D2
	ADD.B	#'0',D2
	MOVE.B	D2,5(A0)
	CLR.W	D2
	SWAP	D2

	DIVU.W	#10,D2	; fifth digit
	SWAP	D2
	ADD.B	#'0',D2
	MOVE.B	D2,4(A0)
	CLR.W	D2
	SWAP	D2
	
	DIVU.W	#10,D2	; fourth digit
	SWAP	D2
	ADD.B	#'0',D2
	MOVE.B	D2,3(A0)
	CLR.W	D2
	SWAP	D2
	
	DIVU.W	#10,D1	; third digit
	SWAP	D1
	ADD.B	#'0',D1
	MOVE.B	D1,2(A0)
	CLR.W	D1
	SWAP	D1
	
	DIVU.W	#10,D1	; second digit
	SWAP	D1
	ADD.B	#'0',D1
	MOVE.B	D1,1(A0)
	CLR.W	D1
	SWAP	D1
	
	DIVU.W	#10,D1	; first digit
	SWAP	D1
	ADD.B	#'0',D1
	MOVE.B	D1,(A0)
		
	; replace zeroes to the left with space
	MOVE.L	A0,A1
.loop	CMP.B	#'0',(A1)
	BNE.B	p6ddok
	MOVE.B	#' ',(A1)+
	BRA.B	.loop
p6ddok	MOVE.W	#6,TextLength
	BRA	ShowText2

toobig	; number is >999999. divide by 1000, then display space + 4 digits + 'K' at end
	CMP.L	#9999999,D0
	BHI.B	toobigoverflow
	MOVE.L	D0,-(SP)
	MOVE.B	#' ',D0	; print space
	BSR.B	printch
	MOVE.L	(SP)+,D0
	DIVU.W	#1000,D0
	MOVE.W	D0,WordNumber
	BSR	Print4DecDigits
	MOVE.B	#'K',D0
printch	LEA	NumberText(PC),A0
	MOVE.B	D0,(A0)
	MOVE.W	#1,TextLength
	BRA.W	ShowText2
	
toobigoverflow
	MOVE.B	#'>',D0
	BSR.B	printch
	MOVE.W	#9999,WordNumber
	BSR	Print4DecDigits
	MOVE.B	#'K',D0
	BRA.B	printch

	CNOP 0,4
NumberText	dcb.b	6,0
	EVEN
	
;---- Print Hex Digits ----

PrintHiInstrNum
	MOVEQ	#0,D0
	TST.W	CurrentPlayNote
	BEQ.B	phin2
	MOVE.W	InsNum(PC),D0
	LSR.W	#4,D0
	BNE.B	PrintHexDigit
phin2	TST.B	BlankZeroFlag
	BEQ.B	PrintHexDigit
	LEA	BlankInsText(PC),A0
	BRA.B	phd2
PrintHexDigit	AND.L	#15,D0
	ADD.L	D0,D0
	LEA	FastHexTable+1(PC),A0
	ADD.L	D0,A0
phd2	MOVE.W	#1,TextLength
	BRA.W	ShowText2

BlankInsText	dc.b " "
	EVEN

; this routine was coded by h0ffman and edited by 8bitbubsy
Print5HexDigits
	MOVE.L	D1,-(SP)
	MOVE.L	D7,-(SP)
	LEA	LongWordNumber(PC),A0
	MOVE.L	(A0),D0
	LEA	HexString+5(PC),A0	; 4 (+1 for pre-sub suffix)
	MOVEQ	#5-1,D7
.hexlp	MOVE.B	D0,D1
	AND.B	#$0F,D1
	CMP.B	#9,D1
	BLE.B	.dec
	ADDQ.B	#7,D1
.dec	ADD.B	#'0',D1
	MOVE.B	D1,-(A0)
	LSR.L	#4,D0
	DBRA	D7,.hexlp
	MOVE.L	(SP)+,D7
	MOVE.L	(SP)+,D1
	LEA	HexString(PC),A0
	MOVE.W	#5,TextLength
	BSR.B	ShowText2
	CLR.L	LongWordNumber
	RTS

HexString	dc.b	"00000"
	EVEN
; ---------------------------------------------------------------

PrintHexWord
	LEA	WordNumber(PC),A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	ADD.W	D0,D0
	LEA	FastHexTable(PC),A0
	ADD.W	D0,A0
	MOVE.W	#2,TextLength
	BSR.W	ShowText2
PrintHexByte
	LEA	WordNumber(PC),A0
	MOVEQ	#0,D0
	MOVE.B	1(A0),D0
	ADD.W	D0,D0
	LEA	FastHexTable(PC),A0
	ADD.W	D0,A0
	MOVE.W	#2,TextLength
	BSR.B	ShowText2
	CLR.W	WordNumber
	RTS
	
;---- Text Output Routines ----

ShowText3
	MOVE.W	D0,TextLength
	MOVE.W	D1,TextOffset
ShowText2
	MOVE.L	A0,ShowTextPtr
ShowText
	MOVEM.L	A2-A4,-(SP)
	LEA	FontData,A4
	LEA	FontDataOffsets(PC),A3
	MOVE.W	TextLength(PC),D0
	LEA	TextBitplane,A1
	ADD.W	TextOffset(PC),A1
	ADD.W	D0,TextOffset
	MOVE.L	ShowTextPtr(PC),A0
	SUBQ.W	#1,D0
.loop	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	ADD.W	D1,D1
	MOVE.W	(A3,D1.W),A2
	ADD.L	A4,A2
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,40-1(A1)
	MOVE.B	(A2)+,80-1(A1)
	MOVE.B	(A2)+,120-1(A1)
	MOVE.B	(A2),160-1(A1)
	DBRA	D0,.loop
	MOVEM.L	(SP)+,A2-A4
	RTS

SpaceShowText
	MOVEM.L	A2-A4,-(SP)
	LEA	FontData,A4
	LEA	FontDataOffsets(PC),A3
	MOVE.W	TextLength(PC),D0
	LEA	TextBitplane,A1
	ADD.W	TextOffset(PC),A1
	ADD.W	D0,TextOffset
	MOVE.L	ShowTextPtr(PC),A0
	SUBQ.W	#1,D0
.loop	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	BNE.B	.skip
	MOVEQ	#' ',D1
.skip	ADD.W	D1,D1
	MOVE.W	(A3,D1.W),A2
	ADD.L	A4,A2
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,40-1(A1)
	MOVE.B	(A2)+,80-1(A1)
	MOVE.B	(A2)+,120-1(A1)
	MOVE.B	(A2),160-1(A1)
	DBRA	D0,.loop
	MOVEM.L	(SP)+,A2-A4
	RTS

FontDataOffsets
        dc.w 504,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        dc.w   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        dc.w   0,  8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88, 96,104,112,120
        dc.w 128,136,144,152,160,168,176,184,192,200,208,216,224,232,240,248
        dc.w 256,264,272,280,288,296,304,312,320,328,336,344,352,360,368,376
        dc.w 384,392,400,408,416,424,432,440,448,456,464,472,480,488,496,504
        dc.w 552,264,272,280,288,296,304,312,320,328,336,344,352,360,368,376
        dc.w 384,392,400,408,416,424,432,440,448,456,464,520,528,536,544,504
        dc.w 552,560,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        dc.w   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        dc.w   0,512,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        dc.w   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        dc.w   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        dc.w   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        dc.w   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        dc.w   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0

;---- Set Sprite Position ----

SetSpritePos
	ADD.W	#44,D1
	ADD.W	D1,D2
	ROL.W	#7,D2
	ADD.W	D2,D2
	BCC.B	sppskip
	OR.W	#2,D2
sppskip	ROL.W	#7,D1
	ADD.W	D1,D1
	BCC.B	sppskip2
	OR.W	#4,D2
sppskip2
	ADD.W	#125,D0
	TST.B	ScreenAdjustFlag
	BEQ.B	sppskip3
	SUB.W	#16,D0
sppskip3
	ASR.W	#1,D0
	BHS.B	sppskip4
	OR.W	#1,D2
sppskip4
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	MOVE.W	D2,2(A0)
	RTS
	
;---- DoLoad / DoSave Data ----

DoLoadData
	TST.L	DiskDataLength
	BEQ.B	dlsend
	TST.L	DiskDataPtr
	BEQ.B	dlsend
	JSR	SetDiskPtrCol
	LEA	LoadingText(PC),A0
	BSR.W	ShowStatusText
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileNamePtr(PC),D1
	MOVE.L	#1005,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.B	CantOpenFile
	MOVE.L	FileHandle(PC),D1
	MOVE.L	DiskDataPtr(PC),D2
	MOVE.L	DiskDataLength(PC),D3
	JSR	_LVORead(A6)
	MOVE.L	FileHandle(PC),D1
	JSR	_LVOClose(A6)
dlsend	CLR.L	FileHandle
	JSR	SetNormalPtrCol
	MOVEQ	#-1,D0
	RTS

CantOpenFile
	LEA	CantOpenFileText(PC),A0
caopfil	BSR.W	ShowStatusText
	;JSR	PTScreenToFront (8bitbubsy: this causes issues on exit!)
	JSR	SetErrorPtrCol
	MOVEQ	#0,D0
	RTS

CantSaveFile
	LEA	CantSaveFileText(PC),A0
	BRA.B	caopfil
CantExamFile
	LEA	CantExamFileText(PC),A0
	BRA.B	caopfil
CantFindFile
	LEA	CantFindFileText(PC),A0
	BRA.B	caopfil
FileIsEmpty
	LEA	FileIsEmptyText(PC),A0
	BRA.B	caopfil

CantOpenFileText	dc.b "can't open file !",0
CantSaveFileText	dc.b "can't save file !",0
CantExamFileText	dc.b "examine error !",0
CantFindFileText	dc.b "can't find file !",0
FileIsEmptyText		dc.b "file is empty !",0
	EVEN
	
DoSaveData
	JSR	SetDiskPtrCol
	LEA	SavingText(PC),A0
	BSR.W	ShowStatusText
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileNamePtr(PC),D1
	MOVE.L	#1006,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.W	CantOpenFile
	MOVE.L	FileHandle(PC),D1
	MOVE.L	DiskDataPtr(PC),D2
	MOVE.L	DiskDataLength(PC),D3
	JSR	_LVOWrite(A6)
	CMP.L	DiskDataLength(PC),D3
	BEQ.B	dsdskip
	BSR.W	CantSaveFile
dsdskip	MOVE.L	FileHandle(PC),D1
	JSR	_LVOClose(A6)
	CLR.L	FileHandle
	JMP	SetNormalPtrCol

;---- PLST ----

PLST	CLR.B	RawKeyCode
	CMP.W	#6,CurrScreen
	BEQ.W	ExitPLST
	CMP.W	#1,CurrScreen
	BNE.W	Return3
	JSR	WaitForButtonUp
	MOVE.W	#6,CurrScreen
	JSR	ClearRightArea
	JSR	ClearAnalyzerColors
	BSR.B	DrawPLSTScreen
	BEQ.W	ExitPLST
	BSR.W	RedrawPLST
PLST_rts
	RTS

DrawPLSTScreen
	LEA	PLSTData,A0
	MOVE.L	#PLSTSize,D0
DecompactPLST
	BSR.W	Decompact
	BEQ.W	Return3
	LEA	TopMenusPos,A0
	MOVEQ	#99-1,D0
dplstloop1
	MOVEQ	#25-1,D1
dplstloop2
	MOVE.B	2574(A1),10240(A0)
	MOVE.B	(A1)+,(A0)+
	DBRA	D1,dplstloop2
	LEA	15(A0),A0
	ADDQ	#1,A1
	DBRA	D0,dplstloop1
	BSR.W	FreeDecompMem
	MOVEQ	#-1,D0
	RTS

ShowDiskNames
	MOVE.W	#616,TextOffset
	MOVE.W	#5,TextLength
	LEA	STText1(PC),A0
	BSR.W	ShowText2
	ADDQ.W	#1,TextOffset
	LEA	STText2(PC),A0
	BSR.W	ShowText2
	ADDQ.W	#1,TextOffset
	LEA	STText3(PC),A0
	BRA.W	ShowText2

PLSTCheckNum
	TST.L	PLSTmem
	BEQ.W	NoPLST
	TST.L	MaxPLSTOffset
	BEQ.W	NoPLST
	MOVE.L	PLSTmem(PC),A0
	MOVE.W	PresetTotal(PC),D7
	SUBQ.W	#1,D7
	TST.B	STText1Number
	BNE.B	plstsskip
	TST.B	STText2Number
	BNE.B	plstsskip
	TST.B	STText3Number
	BEQ.B	PLSTMarkAll
plstsskip
	MOVE.L	STText1Number-1(PC),A3
	MOVE.L	STText2Number-1(PC),A4
	MOVE.L	STText3Number-1(PC),A5
	MOVEQ	#0,D6
PLSTmarkloop
	MOVE.W	#'st',(A0)	; Set lowercase 'st'
	MOVE.B	3(A0),D0
	CMP.B	#'a',D0
	BLO.B	pmlskp1
	SUB.B	#32,D0
pmlskp1	MOVE.B	D0,3(A0)
	MOVE.B	4(A0),D0
	CMP.B	#'a',D0
	BLO.B	pmlskp2
	SUB.B	#32,D0
pmlskp2	MOVE.B	D0,4(A0)
	MOVE.L	2(A0),D0	; Get number ('-01:' etc)
PLSTchk1
	CMP.L	A3,D0
	BNE.B	PLSTchk2
	MOVE.W	#'ST',(A0)
	ADDQ.W	#1,D6
	BRA.B	PLSTmarknext

PLSTchk2
	CMP.L	A4,D0
	BNE.B	PLSTchk3
	MOVE.W	#'ST',(A0)
	ADDQ.W	#1,D6
	BRA.B	PLSTmarknext

PLSTchk3
	CMP.L	A5,D0
	BNE.B	PLSTmarknext
	MOVE.W	#'ST',(A0)
	ADDQ.W	#1,D6
PLSTmarknext
	LEA	30(A0),A0
	DBRA	D7,PLSTmarkloop
	MOVE.W	D6,PresetMarkTotal
	CLR.W	PLSTpos
	CLR.L	PLSTOffset
	RTS

PLSTMarkAll
	MOVE.W	#'ST',(A0)	; Set uppercase 'ST'
	LEA	30(A0),A0
	DBRA	D7,PLSTMarkAll
	MOVE.W	PresetTotal(PC),PresetMarkTotal
	CLR.W	PLSTpos
	CLR.L	PLSTOffset
	RTS

NoPLST
	CLR.W	PresetMarkTotal
	CLR.W	PLSTpos
	CLR.L	PLSTOffset
	RTS

RedrawPLST
	MOVE.W	PresetMarkTotal(PC),WordNumber
	MOVE.W	#189,TextOffset
	BSR.W	Print4DecDigits
	BSR.W	ShowDiskNames
	TST.L	PLSTmem
	BEQ.W	PLST_rts
	TST.L	MaxPLSTOffset
	BEQ.W	PLST_rts
	
	MOVE.L	PLSTOffset(PC),D6
	MOVE.L	PLSTmem(PC),A6
	MOVE.W	#976,A5 ; TextOffset
	LEA	PLSTOffset(PC),A4
	MOVEQ	#12-1,D7	; Number of lines to print
	TST.L	D6
	BMI.B	EndOfPLST
dtplstloop
	CMP.W	#'ST',(A6,D6.L)	; Check for 'ST'
	BNE.B	PLSTNext
	MOVE.L	D6,(A4)+
	MOVE.W	A5,TextOffset
	MOVE.W	#18,TextLength
	LEA	(A6,D6.L),A3
	ADDQ	#3,A3
	MOVE.L	A3,ShowTextPtr
	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	SpaceShowText
	MOVEM.L	(SP)+,D0-D7/A0-A6
	MOVE.W	22(A6,D6.L),WordNumber
	MOVE.W	WordNumber(PC),D0
	ADD.W	D0,D0
	MOVE.W	D0,WordNumber
	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	PrintHexWord
	MOVEM.L	(SP)+,D0-D7/A0-A6
	ADD.L	#$1E,D6
	CMP.L	MaxPLSTOffset(PC),D6
	BHI.B	EndOfPLST
	LEA	240(A5),A5	; Next Screen position
	DBRA	D7,dtplstloop
	RTS

PLSTNext
	ADD.L	#30,D6
	CMP.L	MaxPLSTOffset(PC),D6
	BHI.B	EndOfPLST
	BRA.B	dtplstloop

EndOfPLST
	MOVE.L	#$FFFFFFFF,(A4)+
	MOVE.W	A5,TextOffset
	MOVE.W	#23,TextLength
	MOVE.L	#EmptyLineText,ShowTextPtr
	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	SpaceShowText
	MOVEM.L	(SP)+,D0-D7/A0-A6
	LEA	240(A5),A5
	DBRA	D7,EndOfPLST
	RTS

TypeInDisk1
	LEA	STText1Number(PC),A6
	MOVE.W	#156,LineCurX
	BRA.B	DoTypeInDisk

TypeInDisk2
	LEA	STText2Number(PC),A6
	MOVE.W	#204,LineCurX
	BRA.B	DoTypeInDisk

TypeInDisk3
	LEA	STText3Number(PC),A6
	MOVE.W	#252,LineCurX
DoTypeInDisk
	MOVE.W	#1,lbW010D56
	CLR.B	(A6)
	CLR.B	1(A6)
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	BSR.W	ShowDiskNames
	MOVE.W	#20,LineCurY
	JSR	UpdateLineCurPos
	JSR	GetHexKey
	TST.B	RawKeyCode
	BNE.W	ClearDiskNum
	BTST	#2,$DFF016	; right mouse button
	BEQ.W	ClearDiskNum
	CMP.B	#128,D1
	BEQ.W	ClearDiskNum
	ADD.W	D1,D1
	LEA	FastHexTable+1(PC),A0
	MOVE.B	(A0,D1.W),(A6)
	ADDQ.W	#8,LineCurX
	BSR.W	ShowDiskNames
	JSR	UpdateLineCurPos
	JSR	GetHexKey
	TST.B	RawKeyCode
	BNE.W	ClearDiskNum
	BTST	#2,$DFF016	; right mouse button
	BEQ.W	ClearDiskNum
	CMP.B	#128,D1
	BEQ.W	ClearDiskNum
	ADD.W	D1,D1
	LEA	FastHexTable+1(PC),A0
	MOVE.B	(A0,D1.W),1(A6)
	JSR	RestorePtrCol
	BSR.W	PLSTCheckNum
	BSR.W	RedrawPLST
	CLR.W	LineCurX
	MOVE.W	#270,LineCurY
	JMP	UpdateLineCurPos

ClearAllDisks
	CLR.W	lbW010D56
	BSR.B	DoClearDisks
	BSR.W	PLSTCheckNum
	BRA.W	RedrawPLST

DoClearDisks
	MOVEQ	#0,D0
	MOVE.B	D0,STText1Number
	MOVE.B	D0,STText1Number+1
	MOVE.B	D0,STText2Number
	MOVE.B	D0,STText2Number+1
	MOVE.B	D0,STText3Number
	MOVE.B	D0,STText3Number+1
	RTS

MountList
	MOVE.W	#1,lbW010D56
	JSR	StorePtrCol
	JSR	SetDiskPtrCol
	MOVE.L	PTProcess,A0
	MOVE.L	184(A0),lbL010D58
	MOVE.L	#$FFFFFFFF,184(A0)
	BSR.B	DoClearDisks
	MOVE.W	#1,MountFlag
	LEA	df0text(PC),A4
	BSR.B	lbC010C98
	LEA	PEdDefaultVol(PC),A0
	BSR.W	CheckMountName
	LEA	df1text(PC),A4
	BSR.B	lbC010C98
	LEA	STText2(PC),A0
	BSR.W	CheckMountName
	LEA	df2text(PC),A4
	BSR.B	lbC010C98
	LEA	STText3(PC),A0
	BSR.W	CheckMountName
	CLR.W	MountFlag
	JSR	RestorePtrCol
	BSR.B	lbC010C72
	BSR.W	cdisknum2
	MOVE.L	PTProcess,A0
	MOVE.L	lbL010D58(PC),184(A0)
	RTS

lbC010C72
	TST.B	STText1Number
	BNE.W	Return2
	TST.B	STText2Number
	BNE.W	Return2
	TST.B	STText3Number
	BNE.W	Return2
	CLR.W	lbW010D56
	RTS

lbC010C98
	CLR.L	FIB_FileName
	CLR.L	FIB_FileName+4
	CLR.L	FIB_FileName+8
	MOVE.L	DOSBase(PC),A6
	MOVE.L	A4,D1
	MOVEQ	#-2,D2
	JSR	_LVOLock(A6)
	MOVE.L	D0,FileLock
	BEQ.B	MountError
	MOVE.L	FileLock(PC),D1
	MOVE.L	#FileInfoBlock,D2
	JSR	_LVOExamine(A6)
	TST.L	D0
	BEQ.B	MountError
	MOVE.L	FileLock(PC),D1
	JSR	_LVOUnLock(A6)
MountError
	MOVEQ	#-1,D0
	RTS

CheckMountName
	MOVE.W	FIB_FileName,D0
	BEQ.B	MountError
	MOVE.W	#'ST',D1	; Check for ST
	AND.W	#$1F1F,D0
	AND.W	#$1F1F,D1
	CMP.W	D0,D1
	BNE.B	ClearDiskNum
	MOVE.B	FIB_FileName+3,D0
	LSL.W	#8,D0
	MOVE.B	FIB_FileName+4,D0
	CMP.W	#'00',D0
	BEQ.B	ClearDiskNum
	MOVE.B	D0,4(A0)	; Put disk number into ST-xx
	LSR.W	#8,D0
	MOVE.B	D0,3(A0)
	MOVEQ	#0,D0
	RTS

ClearDiskNum 
	CLR.B	RawKeyCode
	JSR	RestorePtrCol
	CLR.B	(A6)
	CLR.B	1(A6)
	CLR.W	LineCurX
	MOVE.W	#270,LineCurY
	JSR	UpdateLineCurPos
cdisknum2
	BSR.W	PLSTCheckNum
	BRA.W	RedrawPLST

	CNOP 0,4
lbL010D58	dc.l 0
lbW010D56	dc.w 0
df0text		dc.b 'DF0:',0
df1text		dc.b 'DF1:',0
df2text		dc.b 'DF2:',0
	EVEN

CheckPLSTGadgs
	MOVE.W	MouseX2(PC),D0
	MOVE.W	MouseY2(PC),D1
	CMP.W	#120,D0
	BLO.B	cplstend
	CMP.W	#23,D1
	BHS.W	PLSTPressed
	CMP.W	#12,D1
	BHS.B	PLSTLine2
PLSTLine1
	CMP.W	#268,D0
	BHS.B	ExitPLST
	CMP.W	#172,D0
	BHS.B	cplstend
	CMP.W	#120,D0
	BHS.W	ClearAllDisks
	RTS

PLSTLine2
	CMP.W	#268,D0
	BHS.W	MountList
	CMP.W	#220,D0
	BHS.W	TypeInDisk3
	CMP.W	#172,D0
	BHS.W	TypeInDisk2
	BRA.W	TypeInDisk1
cplstend
	RTS

ExitPLST
	JSR	WaitForButtonUp
	CLR.B	RawKeyCode
	JSR	ClearRightArea
	JMP	DisplayMainScreen

lbC010DC2
	CMP.W	#$63,D1
	BHI.W	Return3
	CMP.W	#$59,D1
	BHS.W	lbC010E78
	CMP.W	#$4E,D1
	BHS.B	lbC010DF4
	CMP.W	#$2D,D1
	BHS.B	ExitPLST
	CMP.W	#$22,D1
	BHS.B	lbC010DE6
	BRA.B	lbC010E02

lbC010DE6
	TST.W	PresetMarkTotal
	BEQ.W	Return3
	BRA.W	lbC010F12

lbC010DF4
	TST.W	PresetMarkTotal
	BEQ.W	Return3
	BRA.W	lbC010F56

lbC010E02
	TST.W	PresetMarkTotal
	BEQ.W	Return3
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	lbC010E1C
lbC010E16
	MOVEQ	#0,D0
	BRA.W	lbC010F82

lbC010E1C
	TST.W	lbW010D56
	BNE.B	lbC010E16
	MOVE.L	PLSTmem(PC),A1
	MOVE.W	PLSTpos(PC),D0
	MULU.W	#30,D0
	MOVE.B	6(A1,D0.L),D1
lbC010E38
	JSR	lbC0039E8
	SUB.L	#$1E,D0
	BMI.B	lbC010E16
	MOVE.B	6(A1,D0.L),D2
	JSR	lbC0039F0
	CMP.B	D1,D2
	BEQ.B	lbC010E38
	MOVE.B	D2,D1
lbC010E56
	SUB.L	#$1E,D0
	BMI.B	lbC010E16
	MOVE.B	6(A1,D0.L),D2
	JSR	lbC0039F0
	CMP.B	D1,D2
	BEQ.B	lbC010E56
	DIVU.W	#$1E,D0
	ADDQ.W	#1,D0
	BRA.W	lbC010F82

lbC010E78
	TST.W	PresetMarkTotal
	BEQ.W	Return3
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	lbC010E98
lbC010E8C
	MOVE.W	PresetMarkTotal(PC),D0
	SUB.W	#12,D0
	BRA.W	lbC010F82

lbC010E98
	TST.W	lbW010D56
	BNE.B	lbC010E8C
	MOVE.L	PLSTmem(PC),A1
	MOVE.W	PLSTpos(PC),D0
	MULU.W	#30,D0
	MOVE.B	6(A1,D0.L),D1
lbC010EB4
	JSR	lbC0039E8
	ADD.L	#$1E,D0
	MOVE.W	PresetMarkTotal(PC),D2
	SUB.W	#12,D2
	BMI.W	Return2
	MULU.W	#30,D2
	CMP.L	D2,D0
	BLS.B	lbC010EE0
	MOVE.L	D2,D0
	DIVU.W	#$1E,D0
	BRA.W	lbC010F82

lbC010EE0
	MOVE.B	6(A1,D0.L),D2
	JSR	lbC0039F0
	CMP.B	D1,D2
	BEQ.B	lbC010EB4
	DIVU.W	#$1E,D0
	BRA.W	lbC010F82

PLSTOneUp
	ST	SetSignalFlag
	TST.W	PresetMarkTotal
	BEQ.W	Return3
	BTST	#6,$BFE001	; left mouse button
	BEQ.W	PLST_rts
lbC010F12
	MOVE.W	PLSTpos(PC),D0
	MOVE.W	D0,D2
	SUBQ.W	#1,D0
	TST.W	ShiftKeyStatus
	BNE.B	lbC010F2E
	BTST	#2,$DFF016	; right mouse button
	BNE.B	lbC010F32
lbC010F2E
	SUB.W	#9,D0
lbC010F32
	TST.W	D0
	BPL.B	lbC010F82
	CLR.W	D0
	BRA.B	lbC010F82

PLSTOneDown
	ST	SetSignalFlag
	TST.W	PresetMarkTotal
	BEQ.W	Return3
	BTST	#6,$BFE001	; left mouse button
	BEQ.W	PLST_rts
lbC010F56
	MOVE.W	PLSTpos(PC),D0
	MOVE.W	D0,D2
	ADDQ.W	#1,D0
	TST.W	ShiftKeyStatus
	BNE.B	lbC010F70
	BTST	#2,$DFF016	; right mouse button
	BNE.B	lbC010F74
lbC010F70
	ADD.W	#9,D0
lbC010F74
	MOVE.W	PresetMarkTotal(PC),D1
	SUB.W	#12,D1
	CMP.W	D0,D1
	BHS.B	lbC010F82
	MOVE.W	D1,D0
lbC010F82
	BSR.B	lbC010F88
	BRA.W	RedrawPLST

lbC010F88
	MOVE.W	PLSTpos(PC),D1
	MOVE.W	D0,PLSTpos
	CMP.W	D0,D1
	BEQ.W	Return3
	TST.W	D0
	BEQ.B	lbC010FC6
	SUBQ.W	#1,D0
	MOVE.L	PLSTmem(PC),A0
	MOVEQ	#0,D6
lbC010FA4
	CMP.W	#$5354,(A0,D6.L)
	BEQ.B	lbC010FB4
	ADD.L	#$1E,D6
	BRA.B	lbC010FA4

lbC010FB4
	ADD.L	#$1E,D6
	DBRA	D0,lbC010FA4
	MOVE.L	D6,PLSTOffset
	RTS

lbC010FC6
	CLR.L	PLSTOffset
	RTS

PLSTPressed
	CMP.W	#$18,D1
	BLO.W	Return3
	CMP.W	#$134,D0
	BHS.W	lbC010DC2
	CMP.W	#$5F,D1
	BHI.W	Return3
	SUB.W	#$18,D1
	AND.L	#$FFFF,D1
	DIVU.W	#6,D1
	LSL.W	#2,D1
	LEA	PLSTOffset(PC),A0
	MOVE.L	(A0,D1.W),D1
	BMI.W	Return3
	DIVU.W	#$1E,D1
	ADDQ.W	#1,D1
	MOVE.W	D1,CurrentPreset
	JSR	WaitForButtonUp
	BRA.W	UsePreset
	
;---- Preset Editor/PED ----

PresetEditor
	JSR	WaitForButtonUp
	MOVE.W	#4,CurrScreen
	ST	DisableAnalyzer
	ST	NoSampleInfo
	BSR.B	SwapPresEdScreen
	BEQ.W	pedexi2
PED_Refresh
	CLR.W	PED_Action
	LEA	TextBitplane,A0	
	MOVE.W	#1220-1,D0
	MOVEQ	#0,D1
pedloop	MOVE.L	D1,(A0)+
	DBRA	D0,pedloop
	JSR	SetNormalPtrCol
	JSR	ClearAnalyzerColors
	BSR.W	ShowPEDnumbers
	BRA.W	ShowPresetNames

ClearPEDText
	LEA	TextBitplane+2240,A0
	MOVE.W	#660-1,D0
	MOVEQ	#0,D1
cpedtextloop
	MOVE.L	D1,(A0)+
	DBRA	D0,cpedtextloop
	RTS

SwapPresEdScreen
	MOVE.L	DecompMemPtr(PC),D0
	BEQ.B	speds2
	MOVE.L	D0,A1
	BSR.B	speds3
	BRA.W	FreeDecompMem
speds2	LEA	PresetEdData,A0
	MOVE.L	#PresetEdSize,D0
	BSR.W	Decompact
	BEQ.W	Return3
speds3	LEA	BitplaneData,A0
	MOVEQ	#2-1,D2
spesloop1
	MOVE.W	#1220-1,D0
spesloop2
	MOVE.L	(A0),D1
	MOVE.L	(A1),(A0)+
	MOVE.L	D1,(A1)+
	DBRA	D0,spesloop2
	LEA	$14F0(A0),A0
	DBRA	D2,spesloop1
	MOVEQ	#-1,D0
	RTS

CheckPresEdGadgs
	MOVE.W	MouseX2(PC),D0
	MOVE.W	MouseY2(PC),D1
	CMP.W	#45,D1
	BHS.W	CheckPEDnames
	CLR.W	PED_Action
	JSR	SetNormalPtrCol
	CMP.W	#308,D0
	BHS.B	PED_GotoPLST
PED_Menu1
	CMP.W	#102,D0
	BHS.B	PED_Menu2
	CMP.W	#34,D1
	BHS.W	PED_DeleteDisk
	CMP.W	#23,D1
	BHS.W	PED_Delete
	CMP.W	#12,D1
	BHS.W	PED_Insert
	BRA.W	PED_AddPathGadg

PED_Menu2
	CMP.W	#210,D0
	BHS.B	PED_Menu3
	CMP.W	#34,D1
	BHS.W	PED_ClearPLST
	CMP.W	#23,D1
	BHS.W	Return3
	CMP.W	#12,D1
	BHS.W	PED_Disk
	BRA.W	PED_EnterPath

PED_Menu3
	CMP.W	#34,D1
	BHS.W	PED_Print
	CMP.W	#23,D1
	BHS.W	WritePLST
	CMP.W	#12,D1
	BHS.B	xLoadPLST
	BRA.W	PED_EnterPath

xLoadPLST
	BSR.W	LoadPLST
	CLR.W	PEDpos
	BRA.W	PED_Refresh

PED_GotoPLST
	BSR.B	PED_Exit
	BRA.W	PLST

PED_Exit
	JSR	WaitForButtonUp
	BSR.W	PLSTCheckNum
	BSR.W	SwapPresEdScreen
	LEA	TextBitplane,A0
	MOVE.W	#1220-1,D0
	MOVEQ	#0,D1
pedeloop
	MOVE.L	D1,(A0)+
	DBRA	D0,pedeloop
	CLR.B	RawKeyCode
pedexi2	JSR	ClearAnalyzerColors
	JMP	DisplayMainAll

PED_AddPathGadg
	TST.L	PLSTmem
	BNE.B	pedawok
	BSR.W	AllocPLST
	TST.L	PLSTmem
	BEQ.W	PLSTMemErr
pedawok	MOVE.L	DOSBase(PC),A6
	MOVE.L	#PEdDefaultPath,D1
	MOVEQ	#-2,D2
	JSR	_LVOLock(A6)
	MOVE.L	D0,FileLock
	BEQ.W	UnlockReadPath
	JSR	SetDiskPtrCol
	LEA	AddingPathText(PC),A0
	BSR.W	ShowStatusText
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileLock(PC),D1
	MOVE.L	#FileInfoBlock,D2
	JSR	_LVOExamine(A6)
	TST.L	D0
	BPL.W	UnlockReadPath
	TST.L	FIB_EntryType
	BPL.B	CheckPathDirName
	BSR.W	AddPreset
	BRA.B	IsPLSTfull

CheckPathDirName
	CMP.B	#'-',FIB_FileName+2
	BNE.B	IsPLSTfull
	MOVE.B	FIB_FileName+3,SndDiskNum0
	MOVE.B	FIB_FileName+4,SndDiskNum1
	BSR.W	ShowPEDnumbers
IsPLSTfull
	MOVE.W	PresetTotal(PC),D0
	CMP.W	MaxPLSTEntries,D0
	BLO.B	ReadPathNext
	BSR.W	PLSTisFull
	BRA.W	ReadPathEnd

ReadPathNext
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileLock(PC),D1
	MOVE.L	#FileInfoBlock,D2
	JSR	_LVOExNext(A6)
	TST.L	D0
	BPL.W	ReadPathEnd
	BTST	#2,$DFF016	; right mouse button
	BEQ.W	ReadPathEnd
	TST.L	FIB_EntryType
	BPL.B	IsPLSTfull
	CMP.L	#'.inf',FIB_FileName
	BEQ.W	IsPLSTfull
	CMP.L	#'.inf',FIB_FileName+4
	BEQ.W	IsPLSTfull
	LEA	FIB_FileName,A0
	MOVEQ	#29-1,D0
repalop	CMP.B	#'.',(A0)+
	BEQ.W	CouldBeInfo
	DBRA	D0,repalop
rpnskip	CLR.W	PresetRepeat
	MOVE.W	#1,PresetReplen
	TST.B	IFFLoopFlag ; name is ok, test for IFF
	BEQ.W	rpnskp2
	LEA	PEdDefaultPath(PC),A0
	JSR	CopyPath
	LEA	FIB_FileName,A0
rpncpfn	MOVE.B	(A0)+,(A1)+
	BNE.B	rpncpfn
	MOVE.L	#FileName,D1
	MOVE.L	#1005,D2
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.B	rpnskp2
	MOVE.L	D0,D1
	LEA	chkiffbuffer(PC),A2
	CLR.L	(A2)
	MOVE.L	A2,D2
	MOVEQ	#12,D3
	JSR	_LVORead(A6)
	CMP.L	#"FORM",(A2)
	BNE.B	rpnclse
	CMP.L	#"8SVX",8(A2)
	BNE.B	rpnclse
rpnvhdr	MOVE.L	FileHandle(PC),D1
	MOVE.L	A2,D2
	MOVEQ	#4,D3
	JSR	_LVORead(A6)
	TST.L	D0
	BEQ.B	rpnclse
	CMP.L	#"VHDR",(A2)
	BNE.B	rpnvhdr
	MOVE.L	FileHandle(PC),D1
	MOVE.L	A2,D2
	MOVEQ	#12,D3
	JSR	_LVORead(A6)
	MOVE.L	8(A2),D0
	BEQ.B	rpnclse
	LSR.W	#1,D0
	MOVE.W	D0,PresetReplen
	MOVE.L	4(A2),D0
	LSR.W	#1,D0
	MOVE.W	D0,PresetRepeat
rpnclse	MOVE.L	FileHandle(PC),D1
	JSR	_LVOClose(A6)
rpnskp2	BSR.B	AddPreset
	BSR.W	ShowPEDnumbers
	BRA.W	IsPLSTfull

	CNOP 0,4
chkiffbuffer
	dc.l 0,0,0

CouldBeInfo
	CMP.B	#'i',(A0)+
	BNE.W	rpnskip
	CMP.B	#'n',(A0)+
	BNE.W	rpnskip
	CMP.B	#'f',(A0)+
	BNE.W	rpnskip
	CMP.B	#'o',(A0)+
	BNE.W	rpnskip
	TST.B	(A0)+
	BNE.W	rpnskip
	BRA.W	IsPLSTfull

ReadPathEnd
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileLock(PC),D1
	BEQ.B	rpeskip
	JSR	_LVOUnLock(A6)
rpeskip	JSR	SetNormalPtrCol
	BSR.W	ShowPresetNames
	BRA.W	ShowAllRight

UnlockReadPath
	MOVE.L	DOSBase(PC),A6
	MOVE.L	FileLock(PC),D1
	BEQ.B	urpend
	JSR	_LVOUnLock(A6)
urpend	JMP	SetErrorPtrCol

AddPreset
	LEA	PEdDefaultVol(PC),A0

	LEA	PresetName(PC),A1
	MOVEQ	#6-1,D0	; Disk ST-XX:
aploop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,aploop
	
	LEA	FIB_FileName,A0
	MOVEQ	#15-1,D0	; Name 16 letters.
aploop2	MOVE.B	(A0)+,(A1)+
	BNE.B	.skip
	SUBQ.L	#1,A0
.skip	DBRA	D0,aploop2
	CLR.B	(A1)
	
	MOVE.L	FIB_FileSize,D0
	CMP.L	#$FFFE,D0
	BLS.B	apskip2
	MOVE.W	#$FFFE,D0
apskip2	LSR.W	#1,D0
	MOVE.W	D0,PresetLength
	CLR.W	PresetFineTune
	LEA	PresetName(PC),A6
	BSR.W	PED_CheckAdd
	ADDQ.W	#1,PresetTotal
	ADD.L	#30,MaxPLSTOffset
	RTS

PED_Insert
	TST.L	PLSTmem
	BNE.B	pediwok
	BSR.W	AllocPLST
	TST.L	PLSTmem
	BEQ.W	PLSTMemErr
pediwok	MOVE.W	PresetTotal(PC),D0
	CMP.W	MaxPLSTEntries2(PC),D0
	BHS.W	PLSTisFull
	LEA	InsertPsetText(PC),A0
	LEA	PresetName(PC),A1
	MOVEQ	#40-1,D0
pediloop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,pediloop
PossibleEdit
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	LEA	TextBitplane+2320,A0
	MOVEQ	#60-1,D0
	MOVEQ	#0,D1
pediloop2
	MOVE.L	D1,(A0)+
	DBRA	D0,pediloop2
	LEA	EnterDataText(PC),A0
	BSR.W	ShowStatusText
	MOVE.W	#63,LineCurY
	LEA	PresetName(PC),A6
	MOVEQ	#3,D7
	MOVE.B	#4,EnterTextFlag
ShowPsetText
	LEA	PresetName+3(PC),A0
	MOVEQ	#37,D0
	MOVE.W	#2321,D1
	BSR.W	ShowText3
	MOVE.W	D7,D0
	SUBQ.W	#3,D0
	LSL.W	#3,D0
	ADD.W	#12,D0
	MOVE.W	D0,LineCurX
	JSR	UpdateLineCurPos
pediwaitkey
	JSR	DoKeyBuffer
	MOVE.B	RawKeyCode(PC),D0
	BEQ.B	pediwaitkey
	CLR.B	RawKeyCode
	BTST	#7,D0
	BNE.B	pediwaitkey
	AND.W	#$FF,D0
	CMP.B	#69,D0
	BEQ.W	PED_ESCkey
	CMP.B	#65,D0
	BEQ.W	PED_BkspaceKey
	CMP.B	#68,D0
	BEQ.B	PED_ReturnKey
	CMP.B	#79,D0
	BEQ.W	PED_LeftArrowKey
	CMP.B	#78,D0
	BEQ.W	PED_RightArrowKey
	CMP.B	#64,D0
	BHI.B	pediwaitkey
	CMP.W	#40,D7
	BEQ.B	pediwaitkey
	CMP.W	#22,D7
	BEQ.B	pediwaitkey
	LEA	UnshiftedKeymap(PC),A0
	TST.W	ShiftKeyStatus
	BEQ.B	ShiftKeySkip
	LEA	ShiftedKeymap(PC),A0
ShiftKeySkip
	MOVE.B	(A0,D0.W),D1
	BEQ.B	pediwaitkey
	
	CMP.W	#6,D7
	BLO.B	hexchk2
	CMP.W	#25,D7
	BLO.B	PED_PrintChar
hexchk2	CMP.B	#'0',D1
	BLO.B	pediwaitkey
	CMP.B	#'f',D1
	BHI.W	pediwaitkey
	CMP.B	#'9',D1
	BLS.B	PED_PrintChar
	CMP.B	#'a',D1
	BHS.B	PED_PrintChar
	BRA.W	pediwaitkey

PED_PrintChar
	MOVE.B	D1,(A6,D7.W)
	BRA.W	PED_RightArrowKey

PED_ReturnKey
	CMP.B	#' ',PsetNameText
	BEQ.B	PED_ESCkey
	LEA	PsetVolText(PC),A0
	LEA	fitutexttab+32(PC),A1
	MOVE.B	(A0)+,D1
	LSL.W	#8,D1
	MOVE.B	(A0),D1
	MOVEQ	#16-1,D0
vofloop	CMP.W	-(A1),D1
	BEQ.B	vofound
	DBRA	D0,vofloop
	MOVEQ	#0,D0
vofound	MOVE.W	D0,PresetFineTune
	LEA	PsetLenText(PC),A0
	BSR.W	HexToInteger
	LSR.W	#1,D0
	MOVE.W	D0,PresetLength
	LEA	PsetRepeatText(PC),A0
	BSR.W	HexToInteger
	LSR.W	#1,D0
	MOVE.W	D0,PresetRepeat
	LEA	PsetReplenText(PC),A0
	BSR.W	HexToInteger
	LSR.W	#1,D0
	MOVE.W	D0,PresetReplen
	BSR.W	PED_CheckAdd
	ADDQ.W	#1,PresetTotal
PED_ESCkey
	CLR.W	LineCurX
	MOVE.W	#270,LineCurY
	JSR	UpdateLineCurPos
	BSR.W	ShowAllRight
	CLR.B	EnterTextFlag
	BRA.W	PED_Refresh

PED_BkspaceKey
	CMP.W	#23,D7
	BHS.B	pedbsend
	CMP.W	#6,D7
	BLS.B	pedbsend
	SUBQ.W	#1,D7
	MOVE.B	#' ',(A6,D7.W)
pedbsend
	BRA.W	ShowPsetText

PED_LeftArrowKey
	SUBQ.W	#1,D7
	CMP.W	#2,D7
	BLS.B	pedlakskip2
	CMP.W	#5,D7
	BEQ.B	pedlakskip
	CMP.W	#22,D7
	BEQ.B	pedlakskip
	CMP.W	#25,D7
	BEQ.B	pedlakskip
	CMP.W	#30,D7
	BEQ.B	pedlakskip
	CMP.W	#35,D7
	BEQ.B	pedlakskip
	BRA.W	ShowPsetText

pedlakskip
	SUBQ.W	#1,D7
	BRA.W	ShowPsetText

pedlakskip2
	MOVEQ	#3,D7
	BRA.W	ShowPsetText

PED_RightArrowKey
	ADDQ.W	#1,D7
	CMP.W	#5,D7
	BEQ.B	pedrakskip
	CMP.W	#22,D7
	BEQ.B	pedrakskip
	CMP.W	#25,D7
	BEQ.B	pedrakskip
	CMP.W	#30,D7
	BEQ.B	pedrakskip
	CMP.W	#35,D7
	BEQ.B	pedrakskip
	CMP.W	#40,D7
	BHS.B	pedrakskip2
	BRA.W	ShowPsetText

pedrakskip
	ADDQ.W	#1,D7
	BRA.W	ShowPsetText

pedrakskip2
	MOVEQ	#39,D7
	BRA.W	ShowPsetText

PED_CheckAdd
	MOVEQ	#23,D0
pedcaloop
	SUBQ.W	#1,D0
	CMP.B	#' ',(A6,D0.W)
	BEQ.B	pedcaloop
	CLR.B	1(A6,D0.W)
	MOVE.L	PLSTmem(PC),A5
pedccnextloop
	MOVEQ	#6,D0
	TST.B	6(A5)
	BEQ.B	PED_AddPreset
PED_ConvertLoop
	MOVE.B	(A5,D0.W),D2
	BNE.B	PED_ConvertCase
	TST.B	(A6,D0.W)
	BNE.B	PED_ConvertCase
	CLR.B	6(A5)
	SUBQ.W	#1,PresetTotal
	BRA.B	PED_AddPreset

PED_ConvertCase
	CMP.B	#'A',D2
	BLO.B	pedccskip
	CMP.B	#'Z',D2
	BHI.B	pedccskip
	ADD.B	#32,D2
pedccskip
	MOVE.B	(A6,D0.W),D1
	CMP.B	#' ',D1
	BEQ.B	pedccskip3
	CMP.B	#'A',D1
	BLO.B	pedccskip2
	CMP.B	#'Z',D1
	BHI.B	pedccskip2
	ADD.B	#32,D1
pedccskip2
	CMP.B	D2,D1
	BEQ.B	pedccnext
	BHI.B	pedccskip3
	BRA.B	PED_AddPreset

pedccnext
	ADDQ.W	#1,D0
	CMP.W	#22,D0
	BNE.B	PED_ConvertLoop
pedccskip3
	LEA	30(A5),A5
	BRA.B	pedccnextloop

PED_AddPreset
	TST.B	6(A5)
	BEQ.B	pedapskip
	MOVE.L	PLSTmem(PC),A1
	MOVE.W	PresetTotal(PC),D0
	BEQ.B	pedapskip
	MULU.W	#30,D0
	ADD.L	D0,A1
	LEA	30(A1),A1
	CLR.B	31(A1)
pedaploop
	MOVE.W	(A1),30(A1)
	SUBQ.L	#2,A1
	CMP.L	A1,A5
	BLS.B	pedaploop
pedapskip
	MOVEQ	#22-1,D0
pedaploop2
	MOVE.B	(A6,D0.W),D1
	CMP.B	#'A',D1
	BLO.B	pedapskip2
	CMP.B	#'Z',D1
	BHI.B	pedapskip2
	ADD.B	#32,D1
pedapskip2
	CMP.B	#' ',D1
	BNE.B	pedapskip3
	MOVEQ	#0,D1
pedapskip3
	MOVE.B	D1,(A5,D0.W)
	DBRA	D0,pedaploop2
	MOVE.W	PresetLength(PC),22(A5)
	MOVE.B	PresetFineTune+1(PC),24(A5)
	MOVE.B	#$40,25(A5)
	MOVE.W	PresetRepeat(PC),26(A5)
	MOVE.W	PresetReplen(PC),28(A5)
	RTS

HexToInteger
	MOVEQ	#0,D0
	BSR.B	Single_hti
	LSL.W	#8,D1
	LSL.W	#4,D1
	OR.W	D1,D0
	BSR.B	Single_hti
	LSL.W	#8,D1
	OR.W	D1,D0
HexToInteger2
	BSR.B	Single_hti
	LSL.W	#4,D1
	OR.W	D1,D0
	BSR.B	Single_hti
	OR.W	D1,D0
	RTS

Single_hti
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	CMP.B	#$60,D1
	BLO.B	shtiskip
	SUB.B	#$20,D1
shtiskip
	SUB.B	#$30,D1
	CMP.B	#9,D1
	BLS.W	Return3
	SUBQ.B	#7,D1
	RTS

PED_Delete
	JSR	SetDeletePtrCol
	MOVE.W	#1,PED_Action
	LEA	SelectEntryText(PC),A0
	BRA.W	ShowStatusText

PED_ClearPLST
	LEA	ClearPLSTText(PC),A0
	JSR	AreYouSure
	BNE.W	Return3
	BSR.W	FreePLST
	BRA.W	PED_Refresh

ClearPLSTText	dc.b 'clear plst ?',0
	EVEN

PED_Print
	LEA	PrintPLSTText(PC),A0
	JSR	AreYouSure
	BNE.W	Return3
	JSR	StorePtrCol
	MOVE.L	DOSBase(PC),A6
	MOVE.L	#PrintPath,D1
	MOVE.L	#1006,D2
	JSR	_LVOOpen(A6)
	MOVE.L	D0,FileHandle
	BEQ.W	CantOpenFile
	JSR	SetDiskPtrCol
	MOVE.L	D0,D1
	MOVE.L	#PsetPLSTtext,D2
	MOVEQ	#56,D3
	JSR	_LVOWrite(A6)
	LEA	PrintingPLSTText(PC),A0
	BSR.W	ShowStatusText
	CLR.W	PsetNumTemp
pedpmloop
	MOVE.W	PsetNumTemp(PC),D0
	LEA	PsetPrtNumText(PC),A0
	BSR.W	IntToDecASCII
	MOVE.L	PLSTmem(PC),A0
	MOVE.W	PsetNumTemp(PC),D0
	MULU.W	#30,D0
	ADD.L	D0,A0
	MOVE.L	A0,PsetPtrTemp
	LEA	PsetPrtNameText(PC),A1
	MOVE.L	A1,A2
	MOVEQ	#20-1,D1
FillSpaceLoop
	MOVE.B	#' ',(A2)+
	DBRA	D1,FillSpaceLoop
	MOVEQ	#20-1,D1
pedploop
	TST.B	(A0)
	BEQ.B	pedpskip
	MOVE.B	(A0)+,(A1)+
	DBRA	D1,pedploop
pedpskip
	MOVE.L	PsetPtrTemp(PC),A1
	MOVE.W	22(A1),D0
	LEA	PsetPrtLenText(PC),A0
	BSR.W	IntToHexASCII
	MOVE.L	PsetPtrTemp(PC),A1
	MOVE.W	26(A1),D0
	LEA	PsetPrtRepeatText(PC),A0
	BSR.W	IntToHexASCII
	MOVE.L	PsetPtrTemp(PC),A1
	MOVE.W	28(A1),D0
	ADD.W	D0,D0
	LEA	PsetPrtRepLenText(PC),A0
	BSR.B	IntToHexASCII
	MOVE.L	FileHandle(PC),D1
	MOVE.L	#PsetPrtNumText,D2
	MOVEQ	#53,D3
	JSR	_LVOWrite(A6)
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	AbortPLSTPrint
	ADDQ.W	#1,PsetNumTemp
	MOVE.W	PsetNumTemp(PC),D0
	CMP.W	PresetTotal(PC),D0
	BNE.W	pedpmloop
	BRA.B	pedpend

AbortPLSTPrint
	LEA	OprAbortedText(PC),A0
	BSR.W	ShowStatusText
	JSR	SetErrorPtrCol
pedpend	MOVE.L	FileHandle(PC),D1
	JSR	_LVOClose(A6)
	BSR.W	ShowAllRight
	JMP	RestorePtrCol

IntToDecASCII
	MOVEQ	#4-1,D3
	MOVE.L	#1000,D2
itdloop	EXT.L	D0
	DIVU.W	D2,D0
	ADD.B	#'0',D0
	MOVE.B	D0,(A0)+
	DIVU.W	#10,D2
	SWAP	D0
	DBRA	D3,itdloop
	RTS

IntToHex2
	MOVEQ	#1,D2
	BRA.B	ithaloop

IntToHexASCII
	MOVEQ	#4-1,D2
ithaloop
	MOVE.W	D0,D1
	AND.B	#15,D1
	CMP.B	#10,D1
	BLO.B	ithaskip
	ADDQ.B	#7,D1
ithaskip
	ADD.B	#'0',D1
	MOVE.B	D1,-(A0)
	ROR.W	#4,D0
	DBRA	D2,ithaloop
	RTS

WritePLST
	LEA	SavePLSTText(PC),A0
	JSR	AreYouSure
	BNE.W	Return3
	JSR	StorePtrCol
	JSR	SetDiskPtrCol
	LEA	SavingPLSTText(PC),A0
	BSR.W	ShowStatusText
	LEA	PTPath,A0
	JSR	CopyPath
	LEA	PLSTname(PC),A0
	MOVEQ	#5-1,D0
dsploop	MOVE.B	(A0)+,(A1)+
	DBRA	D0,dsploop
	MOVE.L	#FileName,D1
	MOVE.L	#1006,D2
	MOVE.L	DOSBase(PC),A6
	JSR	_LVOOpen(A6)
	MOVE.L	D0,D7
	BEQ.W	CantOpenFile
	MOVE.L	D0,D1
	MOVE.L	PLSTmem(PC),D2
	MOVE.W	PresetTotal(PC),D3
	MULU.W	#30,D3
	MOVE.L	D3,-(SP)
	JSR	_LVOWrite(A6)
	CMP.L	(SP)+,D3
	BEQ.B	wplstskip
	BSR.W	CantSaveFile
wplstskip
	MOVE.L	D7,D1
	JSR	_LVOClose(A6)
	BSR.W	ShowAllRight
	JMP	RestorePtrCol

xDoCheckGadgets2	JMP	DoCheckGadgets2

CheckPEDnames
	CMP.W	#307,D0
	BLO.W	PED_PsetHit
	CLR.W	PED_Action
	JSR	SetNormalPtrCol
	CMP.W	#122,D1
	BHS.B	xDoCheckGadgets2
	CMP.W	#111,D1
	BHS.W	PED_Bottom
	CMP.W	#100,D1
	BHS.W	PED_OneDown
	CMP.W	#67,D1
	BHS.W	PED_Exit
	CMP.W	#56,D1
	BHS.B	PED_OneUp

	BTST	#2,$DFF016	; right mouse button
	BEQ.B	lbC0119AE	
PED_Top
	CLR.W	PEDpos
	BRA.W	ShowPresetNames
	
lbC0119AE
	MOVE.L	PLSTmem(PC),A1
	MOVE.W	PEDpos(PC),D0
	MULU.W	#30,D0
	MOVE.B	6(A1,D0.L),D1
lbC0119C0	
	SUB.L	#30,D0
	BMI.B	PED_Top
	MOVE.B	6(A1,D0.L),D2
	CMP.B	D1,D2
	BEQ.B	lbC0119C0
	MOVE.B	D2,D1
lbC0119D2
	SUB.L	#30,D0
	BMI.B	PED_Top
	MOVE.B	6(A1,D0.L),D2
	CMP.B	D1,D2
	BEQ.B	lbC0119D2
	DIVU.W	#30,D0
	ADDQ.W	#1,D0
	BRA.B	pdodsx

PED_OneUp
	ST	SetSignalFlag
	SUBQ.W	#1,PEDpos
	TST.W	ShiftKeyStatus
	BNE.B	poup2
	BTST	#2,$DFF016	; right mouse button
	BNE.B	pdouskip
poup2	SUBQ.W	#7,PEDpos
pdouskip
	TST.W	PEDpos
	BGE.W	ShowPresetNames
	BRA.B	PED_Top

PED_OneDown
	ST	SetSignalFlag
	CMP.W	#10,PresetTotal
	BLO.W	ShowPresetNames
	ADDQ.W	#1,PEDpos
	TST.W	ShiftKeyStatus
	BNE.B	podn2
	BTST	#2,$DFF016	; right mouse button
	BNE.B	pdodskip
podn2	ADDQ.W	#7,PEDpos
pdodskip
	MOVE.W	PresetTotal(PC),D0
	SUB.W	#10,D0
	CMP.W	PEDpos(PC),D0
	BHS.B	ShowPresetNames
pdodsx	MOVE.W	D0,PEDpos
	BRA.B	ShowPresetNames

PED_Bottom
	BTST	#2,$DFF016	; right mouse button
	BEQ.B	.L0
	MOVE.W	PresetTotal(PC),D0
	SUB.W	#11,D0
	BMI.W	PED_Top
	ADDQ.W	#1,D0
	BRA.B	pdodsx
.L0	MOVE.L	PLSTmem(PC),A1
	MOVE.W	PEDpos(PC),D0
	MULU.W	#30,D0
	MOVE.B	6(A1,D0.L),D1
.loop	ADD.L	#30,D0
	MOVE.W	PresetTotal(PC),D2
	SUB.W	#10,D2
	BMI.W	Return3
	MULU.W	#30,D2
	CMP.L	D2,D0
	BLS.B	.L1
	MOVE.L	D2,D0
	DIVU.W	#30,D0
	BRA.B	pdodsx
.L1	MOVE.B	6(A1,D0.L),D2
	CMP.B	D1,D2
	BEQ.B	.loop
	DIVU.W	#30,D0
	MOVE.W	D0,PEDpos
	
ShowPresetNames
	MOVE.W	#2321,D6
	MOVEQ	#10-1,D7
	MOVE.L	PLSTmem(PC),D0
	BEQ.W	Return3
	MOVE.L	D0,A5
	MOVE.W	PEDpos(PC),D0
	MULU.W	#30,D0
	ADD.L	D0,A5
spndploop
	TST.B	(A5)
	BEQ.W	Return3
	LEA	PresetNameText,A1
	MOVEQ	#22-1,D0
spnloop	MOVE.B	#' ',(A1)+
	DBRA	D0,spnloop
	MOVE.L	A5,A0
	ADDQ	#3,A0
	LEA	-22(A1),A1
spnloop2
	MOVE.B	(A0)+,D0
	BEQ.B	DisplayPreset
	MOVE.B	D0,(A1)+
	BRA.B	spnloop2

fitutexttab
	dc.b " 0+1+2+3+4+5+6+7-8-7-6-5-4-3-2-1"
	EVEN

DisplayPreset
	MOVEQ	#19,D0
	LEA	PresetNameText,A0
	MOVE.W	D6,D1
	BSR.W	ShowText3
	ADD.W	#20,D6
	MOVE.W	D6,TextOffset
	MOVEQ	#0,D0
	MOVE.B	24(A5),D0
	AND.B	#$0F,D0
	ADD.W	D0,D0
	LEA	fitutexttab(PC,D0.W),A0
	MOVE.W	#2,TextLength
	BSR.W	ShowText2
	MOVE.W	22(A5),D0
	ADD.W	D0,D0
	MOVE.W	D0,WordNumber
	ADDQ.W	#1,TextOffset
	BSR.W	PrintHexWord
	MOVE.W	26(A5),D0
	ADD.W	D0,D0
	MOVE.W	D0,WordNumber
	ADDQ.W	#1,TextOffset
	BSR.W	PrintHexWord
	MOVE.W	28(A5),D0
	ADD.W	D0,D0
	MOVE.W	D0,WordNumber
	ADDQ.W	#1,TextOffset
	BSR.W	PrintHexWord
	ADD.W	#220,D6   ; 218
	LEA	30(A5),A5
	DBRA	D7,spndploop
	RTS

PED_EnterPath
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	CLR.L	EditMode
	LEA	PEdDefaultPath(PC),A6
	JSR	UpdateLineCurPos
	MOVE.L	A6,TextEndPtr
	MOVE.L	A6,ShowTextPtr
	ADD.L	#31,TextEndPtr
	MOVE.W	#20,TextLength
	MOVEA.W	#178,A4
	BSR.W	GetTextLine
	CLR.L	TextEndPtr
	JMP	RestorePtrCol

PED_Disk
	JSR	SetWaitPtrCol
	CLR.L	EditMode
	MOVE.W	#621,TextOffset
	JSR	GetHexByte
	TST.W	AbortHexFlag
	BNE.B	peddskip
	MOVE.W	D0,D1
	LSR.W	#4,D0
	AND.W	#15,D1
	LEA	HexTable(PC),A0
	MOVE.B	(A0,D0.W),SndDiskNum0
	MOVE.B	(A0,D1.W),SndDiskNum1
	MOVE.B	#':',SndDiskNum0+2
	CLR.B	EnterTextFlag
peddskip
	BSR.B	ShowPEDnumbers
	JMP	SetNormalPtrCol

ShowPEDnumbers
	MOVE.W	PresetTotal(PC),WordNumber
	MOVE.W	#1061,TextOffset
	BSR.W	Print4DecDigits
	LEA	PEdDefaultPath(PC),A0
	MOVE.W	#178,D1
	MOVEQ	#20,D0
	BSR.W	ShowText3
	LEA	PEdDefaultVol(PC),A0
	MOVE.W	#618,D1
	MOVEQ	#6,D0
	BRA.W	ShowText3

PED_PsetHit
	CMP.W	#122,D1
	BHS.W	xDoCheckGadgets2
	TST.W	PresetTotal
	BEQ.B	pedphend
	MOVEQ	#0,D0	; --PT2.3D bug fix: fix PSED mouse weirdness
	MOVE.W	MouseY2(PC),D0
	CMP.W	#58,D0	; --PT2.3D bug fix: 58, not 59
	BLO.B	pedphend
	CMP.W	#119,D0
	BHS.B	pedphend
	SUB.W	#58,D0	; --PT2.3D bug fix: 58, not 59
	AND.L	#$FFFF,D0
	DIVU.W	#6,D0
	MOVE.L	D0,D1
	SWAP	D1
	CMP.W	#5,D1
	BEQ.B	pedphend
	MOVE.W	D0,D2
	ADD.W	PEDpos(PC),D2
	CMP.W	PresetTotal(PC),D2
	BGE.B	pedphend
	MULU.W	#30,D0
	MOVE.L	PLSTmem(PC),A5
	ADD.L	D0,A5
	MOVE.W	PEDpos(PC),D0
	MULU.W	#30,D0
	ADD.L	D0,A5
	TST.W	PED_Action
	BEQ.B	PED_CopyName
	CMP.W	#1,PED_Action
	BEQ.B	PED_DoDelete
pedphend
	RTS

PED_CopyName
	LEA	PresetName(PC),A0
	MOVEQ	#22-1,D0
pedcnloop
	MOVE.B	(A5)+,D1
	BNE.B	pedcnskip
	MOVE.B	#' ',D1
pedcnskip
	MOVE.B	D1,(A0)+
	DBRA	D0,pedcnloop
	MOVEQ	#0,D0
	MOVE.B	2(A5),D0
	AND.B	#$0F,D0
	ADD.W	D0,D0
	LEA	fitutexttab(PC),A1
	LEA	(A1,D0.W),A1
	LEA	PsetVolText(PC),A0
	MOVE.B	#' ',-1(A0)
	MOVE.B	(A1)+,(A0)+
	MOVE.B	(A1),(A0)
	MOVE.W	(A5),D0
	ADD.W	D0,D0
	ADDQ	#6,A0
	BSR.W	IntToHexASCII
	MOVE.W	4(A5),D0
	ADD.W	D0,D0
	LEA	9(A0),A0
	BSR.W	IntToHexASCII
	LEA	9(A0),A0
	MOVE.W	6(A5),D0
	ADD.W	D0,D0
	BSR.W	IntToHexASCII
	BRA.W	PossibleEdit

PED_DoDelete
	CLR.W	PED_Action
	LEA	DeletePresetText(PC),A0
	JSR	AreYouSure
	BNE.B	pedddno	; --PT2.3D bug fix: set normal cursor
	MOVE.L	PLSTmem(PC),A1
	MOVE.W	PresetTotal(PC),D0
	MULU.W	#30,D0
	ADD.L	D0,A1
pedddloop
	MOVE.W	30(A5),(A5)
	ADDQ	#2,A5
	CMP.L	A5,A1
	BHI.B	pedddloop
	CLR.B	(A5)
	SUBQ.W	#1,PresetTotal
	SUB.L	#30,MaxPLSTOffset
	MOVE.W	PEDpos(PC),D0
	ADD.W	#9,D0
	CMP.W	PresetTotal(PC),D0
	BHI.B	pedddskip
	SUBQ.W	#1,PEDpos
	TST.W	PEDpos
	BPL.B	pedddskip
	CLR.W	PEDpos
pedddskip
	BSR.W	ClearPEDText
	BSR.W	ShowPEDnumbers
	BSR.W	ShowPresetNames
	JSR	SetNormalPtrCol
	JMP	StorePtrCol

pedddno	JMP	SetNormalPtrCol

PLSTisFull
	LEA	PLSTFullText(PC),A0
	BSR.W	ShowStatusText
	JMP	SetErrorPtrCol

PED_DeleteDisk
	LEA	DelDiskText(PC),A0
	MOVE.B	SndDiskNum0(PC),10(A0)
	MOVE.B	SndDiskNum1(PC),11(A0)
	JSR	AreYouSure
	BNE.W	Return3
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVE.L	PLSTmem(PC),A0
	MOVE.L	A0,A1
	MOVE.W	PresetTotal(PC),D0
	MULU.W	#30,D0
	ADD.L	D0,A1
	MOVE.L	SndDiskNum0-1(PC),D1
	MOVE.L	#$FF5F5FFF,D2
	AND.L	D2,D1
peddslo	MOVE.L	2(A0),D0
	AND.L	D2,D0
	CMP.L	D1,D0
	BNE.B	peddsno
	MOVE.L	A0,A2
peddslp	MOVE.W	30(A0),(A0)+
	CMP.L	A1,A0
	BLO.B	peddslp
	SUBQ.W	#1,PresetTotal
	SUB.L	#$1E,MaxPLSTOffset
	MOVE.L	A2,A0
	BRA.B	peddsn1
peddsno	LEA	30(A0),A0
peddsn1	CMP.L	A1,A0
	BLO.B	peddslo
	CLR.W	PEDpos
	BSR.W	ClearPEDText
	BSR.W	ShowPEDnumbers
	BSR.W	ShowPresetNames
	JMP	RestorePtrCol

DelDiskText	dc.b "Delete ST-.. ?",0
	EVEN

;************  MIDI Routines  ************

; *   Apollon MIDI Routines V0.2    *
; *  V0.2 04/07-1991 First version  *

_RVOAllocMiscResource =  -6
_RVOFreeMiscResource  = -12

OpenMIDI
	TST.L	MIDIinBuffer
	BNE.B	omidisk
	MOVE.L	#256,D0
	MOVE.L	#MEMF_PUBLIC!MEMF_CLEAR,D1
	JSR	PTAllocMem
	MOVE.L	D0,MIDIinBuffer
	BEQ.W	Return3
omidisk	CLR.B	MIDIinTo
	CLR.B	MIDIinFrom
	
	BSR.B	.GetSer2		;got the port?
	BEQ.B	.end			;yes
	MOVE.L	4.W,A6			;no..try to flush serial.device:
	JSR	_LVOForbid(A6)
	LEA	350(A6),A0		;ExecBase->DeviceList
	LEA	SerDevName(PC),A1	;"serial.device"
	JSR	_LVOFindName(A6)
	TST.L	D0
	BEQ.B	.notfnd			;no serial.device!!
	MOVE.L	D0,A1
	JSR	_LVORemDevice(A6)
.notfnd	JSR	_LVOPermit(A6)
	BSR.B	.GetSer2		;now try it again...
.end	RTS

.GetSer2
	MOVE.L	4.W,A6
	MOVEQ	#0,D0
	LEA	MiscResName(PC),A1
	JSR	_LVOOpenResource(A6)
	MOVE.L	D0,MiscResBase
	BEQ.B	.gs_err
	MOVE.L	D0,A6
	LEA	rb_Progname,A1
	MOVEQ	#0,D0		;serial port
	JSR	_RVOAllocMiscResource(A6)
	TST.L	D0
	BNE.B	.gs_err
	ST	SerPortAlloc
	CLR.W	PrevBits
	MOVE.W	$DFF01C,D0
	BTST	#0,D0
	SNE	PrevBits
	BTST	#11,D0
	SNE	PrevBits+1
	MOVEQ	#0,D0		;TBE
	LEA	MIDIOutInterrupt(PC),A1
	MOVE.L	4.W,A6
	JSR	_LVOSetIntVector(A6)
	MOVE.L	D0,PrevTBE
	MOVEQ	#11,D0		;RBF
	LEA	MIDIInInterrupt(PC),A1
	JSR	_LVOSetIntVector(A6)
	MOVE.L	D0,PrevRBF
	MOVE.W	#114,$DFF032	;set baud rate 114/31250 (SERPER)
	MOVE.W	#$8801,$DFF09A	;RBF & TBE on!!
	MOVEQ	#0,D0
	RTS

.gs_err	MOVEQ	#-1,D0
	RTS
	
;----- Close MIDI and release serial port -----

CloseMIDI
	MOVE.L	MIDIinBuffer(PC),D0
	BEQ.B	clmskip
	MOVE.L	D0,A1
	MOVE.L	#256,D0
	JSR	PTFreeMem
	CLR.L	MIDIinBuffer
clmskip
	TST.L	MiscResBase
	BEQ.B	.fs_end
	TST.B	SerPortAlloc
	BEQ.B	.fs_end
	MOVE.W	#$0801,$DFF09A	;disable RBF & TBE
	MOVE.L	PrevTBE(PC),A1
	MOVEQ	#0,D0
	MOVE.L	4.W,A6
	JSR	_LVOSetIntVector(A6)
	MOVE.L	PrevRBF(PC),A1
	MOVEQ	#11,D0
	JSR	_LVOSetIntVector(A6)
	MOVE.W	#$8000,D0
	TST.B	PrevBits
	BEQ.B	.fs1
	BSET	#0,D0
.fs1	TST.B	PrevBits+1
	BEQ.B	.fs2
	BSET	#11,D0
.fs2	MOVE.W	D0,$DFF09A	;set RBF & TBE to their prev. values
	MOVE.L	MiscResBase(PC),A6
	MOVEQ	#0,D0		;serial port
	JSR	_RVOFreeMiscResource(A6)
	CLR.B	SerPortAlloc
	CLR.B	lastcmdbyte
.fs_end	RTS

;----- Every time we receive a MIDI byte -----

MIDIInIntHandler
	MOVE.W	$DFF018,D0		; read from serdatr
	MOVE.W	#$0800,$DFF09C		; intreq
	MOVE.L	D1,-(SP)
	MOVE.L	D2,-(SP)
	MOVEQ	#0,D1
	MOVE.B	4(A1),D1		; in to
	MOVE.L	D1,D2
	ADDQ.B	#1,D2
	CMP.B	5(A1),D2		; in from
	BEQ.B	gmiexit			; Buffer overflow
	MOVE.L	(A1),A0			; midi in buffer
	MOVE.B	D0,(A0,D1.W)
	MOVE.B	D2,4(A1)		; MIDIinTo
	MOVE.L	#$40000000,D0
	MOVE.L	PTProcess,A1
	JSR	_LVOSignal(A6)
gmiexit	MOVE.L	(SP)+,D2
	MOVE.L	(SP)+,D1
	RTS
	
;----- MIDI Transmit Buffer Empty Interrupt (Output) -----

MIDIOutIntHandler
	MOVE.W	#$4000,intena(A0)	;disable int.
	MOVE.W	#1,intreq(A0)		;clear intreq bit
	RTS

	CNOP 0,4
MIDIOutInterrupt
	dc.l 0,0
	dc.b 2,0
	dc.l MIDIOutName,buffptr,MIDIOutIntHandler
	
	CNOP 0,4
MIDIInInterrupt
	dc.l 0,0
	dc.b 2,0
	dc.l MIDIInName,MIDIinBuffer,MIDIInIntHandler
	
	CNOP 0,4
buffptr		dc.l SerPortAlloc
PrevTBE		dc.l 0
PrevRBF		dc.l 0	
MiscResBase	dc.l 0
SerPortAlloc	dc.b 0
lastcmdbyte	dc.b 0
PrevBits	dc.b 0
MIDIOutName	dc.b 'PT MIDI Out',0
MIDIInName	dc.b 'PT MIDI In',0
MiscResName	dc.b 'misc.resource',0
SerDevName	dc.b 'serial.device',0
	EVEN
		
;----- read from input buffer -----

MIDIin
	MOVE.B	MIDIinFrom(PC),D0
	CMP.B	MIDIinTo(PC),D0
	BNE.B	migetbyt
	MOVEQ	#2,D1
	RTS
migetbyt
	MOVE.L	MIDIinBuffer(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADDQ.B	#1,MIDIinFrom
	MOVEQ	#0,D1
	RTS

CheckMIDIin
	TST.B	MIDIFlag
	BEQ.W	Return3
mic_loop
	BSR.B	MIDIin
	TST.L	D1
	BNE.B	mic_error
	BSR.B	mic_ok
	BRA.B	mic_loop

mic_error
	MOVE.B	#1,MIDIError
	RTS

mic_ok
	CLR.B	MIDIError
	TST.B	D0
	BPL.B	mic_databyte
;statusbyte here
	CMP.B	#$F0,D0
	BHS.W	MIDISysMessage
	MOVE.B	D0,MIDIRunStatus
	MOVE.B	D0,D1
	AND.B	#$F0,D1
	MOVE.B	D1,MIDIRunCommand
	AND.B	#$0F,D0
	MOVE.B	D0,MIDIRunChannel
	CLR.B	MIDIByteCount
	RTS

mic_databyte
	MOVE.B	MIDIRunCommand(PC),D1
	CMP.B	#$80,D1
	BEQ.B	M_NoteOff
	CMP.B	#$90,D1
	BEQ.B	M_NoteOn
	CMP.B	#$A0,D1
	BEQ.W	M_PolyTouch
	CMP.B	#$B0,D1
	BEQ.W	M_Control
	CMP.B	#$C0,D1
	BEQ.W	M_ProgChange
	CMP.B	#$D0,D1
	BEQ.W	M_MonoTouch
	CMP.B	#$E0,D1
	BEQ.W	M_PitchBend
	CMP.B	#$F0,D1
	BEQ.W	M_SysExData
	RTS

M_NoteOff
	TST.B	MIDIByteCount
	BNE.B	mnf_veloc
	MOVE.B	D0,MIDINote
	ADDQ.B	#1,MIDIByteCount
	RTS
mnf_veloc
	CLR.B	MIDIByteCount
	MOVE.B	D0,MIDIVelocity
	RTS

M_NoteOn
	TST.B	MIDIByteCount
	BNE.B	mno_veloc
	MOVE.B	D0,MIDINote
	ADDQ.B	#1,MIDIByteCount
	RTS
mno_veloc
	CLR.B	MIDIByteCount
	MOVE.B	D0,MIDIVelocity
	BEQ.B	mnf_veloc
;* MidiPlay *
	MOVE.B	MIDINote(PC),D0
	CMP.B	MIDIinTrans(PC),D0
	BLO.B	miplskip
	SUB.B	MIDIinTrans(PC),D0
	CMP.B	#36,D0
	BLS.B	J_nkp
	RTS
miplskip
	CMP.B	XMIDI_Play(PC),D0
	BEQ.B	J_PlaySong
	CMP.B	XMIDI_Pattern(PC),D0
	BEQ.B	J_PlayPattern
	CMP.B	XMIDI_Edit(PC),D0
	BEQ.B	J_Edit
	CMP.B	XMIDI_Record(PC),D0
	BEQ.B	J_RecordPattern
	CMP.B	XMIDI_Stop(PC),D0
	BEQ.B	J_StopIt
	CMP.B	XMIDI_SampleDown(PC),D0
	BEQ.B	J_SampleDown
	CMP.B	XMIDI_SampleUp(PC),D0
	BEQ.B	J_SampleUp
	RTS

J_nkp	JMP	nkpskip
J_PlaySong
	JMP	PlaySong
J_PlayPattern
	JMP	PlayPattern
J_Edit	JMP	Edit
J_RecordPattern
	JMP	RecordPattern
J_StopIt
	JMP	StopIt
J_SampleDown	JMP	SampleNumDown
J_SampleUp	JMP	SampleNumUp

MIDIinTrans		dc.b 48,0
XMIDI_Play		dc.b 40 ; E
XMIDI_Pattern		dc.b 38 ; D
XMIDI_Edit		dc.b 43 ; G
XMIDI_Record		dc.b 41 ; F
XMIDI_Stop		dc.b 36 ; C
XMIDI_SampleDown	dc.b 45 ; A
XMIDI_SampleUp		dc.b 47 ; B
			dc.b 0 ; free 0
	EVEN

M_PolyTouch
	TST.B	MIDIByteCount
	BNE.B	mpt_touch
	MOVE.B	D0,MIDINote
	ADDQ.B	#1,MIDIByteCount
	RTS
mpt_touch
	CLR.B	MIDIByteCount
	MOVE.B	D0,MIDITouch
	RTS

M_Control
	TST.B	MIDIByteCount
	BNE.B	mc_value
	MOVE.B	D0,MIDIController
	ADDQ.B	#1,MIDIByteCount
	RTS
mc_value
	CLR.B	MIDIByteCount
	MOVE.B	D0,MIDIlsb
	RTS

M_ProgChange
	MOVE.B	D0,MIDIProgram
	RTS

M_MonoTouch
	MOVE.B	D0,MIDITouch
	RTS

M_PitchBend
	TST.B	MIDIByteCount
	BNE.B	mp_msb
	MOVE.B	D0,MIDIlsb
	ADDQ.B	#1,MIDIByteCount
	RTS
mp_msb	CLR.B	MIDIByteCount
	MOVE.B	D0,MIDImsb
	EXT.W	D0
	SUB.W	#128,D0
	MOVE.W	CurrentPlayNote(PC),D1
	SUB.W	D0,D1
	CMP.W	#113,D1
	BLS.B	mp_2
	MOVE.W	#113,D1
mp_2	MOVE.L	NoteAddr(PC),A0
	MOVE.W	D1,6(A0)
	RTS

	CNOP 0,4
NoteAddr	dc.l 0

M_rts	RTS

MIDISysMessage
	CMP.B	#$F0,D0
	BEQ.B	M_SysEx		; System Exclusive
	CMP.B	#$F1,D0
	BEQ.B	M_rts		; Quarter Frame (MIDI Time Code)
	CMP.B	#$F2,D0
	BEQ.B	M_SongPos	; Song Position Pointer
	CMP.B	#$F3,D0
	BEQ.B	M_SongSelect	; Song Select
	CMP.B	#$F4,D0
	BEQ.B	M_rts		; -Reserved-
	CMP.B	#$F5,D0
	BEQ.B	M_rts		; -Reserved-
	CMP.B	#$F6,D0
	BEQ.B	M_rts		; -Reserved-
	CMP.B	#$F7,D0
	BEQ.B	M_EOX		; End of System Exclusive
	CMP.B	#$F8,D0
	BEQ.B	M_rts		; MIDI Timing Clock
	CMP.B	#$F9,D0
	BEQ.B	M_rts		; -Reserved-
	CMP.B	#$FA,D0
	BEQ.B	M_Start		; Start Message
	CMP.B	#$FB,D0
	BEQ.B	M_Continue	; Continue Message
	CMP.B	#$FC,D0
	BEQ.B	M_Stop		; Stop Message
	CMP.B	#$FD,D0
	BEQ.B	M_rts		; --- Reserved ---
	CMP.B	#$FE,D0
	BEQ.B	M_rts		; Active Sensing (Each 300ms if on)
	CMP.B	#$FF,D0
	BRA.B	M_rts		; System Reset Message

M_SysEx		RTS
M_SysExData	RTS
M_SongPos	RTS
M_SongSelect	RTS
M_EOX		RTS

M_Start		JMP	PlaySong
M_Continue	RTS
M_Stop		JMP	StopIt

	CNOP 0,4
MIDIinBuffer	dc.l 0
MIDIinTo	dc.b 0
MIDIinFrom	dc.b 0
MIDIRunStatus	dc.b $80
MIDIRunChannel	dc.b 0
MIDIRunCommand	dc.b 8
MIDIByteCount	dc.b 0
MIDINote	dc.b 0
MIDIVelocity	dc.b 0
MIDITouch	dc.b 0
MIDIController	dc.b 0
MIDImsb		dc.b 0	
MIDIlsb		dc.b 0
MIDIProgram	dc.b 0
MIDIError	dc.b 0
	EVEN

;---- Sampler Screen ----

SamplerScreen
	CLR.B	RawKeyCode
	JSR	WaitForButtonUp
	TST.W	SamScrEnable
	BNE.B	ExitFromSam
	MOVE.W	#1,SamScrEnable
	MOVE.L	EditMode(PC),SaveEditMode
	CLR.L	EditMode

	MOVE.L	#TextBitplane+5560,D0
	LEA	CopList2Bpl4Ptr,A1
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)
	
	MOVEQ	#0,D0
	MOVE.W	#270,D1
	MOVEQ	#14,D2
	LEA	CursorSpriteData,A0
	BSR.W	SetSpritePos
	JSR	SetSamSpritePtrs
	MOVE.W	CopCol0+16,CopperList2+18
	BSR.W	SwapSamScreen
	BEQ.B	exisam2
	BSR.W	ClearSamScr
	JSR	DoShowFreeMem
	BSR.W	ShowSamNote
	BSR.W	ShowResamNote
	BRA.W	RedrawSample

ExitFromSam
	JSR	WaitForButtonUp
	MOVE.L	SamMemPtr(PC),D0
	BEQ.B	exisam2
	MOVE.L	D0,A1
	BSR.W	Bjarne
	BSR.B	FreeDecompMem2
exisam2	JSR	SetDefSpritePtrs
	CLR.B	RawKeyCode
	CLR.W	SamScrEnable
	MOVEQ	#-1,D0
	MOVE.L	D0,MarkStartOfs
	MOVE.L	SaveEditMode(PC),EditMode
	JSR	SetScreenColors2
	JSR	SetupVUCols
	BSR.W	SetScrPatternPos
	BSR.W	ClearSamScr
	JSR	UpdateCursorPos
	JSR	SetTempo
	BRA.W	RedrawPattern

FreeDecompMem2
	MOVE.L	SamMemPtr(PC),D0
	BEQ.W	Return3
	MOVE.L	D0,A1
	MOVE.L	SamMemSize(PC),D0
	CLR.L	SamMemPtr
	JSR	PTFreeMem
	RTS

Decompact2
	MOVE.L	A0,CompPtr
	MOVE.L	D0,CompLen
	BSR.B	FreeDecompMem2
	MOVE.L	CompPtr,A0
	MOVE.L	(A0),D0
	MOVE.L	D0,SamMemSize
	MOVEQ	#MEMF_PUBLIC,D1
	JSR	PTAllocMem
	MOVE.L	D0,SamMemPtr
	BEQ.W	OutOfMemErr
	MOVE.L	D0,A1
	MOVE.L	CompPtr,A0
	MOVE.L	CompLen,D0
	ADDQ	#4,A0
	SUBQ.L	#4,D0
	MOVE.L	D3,-(SP)
	MOVEQ	#-75,D3	; 181 signed (compactor code)
dcmlop3	MOVE.B	(A0)+,D1
	CMP.B	D3,D1
	BEQ.B	DecodeIt3
	MOVE.B	D1,(A1)+
decom3	SUBQ.L	#1,D0
	BGT.B	dcmlop3
	MOVE.L	(SP)+,D3
	MOVE.L	SamMemPtr(PC),A1
	MOVEQ	#-1,D0
	RTS

DecodeIt3
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
dcdlop3	MOVE.B	D2,(A1)+
	DBRA	D1,dcdlop3
	SUBQ.L	#2,D0
	BRA.B	decom3

SwapSamScreen
	LEA	SampScreenData,A0
	MOVE.L	#SampScreenSize,D0
	BSR.B	Decompact2
	BEQ.W	Return3

bjasize=134*10
Bjarne	LEA	SamScrPos,A0
	MOVEQ	#2-1,D2
BjaLop1	MOVE.W	#bjasize-1,D1 ; 134
BjaLop2	MOVE.L	(A0),D0
	MOVE.L	(A1),(A0)+
	MOVE.L	D0,(A1)+
	DBRA	D1,BjaLop2
	LEA	10240-bjasize*4(A0),A0
	DBRA	D2,BjaLop1
	
	LEA	CopListInsPos,A0
	LEA	CopperList2,A1
	MOVEQ	#30-1,D1
BjaLoop	MOVE.W	(A0),D0
	MOVE.W	(A1),(A0)+
	MOVE.W	D0,(A1)+
	DBRA	D1,BjaLoop
	MOVEQ	#-1,D0
	RTS

ClearSamScr
	MOVE.W	#5121,TextOffset
	MOVE.W	#2,TextLength
	MOVE.L	#blnktxt,ShowTextPtr
	BSR.W	ShowText
	MOVE.W	#4964,TextOffset
	MOVE.W	#3,TextLength
	BSR.W	ShowText

	MOVE.L	#(130*10)-1,D0
	LEA	TextBitplane+5560,A0
	MOVE.L	A0,LineScreenPtr
	MOVEQ	#0,D1
clrsslp
	MOVE.L	D1,(A0)+
	DBRA	D0,clrsslp
	RTS

blnktxt	dc.b "    "
	EVEN

	; --PT2.3D change: heavily modified + some optimizations
ClearSamArea
	MOVEM.L	ClearRegs(PC),D0-D7

	; clear scrollbar background
	LEA	TextBitplane+(5560+2760+(40*3)),A0
	MOVEM.L	D0-D7,-(A0)
	MOVEM.L	D0-D7,-(A0)
	MOVEM.L	D0-D7,-(A0)
	MOVEM.L	D0-D7,-(A0)
	MOVEM.L	D0-D7,-(A0)

	; clear dotted center pattern (different bitplanes)
	LEA	BitplaneData+6800+40,A0
	LEA	BitplaneData+10240+6800+40,A1
	MOVEM.L	D0-D4,-(A0)
	MOVEM.L	D0-D4,-(A1)
	MOVEM.L	D0-D4,-(A0)
	MOVEM.L	D0-D4,-(A1)

	; fix trashed frame pixels on left and right edge
	MOVE.B	#%00000101,39(A0)
	MOVE.B	#%00000011,39(A1)
	MOVE.B	#%10100000,(A0)
	MOVE.B	#%01100000,(A1)

	; clear sample view
	MOVE.W	#((64*10)/8)/4,ClearCounter
	LEA	TextBitplane+5560,A0
	MOVE.L	A0,LineScreenPtr
	LEA	64*10*4(A0),A0
clrsare	MOVEM.L	D0-D7,-(A0)
	MOVEM.L	D0-D7,-(A0)
	MOVEM.L	D0-D7,-(A0)
	MOVEM.L	D0-D7,-(A0)
	SUBQ.W	#1,ClearCounter
	BNE.W	clrsare
	RTS

	CNOP 0,4
ClearRegs	dcb.l 8,0
ClearCounter	dc.w 0

CheckSamGadgets
	MOVE.W	MouseX2(PC),D0
	MOVE.W	MouseY2(PC),D1
	CMP.W	#139,D1
	BLO.B	SamTopBar
	CMP.W	#139+64,D1
	BLO.W	SamplePressed
	CMP.W	#201+11,D1
	BLO.W	SamDragBar
	CMP.W	#201+22,D1
	BLO.B	SamMenu1
	CMP.W	#201+33,D1
	BLO.B	SamMenu2
	CMP.W	#201+44,D1
	BLO.B	SamMenu3
	CMP.W	#201+66,D1
	BLO.W	SamMenu4
	RTS

SamTopBar
	CMP.W	#32,D0
	BLO.W	ExitFromSam
	RTS

SamMenu1
	CMP.W	#32,D0
	BLO.W	Return3
	CMP.W	#96,D0
	BLO.W	PlayWaveform
	CMP.W	#176,D0
	BLO.W	ShowRange
	CMP.W	#246,D0
	BLO.W	ZoomOut
	BRA.W	DispBox

SamMenu2
	CMP.W	#32,D0
	BLO.W	StopPlaying
	CMP.W	#96,D0
	BLO.W	PlayDisplay
	CMP.W	#176,D0
	BLO.W	ShowAll
	CMP.W	#246,D0
	BLO.W	RangeAll
	BRA.W	LoopToggle

SamMenu3
	CMP.W	#32,D0
	BLO.W	StopPlaying
	CMP.W	#96,D0
	BLO.W	PlayRange
	CMP.W	#116,D0
	BLO.W	CurToStart
	CMP.W	#136,D0
	BLO.W	CurToEnd
	CMP.W	#176,D0
	BLO.W	SwapBuffer
	CMP.W	#246,D0
	BLO.W	Sampler
	BRA.W	SetSamNote

SamMenu4
	CMP.W	#32,D0
	BLO.W	SamCut
	CMP.W	#64,D0
	BLO.W	SamCopy
	CMP.W	#96,D0
	BLO.W	SamPaste
	CMP.W	#136,D0
	BLO.W	RampVolume
	CMP.W	#176,D0
	BLO.W	TuningTone
	CMP.W	#246,D0
	BLO.W	Resample
	BRA.W	SetResamNote

PlayWaveform
	; --PT2.3D bug fix: instant channel muting
	LEA	audchan1toggle,A0
	MOVEQ	#0,D0
	MOVE.W	PattCurPos(PC),D0
	DIVU.W	#6,D0
	LSL.B	#3,D0
	MOVE.W	(A0,D0.W),D0
	BEQ.B	pwskip
	JSR	PlayNote
pwskip	JMP	WaitForButtonUp

PlayDisplay
	; --PT2.3D bug fix: instant channel muting
	LEA	audchan1toggle,A0
	MOVEQ	#0,D0
	MOVE.W	PattCurPos(PC),D0
	DIVU.W	#6,D0
	LSL.B	#3,D0
	MOVE.W	(A0,D0.W),D0
	BNE.B	pdskip
	JMP	WaitForButtonUp
pdskip	; ----------------------------------------
	LEA	SampleInfo(PC),A0
	MOVE.L	SamOffset(PC),StartOfs
	MOVE.L	SamDisplay(PC),D0
	LSR.L	#1,D0
	MOVE.W	D0,0(A0)	; length
	CLR.W	4(A0)		; repeat
	MOVE.W	#1,6(A0)	; replen
	MOVE.W	PlayInsNum,D0
	MOVE.W	D0,-(SP)
	MOVE.B	D0,PlayInsNum2
	CLR.W	PlayInsNum
	JSR	PlayNote
	MOVE.W	(SP)+,PlayInsNum
	BSR.W	ShowSampleInfo
	JMP	WaitForButtonUp

PlayRange
	; --PT2.3D bug fix: instant channel muting
	LEA	audchan1toggle,A0
	MOVEQ	#0,D0
	MOVE.W	PattCurPos(PC),D0
	DIVU.W	#6,D0
	LSL.B	#3,D0
	MOVE.W	(A0,D0.W),D0
	BNE.B	prskip
	JMP	WaitForButtonUp
prskip	; ----------------------------------------
	MOVE.L	MarkStartOfs(PC),D1
	BMI.W	NoRangeError
	MOVE.L	MarkEndOfs(PC),D0
	CMP.L	D0,D1
	BEQ.W	LargerRangeError
	LEA	SampleInfo(PC),A0
	MOVE.L	D1,StartOfs
	SUB.L	D1,D0
	LSR.L	#1,D0
	MOVE.W	D0,0(A0)	; length
	CLR.W	4(A0)		; repeat
	MOVE.W	#1,6(A0)	; replen
	MOVE.W	PlayInsNum,D0
	MOVE.W	D0,-(SP)
	MOVE.B	D0,PlayInsNum2
	CLR.W	PlayInsNum
	JSR	PlayNote
	MOVE.W	(SP)+,PlayInsNum
	BSR.W	ShowSampleInfo
	JMP	WaitForButtonUp
StopPlaying
	BRA.W	TurnOffVoices

	CNOP 0,4
StartOfs	dc.l 0

	; This is only called once when the sample view size changes,
	; so speed is not a concern here.
SetSamPosDelta
	MOVEM.L	D0-D1,-(SP)
	MOVE.L	SamDisplay(PC),D0	; 17 bits
	MOVEQ	#15,D1			; max fractional bits (32-17)
	LSL.L	D1,D0
	MOVE.L	#314,D1
	JSR	DIVU32
	MOVE.L	D0,SamPosDelta		; sample pos delta (17.15 fixed-point)
	MOVEM.L	(SP)+,D0-D1
	RTS

ShowRange
	; --PT2.3D bug fix: Show error if trying to zoom on empty sample
	TST.B	EmptySampleFlag
	BNE.W	EmptySampleError
srskip	; --------------------------------------------------------------
	MOVE.L	MarkStartOfs(PC),D0
	BMI.W	NoRangeError
	MOVE.L	MarkEndOfs(PC),D1
	CMP.L	D1,D0
	BEQ.W	LargerRangeError
	SUB.L	D0,D1
	BNE.B	shorano
	MOVEQ	#1,D1
shorano	MOVE.L	D1,SamDisplay
	MOVE.L	D0,SamOffset
	BSR.W	SetSamPosDelta
	MOVEQ	#-1,D0
	MOVE.L	D0,MarkStartOfs
	CLR.W	MarkStart
	BSR.W	DisplaySample
	JMP	WaitForButtonUp

ZoomOut
	MOVE.L	SamDisplay(PC),D0
	MOVE.L	SamLength(PC),D1
	CMP.L	D0,D1
	BEQ.W	Return3 ; don't attempt to zoom out if already 100% zoomed out
	MOVE.L	SamOffset(PC),D2
	MOVE.L	D0,D3
	ADD.L	D3,D3
	CMP.L	D1,D3
	BHI.B	ShowAll
	LSR.L	#1,D0
	CMP.L	D2,D0
	BLO.B	zoomou2
	MOVEQ	#0,D0
zoomou2	SUB.L	D0,D2
	MOVE.L	D2,D0
	ADD.L	D3,D0
	CMP.L	D1,D0
	BLS.B	zoomou3
	SUB.L	D3,D1
	MOVE.L	D1,D2
zoomou3	MOVE.L	D2,SamOffset
	MOVE.L	D3,SamDisplay
	BSR.W	SetSamPosDelta
	BSR.W	OffsetToMark
	MOVE.L	MarkStartOfs(PC),D0
	CMP.L	MarkEndOfs(PC),D0
	BNE.B	zoomouo
	MOVEQ	#-1,D0
	MOVE.L	D0,MarkStartOfs
zoomouo	BSR.W	DisplaySample
	JMP	WaitForButtonUp
	
ShowAll
	CLR.L	SamOffset
	MOVE.L	SamLength(PC),SamDisplay
	BSR.W	SetSamPosDelta
	BSR.W	OffsetToMark
	MOVE.L	MarkStartOfs(PC),D0
	CMP.L	MarkEndOfs(PC),D0
	BNE.B	shoallo
	MOVEQ	#-1,D0
	MOVE.L	D0,MarkStartOfs
	CLR.W	MarkStart
shoallo	BSR.W	DisplaySample
	JMP	WaitForButtonUp

RangeAll
	BSR.W	InvertRange
	MOVE.W	#3,MarkStart
	MOVE.W	#316,MarkEnd
	BSR.W	MarkToOffset
ranall2	BSR.W	InvertRange
	JMP	WaitForButtonUp

CurToStart
	BSR.W	InvertRange
	MOVEQ	#3,D0
	MOVE.W	D0,MarkStart
	MOVE.W	D0,MarkEnd
	MOVE.L	SamOffset(PC),D0
	MOVE.L	D0,MarkStartOfs
	MOVE.L	D0,MarkEndOfs
	BRA.B	ranall2

CurToEnd
	BSR.W	InvertRange
	MOVE.W	#316,D0
	MOVE.W	D0,MarkStart
	MOVE.W	D0,MarkEnd
	MOVE.L	SamOffset(PC),D0
	ADD.L	SamDisplay(PC),D0
	MOVE.L	D0,MarkStartOfs
	MOVE.L	D0,MarkEndOfs
	BRA.B	ranall2

SwapBuffer
	MOVE.W	InsNum(PC),D1
	BEQ.W	NotSampleNull
	LSL.W	#2,D1
	LEA	SongDataPtr(PC),A0
	LEA	(A0,D1.W),A0
	
	MOVE.L	CopyBufPtr(PC),D0
	MOVE.L	(A0),CopyBufPtr
	MOVE.L	D0,(A0)
	MOVE.L	D0,A1
	CLR.W	(A1)
	
	MOVE.L	CopyBufSize(PC),D0
	MOVE.L	124(A0),CopyBufSize
	MOVE.L	D0,124(A0)
	
	MOVE.L	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	MULU.W	#30,D1
	LEA	12(A0,D1.W),A0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)
	MOVE.L	RepBuf(PC),D0
	MOVE.L	4(A0),RepBuf
	MOVE.L	D0,4(A0)
	
	MOVE.W	RepBuf2(PC),D0
	MOVE.W	2(A0),RepBuf2
	TST.B	D0
	BNE.B	swabuf2
	MOVEQ	#$40,D0
swabuf2	MOVE.W	D0,2(A0)
	BSR.W	TurnOffVoices
	BSR.W	ValidateLoops
	BSR.W	ShowSampleInfo
	JSR	UpdateRepeats
	BSR.W	RedrawSample
	JMP	WaitForButtonUp

	CNOP 0,4
RepBuf	dc.l 1
RepBuf2	dc.w $0040

;----

NoRangeError
	LEA	NoRangeText(PC),A0
nres2	BSR.W	ShowStatusText
	JMP	SetErrorPtrCol

LargerRangeError
	LEA	LargerRangeText(PC),A0
	BRA.B	nres2

SetCursorError
	LEA	SetCursorText(PC),A0
	BRA.B	nres2

BufIsEmptyError
	LEA	BufIsEmptyText(PC),A0
	BRA.B	nres2

EmptySampleError
	LEA	EmptySampleText(PC),A0
	BRA.B	nres2

NoRangeText	dc.b "no range selected",0
LargerRangeText	dc.b "set larger range",0
SetCursorText	dc.b "set cursor pos",0
BufIsEmptyText	dc.b "buffer is empty",0
EmptySampleText	dc.b "sample is empty",0

;----

DispBox
	RTS

LoopToggle
	JSR	WaitForButtonUp
	MOVE.W	InsNum(PC),D1
	BEQ.W	NotSampleNull
	MOVE.L	SongDataPtr(PC),A0
	MULU.W	#30,D1
	LEA	12(A0,D1.W),A0
	
	TST.W	(A0)		; sample length == 0?
	BEQ.B	LTSmpEmpty	; yup, don't allow loop toggle...
		
	TST.W	LoopOnOffFlag
	BEQ.B	loopton
	MOVE.L	4(A0),SavSamInf
	MOVEQ	#1,D0
	MOVE.L	D0,4(A0)
	BSR.W	TurnOffVoices
looptlo	BSR.W	ShowSampleInfo
	JSR	UpdateRepeats
	BRA.W	DisplaySample
loopton	BSR.W	TurnOffVoices
	MOVE.L	SavSamInf(PC),D0
	BNE.B	loopto2
	MOVE.W	(A0),D0
loopto2	MOVE.L	D0,4(A0)
	BRA.B	looptlo

LTSmpEmpty	RTS

ShowLoopToggle
	LEA	ToggleOFFText,A0
	TST.W	LoopOnOffFlag
	BEQ.B	sltskip
	LEA	ToggleONText,A0
sltskip	MOVEQ	#3,D0
	MOVE.W	#9076,D1
	BRA.W	ShowText3
	
	CNOP 0,4
SavSamInf	dc.l 0
LoopOnOffFlag	dc.w 0

SetSamNote
	BSR.W	ShowResamNote
	MOVE.W	#9516,TextOffset
	MOVE.W	#3,TextLength
	MOVE.L	#SpcNoteText,ShowTextPtr
	BSR.W	ShowText
	MOVE.W	#1,SamNoteType
	MOVE.L	#SampleNote,SplitAddress
	JMP	WaitForButtonUp

SetResamNote
	BSR.W	ShowSamNote
	MOVE.W	#9956,TextOffset
	MOVE.W	#3,TextLength
	MOVE.L	#SpcNoteText,ShowTextPtr
	BSR.W	ShowText
	MOVE.W	#2,SamNoteType
	MOVE.L	#ResampleNote,SplitAddress
	JMP	WaitForButtonUp

ResampleText	dc.b "Resample?",0
ResamplingText	dc.b "Resampling...",0
	EVEN

	; 128kB compatible and optimized by 8bitbubsy.
	; Almost twice as fast as the original routine,
	; and has slightly better resampling precision.
Resample	
	LEA	ResampleText(PC),A0
	JSR	AreYouSure
	BNE.W	Return3
	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	LEA	ResamplingText(PC),A0
	BSR.W	ShowStatusText
	LEA	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	BEQ.W	NotSampleNull
	LSL.W	#2,D1
	LEA	(A0,D1.W),A0
	MOVE.L	(A0),D0
	BEQ.W	ERC2
	MOVE.L	D0,A2
	MOVE.L	124(A0),D6
	CMP.L	#2,D6
	BLS.W	ERC2

	; get resample (target) period from selected note + finetune
	MOVE.L	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	BNE.B	rssmpok
	MOVE.W	LastInsNum(PC),D1
rssmpok
	MULU.W	#30,D1
	MOVEQ	#0,D0		
	MOVE.B	12+2(A0,D1.W),D0 ; finetune
	AND.B	#$0F,D0
	LSL.B	#2,D0
	LEA	ftunePerTab(PC),A0
	MOVE.L	(A0,D0.W),A0
	
	MOVEQ	#0,D1
	MOVE.W	ResampleNote(PC),D1
	ADD.W	D1,D1
	MOVE.W	(A0,D1.W),D1
	BEQ.W	ERC2	; can't have a resample period of 0!
	; D1.L = resample period (108..907)
	
	; get reference period from tuning note
	LEA	PeriodTable(PC),A0
	MOVEQ	#0,D5
	MOVE.W	TuneNote,D5
	ADD.W	D5,D5
	MOVE.W	(A0,D5.W),D5
	BEQ.W	ERC2	; can't have a reference period of 0!	
	; D5.L = reference period (113..856)

	; calculate resample delta
	MOVE.L	D5,D0
	SWAP	D0
	CLR.W	D0
	JSR	DIVU32
	MOVE.L	D0,D4	
	; D4.L = 16.16fp resampling delta

	; calculate new sample length (write length)
	MOVE.L	D6,D0
	JSR	MULU32
	MOVE.L	D5,D1
	JSR	DIVU32
	MOVE.L	D0,D7
	AND.L	#~1,D7		; evenify
	CMP.L	#$1FFFE,D7
	BHI.B	resamskip
	CMP.L	#2,D7
	BLO.W	ERC2		; can't have a sample length of 2 or shorter!
	BRA.B	resamok
resamskip
	MOVE.L	#$1FFFE,D7	; max sample length
resamok
	; D7 = (oldSampleLen * resamplePeriod) / referencePeriod

	; allocate memory for new sample
	MOVE.L	D7,D0
	MOVE.L	#MEMF_CHIP,D1
	JSR	PTAllocMem
	TST.L	D0
	BEQ.W	SamMemError
	
	MOVE.L	D0,A1
	MOVE.L	D0,A3
	
	; clear last byte (just in case)
	CLR.B	-1(A1,D7.L)

	MOVE.L	A2,A0	; old sample data pointer
	MOVE.L	D6,A6	; old sample length
	MOVE.L	A1,A5
	ADD.L	D7,A5	; new end-of-sample address
	
	MOVEQ	#0,D1	; set frac to 0
	MOVEQ	#0,D6	; set pos to 0
	MOVE.W	D4,D3	; D3.W = delta lo (16-bit)
	CLR.W	D4
	SWAP	D4	; D4.L = delta hi (16-bit)	

	BSR.W	TurnOffVoices

resampleloop
	MOVE.B	(A0,D6.L),D2	; linear interpolation
	EXT.W	D2
	MOVE.B	1(A0,D6.L),D0
	EXT.W	D0
	SUB.W	D2,D0
	MOVE.W	D1,D5
	LSR.W	#1,D5		; D5.W = frac/2 (0..32767)
	MULS.W	D5,D0
	SWAP	D0
	ROL.L	#1,D0
	ADD.W	D0,D2
	MOVE.B	D2,(A1)+
	ADD.W	D3,D1
	ADDX.L	D4,D6
	CMP.L	A5,A1		; destination address beyond end?
	BHS.B	resampledone	; yes, we're done
	CMP.L	A6,D6		; source address beyond end?
	BLO.B	resampleloop	; nope, keep resampling
resampledone
	; free old sample memory
	MOVE.L	A2,A1
	MOVE.L	A6,D0
	JSR	PTFreeMem

	; update sample attributes and redraw sample
	MOVE.W	InsNum(PC),D1
	LSL.W	#2,D1
	LEA	SongDataPtr(PC),A0
	LEA	(A0,D1.W),A0
	MOVE.L	A3,(A0)
	MOVE.L	D7,124(A0)
	MOVE.L	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	MULU.W	#30,D1
	LEA	12(A0,D1.W),A0
	LSR.L	#1,D7		; len/2 -> (A0)
	MOVE.W	D7,(A0)
	CLR.B	2(A0)		; clear finetune
	CLR.W	4(A0)		; clear repeat
	MOVE.W	#1,6(A0)	; replen=1
	JSR	RestorePtrCol
	BSR.W	ClearSamStarts
	BSR.W	ShowSampleInfo
	BSR.W	ShowAllRight
	BRA.W	RedrawSample
	
ERC2
	JMP	ErrorRestoreCol

SamCut	; fixed in PT2.3E to be 128kB compatible
	CLR.B	RawKeyCode
	MOVE.L	MarkStartOfs(PC),D0
	BMI.W	NoRangeError
	CMP.L	MarkEndOfs(PC),D0
	BEQ.W	LargerRangeError
	TST.B	CutToBufFlag
	BEQ.B	samcut2
	BSR.W	SamCopy
samcut2	BSR.W	TurnOffVoices
	LEA	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	BEQ.W	NotSampleNull
	LSL.W	#2,D1
	LEA	(A0,D1.W),A0
	MOVE.L	(A0),D0
	BEQ.W	EmptySampleError
	MOVE.L	124(A0),D2
	CMP.L	#2,D2
	BLO.W	EmptySampleError
	
	MOVE.L	D0,A1
	MOVE.L	D0,A2			; sample start
	MOVE.L	D0,A3
	MOVE.L	D0,A4
	MOVE.L	D0,A5
	ADD.L	MarkStartOfs(PC),A3	; mark start
	MOVE.L	MarkEndOfs(PC),D0
	SUB.L	MarkStartOfs(PC),D0
	CMP.L	D2,D0
	BHS.W	Destroy
	MOVE.L	MarkEndOfs(PC),D0
	CMP.L	D2,D0
	BLO.B	samsome
	MOVE.L	D2,D0
	SUBQ.L	#1,D0
samsome	ADD.L	D0,A4		; mark end
	ADD.L	D2,A5		; sample end
	
	MOVE.L	A3,D0
	SUB.L	A2,D0
	ADD.L	A5,D0
	SUB.L	A4,D0
	BNE.B	sacoklen
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	BRA.B	sacfree

sacoklen
	MOVE.L	D0,D3
	MOVEQ	#MEMF_CHIP,D1
	JSR	PTAllocMem
	MOVE.L	D0,D4
	BEQ.W	OutOfMemErr ; No memory
	
	MOVE.L	D0,A0
	MOVE.L	A2,A1
	MOVE.L	A3,D0
	SUB.L	A2,D0
	BRA.B	sacskp1
saclop1	MOVE.B	(A2)+,(A0)+
sacskp1
	SUBQ.L	#1,D0
	BPL.B	saclop1

	MOVE.L	A5,D0
	SUB.L	A4,D0
	BRA.B	sacskp2
smclop2	MOVE.B	(A4)+,(A0)+
sacskp2
	SUBQ.L	#1,D0
	BPL.B	smclop2

sacfree	MOVE.L	D2,D0
	JSR	PTFreeMem
	
	MOVE.W	InsNum(PC),D1
	LSL.W	#2,D1
	LEA	SongDataPtr(PC),A0
	LEA	(A0,D1.W),A0
	MOVE.L	D4,(A0)
	MOVE.L	D3,124(A0)
	
	MOVE.L	D4,SamStart
	MOVE.L	D3,SamLength
	MOVE.L	SamOffset(PC),D4
	ADD.L	SamDisplay(PC),D4
	CMP.L	D3,D4
	BLO.B	samcuto		; display ok
	MOVE.L	SamDisplay(PC),D4
	CMP.L	D3,D4
	BLO.B	samnils		; if display < length, move offset
samsall	CLR.L	SamOffset	; else show all
	MOVE.L	D3,SamDisplay
	BSR.W	SetSamPosDelta
	BRA.B	samcuto
samnils	MOVE.L	D3,D4
	SUB.L	SamDisplay(PC),D4
	BMI.B	samsall		; if offset < 0, show all
	MOVE.L	D4,SamOffset
samcuto	MOVE.L	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	MULU.W	#30,D1
	LEA	12(A0,D1.W),A0
	
	MOVE.L	D3,D4
	LSR.L	#1,D3
	MOVE.W	D3,(A0)
	MOVE.W	4(A0),D0
	CMP.W	D3,D0
	BLS.B	samcuxx
	MOVEQ	#1,D0
	MOVE.L	D0,4(A0)
	BRA.B	samcuex
samcuxx	ADD.W	6(A0),D0
	CMP.W	D3,D0
	BLS.B	samcuex
	SUB.W	4(A0),D3
	MOVE.W	D3,6(A0)
	
samcuex
	MOVE.L	MarkStartOfs(PC),MarkEndOfs
	BSR.W	ClearSamStarts
	BSR.W	ValidateLoops
	BSR.W	ShowSampleInfo
	BRA.W	DisplaySample

SamCopy	; was already 128kB compliant (wow)
	CLR.B	RawKeyCode
	MOVE.L	MarkStartOfs(PC),D0
	BMI.W	NoRangeError
	CMP.L	MarkEndOfs(PC),D0
	BEQ.W	LargerRangeError
	LEA	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	BEQ.W	NotSampleNull
	LSL.W	#2,D1
	LEA	(A0,D1.W),A0
	MOVE.L	(A0),D0
	BEQ.W	EmptySampleError
	MOVE.L	124(A0),D2
	BEQ.W	EmptySampleError
	MOVE.L	D0,A3
	MOVE.L	D0,A4
	ADD.L	MarkStartOfs(PC),A3	; mark start
	MOVE.L	MarkEndOfs(PC),D0	; mark end
	CMP.L	D2,D0
	BLO.B	csamsom
	MOVE.L	D2,D0
	SUBQ.L	#1,D0
csamsom	ADD.L	D0,A4
	BSR.B	FreeCopyBuf
	MOVE.L	A4,D0
	SUB.L	A3,D0
	ADDQ.L	#1,D0
	MOVE.L	D0,CopyBufSize
	MOVEQ	#MEMF_CHIP,D1
	JSR	PTAllocMem
	MOVE.L	D0,CopyBufPtr
	BEQ.W	OutOfMemErr ; No memory
	MOVE.L	D0,A5
csamlop	MOVE.B	(A3)+,(A5)+
	CMP.L	A4,A3
	BLS.B	csamlop
	BSR.W	InvertRange
	BSR.W	InvertRange
	JMP	WaitForButtonUp

FreeCopyBuf
	MOVE.L	CopyBufPtr(PC),D0
	BEQ.W	Return3
	MOVE.L	D0,A1
	MOVE.L	CopyBufSize(PC),D0
	JSR	PTFreeMem
	CLR.L	CopyBufPtr
	RTS

	CNOP 0,4
CopyBufPtr	dc.l 0
CopyBufSize	dc.l 0

SamPaste	; fixed in PT2.3E to be 128kB compatible
	CLR.B	RawKeyCode
	LEA	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	BEQ.W	NotSampleNull
	LSL.W	#2,D1
	LEA	(A0,D1.W),A0
	MOVEQ	#0,D2
	MOVE.L	(A0),D0
	BEQ.B	sapanul
	MOVE.L	124(A0),D2
sapanul	MOVE.L	D0,A2
	TST.L	D0
	BEQ.B	sepaskip
	MOVE.L	MarkStartOfs(PC),D0
	BMI.W	SetCursorError
sepaskip
	MOVE.L	CopyBufPtr(PC),D3
	BEQ.W	BufIsEmptyError
	MOVE.L	D3,A3
	MOVE.L	CopyBufSize(PC),D3
	BEQ.W	BufIsEmptyError
	
	MOVE.L	D3,D4 ; copysize
	ADD.L	D2,D4 ; + origsize
	CMP.L	#$1FFFE,D4	; 128kb patch
	BLO.B	sapaok
	MOVE.L	#$1FFFE,D4	; 128kb patch
sapaok	MOVE.L	D4,D0
	MOVE.L	#MEMF_CHIP!MEMF_CLEAR,D1
	JSR	PTAllocMem
	TST.L	D0
	BEQ.W	OutOfMemErr
	MOVE.L	D0,A4
	MOVEQ	#0,D0
	TST.L	D2
	BEQ.B	sapask1
	MOVE.L	MarkStartOfs(PC),D0
sapask1	MOVE.L	D0,MarkStartOfs
	MOVE.L	A2,A1
	MOVE.L	D2,D1
	MOVE.L	A4,A5
	MOVE.L	A4,A0
	ADD.L	D4,A0

; D0	= paste position
; A0	= end of new sample
; A1/D1 = copy of A2/D2
; A2/D2 = original sample
; A3/D3 = copy buffer
; A4/D4 = new sample
; A5	= copy of A4
	BRA.B	sapask2
sapalp1	MOVE.B	(A2)+,(A4)+ ; copy first part
	CMP.L	A0,A4
	BHS.B	sapaski
	SUBQ.L	#1,D2
sapask2
	SUBQ.L	#1,D0
	BPL.B	sapalp1
	
	BRA.B	sapask3
sapalp2	MOVE.B	(A3)+,(A4)+ ; copy from buffer
	CMP.L	A0,A4
	BHS.B	sapaski
sapask3
	SUBQ.L	#1,D3
	BPL.B	sapalp2
	TST.L	D2
	BEQ.B	sapaski
	BMI.B	sapaski
sapalp3	MOVE.B	(A2)+,(A4)+ ; copy last part
	CMP.L	A0,A4
	BHS.B	sapaski
	SUBQ.L	#1,D2
	BNE.B	sapalp3
	
sapaski	MOVE.L	D1,D0
	BEQ.B	.skip
	JSR	PTFreeMem
.skip	MOVE.W	InsNum(PC),D1
	LSL.W	#2,D1
	LEA	SongDataPtr(PC),A0
	LEA	(A0,D1.W),A0
	MOVE.L	A5,(A0)
	MOVE.L	D4,124(A0)
	
	MOVE.L	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	MULU.W	#30,D1
	LEA	12(A0,D1.W),A0
	LSR.L	#1,D4
	MOVE.W	D4,(A0)
	
	MOVE.L	MarkStartOfs(PC),MarkEndOfs
	BSR.W	OffsetToMark
	BSR.W	ClearSamStarts
	BSR.W	ShowSampleInfo
	BRA.W	RedrawSample

RampVolume
	BSR.W	HideLoopSprites		; -PT2.3D bug fix
	ST	VolToolBoxShown		; --
	LEA	TextBitplane+6209,A0
	MOVEQ	#33-1,D3
ravlap2	MOVEQ	#17-1,D2
ravlap1	CLR.B	(A0)+
	DBRA	D2,ravlap1
	LEA	23(A0),A0
	DBRA	D3,ravlap2
	LEA	VolBoxPos,A0
	LEA	VolBoxData,A1
	MOVEQ	#2-1,D4
ravlop3	MOVEQ	#33-1,D3
ravlop2	MOVEQ	#17-1,D2
ravlop1	MOVE.B	(A1)+,(A0)+
	DBRA	D2,ravlop1
	ADDQ	#1,A1
	LEA	23(A0),A0
	DBRA	D3,ravlop2
	LEA	8920(A0),A0
	DBRA	D4,ravlop3
	BSR.W	ShowVolSliders
	JSR	WaitForButtonUp
ravloop
	TST.W	AbortDecFlag		; --PT2.3D bug fix
	BNE.B	ravskip			; --
	BTST	#2,$DFF016		; right mouse button
	BEQ.B	ExitVolBox
ravskip					; --
	JSR	WaitForButtonUp		; --
	CLR.W	AbortDecFlag
ravskip2				; --
	JSR	DoKeyBuffer
	MOVE.B	RawKeyCode(PC),D2
	CMP.B	#68,D2
	BEQ.B	ExitVolBox
	BTST	#6,$BFE001		; left mouse button
	BNE.B	ravloop
	MOVE.W	MouseX(PC),D0
	MOVE.W	MouseY(PC),D1
	; -PT2.3D bug fix: toggle vol toolbox with same button
	CMP.W	#245,D1
	BLO.B	ravskip3
	CMP.W	#96,D0
	BLO.B	ravskip3
	CMP.W	#135,D0
	BHI.B	ravskip3
	BRA.B	ExitVolBox
ravskip3
	; ----------------------------------------------------
	CMP.W	#72,D0
	BLO.B	ravloop
	CMP.W	#72+136,D0
	BHS.B	ravloop
	CMP.W	#155,D1
	BLO.B	ravloop
	CMP.W	#166,D1
	BLO.B	Vol1Slider
	CMP.W	#177,D1
	BLO.W	Vol2Slider
	CMP.W	#188,D1
	BLO.W	VolGadgs
	BRA.B	ravloop

ExitVolBox
	LEA	VolBoxPos,A0
	MOVEQ	#2-1,D2
revlap3	MOVEQ	#33-1,D1
revlap2	MOVEQ	#17-1,D0
revlap1	CLR.B	(A0)+
	DBRA	D0,revlap1
	LEA	23(A0),A0
	DBRA	D1,revlap2
	LEA	8920(A0),A0
	DBRA	D2,revlap3
	SF	VolToolBoxShown	; --PT2.3D bug fix
	BRA.W	DisplaySample

Vol1Slider
	CMP.W	#167,D0
	BHI.B	v1skip
	LEA	Vol1(PC),A4
	MOVEQ	#0,D7
v1loop1	BTST	#6,$BFE001	; left mouse button
	BNE.W	ravloop
	MOVE.W	MouseX(PC),D0
	CMP.W	D7,D0
	BEQ.B	v1loop1
	MOVE.W	D0,D7
	SUB.W	#107,D0
	BPL.B	v1skp2
	MOVEQ	#0,D0
v1skp2	CMP.W	#60,D0
	BLS.B	v1skp3
	MOVEQ	#60,D0
v1skp3	MULU.W	#200,D0
	DIVU.W	#60,D0
	MOVE.W	D0,(A4)
shvosl	BSR.W	ShowVolSliders
	BRA.B	v1loop1

v1skip	MOVE.W	#180,LineCurX
	MOVE.W	#163,LineCurY
	MOVE.W	#6342,TextOffset
	JSR	GetDec3Dig
	TST.W	AbortDecFlag
	BNE.B	shvosl
	CMP.W	#200,D0
	BLS.B	v1sk2
	MOVE.W	#200,D0
v1sk2	MOVE.W	D0,Vol1
	BRA.B	shvosl

Vol2Slider
	CMP.W	#167,D0
	BHI.B	v2skip
	LEA	Vol2(PC),A4
	MOVEQ	#0,D7
	BRA.B	v1loop1
v2skip	MOVE.W	#180,LineCurX
	MOVE.W	#174,LineCurY
	MOVE.W	#6782,TextOffset
	JSR	GetDec3Dig
	TST.W	AbortDecFlag
	BNE.B	shvosl
	CMP.W	#200,D0
	BLS.B	v2sk2
	MOVE.W	#200,D0
v2sk2	MOVE.W	D0,Vol2
	BRA.W	shvosl

VolGadgs
	CMP.W	#100,D0
	BLO.W	DoRampVol
	CMP.W	#144,D0
	BLO.W	Normalize
	CMP.W	#154,D0
	BLO.B	SetRampDown
	CMP.W	#164,D0
	BLO.B	SetRampUp
	CMP.W	#174,D0
	BLO.B	SetRampUnity
	BRA.W	ExitVolBox

SetRampDown
	MOVE.W	#100,Vol1
	CLR.W	Vol2
	BRA.B	sru2
SetRampUp
	CLR.W	Vol1
	MOVE.W	#100,Vol2
	BRA.B	sru2
SetRampUnity
	MOVE.W	#100,Vol1
	MOVE.W	#100,Vol2
sru2	BSR.B	ShowVolSliders
	JSR	WaitForButtonUp
	BRA.W	ravloop

ShowVolSliders
	LEA	TextBitplane+6209,A0
	MOVEQ	#22-1,D3
ravlip2	MOVEQ	#13-1,D2
ravlip1	CLR.B	(A0)+
	DBRA	D2,ravlip1
	LEA	27(A0),A0
	DBRA	D3,ravlip2
	MOVEQ	#0,D4
	MOVE.W	Vol1(PC),D4
	MOVEQ	#20,D5
	BSR.B	OneSlider
	MOVEQ	#0,D4
	MOVE.W	Vol2(PC),D4
	MOVEQ	#31,D5
	BSR.B	OneSlider
	MOVE.W	Vol1(PC),WordNumber
	MOVE.W	#6342,TextOffset
	BSR.W	Print3DecDigits
	MOVE.W	Vol2(PC),WordNumber
	MOVE.W	#6782,TextOffset
	BRA.W	Print3DecDigits

OneSlider
	MOVE.W	D4,D6
	ADD.W	D4,D4
	ADD.W	D6,D4
	AND.L	#$FFFF,D4
	DIVU.W	#10,D4
	ADD.W	#105,D4
	MOVEQ	#3-1,D6
oneslop	MOVE.W	D4,D0
	MOVE.W	D4,D2
	ADDQ.W	#5,D2
	MOVE.W	D5,D1
	MOVE.W	D5,D3
	BSR.W	DrawLine
	ADDQ.W	#1,D5
	DBRA	D6,oneslop
	RTS

	; 128kB compatible, and heavily optimized by 8bitbubsy.
	; Uses 10.22fp deltas instead of several DIV+MULs.
	;
	; Benchmark:
	; - Before: ~18 seconds (128kB sample) on stock Amiga 500
	; -    Now: ~4 seconds
DoRampVol
	CLR.B	RawKeyCode
	LEA	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	BEQ.W	nozerr1
	LSL.W	#2,D1
	LEA	(A0,D1.W),A0
	MOVEQ	#0,D2
	MOVE.L	(A0),D0
	BEQ.W	nozerr2
	MOVE.L	D0,A2
	MOVE.L	124(A0),D2
	BEQ.W	nozerr2
	MOVE.L	MarkStartOfs(PC),D0
	BMI.B	drvskip
	MOVE.L	MarkEndOfs(PC),D1
	SUB.L	D0,D1
	BEQ.B	drvskip
	ADD.L	D0,A2
	MOVE.L	D1,D2
	ADDQ.L	#1,D2
drvskip	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	; --------------------
	MOVE.L	D2,D7
	; --------------------
	; Prepare some stuff...
	; --------------------
	MOVEQ	#0,D5		; Rescale volume range (for DIV -> ASR)
	MOVEQ	#0,D6
	MOVE.W	Vol1(PC),D5
	MOVE.W	Vol2(PC),D6	
	LSL.L	#7,D5
	LSL.L	#7,D6
        DIVU.W	#100,D5
	DIVU.W	#100,D6
	AND.L	#$FFFF,D5	; D5.L = Vol1 (0..256)
	AND.L	#$FFFF,D6	; D6.L = Vol2 (0..256)
	; --------------------
	MOVEQ	#22,D3		; fractional bits (max)
	; --------------------
	MOVE.L	D6,D0
	LSL.L	D3,D0
	MOVE.L	D7,D1
	JSR	DIVU32
	MOVE.L	D0,A5		; 10.22fp delta from Vol2
	; --------------------
	MOVE.L	D5,D0
	LSL.L	D3,D0
	MOVE.L	D7,D1
	JSR	DIVU32
	MOVE.L	D0,A6		; 10.22fp delta from Vol1
	; --------------------
	MOVE.L	D5,D6
	LSL.L	D3,D6
	MOVEQ	#0,D5
	MOVEQ	#127,D4
	MOVEQ	#-128,D2
	; --------------------
drvloop	MOVE.L	D5,D1
	ADD.L	D6,D1
	SWAP	D1
	LSR.W	#6,D1
	MOVE.B	(A2),D0
	EXT.W	D0
	MULS.W	D1,D0
	ASR.W	#7,D0
	CMP.W	D4,D0
	BGT.B	drvhi
	CMP.W	D2,D0
	BLT.B	drvlo
drvset	MOVE.B	D0,(A2)+
	ADD.L	A5,D5
	SUB.L	A6,D6
	SUBQ.L	#1,D7
	BNE.B	drvloop
	; --------------------
	JSR	RestorePtrCol
	BRA.W	ExitVolBox
	; --------------------
drvhi	MOVE.B	D4,D0
	BRA.B	drvset
drvlo	MOVE.B	D2,D0
	BRA.B	drvset

nozerr1	BSR.W	NotSampleNull
	BRA.W	ravloop
nozerr2	BSR.W	EmptySampleError
	BRA.W	ravloop

Normalize
	CLR.B	RawKeyCode
	LEA	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	BEQ.B	nozerr1
	LSL.W	#2,D1
	LEA	(A0,D1.W),A0
	MOVEQ	#0,D2
	MOVE.L	(A0),D0
	BEQ.B	nozerr2
	MOVE.L	D0,A2
	MOVE.L	124(A0),D2
	BEQ.B	nozerr2
	MOVE.L	MarkStartOfs(PC),D0
	BMI.B	nozskip
	MOVE.L	MarkEndOfs(PC),D1
	SUB.L	D0,D1
	BEQ.B	nozskip
	ADD.L	D0,A2
	MOVE.L	D1,D2
	ADDQ.L	#1,D2
nozskip	JSR	StorePtrCol
	JSR	SetWaitPtrCol
	MOVEQ	#0,D0
nozloop	MOVE.B	(A2)+,D1
	EXT.W	D1
	BPL.B	nozskp2
	NEG.W	D1
nozskp2	CMP.W	D0,D1
	BLO.B	nozskp3
	MOVE.W	D1,D0
nozskp3	SUBQ.L	#1,D2
	BNE.B	nozloop
	JSR	RestorePtrCol
	TST.W	D0
	BEQ.W	SetRampUnity
	CMP.W	#127,D0
	BHI.W	SetRampUnity
	CMP.W	#64,D0
	BLO.B	nozmax
	MOVE.L	#127*100,D1
	DIVU.W	D0,D1
	MOVE.W	D1,Vol1
	MOVE.W	D1,Vol2
	BRA.W	sru2
nozmax	MOVE.W	#200,Vol1
	MOVE.W	#200,Vol2
	BRA.W	sru2

Vol1	dc.w	100
Vol2	dc.w	100

TuningTone
	JSR	WaitForButtonUp
	CLR.B	RawKeyCode
	TST.W	TToneFlag
	BNE.W	TToneOff
	TST.L	RunMode
	BNE.W	ttrts
	MOVE.W	#1,TToneFlag
	MOVEQ	#0,D2
	MOVE.W	PattCurPos(PC),D2
	DIVU.W	#6,D2
	ADDQ.W	#1,D2
	AND.L	#3,D2
	LEA	TToneCh1Flag(PC),A0
	ADD.L	D2,A0
	ST	(A0)
	MOVEQ	#1,D0
	LSL.W	D2,D0
	MOVE.W	D0,TToneBit
	LEA	$DFF0A0,A0
	LSL.W	#4,D2
	LEA	(A0,D2.W),A0
	MOVE.L	A0,TToneChPtr
	LEA	PeriodTable(PC),A1
	MOVE.W	TuneNote,D1
	ADD.W	D1,D1
	MOVE.W	(A1,D1.W),D1
	LEA	TToneData,A2
	MOVE.W	D0,$DFF096	; turn off DMA
	MOVE.L	A2,(A0)
	MOVE.W	#16,4(A0) 	; 32 bytes
	MOVE.W	D1,6(A0)
	MOVE.W	TToneVol,8(A0)
	JSR	WaitForPaulaLatch
	BSET	#15,D0
	MOVE.W	D0,$DFF096	; turn DMA on
ttrts
	RTS

TToneOff
	CLR.W	TToneFlag
	CLR.L	TToneCh1Flag ;	clear all four
	MOVE.W	TToneBit(PC),$DFF096
	MOVE.L	TToneChPtr(PC),A0
	CLR.W	8(A0)
	RTS

	CNOP 0,4
TToneChPtr	dc.l 0
TToneFlag	dc.w 0
TToneBit	dc.w 0
TToneCh1Flag	dc.b 0
TToneCh2Flag	dc.b 0
TToneCh3Flag	dc.b 0
TToneCh4Flag	dc.b 0

SamplePressed
	CMP.W	#144,D1
	BHS.B	spruskp
	MOVE.W	LoopStartPos(PC),D2
	BEQ.B	sprusk5
	SUBQ.W	#3,D2
	CMP.W	D2,D0
	BLT.B	sprusk5
	ADDQ.W	#4,D2
	CMP.W	D2,D0
	BLO.W	LoopStartDrag
sprusk5	MOVE.W	LoopEndPos(PC),D2
	BEQ.B	spruskp
	SUBQ.W	#3,D2
	CMP.W	D2,D0
	BLT.B	spruskp
	ADDQ.W	#4,D2
	CMP.W	D2,D0
	BLO.W	LoopEndDrag
spruskp	CMP.W	#3,D0
	BLO.W	Return3
	CMP.W	#317,D0
	BHS.W	Return3
	MOVE.W	D0,LastSamPos
	BSR.W	InvertRange
	MOVE.W	LastSamPos(PC),D0
	MOVE.W	D0,MarkStart
	MOVE.W	D0,MarkEnd
	BSR.B	InvertRange
	BSR.W	MarkToOffset
	MOVE.L	MarkEndOfs(PC),SamplePos
	BSR.W	ShowPos
sprulop	BTST	#6,$BFE001	; left mouse button
	BNE.B	spruend
	MOVE.W	MouseX(PC),D0
	CMP.W	#3,D0
	BLO.B	sprusk3
	CMP.W	#317,D0
	BHS.B	sprusk2
	BRA.B	sprusk4
sprusk2	MOVE.W	#316,D0
	BRA.B	sprusk4
sprusk3	MOVEQ	#3,D0
sprusk4	CMP.W	LastSamPos(PC),D0
	BEQ.B	sprulop
	MOVE.W	D0,LastSamPos
	BSR.B	InvertRange
	MOVE.W	LastSamPos(PC),MarkEnd
	BSR.B	InvertRange
	BSR.W	MarkToOffset
	MOVE.L	MarkEndOfs(PC),SamplePos
	BSR.W	ShowPos
	BRA.B	sprulop
spruend	MOVE.W	MarkStart(PC),D0
	MOVE.W	MarkEnd(PC),D1
	CMP.W	D0,D1
	BHS.W	MarkToOffset
	MOVE.W	D0,MarkEnd
	MOVE.W	D1,MarkStart
	BRA.W	MarkToOffset

InvertRange ; taken from PT315.s and changed a bit
	MOVE.W	MarkStart(PC),D0
	BEQ.W	Return3
	MOVE.W	MarkEnd(PC),D2
	CMP.W	D0,D2
	BPL.B	ivok
	EXG.L	D0,D2
ivok	ADDQ.W	#1,D2		; this is needed for the new invertrange routine
	CMP.W	#317,D2		; -
	BLS.B	ivok2		; -
	MOVE.W	#317,D2		; -
ivok2	MOVEQ	#0,D1
	MOVEQ	#64,D3
	MOVE.L	A4,-(SP)
	MOVE.L	A5,-(SP)
	MOVE.L	GfxBase(PC),A6
	JSR	_LVOOwnBlitter(A6)
	JSR	_LVOWaitBlit(A6)
	MOVE.L	LineScreenPtr(PC),A4
	LEA	$DFF000,A6
ivwait1	BTST	#6,2(A6)
	BNE.B	ivwait1
	MOVE.L	A4,A5
	ADD.W	#16,D2
	MOVE.W	#$035A,$40(A6)	; EOR
	CLR.W	$42(A6)
	MOVE.W	D2,D4
	AND.W	#$000F,D4
	MOVEQ	#-1,D5
	LSR.W	D4,D5
	NOT.W	D5
	MOVE.W	D5,$46(A6)
	MOVE.W	D0,D4
	AND.W	#$000F,D4
	MOVEQ	#-1,D5
	LSR.W	D4,D5
	MOVE.W	D5,$44(A6)
	SUB.W	D1,D3
	MULU.W	#40,D1
	ADD.L	D1,A5
	ADD.W	D4,D2
	SUB.W	D0,D2
	LSR.W	#3,D0
	AND.W	#$00FE,D0
	EXT.L	D0
	ADD.L	D0,A5
	LSR.W	#3,D2
	AND.W	#$FFFE,D2
	MOVEQ	#40,D4
	NEG.W	D2
	ADD.W	D2,D4
	MOVE.W	D4,$60(A6)
	MOVE.W	D2,$64(A6)
	MOVE.W	D4,$66(A6)
	NEG.W	D2
	MOVE.L	A5,$48(A6)
	MOVE.W	#$FFFF,$74(A6)
	MOVE.L	A5,$54(A6)
	LSL.W	#6,D3
	LSR.W	#1,D2
	ADD.W	D2,D3
	MOVE.W	D3,$58(A6)
ivwait2	BTST	#6,2(A6)
	BNE.B	ivwait2
	MOVE.L	GfxBase(PC),A6
	JSR	_LVODisownBlitter(A6)
	MOVEA.L	(SP)+,A5
	MOVEA.L	(SP)+,A4
	RTS

LoopStartPos	dc.w 0
LoopEndPos	dc.w 0

LoopStartDrag
	CLR.W	DragType
LopDrgLop
	MOVE.L	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D0
	BEQ.W	Return3
	MULU.W	#30,D0
	LEA	12(A0,D0.W),A0
	MOVE.W	MouseX(PC),D0
lsdlop1	BTST	#6,$BFE001	; left mouse button
	BNE.B	lsdexit
	MOVE.W	MouseX(PC),D1
	CMP.W	D0,D1
	BEQ.B	lsdlop1
	SUB.W	DragType(PC),D1
	BPL.B	lsdmsk1
	MOVEQ	#0,D1
lsdmsk1	CMP.W	#314,D1
	BLO.B	lsdmsk2
	MOVE.W	#314,D1
lsdmsk2	MOVE.L	SamDisplay(PC),D0

	JSR	MULU32
	MOVE.L	#314,D1
	JSR	DIVU32
	MOVE.L	D0,D1
	
	MOVE.L	SamOffset(PC),D0
	ADD.L	D1,D0	; new repeat
	BCLR	#0,D0	; even'ify
	MOVEQ	#0,D1
	MOVE.W	4(A0),D1 ; old repeat
	ADD.L	D1,D1
	TST.W	DragType
	BNE.B	drgrepl
	MOVE.L	D1,D3
	SUB.L	D1,D0	; offset
	ADD.L	D0,D1
	MOVEQ	#0,D2
	MOVE.W	6(A0),D2
	ADD.L	D2,D2
	ADD.L	D2,D3
	SUBQ.L	#2,D3
	SUB.L	D0,D2
	CMP.L	D3,D1
	BLS.B	lsdok
	MOVE.L	D3,D1
	MOVEQ	#2,D2
lsdok	LSR.L	#1,D1
	MOVE.W	D1,4(A0)
	LSR.L	#1,D2
	MOVE.W	D2,6(A0)
	BSR.B	lsdexit
	BRA.W	LopDrgLop
lsdexit	BSR.W	ShowSampleInfo
	JSR	UpdateRepeats
	BRA.W	SetLoopSprites2

LoopEndDrag
	MOVE.W	#3,DragType
	BRA.W	LopDrgLop

drgrepl	MOVE.L	D0,D2 ; repend
	SUB.L	D1,D2 ; subtract repstart
	CMP.L	#2,D2
	BGT.B	ledskp1
	MOVEQ	#2,D2
	BRA.B	lsdok

ledskp1	MOVE.L	D1,D0	; 128kB-fixed by 8bitbubsy
	ADD.L	D2,D0
	MOVEQ	#0,D3
	MOVE.W	(A0),D3
	ADD.L	D3,D3
	CMP.L	D3,D0
	BLS.B	lsdok
	SUB.L	D1,D3
	MOVE.L	D3,D2
	BRA.B	lsdok

DragType	dc.w	0

SamDragBar
	CMP.W	#4,D0
	BLO.W	Return3
	CMP.W	#316,D0
	BHS.W	Return3
	CMP.W	DragStart(PC),D0
	BLO.B	draglo
	CMP.W	DragEnd(PC),D0
	BHS.B	draghi
	MOVE.W	MouseX(PC),D0
	MOVE.W	D0,LastMouseX
	SUB.W	DragStart(PC),D0
	ADDQ.W	#3,D0
	MOVE.W	D0,DragOffset
sdrlop1	BTST	#6,$BFE001	; left mouse button
	BNE.W	Return3
	MOVEQ	#0,D0
	MOVE.W	MouseX(PC),D0
	CMP.W	LastMouseX(PC),D0
	BEQ.B	sdrlop1
	MOVE.W	D0,LastMouseX
	SUB.W	DragOffset(PC),D0
	BPL.B	sdrskp1
	MOVEQ	#0,D0
sdrskp1	MOVE.L	SamLength(PC),D1
	BEQ.W	Return3
	JSR	MULU32
	MOVE.L	#311,D1
	JSR	DIVU32
	BSR.B	dragchk
	BRA.B	sdrlop1
	
draglo	MOVE.L	SamOffset(PC),D0

	SUB.L	SamDisplay(PC),D0
	BPL.B	draglo2
	MOVEQ	#0,D0
draglo2	CMP.L	SamOffset(PC),D0
	BEQ.W	Return3		
	MOVE.L	D0,SamOffset
	BRA.W	DisplaySampleNoTextUpdate
	
draghi	MOVE.L	SamOffset(PC),D0
	ADD.L	SamDisplay(PC),D0
dragchk	MOVE.L	D0,D1
	ADD.L	SamDisplay(PC),D1
	CMP.L	SamLength(PC),D1
	BLS.B	draglo2
	MOVE.L	SamLength(PC),D0
	SUB.L	SamDisplay(PC),D0
	BRA.B	draglo2

DragOffset	dc.w	0
LastMouseX	dc.w	0
;----

MarkToOffset
	MOVEQ	#0,D0
	MOVE.W	MarkStart(PC),D0
	BEQ.W	Return3
	SUBQ.W	#3,D0
	MOVE.L	SamDisplay(PC),D1		
	JSR	MULU32
	MOVE.L	#314,D1
	JSR	DIVU32
	ADD.L	SamOffset(PC),D0
	MOVE.L	D0,MarkStartOfs
	; ------------------------
	MOVEQ	#0,D0
	MOVE.W	MarkEnd(PC),D0
	CMP.W	#316,D0
	BLO.B	mtosome
	MOVE.L	SamOffset(PC),D0
	ADD.L	SamDisplay(PC),D0
	BRA.B	mtoexit
mtosome	SUBQ.W	#3,D0
	MOVE.L	SamDisplay(PC),D1	
	JSR	MULU32
	MOVE.L	#314,D1
	JSR	DIVU32	
	ADD.L	SamOffset(PC),D0
mtoexit	MOVE.L	D0,MarkEndOfs
	RTS

OffsetToMark
	MOVE.L	D2,-(SP)
	; ------------------------
	MOVE.L	MarkStartOfs(PC),D0
	BMI.B	otmout
	MOVE.W	#3,MarkStart
	MOVE.W	#3,MarkEnd
	MOVE.L	SamDisplay(PC),D2
	BEQ.W	otmend
	SUB.L	SamOffset(PC),D0
	BMI.B	otmskip	; set to start if before offset
	MOVE.L	#314,D1
	JSR	MULU32
	MOVE.L	D2,D1
	JSR	DIVU32	
	CMP.W	#314,D0
	BHI.B	otmout	; if start after display
	ADD.W	D0,MarkStart
otmskip	; ------------------------
	MOVE.L	MarkEndOfs(PC),D0
	SUB.L	SamOffset(PC),D0
	BMI.B	otmout	; if end before offset	
	MOVE.L	#314,D1
	JSR	MULU32
	MOVE.L	D2,D1
	JSR	DIVU32	
	CMP.W	#313,D0
	BLS.B	otmok
	MOVE.W	#313,D0	; set to end if after display
otmok	ADD.W	D0,MarkEnd
otmend	; ------------------------
	MOVE.L	(SP)+,D2
	RTS
otmout	CLR.W	MarkStart
	CLR.W	MarkEnd
	BRA.B	otmend

	CNOP 0,4
MarkStartOfs	dc.l	0
MarkEndOfs	dc.l	0
SamMemPtr	dc.l	0
SamMemSize	dc.l	0
SamScrEnable	dc.w	0
LastSamPos	dc.w	0
MarkStart	dc.w	0
MarkEnd		dc.w	0

;---- Sample graphing stuff ----

DisplaySample
	TST.W	SamScrEnable
	BEQ.W	Return3
	BSR.W	rdsskip
	TST.L	MarkStartOfs
	BMI.W	Return3
	BSR.W	OffsetToMark
	BRA.W	InvertRange
	
DisplaySampleNoTextUpdate
	TST.W	SamScrEnable
	BEQ.W	Return3
	BSR.W	rdsdoit
	TST.L	MarkStartOfs
	BMI.W	Return3
	BSR.W	OffsetToMark
	BRA.W	InvertRange
	; fall-through

RedrawSample
	TST.W	SamScrEnable
	BEQ.W	Return3	
	MOVEQ	#-1,D0
	MOVE.L	D0,MarkStartOfs
	CLR.W	MarkStart
	SF	EmptySampleFlag
	MOVE.W	InsNum(PC),D0
	BEQ.B	rdsblnk
	LEA	SampleStarts(PC),A1
	SUBQ.W	#1,D0
	LSL.W	#2,D0
	MOVE.L	(A1,D0.W),SamStart
	BEQ.B	rdsblnk
	MOVE.L	124(A1,D0.W),D1
	BEQ.B	rdsblnk
	MOVE.L	D1,SamLength
	CLR.L	SamOffset
	MOVE.L	D1,SamDisplay
	BSR.W	SetSamPosDelta
	BRA.B	rdsskip
rdsblnk	ST	EmptySampleFlag
	LEA	BlankSample,A0
	MOVE.L	A0,SamStart
	MOVE.L	#314,SamLength
	CLR.L	SamOffset
	MOVE.L	#314,SamDisplay
	BSR.W	SetSamPosDelta
rdsskip	MOVE.L	SamDisplay(PC),D0
	LEA	BlankSample,A0
	CMP.L	SamStart(PC),A0
	BNE.B	rdsslwo
	MOVEQ	#0,D0
rdsslwo	MOVE.W	#215*40+33,TextOffset
	BSR.W	Print6DecDigits	

rdsdoit
	BSR.W	ClearSamArea
	BSR.W	SetDragBar
	
	; --PT2.3D change:
	; Slightly optimized sample draw routine, which also supports
	; 128kB samples. This one doesn't use DIVU & MULU per pixel.
	;
	; This is still awfully slow (because of blitter line drawing..?)
	;
	MOVE.L	SamStart(PC),A0
	MOVE.L	SamDisplay(PC),D3
	MOVE.L	SamOffset(PC),D2
	MOVE.L	D2,D7
	MOVE.L	A0,D0
	ADD.L	D2,D0
	MOVE.L	D0,SamDrawStart
	ADD.L	D3,D0
	MOVE.L	D0,SamDrawEnd

	ADD.L	D2,A0
	MOVE.L	SamPosDelta(PC),D7
	MOVEQ	#0,D6		; starting sample pos (17.15 fixed-point)

	; If we're zoomed out, adjust sample start pos/frac so
	; that the waveform doesn't "wiggle" while scrolling it.
	;	
	CMP.L	#314,D3		; SamDisplay (2..131070)
	BLS.B	rdsskp3		; not zoomed out, no adjustment needed
	TST.L	D2		; SamOffset (0..131068)
	BEQ.B	rdsskp3		; not scrolled, no adjustment needed 
	SUB.L	D2,A0

	MOVE.L	D2,D0
	MOVE.L	#314,D1
	JSR	MULU32
	MOVE.L	D3,D1
	JSR	DIVU32	
	MOVE.L	D0,D3
	
	MOVE.L	D7,D1
	AND.L	#32767,D1	; D1.L = sample delta frac
	JSR	MULU32	
	MOVE.L	D0,D6
	
	MOVEQ	#15,D2
	MOVE.L	D7,D1
	LSR.L	D2,D1		; D1.L = sample delta integer	
	MOVE.L	D3,D0
	JSR	MULU32
	LSL.L	D2,D0
	ADD.L	D0,D6
rdsskp3
	
	MOVE.L	D6,-(SP)
	MOVE.L	D7,-(SP)
	
	MOVE.L	GfxBase(PC),A6
	JSR	_LVOOwnBlitter(A6)
	JSR	_LVOWaitBlit(A6)	

	BSR.W	DrawDragBar ; (also uses blitter, so do it now)

	MOVE.L	(SP)+,D7
	MOVE.L	(SP)+,D6

	MOVEQ	#0,D4
	MOVE.L	#$1FFFF,D5
rdsloop	MOVE.L	D6,D0	; D0.L = current sample pos (17.15fp)
	SWAP	D0	;
	ROL.L	#1,D0	;
	AND.L	D5,D0	; D0.L = current sample pos (integer)
	MOVEQ	#127,D1
	SUB.B	(A0,D0.L),D1
	LSR.W	#2,D1
	MOVE.W	D4,D0
	ADDQ.W	#3,D0	
	TST.W	D4
	BNE.B	rdsdraw
	BSR.W	MoveTo
	BRA.B	rdsupdt
rdsdraw	BSR.W	DrawTo
rdsupdt	ADD.L	D7,D6
	ADDQ.W	#1,D4	
	CMP.W	#314,D4
	BLO.B	rdsloop

	JSR	_LVODisownBlitter(A6)

	BRA.W	SetLoopSprites
	
	CNOP 0,4
SamPosDelta	dc.l 0
SamStart	dc.l 0
SamLength	dc.l 0
SamOffset	dc.l 0
SamDisplay	dc.l 0
SavSamIns	dc.w 0
SamFracBits	dc.w 0
EmptySampleFlag	dc.b 0
	EVEN

SetDragBar
	SF	DragBarShown
	; ------------------------
	MOVE.L	SamLength(PC),D3
	BEQ.B	.end
	MOVE.L	SamOffset(PC),D4
	MOVE.L	SamDisplay(PC),D5
	CMP.L	D3,D5
	BEQ.B	.end
	ADD.L	D4,D5
	; ------------------------
	MOVE.L	D4,D0
	MOVE.L	#311,D1
	JSR	MULU32
	MOVE.L	D3,D1
	JSR	DIVU32
	ADDQ.W	#4,D0
	MOVE.W	D0,DragStart
	; ------------------------
	MOVE.L	D5,D0
	MOVE.L	#311,D1
	JSR	MULU32
	MOVE.L	D3,D1
	JSR	DIVU32	
	ADDQ.W	#5,D0	
	MOVE.W	D0,DragEnd	
	; ------------------------
	ST	DragBarShown
.end	RTS
	
DrawDragBar
	TST.B	DragBarShown
	BEQ.B	.end	
	MOVE.W	DragStart,D4
	MOVE.W	DragEnd,D5	
	MOVEQ	#68,D6
	MOVEQ	#4-1,D7
.loop	MOVE.W	D4,D0
	MOVE.W	D6,D1
	MOVE.W	D5,D2
	MOVE.W	D6,D3
	BSR.B	DrawLine
	ADDQ.W	#1,D6
	DBRA	D7,.loop
.end	RTS


DragStart	dc.w 0
DragEnd		dc.w 0
DragBarShown	dc.b 0
	EVEN

;---- Line Routine ----

ScrWidth = 40

DrawInvertLine
	MOVE.B	#$48,MinTerm
	BSR.B	DrawLine
	MOVE.B	#$C8,MinTerm
	RTS

MoveTo
	MOVE.W	D0,PenX
	MOVE.W	D1,PenY
	RTS

DrawTo
	MOVE.W	PenX(PC),D2
	MOVE.W	PenY(PC),D3
	MOVE.W	D0,PenX
	MOVE.W	D1,PenY
	CMP.W	D0,D2
	BNE.B	DrawLine
	CMP.W	D1,D3
	BEQ.W	dlrts
	; fall-through
DrawLine
	MOVE.L	D4,-(SP)
	MOVE.L	D5,-(SP)

	MOVEQ	#0,D4
	SUB.W	D1,D3
	BGE.B	dypos
	NEG.W	D3
	BRA.B	dyneg

dypos	BSET	#0,D4
dyneg	SUB.W	D0,D2
	BGE.B	dxpos
	NEG.W	D2
	BRA.B	dxneg

dxpos	BSET	#1,D4
dxneg	MOVE.W	D2,D5
	SUB.W	D3,D5
	BGE.B	dxdypos
	EXG	D2,D3
	BRA.B	dxdyneg

dxdypos	BSET	#2,D4
dxdyneg	MOVEQ	#0,D5
	ROR.W	#4,D0
	OR.W	#$0B00,D0
	MOVE.B	D0,D5
	MOVE.B	MinTerm(PC),D0
	ADD.W	D5,D5
	MULU.W	#ScrWidth,D1
	ADD.W	D5,D1
	ADD.L	LineScreenPtr(PC),D1
	
blitrdy	BTST	#14-8,$DFF002
	BNE.B	blitrdy

	MOVE.W	#$4000,$DFF09A	
	MOVE.B	Octants(PC,D4),D4
	ADD.W	D3,D3
	MOVE.W	D3,$DFF062 		; BLTBMOD
	SUB.W	D2,D3
	BGE.B	dldspos
	OR.B	#$40,D4
dldspos	MOVE.L	D3,$DFF050 		; BLTAPTR
	SUB.W	D2,D3
	MOVE.W	D3,$DFF064 		; BLTAMOD
	MOVE.W	D4,$DFF042 		; BLTCON1
	MOVE.W	D0,$DFF040 		; BLTCON0
	MOVE.L	D1,$DFF048 		; BLTCPTR
	MOVE.L	D1,$DFF054 		; BLTDPTR
	MOVE.W	#ScrWidth,$DFF060 	; BLTCMOD
	MOVE.W	#ScrWidth,$DFF066 	; BLTDMOD
	MOVE.W	#$8000,$DFF074 		; BLTADAT
	MOVE.W	#$FFFF,$DFF044 		; BLTAFWM
	MOVE.W	LinMask(PC),$DFF072 	; BLTBDAT
	LSL.W	#6,D2
	ADDQ.W	#2,D2
	MOVE.W	D2,$DFF058 		; BLTSIZE
	MOVE.W	#$C000,$DFF09A
	
	MOVE.L	(SP)+,D5
	MOVE.L	(SP)+,D4
dlrts	RTS
	
Octants		dc.b 3*4+1,2*4+1,1*4+1,0*4+1,7*4+1,5*4+1,6*4+1,4*4+1

	CNOP 0,4
LineScreenPtr	dc.l 0
LinMask		dc.w $FFFF
PenX		dc.w 0
PenY		dc.w 0
MinTerm		dc.b $C8,0

;---- Loop Sprites ----

SetLoopSprites
	MOVEQ	#-1,D6
	MOVEQ	#-1,D7
	MOVE.W	InsNum(PC),D0
	BEQ.W	slsset
	MULU.W	#30,D0
	MOVE.L	SongDataPtr(PC),A0
	LEA	12(A0,D0.W),A0
SetLoopSprites2
	TST.W	SamScrEnable
	BEQ.W	Return3
	CLR.W	LoopOnOffFlag
	MOVEQ	#-1,D6
	MOVEQ	#-1,D7
	MOVEQ	#0,D0
	MOVE.W	4(A0),D0
	ADD.L	D0,D0
	MOVEQ	#0,D1
	MOVE.W	6(A0),D1
	ADD.L	D1,D1
	MOVE.L	D0,D5
	ADD.L	D1,D5
	CMP.W	#2,D5
	BLS.B	slsset
	MOVE.W	#1,LoopOnOffFlag
	MOVE.L	SamOffset(PC),D2
	MOVE.L	SamDisplay(PC),D3
	MOVE.L	D2,D4
	ADD.L	D3,D4
	CMP.L	D2,D0
	BLO.B	.l1
	CMP.L	D4,D0
	BHI.B	.l1
	SUB.L	D2,D0

	MOVE.L	D3,-(SP)
	LSR.L	#1,D0
	LSR.L	#1,D3
	MULU.W	#314,D0
	DIVU.W	D3,D0
	MOVE.L	(SP)+,D3
	
	ADDQ.W	#3,D0
	MOVE.W	D0,D6
.l1	CMP.L	D2,D5
	BLO.B	slsset
	CMP.L	D4,D5
	BHI.B	slsset
	SUB.L	D2,D5
	
	MOVE.L	D3,-(SP)
	LSR.L	#1,D3
	LSR.L	#1,D5
	MULU.W	#314,D5
	DIVU.W	D3,D5
	MOVE.L	(SP)+,D3

	ADDQ.W	#6,D5
	MOVE.W	D5,D7
slsset	MOVE.W	#139,D1
	MOVE.W	D6,D0
	BPL.B	.l2
	MOVEQ	#0,D0
	MOVE.W	#270,D1
.l2	MOVEQ	#64,D2
	LEA	LoopSpriteData1,A0
	MOVE.W	D0,LoopStartPos
	BSR.W	SetSpritePos
	MOVE.W	#139,D1
	MOVE.W	D7,D0
	BPL.B	.l3
	MOVEQ	#0,D0
	MOVE.W	#270,D1
.l3	MOVEQ	#64,D2
	LEA	LoopSpriteData2,A0
	MOVE.W	D0,LoopEndPos
	BSR.W	SetSpritePos
	BRA.W	ShowLoopToggle
	
HideLoopSprites	; new PT2.3E routine
	MOVEM.L	D0-D2/A0,-(SP)
	MOVEQ	#0,D0
	MOVE.W	#270,D1
	MOVEQ	#64,D2
	LEA	LoopSpriteData1,A0
	BSR	SetSpritePos
	LEA	LoopSpriteData2,A0
	BSR	SetSpritePos
	MOVEM.L	(SP)+,D0-D2/A0
	RTS
	
;---- Playroutine ----

	CNOP 0,4
audchan1temp
	dcb.b 24
	dc.w $0001	; voice #1 DMA bit
	dcb.b 34
audchan2temp
	dcb.b 24
	dc.w $0002	; voice #2 DMA bit
	dcb.b 34
audchan3temp
	dcb.b 24
	dc.w $0004	; voice #3 DMA bit
	dcb.b 34
audchan4temp
	dcb.b 24
	dc.w $0008	; voice #4 DMA bit
	dcb.b 34

IntMusic
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	RunMode(PC),D0
	BEQ.W	NoNewPositionYet
	CMP.L	#'patt',D0
	BEQ.B	.l1
	MOVE.L	SongPosition(PC),CurrPos
.l1
	MOVE.L	SongDataPtr(PC),A0
	TST.W	StepPlayEnable
	BNE.B	.l2
	ADDQ.L	#1,Counter
	MOVE.L	Counter(PC),D0
	CMP.L	CurrSpeed(PC),D0
	BLO.B	NoNewNote
.l2	CLR.L	Counter
	TST.B	PattDelayTime2
	BEQ.B	GetNewNote
	BSR.B	NoNewAllChannels
	BRA.W	dskip

NoNewNote
	BSR.B	NoNewAllChannels
	BRA.W	NoNewPositionYet

NoNewAllChannels
	LEA	audchan1temp(PC),A6
	LEA	$DFF0A0,A5
	BSR.W	CheckEffects
	LEA	audchan2temp(PC),A6
	LEA	$DFF0B0,A5
	BSR.W	CheckEffects
	LEA	audchan3temp(PC),A6
	LEA	$DFF0C0,A5
	BSR.W	CheckEffects
	LEA	audchan4temp(PC),A6
	LEA	$DFF0D0,A5
	BRA.W	CheckEffects

GetNewNote
	LEA	12(A0),A3
	LEA	sd_pattpos(A0),A2
	LEA	sd_patterndata(A0),A0
	MOVEQ	#0,D1
	MOVE.L	SongPosition(PC),D0
	MOVE.B	(A2,D0.W),D1
	
	CMP.L	#'patt',RunMode
	BNE.B	.l1
	MOVE.L	PatternNumber(PC),D1
.l1	LSL.L	#8,D1

	LSL.L	#2,D1
	ADD.L	PatternPosition(PC),D1
	CLR.W	DMACONtemp
	LEA	$DFF0A0,A5
	LEA	audchan1temp(PC),A6
	MOVEQ	#1,D2
	BSR.W	PlayVoice
	TST.B	n_muted(A6)		; --PT2.3D bug fix: instant channel muting
	BNE.W	.l2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	MOVE.B	D0,n_volumeout(A6)	; set quadrascope volume
.l2
	LEA	$DFF0B0,A5
	LEA	audchan2temp(PC),A6
	MOVEQ	#2,D2
	BSR.W	PlayVoice
	TST.B	n_muted(A6)		; --PT2.3D bug fix: instant channel muting
	BNE.W	.l3
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	MOVE.B	D0,n_volumeout(A6)	; set quadrascope volume
.l3
	LEA	$DFF0C0,A5
	LEA	audchan3temp(PC),A6
	MOVEQ	#3,D2
	BSR.W	PlayVoice
	TST.B	n_muted(A6)		; --PT2.3D bug fix: instant channel muting
	BNE.W	.l4
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	MOVE.B	D0,n_volumeout(A6)	; set quadrascope volume
.l4
	LEA	$DFF0D0,A5
	LEA	audchan4temp(PC),A6
	MOVEQ	#4,D2
	BSR.W	PlayVoice
	TST.B	n_muted(A6)		; --PT2.3D bug fix: instant channel muting
	BNE.W	.l5
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	MOVE.B	D0,n_volumeout(A6)	; set quadrascope volume
.l5
	BRA.W	SetDMA
	
SetVUMeterHeight			; - PT2.3D change: perfect VU-meters (never buggy at high BPMs)
	TST.B	RealVUMetersFlag	; real VU-meters mode?
	BNE.B	vuend			; yes, don't use this routine
	; -------------------------
	TST.B	n_muted(A6)		; is this channel muted?
	BNE.B	vuend			; yes, don't set VU-meter height for this channel		
	MOVEQ	#0,D0
	MOVE.B	n_dmabit+1(A6),D0	; check temp dmacon to find out what channel we're on
	AND.B   #$0F,D0
	BEQ.B   vuend			; no active channel...
	; -------------------------
	MOVE.L	A0,-(SP)
	MOVE.L	D1,-(SP)
	BTST	#0,D0			; are we on channel #1?
	BEQ.B	notch1			; no
	LEA	VUSpriteData1,A0	; yes, get current sprite
	BRA.B   vuskip
notch1	BTST	#1,D0			; are we on channel #2?
	BEQ.B	notch2			; no
	LEA	VUSpriteData2,A0	; yes, get current sprite
	BRA.B   vuskip
notch2	BTST	#2,D0			; are we on channel #3?
	BEQ.B	notch3			; no
	LEA	VUSpriteData3,A0	; yes, get current sprite
	BRA.B   vuskip
notch3	LEA	VUSpriteData4,A0	; we are on channel #4
vuskip	MOVE.B	n_cmd(A6),D0		; get channel effect
	AND.B	#$0F,D0			; mask
	CMP.B   #$0C,D0			; is current effect 'C' (set vol)?
	BNE.B	vuskip2			; no
	MOVE.B	n_cmdlo(A6),D0		; yes, use parameter as VU-meter volume
	BRA.B	vuskip3
vuskip2	MOVE.B	n_volume(A6),D0		; get channel volume instead
vuskip3	CMP.B	#64,D0			; higher than $40?
	BLS.B	vuskip4			; no, safe for use!
	MOVEQ	#64,D0			; yes, set to $40
vuskip4	MOVE.B	(VUmeterHeights,PC,D0.W),(A0)
	MOVE.L	(SP)+,D1
	MOVE.L	(SP)+,A0
vuend	RTS
	; ------------------
	
	; This table is also used for the "real" VU meter mode.
	;
	; for (i = 0 to 64) x = 233 - round[i * (47/64)]
VUmeterHeights
        dc.b 233,232,232,231,230,229,229,228,227,226,226,225,224,223,223,222
        dc.b 221,221,220,219,218,218,217,216,215,215,214,213,212,212,211,210
        dc.b 209,209,208,207,207,206,205,204,204,203,202,201,201,200,199,198
        dc.b 198,197,196,196,195,194,193,193,192,191,190,190,189,188,187,187
        dc.b 186
	EVEN

CheckMetronome
	TST.B	MetroFlag
	BEQ.W	Return3
	CMP.B	MetroChannel(PC),D2
	BNE.W	Return3
	MOVE.B	MetroSpeed(PC),D2
	BEQ.W	Return3
	MOVE.L	PatternPosition(PC),D3
	LSR.L	#4,D3
	DIVU.W	D2,D3
	SWAP	D3
	TST.W	D3
	BNE.W	Return3
	CLR.W	D3
	SWAP	D3
	DIVU.W	D2,D3
	SWAP	D3
	TST.W	D3
	BNE.B	MetroNotFirst
	AND.L	#$00000FFF,(A6)
	OR.L	#$10A0F000,(A6) ; Play sample $1F at period $0A0 (160)
	RTS
MetroNotFirst
	AND.L	#$00000FFF,(A6)
	OR.L	#$10D6F000,(A6) ; Play sample $1F at period $0D6 (214)
	RTS

PlayVoice
	MOVE.L	D2,D7		; D7 = channel number
	TST.L	(A6)
	BNE.B	plvskip
	BSR.W	PerNop
plvskip	MOVE.L	(A0,D1.L),(A6)	; Read note from pattern
	BSR.B	CheckMetronome
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2	; Get lower 4 bits of instrument
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0		; Get higher 4 bits of instrument
	AND.B	#$F0,D0
	OR.B	D0,D2	
	AND.B	#31,D2		; PT2.3D bugfix: mask instrument
	TST.B	D2
	BEQ.W	SetRegisters	; Instrument was zero
	
	MOVEQ	#0,D3
	LEA	SampleStarts(PC),A1
	MOVE.W	D2,D4
	MOVE.B	D2,n_samplenum(A6)
	SUBQ.L	#1,D2
	LSL.L	#2,D2
	MULU.W	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.L	n_start(A6),n_oldstart(A6)	; for quadrascope
	MOVE.W	(A3,D4.L),n_length(A6)
	
	MOVEQ	#0,D0
	MOVE.B	2(A3,D4.L),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	; ----------------------------------
	LSL.B	#2,D0 ; update n_peroffset
	LEA	ftunePerTab(PC),A4
	MOVE.L	(A4,D0.W),n_peroffset(A6)
	; ----------------------------------	
	
	AND.B	#$0F,n_finetune(A6)		; --PT2.3D bug fix: mask finetune...
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3			; Get repeat
	MOVE.W	D3,n_repeat(A6)
	TST.W	D3
	BEQ.B	NoLoop
	MOVE.L	n_start(A6),D2			; Get start
	ADD.L	D3,D3				; PT2.3D bug fix: 128kB support
	ADD.L	D3,D2				; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0			; Get repeat
	ADD.W	6(A3,D4.L),D0			; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	D0,n_oldlength(A6)		; for quadrascope
	MOVE.W	6(A3,D4.L),n_replen(A6)		; Save replen
	BRA.B	SetRegisters

NoLoop
	MOVE.W	n_length(A6),n_oldlength(A6)	; for quadrascope
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
SetRegisters
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ.W	CheckMoreEffects	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$FF0,D0
	CMP.W	#$E50,D0 ; finetune
	BEQ.B	DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.B	ChkTonePorta
	CMP.B	#5,D0	; TonePortamento + VolSlide
	BEQ.B	ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.B	SetPeriod
	BSR.W	CheckMoreEffects
	BRA.B	SetPeriod

DoSetFineTune
	BSR.W	SetFineTune
	BRA.B	SetPeriod

ChkTonePorta
	BSR.W	SetVUMeterHeight	; set VU-meter height now as well
	BSR.W	SetTonePorta
	BRA.W	CheckMoreEffects

SetPeriod
	MOVEM.L	D0/D1/A0/A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	PeriodTable(PC),A1
	MOVEQ	#37-1,D7
ftuloop	CMP.W	(A1)+,D1
	BHS.B	ftufound
	DBRA	D7,ftuloop
ftufound
	MOVEQ	#37-1,D0
	SUB.W	D7,D0	 ; 0..37
	ADD.W	D0,D0
	MOVE.L	n_peroffset(A6),A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0/D1/A0/A1
	
	MOVE.W	2(A6),D0
	AND.W	#$FF0,D0
	CMP.W	#$ED0,D0 ; Notedelay
	BEQ.W	CheckMoreEffects
	
	MOVE.W	n_dmabit(A6),$DFF096
	BTST	#2,n_wavecontrol(A6)
	BNE.B	vibnoc
	CLR.B	n_vibratopos(A6)
vibnoc	BTST	#6,n_wavecontrol(A6)
	BNE.B	trenoc
	CLR.B	n_tremolopos(A6)
trenoc
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.L	n_start(A6),(A5)	; Set start
	BNE.B	sdmaskp
	CLR.L	n_loopstart(A6)
	CLR.L	n_wavestart(A6)
	MOVEQ	#1,D0
	MOVE.W	D0,4(A5)
	MOVE.W	D0,n_replen(A6)
sdmaskp
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,6(A5)		; Set period
	MOVE.W	D0,n_periodout(A6)	; Set quadrascope period
	ST	n_trigger(A6)		; Trigger quadrascope
	JSR	SpectrumAnalyzer	; Do the analyzer
	BSR.W	SetVUMeterHeight	; Set VU-meter height
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,DMACONtemp
	BRA.W	CheckMoreEffects

SetDMA
	JSR	WaitForPaulaLatch
	MOVE.W	DMACONtemp(PC),D0
	OR.W	#$8000,D0	; Set DMA bits
	MOVE.W	D0,$DFF096
	JSR	WaitForPaulaLatch
	
	LEA	$DFF000,A5
	LEA	audchan4temp(PC),A6
	MOVE.L	n_loopstart(A6),$D0(A5)
	MOVE.W	n_replen(A6),$D4(A5)
	LEA	audchan3temp(PC),A6
	MOVE.L	n_loopstart(A6),$C0(A5)
	MOVE.W	n_replen(A6),$C4(A5)
	LEA	audchan2temp(PC),A6
	MOVE.L	n_loopstart(A6),$B0(A5)
	MOVE.W	n_replen(A6),$B4(A5)
	LEA	audchan1temp(PC),A6
	MOVE.L	n_loopstart(A6),$A0(A5)
	MOVE.W	n_replen(A6),$A4(A5)
	
dskip	TST.L	RunMode
	BEQ.B	dskipx
	JSR	SetPatternPos
dskipx	MOVE.L	PatternPosition(PC),D0
	LSR.L	#4,D0
	MOVE.W	D0,ScrPattPos
	ADD.L	#16,PatternPosition
	MOVE.B	PattDelayTime(PC),D0
	BEQ.B	dskpc
	MOVE.B	D0,PattDelayTime2
	CLR.B	PattDelayTime
dskpc	TST.B	PattDelayTime2
	BEQ.B	dskpa
	SUBQ.B	#1,PattDelayTime2
	BEQ.B	dskpa
	SUB.L	#16,PatternPosition
dskpa	TST.B	PBreakFlag
	BEQ.B	nnpysk
	SF	PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	PBreakPosition(PC),D0
	LSL.W	#4,D0
	MOVE.L	D0,PatternPosition
	CLR.B	PBreakPosition
nnpysk	TST.W	StepPlayEnable
	BEQ.B	nnpysk2
	JSR	DoStopIt
	CLR.W	StepPlayEnable
	MOVE.L	PatternPosition(PC),D0
	LSR.L	#4,D0
	AND.W	#63,D0
	MOVE.W	D0,ScrPattPos
nnpysk2	CMP.L	#1024,PatternPosition
	BNE.B	NoNewPositionYet
NextPosition
	MOVEQ	#0,D0
	MOVE.B	PBreakPosition(PC),D0
	LSL.W	#4,D0
	MOVE.L	D0,PatternPosition
	CLR.B	PBreakPosition
	CLR.B	PosJumpAssert
	CMP.L	#'patp',RunMode
	BNE.B	NoNewPositionYet
	ST	PattRfsh
	ADDQ.L	#1,SongPosition
	AND.L	#$7F,SongPosition
	MOVE.L	SongPosition(PC),D1
	MOVE.L	SongDataPtr(PC),A0
	CMP.B	sd_numofpatt(A0),D1
	BLO.B	NoNewPositionYet
	CLR.L	SongPosition
	
	TST.W	StepPlayEnable
	BEQ.B	NoNewPositionYet
	JSR	DoStopIt
	CLR.W	StepPlayEnable
	MOVE.L	PatternPosition(PC),D0
	LSR.L	#4,D0
	MOVE.W	D0,ScrPattPos
	
NoNewPositionYet
	TST.B	PosJumpAssert
	BNE.B	NextPosition
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

CheckEffects
	BSR.B	chkefx2
	TST.B	n_muted(A6)		; --PT2.3D bug fix: instant muting
	BNE.B	ceend
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	MOVE.B	D0,n_volumeout(A6)	; Set scope volume
ceend	RTS

	CNOP 0,4
JumpList1
	dc.l Arpeggio			; 0xy (Arpeggio)
	dc.l PortaUp			; 1xx (Portamento Up)
	dc.l PortaDown			; 2xx (Portamento Down)
	dc.l TonePortamento		; 3xx (Tone Portamento)
	dc.l Vibrato			; 4xy (Vibrato)
	dc.l TonePlusVolSlide		; 5xy (Tone Portamento + Volume Slide)
	dc.l VibratoPlusVolSlide	; 6xy (Vibrato + Volume Slide)
	dc.l SetBack			; 7 - not used here
	dc.l SetBack			; 8 - unused!
	dc.l SetBack			; 9 - not used here
	dc.l SetBack			; A - not used here
	dc.l SetBack			; B - not used here
	dc.l SetBack			; C - not used here
	dc.l SetBack			; D - not used here
	dc.l E_Commands			; Exy (Extended Commands)
	dc.l SetBack			; F - not used here

chkefx2
	BSR.W	UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.B	Return3
	MOVEQ	#0,D0
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	MOVE.W	D0,D1
	LSL.B	#2,D1
	MOVE.L	JumpList1(PC,D1.W),A4
	JMP	(A4) ; every efx has RTS at the end, this is safe
	
SetBack	MOVE.W	n_period(A6),6(A5)
	MOVE.W	n_period(A6),n_periodout(A6)	; Set scope period
	CMP.B	#7,D0
	BEQ.W	Tremolo
	CMP.B	#$A,D0
	BEQ.W	VolumeSlide
Return3	RTS

PerNop	MOVE.W	n_period(A6),6(A5)
	MOVE.W	n_period(A6),n_periodout(A6)	; Set scope period
	RTS

Arpeggio
	MOVE.L	Counter(PC),D0
	AND.W	#255,D0			; just in case
	MOVE.B	ArpTab(PC,D0.W),D0
	CMP.B	#1,D0
	BEQ.W	Arpeggio1
	CMP.B	#2,D0
	BEQ.W	Arpeggio2
Arpeggio0
	MOVE.W	n_period(A6),D2
	BRA.W	ArpeggioSet
	
	; DIV -> LUT optimization. DIVU is up to 140+ cycles on a 68000.
ArpTab
        dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
        dc.b 2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
        dc.b 1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2
        dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
        dc.b 2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
        dc.b 1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2
        dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
        dc.b 2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	EVEN

Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.B	ArpeggioFind

Arpeggio2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
ArpeggioFind
	ADD.W	D0,D0
	MOVE.L	n_peroffset(A6),A0
	MOVE.W	n_period(A6),D1
	MOVEQ	#37-1,D7
arploop	CMP.W	(A0)+,D1
	BHS.B	ArpeggioFound
	DBRA	D7,arploop
	RTS
	
ArpeggioFound
	MOVE.W	-2(A0,D0.W),D2
ArpeggioSet
	MOVE.W	D2,6(A5)
	MOVE.W	D2,n_periodout(A6)	; Set scope period
	RTS

FinePortaUp
	TST.L	Counter
	BNE.W	Return3
	MOVE.B	#$0F,LowMask
PortaUp	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	LowMask(PC),D0
	MOVE.B	#$FF,LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#$0071,D0
	BPL.B	PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#$0071,n_period(A6)
PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	MOVE.W	D0,n_periodout(A6)	; Set scope period
	RTS

FinePortaDown
	TST.L	Counter
	BNE.W	Return3
	MOVE.B	#$0F,LowMask
PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	LowMask(PC),D0
	MOVE.B	#$FF,LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#$0358,D0
	BMI.B	PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#$0358,n_period(A6)
PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	MOVE.W	D0,n_periodout(A6)	; Set scope period
	RTS

SetTonePorta
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVE.L	n_peroffset(A6),A4
	MOVEQ	#37-1,D0
StpLoop	CMP.W	(A4)+,D2
	BHS.B	StpFound
	DBRA	D0,StpLoop
	SUBQ.W	#4,A4			; a4 = &periods[35]
StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.B	StpGoss
	CMP.W	#37-1,D0		; a4 = &periods[0]?
	BEQ.B	StpGoss
	SUBQ.W	#2,A4			; nope, dec ptr
StpGoss	MOVE.W	-2(A4),D2
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.B	ClearTonePorta
	BGE.W	Return3
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ.W	Return3
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.B	TonePortaUp
TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.B	TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.B	TonePortaSetPer

TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.B	TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	
TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.B	GlissSkip
	MOVE.L	n_peroffset(A6),A0
	MOVEQ	#37-1,D0
GlissLoop
	CMP.W	(A0)+,D2
	BHS.B	GlissFound
	DBRA	D0,GlissLoop
	SUBQ.W	#4,A0			; A0 = &periods[35]
GlissFound
	MOVE.W	-2(A0),D2
GlissSkip
	MOVE.W	D2,6(A5) 		; Set period
	MOVE.W	D2,n_periodout(A6)	; Set scope period
	RTS

Vibrato	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.B	vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
vibskip	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.B	vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
Vibrato2
	MOVE.L	A4,-(SP)
	MOVE.B	n_vibratopos(A6),D0
	LEA	VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#3,D2
	BEQ.B	vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.B	vib_rampdown
	MOVE.B	#255,D2
	BRA.B	vib_set
vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.B	vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.B	vib_set
vib_rampdown2
	MOVE.B	D0,D2
	BRA.B	vib_set
vib_sine
	MOVE.B	(A4,D0.W),D2
vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.B	VibratoNeg
	ADD.W	D2,D0
	BRA.B	Vibrato3
VibratoNeg
	SUB.W	D2,D0
Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.W	D0,n_periodout(A6)	; Set scope period
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	MOVE.L	(SP)+,A4
	RTS

TonePlusVolSlide
	BSR.W	TonePortNoChange
	BRA.W	VolumeSlide

VibratoPlusVolSlide
	BSR.B	Vibrato2
	BRA.W	VolumeSlide

Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.B	treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
treskip	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.B	treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
treskip2
	MOVE.B	D2,n_tremolocmd(A6)
Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#3,D2
	BEQ.B	tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.B	tre_rampdown
	MOVE.B	#255,D2
	BRA.B	tre_set
tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.B	tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.B	tre_set
tre_rampdown2
	MOVE.B	D0,D2
	BRA.B	tre_set
tre_sine
	MOVE.B	(A4,D0.W),D2
tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.B	TremoloNeg
	ADD.W	D2,D0
	BRA.B	Tremolo3
TremoloNeg
	SUB.W	D2,D0
Tremolo3
	BPL.B	TremoloSkip
	CLR.W	D0
TremoloSkip
	CMP.W	#$40,D0
	BLS.B	TremoloOk
	MOVE.W	#$40,D0
TremoloOk
	; --PT2.3D bug fix: instant muting	
	TST.B	n_muted(A6)
	BNE.B	TremoloSkip2
	MOVE.W	D0,8(A5)
	MOVE.B	D0,n_volumeout(A6)	; Set scope volume
TremoloSkip2
	; --END OF FIX--------------------
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	ADDQ.L	#4,SP
	RTS

SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	sononew
	MOVE.B	D0,n_sampleoffset(A6)
sononew	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BHS.B	sofskip
	SUB.W	D0,n_length(A6)
	ADD.W	D0,D0
	ADD.L	D0,n_start(A6)
	RTS
sofskip	MOVE.W	#$0001,n_length(A6)
	RTS

VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.B	VolSlideDown
VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.B	vsuskip
	MOVE.B	#$40,n_volume(A6)
vsuskip	RTS

VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.B	vsdskip
	CLR.B	n_volume(A6)
vsdskip	RTS

PositionJump
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.L	D0,SongPosition
pj2	CLR.B	PBreakPosition
	ST	PosJumpAssert
	RTS

VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.B	VolumeOk
	MOVEQ	#$40,D0
VolumeOk
	MOVE.B	D0,n_volume(A6)
	RTS

PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU.W	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.B	pj2
	MOVE.B	D0,PBreakPosition
	ST	PosJumpAssert
	RTS

SetSpeed
	MOVE.B	3(A6),D0
	AND.W	#$FF,D0
	BEQ.B	SpeedNull
	TST.B	IntMode
	BEQ.B	normspd
	CMP.W	#32,D0
	BLO.B	normspd
	MOVE.W	D0,RealTempo
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.W	SamScrEnable(PC),-(SP)
	ST	SamScrEnable
	ST	UpdateTempo
	JSR	SetTempo
	MOVE.W	(SP)+,SamScrEnable
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
normspd	CLR.L	Counter
	MOVE.W	D0,CurrSpeed+2
	RTS
SpeedNull
	CLR.L	RunMode
	JSR	SetNormalPtrCol
	; PT2.3D fix: fixes for F00 while in string/number edit mode
	JSR	StorePtrCol	; store idle pointer color in backup
	TST.W	LineCurX	; are we editing a number or string?
	BEQ.B	.end
	JSR	SetWaitPtrCol	; we're editing, set edit pointer color
.end	; ----------------------------------------------------------------
	RTS
	
	CNOP 0,4
JumpList2
	dc.l PerNop		; 0 - not used
	dc.l PerNop		; 1 - not used
	dc.l PerNop		; 2 - not used
	dc.l PerNop		; 3 - not used
	dc.l PerNop		; 4 - not used
	dc.l PerNop		; 5 - not used
	dc.l PerNop		; 6 - not used
	dc.l PerNop		; 7 - not used
	dc.l PerNop		; 8 - not used
	dc.l SampleOffset	; 9xx (Set Sample Offset)
	dc.l PerNop		; A - not used
	dc.l PositionJump	; Bxx (Position Jump)
	dc.l VolumeChange	; Cxx (Set Volume)
	dc.l PatternBreak	; Dxx (Pattern Break)
	dc.l E_Commands		; Exy (Extended Commands)
	dc.l SetSpeed		; Fxx (Set Speed)

CheckMoreEffects
	MOVEQ	#0,D0
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	LSL.B	#2,D0
	MOVE.L	JumpList2(PC,D0.W),A4
	JMP	(A4) ; every efx has RTS at the end, this is safe
	
	CNOP 0,4
E_JumpList
	dc.l FilterOnOff	; E0x (Set LED Filter)
	dc.l FinePortaUp	; E1x (Fine Portamento Up)
	dc.l FinePortaDown	; E2x (Fine Portamento Down)
	dc.l SetGlissControl	; E3x (Glissando/Funk Control)
	dc.l SetVibratoControl	; E4x (Vibrato Control)
	dc.l SetFineTune	; E5x (Set Finetune)
	dc.l JumpLoop		; E6x (Pattern Loop)
	dc.l SetTremoloControl	; E7x (Tremolo Control)
	dc.l PerNop		; E8x - not used
	dc.l RetrigNote		; E9x (Retrig Note)
	dc.l VolumeFineUp	; EAx (Fine Volume-Slide Up)
	dc.l VolumeFineDown	; EBx (Fine Volume-Slide Down)
	dc.l NoteCut		; ECx (Note Cut)
	dc.l NoteDelay		; EDx (Note Delay)
	dc.l PatternDelay	; EEx (Pattern Delay)
	dc.l FunkIt		; EFx (Invert Loop)

E_Commands
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4-2,D0
	MOVE.L	E_JumpList(PC,D0.W),A4
	JMP	(A4) ; every E-efx has RTS at the end, this is safe

FilterOnOff
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#1,D0
	ADD.B	D0,D0
	AND.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS

SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

SetFineTune
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	; ----------------------------------
	LSL.B	#2,D0	; update n_peroffset
	LEA	ftunePerTab(PC),A4
	MOVE.L	(A4,D0.W),n_peroffset(A6)
	; ----------------------------------
	RTS

JumpLoop
	TST.L	Counter
	BNE.W	Return3
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.B	SetLoop
	TST.B	n_loopcount(A6)
	BEQ.B	jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ.W	Return3
jmploop	MOVE.B	n_pattpos(A6),PBreakPosition
	ST	PBreakFlag
	RTS

jumpcnt	MOVE.B	D0,n_loopcount(A6)
	BRA.B	jmploop

SetLoop	MOVE.L	PatternPosition(PC),D0
	LSR.L	#4,D0
	AND.B	#63,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

RetrigNote
	MOVE.L	A0,-(SP)
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.W	rtnend
	MOVE.L	Counter(PC),D1
	BNE.B	rtnskp
	MOVE.W	n_note(A6),D1
	AND.W	#$0FFF,D1
	BNE.B	rtnend
	MOVE.L	Counter(PC),D1
rtnskp	DIVU.W	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.B	rtnend
DoRetrg	MOVE.W	n_dmabit(A6),$DFF096		; Channel DMA off
	MOVE.L	n_start(A6),0(A5)		; Set sampledata pointer
	MOVE.W	n_length(A6),4(A5)		; Set length
	MOVE.W	n_period(A6),6(A5)		; Set period
	MOVE.W	n_period(A6),n_periodout(A6)	; Set quadrascope period
	JSR	WaitForPaulaLatch
	MOVE.W	n_dmabit(A6),D0
	BSET	#15,D0				; Set DMA bits
	MOVE.W	D0,$DFF096
	JSR	WaitForPaulaLatch
	MOVE.L	n_loopstart(A6),0(A5)
	MOVE.W	n_replen(A6),4(A5)	
	; -- PT2.3D bug fix: update analyzer/scope/VU-meters on note retrig
	JSR	SpectrumAnalyzer
	ST	n_trigger(A6)			; Trigger quadrascope
	BSR.W	SetVUMeterHeight		; Set VU-meter height
	; ---------------------------------------------------------
rtnend	MOVE.L	(SP)+,D1
	MOVE.L	(SP)+,A0
	RTS

VolumeFineUp
	TST.L	Counter
	BNE.W	Return3
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA.W	VolSlideUp

VolumeFineDown
	TST.L	Counter
	BNE.W	Return3
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA.W	VolSlideDown2

NoteCut MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.L	Counter(PC),D0
	BNE.W	Return3
	CLR.B	n_volume(A6)
	RTS

NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.L	Counter(PC),D0
	BNE.W	Return3
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ.W	Return3
	MOVE.L	A0,-(SP)
	MOVE.L	D1,-(SP)
	BRA.W	DoRetrg

PatternDelay
	TST.L	Counter
	BNE.W	Return3
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	PattDelayTime2
	BNE.W	Return3
	ADDQ.B	#1,D0
	MOVE.B	D0,PattDelayTime
	RTS

FunkIt  TST.L	Counter
	BNE.W	Return3
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ.W	Return3
UpdateFunk
	MOVE.L	D1,-(SP)
	MOVE.L	A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.B	funkend
	LEA	FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.B	funkend
	CLR.B	n_funkoffset(A6)	
	; --PT2.3D bug fix: EFx null pointer--
	MOVE.L	n_wavestart(A6),A0
	CMP.L	#0,A0
	BEQ.B	funkend
	; --END OF FIX------------------------
	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	ADDQ	#1,A0
	CMP.L	D0,A0
	BLO.B	funkok
	MOVE.L	n_loopstart(A6),A0
funkok	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
funkend	MOVE.L	(SP)+,A0
	MOVE.L	(SP)+,D1
	RTS

;************************* End of Code ******************************

; -----------------------------------------------------------------------------
;                                     DATA
; -----------------------------------------------------------------------------

FunkTable	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	
VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

AllRightText	dc.b	'All right',0
PLSTFullText	dc.b	'Plst is full!',0
AreYouSureText	dc.b	'Are you sure?',0
NoDiskInDriveText
		dc.b	'No disk in df0!',0
WriteProtectedText
		dc.b	'Write protected',0
OprAbortedText	dc.b	'Print aborted!',0
EnterDataText	dc.b	'Enter data',0
EnterFilenameText	dc.b	'Enter filename',0
AddingPathText	dc.b	'Adding path...',0
DiskErrorText	dc.b	'Disk error !!',0
LoadingText	dc.b	'Loading...',0
LoadingSongText	dc.b	'Loading song',0
LoadingModuleText
		dc.b	'Loading module',0
LoadingSampleText
		dc.b	'Loading sample',0
LoadingTrackText
		dc.b	'Loading track',0
LoadingPatternText
		dc.b	'Loading pattern',0
SavingText	dc.b	'Saving...',0
SavingModuleText
		dc.b	'Saving module',0
SavingIconText	dc.b	'Saving icon',0
SavingSampleText	dc.b	'Saving sample',0
LoadingPLSTText	dc.b	'Loading plst',0
SavingPLSTText	dc.b	'Saving plst',0
DeletingSongText	dc.b	'Deleting song',0
DeletingModuleText	dc.b	'Deleting module',0
DeletingSampleText	dc.b	'Deleting sample',0
DeletingTrackText	dc.b	'Deleting track',0
DeletingPatternText	dc.b	'Deleting pattern',0
RenamingFileText	dc.b	'Renaming file',0
DecrunchingText	dc.b	'Decrunching...',0
CrunchingText	dc.b	'Crunching...    ',0
SelectEntryText	dc.b	'Select entry',0
SelectSongText	dc.b	'Select song',0
SelectModuleText
		dc.b	'Select module',0
SelectSampleText
		dc.b	'Select sample',0
SelectTrackText
		dc.b	'Select track',0
SelectPatternText
		dc.b	'Select pattern',0
SelectFileText
		dc.b	'Select file',0
ReadingDirText	dc.b	'Reading dir...',0
PosSetText	dc.b	'Position set',0
PrintingSongText
		dc.b	'Printing song',0
PrintingPLSTText
		dc.b	'Printing plst',0

SaveSongText	dc.b	'Save song ?',0
DeleteSongText	dc.b	'Delete song ?',0
SaveModuleText	dc.b	'Save module ?',0
SaveExeText	dc.b	'Save executable ?',0
DeleteModuleText	dc.b	'Delete module ?',0
SaveSampleText	dc.b	'Save sample ?',0
DeleteSampleText	dc.b	'Delete sample ?',0
SaveTrackText	dc.b	'Save track ?',0
DeleteTrackText	dc.b	'Delete track ?',0
SavePatternText	dc.b	'Save pattern ?',0
DeletePatternText	dc.b	'Delete pattern ?',0
PrintPLSTText	dc.b	'Print plst ?',0
PrintSongText	dc.b	'Print song ?',0
QuitPTText	dc.b	'Really quit ?',0
UpsampleText	dc.b	'Upsample ?',0
DownSampleText	dc.b	'Downsample ?',0
PleaseSelectText	dc.b	'Please select',0
ClearSplitText	dc.b	'Clear split ?',0
ResetAllText	dc.b	'Reset config ?',0
DeletePresetText	dc.b	'Delete preset ?',0
LoadPLSTText	dc.b	'Load presetlist?',0
SavePLSTText	dc.b	'Save presetlist;',0
KillSampleText	dc.b	'Kill sample ?',0
AbortLoadingText	dc.b	'Abort loading ?',0
LoadConfigText	dc.b	'Load config ?',0
SaveConfigText	dc.b	'Save config ?',0

DiskFormatText	dc.b	'Disk format'
InProgressText	dc.b	'in progress'
FormattingCylText
		dc.b	'Formatting cyl ',0
VerifyingText	dc.b	'Verifying  cyl ',0
InitDiskText	dc.b	'Initializing',0
PlsEntNamText	dc.b	'Please enter name'
OfVolumeText	dc.b	'of volume:  ST-__',0
	CNOP 0,2
DiskNumText1	dc.b	'0'
DiskNumText2	dc.b	'0  '
PEdDefaultPath	dc.b	'df0:',0
		dcb.b	47,0

PEdDefaultVol	dc.b	'st-'
SndDiskNum0	dc.b	'0'
SndDiskNum1	dc.b	'1:'

PresetName	dc.b	'      '
PsetNameText	dc.b	'                '
		dc.b	' '
PsetVolText	dc.b	'  '
		dc.b	' '
PsetLenText	dc.b	'    '
		dc.b	' '
PsetRepeatText	dc.b	'    '
		dc.b	' '
PsetReplenText	dc.b	'    '

InsertPsetText	dc.b	'ST-01:                  0 0000 0000 0002'
PsetPLSTtext	dc.b	'No.    Samplename               '
		dc.b	'Length  Repeat  RepLen',$A,$A
PsetPrtNumText	dc.b	'    :  '
PsetPrtNameText	dc.b	'                             '
PsetPrtLenText	dc.b	'        '
PsetPrtRepeatText	dc.b	'        '
PsetPrtRepLenText	dc.b	10
		dc.b	0
SongDumpText
		dc.b	9
		dc.b	'ProTracker Song-Dump -- Made with '
		dc.b	'ProTracker v2.3F  ',$D,$A,$A
		dc.b	9
		dc.b	'Songname:  '
CRLF_Text	dc.b	13,10
FF_Text		dc.b	12,0
	
	CNOP 0,2
PatternNumText	dc.b	9,9,9,'Pattern: '
PattNumText1	dc.b	'0'
PattNumText2	dc.b	'0',$D,$A,$D,$A

PtotText	dc.b	9
PattXText1	dc.b	"0"
PattXText2	dc.b	"0 : "
PpText		dc.b	"                      "
Prafs		dc.b	"  0000  0000  0000    ",$D,$A
PnText2		dc.b	"        "
	CNOP 0,2
		dc.b	0
PattPosText	dc.b	'00  :                                       '
		dc.b	'                '
PnText		dc.b	'    ',0

	CNOP 0,2
SongsText	dc.b	'Songs',0
ModulesText	dc.b	'Modules',0
TracksText	dc.b	'Tracks',0
PatternsText	dc.b	'Patterns',0
SamplesText	dc.b	'Samples',0
		dc.b	'DF0:',0
		dc.b	'.'
	
	CNOP 0,2
STText1		dc.b	'ST'
STText1Num	dc.b	'-'
STText1Number	dc.b	0,0,':'
STText2		dc.b	'ST'
STText2Num	dc.b	'-'
STText2Number	dc.b	0,0,':'
STText3		dc.b	'ST'
STText3Num	dc.b	'-'
STText3Number	dc.b	0,0,':'
	
EmptyLineText	dc.b	'                       ',0
	EVEN
	
FastHexTable
	dc.b	'000102030405060708090A0B0C0D0E0F'
	dc.b	'101112131415161718191A1B1C1D1E1F'
	dc.b	'202122232425262728292A2B2C2D2E2F'
	dc.b	'303132333435363738393A3B3C3D3E3F'
	dc.b	'404142434445464748494A4B4C4D4E4F'
	dc.b	'505152535455565758595A5B5C5D5E5F'
	dc.b	'606162636465666768696A6B6C6D6E6F'
	dc.b	'707172737475767778797A7B7C7D7E7F'
	dc.b	'808182838485868788898A8B8C8D8E8F'
	dc.b	'909192939495969798999A9B9C9D9E9F'
	dc.b	'A0A1A2A3A4A5A6A7A8A9AAABACADAEAF'
	dc.b	'B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF'
	dc.b	'C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF'
	dc.b	'D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF'
	dc.b	'E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF'
	dc.b	'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF'

HexTable	dc.b	'0123456789ABCDEF'
TrackdiskName	dc.b	'trackdisk.device',0
InputDevName	dc.b	'input.device',0

RawKeyHexTable
	dc.b	10,1,2,3,4,5,6,7
	dc.b	8,9,32,53,51,34,18,35
RawKeyScaleTable	
	dc.b	49,33,50,34,51,52,36,53,37,54,38,55,56,40,57
	dc.b	41,58,16,2,17,3,18,19,5,20,6,21,7,22,23,9,24,10
	dc.b	25,26,12,27,70,70,0
	
KbdTransTable1	
	dc.b	 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16
	dc.b	12,13,14,15,16,17,18,19,20,21,22,23
	dc.b	24,25,26,27,28,29,30,31,36,36
KbdTransTable2
	dc.b	12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28
	dc.b	24,25,26,27,28,29,30,31,32,33,34,35
	dc.b	36,36,36,36,36,36,36,36,36,36
NoteNames1
	dc.b	'C-1 C#1 D-1 D#1 E-1 F-1 F#1 G-1 G#1 A-1 A#1 B-1 '
	dc.b	'C-2 C#2 D-2 D#2 E-2 F-2 F#2 G-2 G#2 A-2 A#2 B-2 '
	dc.b	'C-3 C#3 D-3 D#3 E-3 F-3 F#3 G-3 G#3 A-3 A#3 B-3 '
SpcNoteText
	dc.b	'--- '
	dc.b	'??? '
NoteNames2
	dc.b	'C-1 D¡1 D-1 E¡1 E-1 F-1 G¡1 G-1 A¡1 A-1 B¡1 B-1 '
	dc.b	'C-2 D¡2 D-2 E¡2 E-2 F-2 G¡2 G-2 A¡2 A-2 B¡2 B-2 '
	dc.b	'C-3 D¡3 D-3 E¡3 E-3 F-3 G¡3 G-3 A¡3 A-3 B¡3 B-3 '
	dc.b	'--- '
	dc.b	'??? '

	; Optimization: prevents MULU for getting correct finetuned period
	CNOP 0,4
ftunePerTab
	dc.l ftune0,ftune1,ftune2,ftune3
	dc.l ftune4,ftune5,ftune6,ftune7
	dc.l ftune8,ftune9,ftuneA,ftuneB
	dc.l ftuneC,ftuneD,ftuneE,ftuneF

PeriodTable
; Tuning 0, Normal
ftune0
	dc.w 856,808,762,720,678,640,604,570,538,508,480,453
	dc.w 428,404,381,360,339,320,302,285,269,254,240,226
	dc.w 214,202,190,180,170,160,151,143,135,127,120,113,0
; Tuning 1
ftune1
	dc.w 850,802,757,715,674,637,601,567,535,505,477,450
	dc.w 425,401,379,357,337,318,300,284,268,253,239,225
	dc.w 213,201,189,179,169,159,150,142,134,126,119,113,0
; Tuning 2
ftune2
	dc.w 844,796,752,709,670,632,597,563,532,502,474,447
	dc.w 422,398,376,355,335,316,298,282,266,251,237,224
	dc.w 211,199,188,177,167,158,149,141,133,125,118,112,0
; Tuning 3
ftune3
	dc.w 838,791,746,704,665,628,592,559,528,498,470,444
	dc.w 419,395,373,352,332,314,296,280,264,249,235,222
	dc.w 209,198,187,176,166,157,148,140,132,125,118,111,0
; Tuning 4
ftune4
	dc.w 832,785,741,699,660,623,588,555,524,495,467,441
	dc.w 416,392,370,350,330,312,294,278,262,247,233,220
	dc.w 208,196,185,175,165,156,147,139,131,124,117,110,0
; Tuning 5
ftune5
	dc.w 826,779,736,694,655,619,584,551,520,491,463,437
	dc.w 413,390,368,347,328,309,292,276,260,245,232,219
	dc.w 206,195,184,174,164,155,146,138,130,123,116,109,0
; Tuning 6
ftune6
	dc.w 820,774,730,689,651,614,580,547,516,487,460,434
	dc.w 410,387,365,345,325,307,290,274,258,244,230,217
	dc.w 205,193,183,172,163,154,145,137,129,122,115,109,0
; Tuning 7
ftune7
	dc.w 814,768,725,684,646,610,575,543,513,484,457,431
	dc.w 407,384,363,342,323,305,288,272,256,242,228,216
	dc.w 204,192,181,171,161,152,144,136,128,121,114,108,0
; Tuning -8
ftune8
	dc.w 907,856,808,762,720,678,640,604,570,538,508,480
	dc.w 453,428,404,381,360,339,320,302,285,269,254,240
	dc.w 226,214,202,190,180,170,160,151,143,135,127,120,0
; Tuning -7
ftune9
	dc.w 900,850,802,757,715,675,636,601,567,535,505,477
	dc.w 450,425,401,379,357,337,318,300,284,268,253,238
	dc.w 225,212,200,189,179,169,159,150,142,134,126,119,0
; Tuning -6
ftuneA
	dc.w 894,844,796,752,709,670,632,597,563,532,502,474
	dc.w 447,422,398,376,355,335,316,298,282,266,251,237
	dc.w 223,211,199,188,177,167,158,149,141,133,125,118,0
; Tuning -5
ftuneB
	dc.w 887,838,791,746,704,665,628,592,559,528,498,470
	dc.w 444,419,395,373,352,332,314,296,280,264,249,235
	dc.w 222,209,198,187,176,166,157,148,140,132,125,118,0
; Tuning -4
ftuneC
	dc.w 881,832,785,741,699,660,623,588,555,524,494,467
	dc.w 441,416,392,370,350,330,312,294,278,262,247,233
	dc.w 220,208,196,185,175,165,156,147,139,131,123,117,0
; Tuning -3
ftuneD
	dc.w 875,826,779,736,694,655,619,584,551,520,491,463
	dc.w 437,413,390,368,347,328,309,292,276,260,245,232
	dc.w 219,206,195,184,174,164,155,146,138,130,123,116,0
; Tuning -2
ftuneE
	dc.w 868,820,774,730,689,651,614,580,547,516,487,460
	dc.w 434,410,387,365,345,325,307,290,274,258,244,230
	dc.w 217,205,193,183,172,163,154,145,137,129,122,115,0
; Tuning -1
ftuneF
	dc.w 862,814,768,725,684,646,610,575,543,513,484,457
	dc.w 431,407,384,363,342,323,305,288,272,256,242,228
	dc.w 216,203,192,181,171,161,152,144,136,128,121,114,0
	; ------------------------------------------------------
	; Overflow bytes from CursorPosTable and UnshiftedKeymap
	; LUTs so that overflown arpeggio at finetune -1 sounds
	; right even if this table was to be moved.
	; ------------------------------------------------------
	dc.w 774,1800,2314,3087,4113,4627,5400,6426,6940,7713
	dc.w 8739,9253,24625,12851,13365
	
CursorPosTable
	dc.b	3,6,7,8,9,10,12
	dc.b	15,16,17,18,19,21
	dc.b	24,25,26,27,28,30
	dc.b	33,34,35,36,37
UnshiftedKeymap
	dc.b	'`1234567890-=\*0'
	dc.b	'qwertyuiop[]*123'
	dc.b	'asdfghjkl;',39,'#',0,'456'
	dc.b	'<zxcvbnm,./',0,'.','789 '
ShiftedKeymap
	dc.b	'~!@#$%^&*()_+|*0'
	dc.b	'qwertyuiop{}*123'
	dc.b	'asdfghjkl:',34,'^',0,'456'
	dc.b	'>zxcvbnm<>?',0,'.','789 '

; -----------------------------------------------------------------------------
;                     UNTOUCHABLE VARIABLES (do not touch!)
; -----------------------------------------------------------------------------

	CNOP 0,4
SampleInfo	dc.w	0
si_volume	dc.w	0
si_long		dc.l	0
si_pointer	dc.l	0,0,0,0,0
SampleInfo2	dc.l	0
si_long2	dc.l	0
si_pointer2	dc.l	0,0,0,0,0

	CNOP 0,4
SongDataPtr	dc.l	0
SampleStarts	dcb.l	31,0
SamplePtrs	EQU	SampleStarts-4
SampleLengths	dcb.l	32,0
SpritePtrsPtr	dc.l	0
LineCurPosPtr	dc.l	0
Ch1SpritePtr	dc.l	0
Ch2SpritePtr	dc.l	0
Ch3SpritePtr	dc.l	0
Ch4SpritePtr	dc.l	0
CursorPosPtr	dc.l	0
NoSpritePtr	dc.l	0
	
; -----------------------------------------------------------------------------
;                               GENERAL VARIABLES
; -----------------------------------------------------------------------------

	CNOP 0,4
StackSave	dc.l	0
DOSBase		dc.l	0
IntuitionBase	dc.l	0
GfxBase		dc.l	0
PPLibBase	dc.l	0
NoteNamesPtr	dc.l	0
SaveEditMode	dc.l	0
EditMode	dc.l	0
RunMode		dc.l	0
CurrCmds	dc.l	0
ShowTextPtr	dc.l	0
PatternNumber	dc.l	0
CurrPos		dc.l	0
CurrSpeed	dc.l	0
KeyTransTabPtr	dc.l	0
DecompMemPtr	dc.l	0
DecompMemSize	dc.l	0
LongFFFF	dc.l	0
TextEndPtr	dc.l	0
LongWordNumber	dc.l	0
MaxPLSTOffset	dc.l	0
FileNamePtr	dc.l	0
DiskDataPtr	dc.l	0
FileHandle	dc.l	0
DiskDataLength	dc.l	0
PattRfshNum	dc.l	0
PatternPosition	dc.l	0
SongPosition	dc.l	0
Counter		dc.l	0
PathPtr		dc.l	0
FileLock	dc.l	0
FormatDataPtr	dc.l	0
PsetPtrTemp	dc.l	0
FreeDiskSpace	dc.l	0
SplitAddress	dc.l	0
LaHeTx		dc.l	$12345678
PLSTAllocSize	dc.l	0
TrackdiskPort	dc.l	0,0,0,0
ProcessPtr	dc.l	0,0,0,0
DateStamp	dc.l	0,0,0,0
SampleSortList	dcb.l	32,0
PLSTmem		dc.l	0
PosEdCurrPos	dc.l	0
PLSTOffset	dcb.l	14,0
PPattPos	dc.w	0
TextOffset	dc.w	0
TextLength	dc.w	0
CmdOffset	dc.w	0
MountFlag	dc.w	0
GetLineFlag	dc.w	0
LoadInProgress	dc.w	0
CurrentPlayNote	dc.w	214
LineCurX	dc.w	0
LineCurY	dc.w	0
ScrPattPos	dc.w	0
PattCurPos	dc.w	0
GadgRepeat	dc.w	0
WordNumber	dc.w	0
HighPattNum	dc.w	0
InsNum		dc.w	0
LastInsNum	dc.w	1
PlayInsNum	dc.w	1
HiLowInstr	dc.w	0
PEDpos		dc.w	0
PLSTpos		dc.w	0
PresetMarkTotal	dc.w	0
CurrentPreset	dc.w	1
UpOrDown	dc.w	0
MouseX2		dc.w	0
MouseY2		dc.w	0
DidQuantize	dc.w	0
LowMask		dc.w	$FF00
DMACONtemp	dc.w	0
CurrScreen	dc.w	0
DiskOpScreen2	dc.w	0
SaveCurrScreen	dc.w	0
PointerCol1Save	dc.w	0
PointerCol2Save	dc.w	0
PointerCol3Save	dc.w	0
MoreInstrFlag	dc.w	0
PresetTotal	dc.w	0
CylinderNumber	dc.w	0
Action		dc.w	0
EnterTextFlag	dc.w	0
PresetLength	dc.w	0
PresetFineTune	dc.w	0
PresetRepeat	dc.w	0
PresetReplen	dc.w	0
PED_Action	dc.w	0
PsetNumTemp	dc.w	0
MaxPLSTEntries2	dc.w	0
NumPatterns	dc.w	0
AutoInsSlot	dc.w	0
lbW015B92	dc.w	0
makeExeModFlag	dc.w	0
AnalyzerHeights	dcb.w	23,0
AnalyzerOpplegg	dcb.w	23,0
RawKeyCode	dc.b	0
PattRfsh	dc.b	0
PosJumpAssert	dc.b	0
PBreakPosition	dc.b	0
PBreakFlag	dc.b	0
LEDStatus	dc.b	0
PattDelayTime	dc.b	0
PattDelayTime2	dc.b	0
GetDecTemp	dc.b	0
UpdateTempo	dc.b	0
SaveScope	dc.b	0
SetSignalFlag	dc.b	0
DisableAnalyzer	dc.b	0
SaveDA		dc.b	0
StopInputFlag	dc.b	0
NoSampleInfo	dc.b	0,0
PosEdNames	dcb.b	16*100,' '
AskBoxShown	dc.b	0,0
AboutScreenShown	dc.b	0
RightMouseButtonHeld	dc.b	0
SmpConvLUT	dcb.b 256,0
	EVEN

; -----------------------------------------------------------------------------
;                                  SETUP DATA
; -----------------------------------------------------------------------------

DefaultSetupData
	dc.b	'PT2.3 Configuration File',$A,0
	dc.b	'ST-00:Songs'
	dcb.b	21,0
	dc.b	'ST-00:Modules'
	dcb.b	19,0
	dc.b	'DF0:'
	dcb.b	28,0
	dc.b	'Prt:'
	dcb.b	28,0
DefCol	dc.w	$000,$BBB,$888,$555,$FD0,$D04,$000,$34F
	dc.b	1   ; Song Pack Mode
	dc.b	0   ; Module Pack Mode
	dc.b	0   ; Split  0=off, 1=on
	dc.b	0   ; Filter
	dc.b	0   ; TransDel
	dc.b	1   ; ShowDec
	dc.b	1   ; AutoDir
	dc.b	1   ; AutoExit
	dc.b	0   ; ModOnly
	dc.b	0   ; MIDI
	dc.b	1,$18,$18,0	; SplitData
	dc.b	2,$1A,$18,0
	dc.b	3,$1C,$18,0
	dc.b	4,$1D,$18,0
	dc.w	20,2	; KeyRepDelay/Speed
	dc.b	0	; Accidental
	dc.b	0	; not in use
	dc.b	'NewShell',0	; ExtCmd 0
	dcb.b	23,0
	dc.b	'Add21k',0	; ExtCmd 1
	dcb.b	25,0
	dc.b	'Info',0	; ExtCmd 2
	dcb.b	27,0
	dc.b	'List',0	; ExtCmd 3
	dcb.b	27,0
	dc.b	'LoadWB -Debug',0 ; ExtCmd 4
	dcb.b	18,0
	dc.b	'DirectoryOpus',0 ; ExtCmd 5
	dcb.b	18,0
	dc.b	'Run AudioMasterIV',0 ; ExtCmd 6
	dcb.b	14,0
	dc.b	'CEd',0	; ExtCmd 7
	dcb.b	28,0
	dc.w	0	; Not in use
	dc.w	2500	; Max PLST Entries
	dc.b	2,3,4,1	; Multi Mode Next
	dc.w	$102,$202,$037,$047,$304, $F06,$C10,$C20,$E93,$A0F	; EFX Macros
	dc.b	0 ; RAW/IFF/PAK Save, 0=RAW, 1=IFF, 2=PAK
	dc.b	1 ; IntMode, 0=VBLANK, 1=CIA
	dc.b	0 ; Override
	dc.b	0 ; Nosamples
	dc.b	0 ; BlankZero
	dc.b	1 ; ShowDirs
	dc.b	0 ; CutToBuf
	dc.b	0 ; ShowPublic
	dc.b	1 ; IFFLoop
	dc.b	0 ; SysReqFlag
	dc.w	125 ; Tempo
	dc.w	300 ; DMAWait (not used anymore)
	dc.w	24  ; TuneNote (C-3)
	dc.w	$20 ; TToneVol
	dc.b	0 ; LoadTrackToBufferFlag
	dc.b	0 ; LoadPattToBufferFlag
	dc.b	0,0,0,0,0,0 ; (Pad to 512 bytes)
	dc.b	"ST-00:" ; ProTracker Path
	dcb.b	26,0
	dc.w	6 ; DefaultSpeed
	dc.w	$0F00,$0F00,$0F10,$0F10,$0F20,$0F20,$0F30,$0F30 ; VU-meter
	dc.w	$0F40,$0F50,$0F60,$0F70,$0F80,$0F90,$0FA0,$0FB0 ; colors
	dc.w	$0FC0,$0FD0,$0FE0,$0FF0,$0FF0,$0EF0,$0EF0,$0DF0
	dc.w	$0DF0,$0CF0,$0CF0,$0BF0,$0BF0,$0AF0,$09F0,$09F0
	dc.w	$08F0,$08F0,$07F0,$07F0,$06F0,$06F0,$05F0,$05F0
	dc.w	$04F0,$04F0,$03F0,$03F0,$02F0,$01F0,$00F0,$00E0

	dc.w	$0F00,$0F10,$0F20,$0F30,$0F40,$0F50,$0F60,$0F70 ; Analyzer
	dc.w	$0F80,$0F90,$0FA0,$0FB0,$0FC0,$0FD0,$0FE0,$0FF0 ; colors
	dc.w	$0EF0,$0DF0,$0CF0,$0BF0,$0AF0,$09F0,$08F0,$07F0
	dc.w	$06F0,$05F0,$04F0,$03F0,$02F0,$01F0,$00F0,$00E0
	dc.w	$00D0,$00C0,$00B0,$00A0,$0090,$0080,$0070,$0060
	dc.b	"ST-00:Tracks"	; Tracks Path
	dcb.b	20,0
	dc.b	"ST-00:Patterns"	; Patterns Path
	dcb.b	18,0
	dc.b	0 ; SalvageFlag
	dc.b	0 ; OneHundredPattFlag
	dc.b	0 ; SaveIconsFlag
	dc.b	0 ; LoadNamesFlag
	dc.b	0 ; SaveNamesFlag
	dc.b	0 ; LoadPLSTFlag
	dc.b	0 ; ScreenAdjustFlag
	dc.b	0 ; SamplePackFlag
	dc.b	0 ; RealVUMetersFlag
	dcb.b	229  ; Pad to 1024 bytes
	
; -----------------------------------------------------------------------------
;                               SAMPLER ROUTINES
; -----------------------------------------------------------------------------

_custom	EQU	$00DFF000
intreq	EQU	$0000009C
intreqr	EQU	$0000001E
intena	EQU	$0000009A
joy0dat	EQU	$0000000A
vhposr	EQU	$00000006
dmacon	EQU	$00000096
dmaconr	EQU	$00000002

	CNOP 0,4
SamInfoPtr	dc.l	0
SamInfoLen	dc.l	0
SampleNote	dc.w	$18
ResampleNote	dc.w	$18
ChordTuneNote	dc.w	$18
SamIntSave	dc.w	0
SamDMASave	dc.w	0

ClearTempSampArea
	LEA	TempSampArea,A0
	MOVE.W	#380-1,D0
	MOVEQ	#0,D1
ctsalop	MOVE.W	D1,(A0)+
	DBRA	D0,ctsalop
	RTS

Sampler CLR.B	RawKeyCode
	JSR	StopIt
	JSR	TopExit
	JSR	WaitForButtonUp
	JSR	SetWaitPtrCol
	BSR.W	ShowMon
	JSR	Wait_4000
	JSR	ClearRightArea
	JSR	ClearAnalyzerColors
	BSR.B	ClearTempSampArea
	BSR.W	WaitForDiskDrive
	MOVE.W	$DFF01C,SamIntSave	; intenar
	MOVE.W	#$7FFF,$DFF09A 		; _custom+intena
	JSR	TurnOffVoices
	MOVE.W	SampleNote(PC),D0
	ADD.W	D0,D0
	LEA	PeriodTable(PC),A0
	MOVE.W	(A0,D0.W),D0
	LSR.W	#1,D0
	LEA	$DFF000,A0
	LEA	$AA(A0),A5
	LEA	$BA(A0),A6
	MOVE.W	D0,$A6(A0)
	MOVE.W	D0,$B6(A0)
	MOVEQ.L	#$20,D0
	MOVE.W	D0,$A8(A0)
	MOVE.W	D0,$B8(A0)
	MOVEQ	#0,D0
	MOVE.W	D0,(A5)
	MOVE.W	D0,(A6)
	MOVE.B	#6,$BFD200
	MOVEQ.L	#2,D0
	MOVE.B	D0,$BFD000
	MOVE.B	#0,$BFE301
	LEA	GraphOffsets(PC),A0
	LEA	TempSampArea,A1
	LEA	TextBitplane+(2536-40),A2
	LEA	$BFE101,A3
	LEA	$DFF01E,A4		; _custom+intreqr
	MOVE.W	#$0180,D7
	MOVEQ	#6,D6
	MOVEQ	#10,D3
monilop2
	MOVEQ	#23-1,D5
monilop4
	MOVEQ	#8-1,D4
monilop3
	BTST	D7,(A4)
	BEQ.B	monilop3
	MOVE.W	D7,$7E(A4)
	MOVEQ	#0,D0
	MOVE.B	(A3),D0
	MOVE.W	D0,D1
	SUB.B	D7,D0
	MOVE.B	D0,(A5)
	MOVE.B	D0,(A6)
	LSR.W	#3,D1
	ADD.W	D1,D1
	MOVE.W	(A0,D1.W),D0
	MOVE.W	(A1),D1
	MOVE.W	D0,(A1)+
	BCLR	D4,(A2,D1.W)
	BSET	D4,(A2,D0.W)
	DBRA	D4,monilop3
	ADDQ	#1,A2
	DBRA	D5,monilop4
	
	LEA	-23(A2),A2
	LEA	-368(A1),A1
	BTST	D6,-$0100(A3)
	BEQ.W	sampexit
	BTST	D3,-8(A4)
	BNE.B	monilop2
	
;-- start sampling --
	
	MOVE.W	InsNum(PC),D1
	BEQ.W	sampexit
	LSL.W	#2,D1
	LEA	SamplePtrs(PC),A0
	MOVE.L	(A0,D1.W),D0
	BEQ.B	samaok
	CLR.L	(A0,D1.W)
	MOVE.L	D0,A1
	MOVE.L	124(A0,D1.W),D0
	BEQ.B	samaok
	CLR.L	124(A0,D1.W)
	JSR	PTFreeMem
samaok	MOVE.L	#$1FFFE,D6		; try 128k
samalclop
	MOVE.L	D6,D0
	MOVE.L	#MEMF_CHIP!MEMF_CLEAR,D1
	JSR	PTAllocMem
	TST.L	D0
	BNE.B	samalcok
	SUB.L	#2048,D6		; try 2k less
	BPL.B	samalclop
	JSR	OutOfMemErr
	BRA.W	sampexit

samalcok
	MOVE.W	InsNum(PC),D1
	LSL.W	#2,D1
	LEA	SamplePtrs(PC),A0
	MOVE.L	D0,(A0,D1.W)
	MOVE.L	D6,124(A0,D1.W)
	
	MOVE.W	$DFF002,SamDMASave
	MOVE.W	#$03FF,$DFF096		; _custom+dmacon
	BSR.W	GetSampleInfo
	MOVE.L	SamInfoLen(PC),D4
	CLR.W	$DFF100
	CLR.W	$DFF180
	MOVE.L	SamInfoPtr(PC),A1
	LEA	$DFF09C,A2		; _custom+intreq
	LEA	$BFE101,A3		; parallel port
	LEA	$DFF01E,A4		; _custom+intreqr
	LEA	$DFF0BA,A6
	
	MOVE.W	#$0180,D7
	MOVEQ	#6,D6
	MOVEQ	#0,D5
samploop
	BTST	D7,(A4)
	BEQ.B	samploop
	MOVE.W	D7,(A2)
	MOVE.B	(A3),D0
	SUB.B	D7,D0
	MOVE.B	D0,(A5)
	MOVE.B	D0,(A6)
	MOVE.B	D0,(A1)+
	ADDQ.L	#1,D5
	CMP.L	D4,D5
	BEQ.B	sampend
	BTST	D6,-$0100(A3)
	BNE.B	samploop
sampend	MOVE.W	SamDMASave(PC),D0
	OR.W	#$8000,D0
	MOVE.W	D0,$DFF096
	
	MOVE.L	A1,D0
	SUB.L	SamInfoPtr(PC),D0
	MOVE.L	D0,SamInfoLen
	
	MOVE.L	SongDataPtr(PC),A0
	MOVE.W	InsNum(PC),D1
	MULU.W	#30,D1
	LEA	12(A0,D1.W),A0
	MOVE.L	SamInfoLen(PC),D0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)+
	MOVE.W	#$0040,(A0)+
	CLR.W	(A0)+
	MOVE.W	#1,(A0)

	; If we didn't fill up the whole sampling buffer,
	; free the memory we didn't use (this is hackish)
	;
	; XXX: THIS IS NOT SAFE !!
	;
	MOVE.L	SamInfoLen(PC),D1
	NEG.L	D1
	AND.L	#$FFFFFFF8,D1
	NEG.L	D1			; D1 is now a multiple of 8 (for FreeMem)
	MOVE.W	InsNum(PC),D0
	LSL.W	#2,D0
	LEA	SamplePtrs(PC),A0
	CMP.L	124(A0,D0.W),D1
	BGE.B	sampexit
	MOVE.L	124(A0,D0.W),D2
	MOVE.L	D1,124(A0,D0.W)
	SUB.L	D1,D2
	MOVE.L	(A0,D0.W),A1
	MOVE.L	124(A0,D0.W),D0
	ADD.L	D0,A1			; A1 points to the area we didn't use in our alloc
	MOVE.L	D2,D0			; D0 = size of memory we didn't use
	JSR	PTFreeMem
sampexit
	MOVE.W	SamIntSave(PC),D0
	BSET	#15,D0
	MOVE.W	D0,$DFF09A
	JSR	TurnOffVoices
	JSR	DisplayMainScreen
	BSR.W	ClearSamStarts
	BSR.W	ShowSampleInfo
	BSR.W	RedrawSample
	JSR	WaitForButtonUp
	CLR.W	KeyBufPos
	CLR.B	RawKeyCode
	CLR.W	ShiftKeyStatus
	JMP	Wait_4000

SampleNullInfo
	CLR.L	SamInfoPtr
	CLR.L	SamInfoLen
	MOVEQ	#-1,D0
	RTS

GetSampleInfo
	MOVE.W	InsNum(PC),D0
	BEQ.B	SampleNullInfo
	LSL.B	#2,D0
	LEA	SamplePtrs(PC),A0
	MOVE.L	(A0,D0.W),SamInfoPtr
	MOVE.L	124(A0,D0.W),SamInfoLen
	MOVEQ	#0,D0
	RTS

ShowMon	SF	ScopeEnable
	ST	DisableAnalyzer
	JSR	ClearRightArea
	LEA	MonitorData,A0
	MOVE.L	#MonitorSize,D0
	MOVEQ	#-1,D4
	JMP	cgjojo

WaitForDiskDrive
	JSR	StorePtrCol
	ST	DiskDriveBusy
	MOVE.L	4.W,A6
	LEA	$15E(A6),A0		; DeviceList
	LEA	TrackdiskName(PC),A1	; trackdisk.device
	JSR	_LVOFindName(A6)
	MOVE.L	D0,A6
	LEA	$24(A6),A6		; dn_GlobalVec
trdloop2
	MOVE.L	A6,A1
	MOVEQ	#4-1,D6
tdrloop	TST.L	(A1)+
	BEQ.B	tdrskip
	MOVE.L	-4(A1),A2
	BTST	#0,$22(A2)
	BNE.B	tdrnotset
tdrskip	DBRA	D6,tdrloop
	SF	DiskDriveBusy
	JMP	RestorePtrCol

DiskDriveBusy	dc.b	0
	EVEN

tdrnotset
	JSR	SetDiskPtrCol
	BRA.B	trdloop2

ClearSamStarts
	LEA	SamplePtrs+4(PC),A0
	MOVEQ	#31-1,D0
	MOVEQ	#0,D2
cssLoop	MOVE.L	(A0)+,D1
	BEQ.B	cssSkip
	MOVE.L	D1,A1
	CLR.W	(A1)
cssSkip	DBRA	D0,cssLoop
	RTS

GraphOffsets
	dc.w 31*40,30*40,29*40,28*40,27*40,26*40,25*40,24*40
	dc.w 23*40,22*40,21*40,20*40,19*40,18*40,17*40,16*40
	dc.w 15*40,14*40,13*40,12*40,11*40,10*40,09*40,08*40
	dc.w 07*40,06*40,05*40,04*40,03*40,02*40,01*40,00*40

SamNoteType	dc.w	0

ShowSamNote
	TST.W	SamScrEnable
	BEQ.W	Return3
	MOVE.L	NoteNamesPtr(PC),A4
	MOVE.W	#237*40+36,TextOffset
	MOVE.W	SampleNote(PC),D0
	LSL.W	#2,D0
	LEA	(A4,D0.W),A0
	MOVE.L	A0,ShowTextPtr
	MOVE.W	#4,TextLength
	BRA.W	ShowText

ShowResamNote
	TST.W	SamScrEnable
	BEQ.W	Return3
	MOVE.L	NoteNamesPtr(PC),A4
	MOVE.W	#248*40+36,TextOffset
	MOVE.W	ResampleNote(PC),D0
	LSL.W	#2,D0
	LEA	(A4,D0.W),A0
	MOVE.L	A0,ShowTextPtr
	MOVE.W	#4,TextLength
	BRA.W	ShowText

; -----------------------------------------------------------------------------
;                               EXE REPLAYER DATA
; -----------------------------------------------------------------------------

	CNOP 0,4
exeDotInfoData		INCBIN "bin/dotinfo.bin"
 	CNOP 0,4
exeReplayData		INCBIN "bin/exereplay.bin"
	CNOP 0,4
exeReplayRelocHunk	INCBIN "bin/reloc32hunk.bin"

; -----------------------------------------------------------------------------
;                                 GRAPHICS DATA
; -----------------------------------------------------------------------------

SpectrumAnaSize	= 839
AboutBoxSize	= 1730
ScopeSize	= 1713
DirScreenSize	= 2882
PLSTSize	= 1896-8
PosEdSize	= 1945-8
Edit1Size	= 1748
Edit2Size	= 1902
Edit3Size	= 2134
Edit4Size	= 2174
SetupScreenSize	= 5448
Setup2Size	= 5071
PresetEdSize	= 5169
SampScreenSize	= 3838
MonitorSize	= 817
HelpScreenSize	= 900

	CNOP 0,4
FontData	INCBIN "raw/ptfont.raw"
	CNOP 0,4
SpectrumAnaData	INCBIN "pak/ptspectrumana.pak"
	CNOP 0,4
ScopeData	INCBIN "pak/ptscope.pak"
	CNOP 0,4
AboutBoxData	INCBIN "pak/ptaboutbox.pak"
	CNOP 0,4
SureBoxData	INCBIN "raw/ptsurebox.raw"
	CNOP 0,4
ClearBoxData	INCBIN "raw/ptclearbox.raw"
	CNOP 0,4
FormatBoxData	INCBIN "raw/ptformatbox.raw"
	CNOP 0,4
TrackNameBox	INCBIN "raw/pttrknamebox.raw"
	CNOP 0,4
CrunchBoxData	INCBIN "raw/ptcrunchbox.raw"
	CNOP 0,4
DirScreenData	INCBIN "pak/ptfilereq.pak"
	CNOP 0,4
DirScreen2Data	INCBIN "pak/ptfilereq2.pak"
	CNOP 0,4
PLSTData	INCBIN "pak/ptplst.pak"
	CNOP 0,4
PosEdData	INCBIN "pak/ptposed.pak"
	CNOP 0,4
Edit1Data	INCBIN "pak/ptedit1.pak"
	CNOP 0,4
Edit2Data	INCBIN "pak/ptedit2.pak"
	CNOP 0,4
Edit3Data	INCBIN "pak/ptedit3.pak"
	CNOP 0,4
Edit4Data	INCBIN "pak/ptedit4.pak"
	CNOP 0,4
SetupScreenData	INCBIN "pak/ptsetup.pak"
	CNOP 0,4
Setup2Data	INCBIN "pak/ptsetup2.pak"
	CNOP 0,4
Setup2ToggleData	INCBIN "raw/ptsetup2toggles.raw"
	CNOP 0,4
PresetEdData	INCBIN "pak/ptpreseted.pak"
	CNOP 0,4
SampScreenData	INCBIN "pak/ptsampler.pak"
	CNOP 0,4
MonitorData	INCBIN "pak/ptmonitor.pak"
	CNOP 0,4
HelpScreenData	INCBIN "pak/pthelpscreen.pak"
	CNOP 0,4
VolBoxData	INCBIN "raw/ptvolbox.raw"
	CNOP 0,4
ToggleONdata	INCBIN "raw/pttoggleon.raw"
	CNOP 0,4
ToggleOFFdata	INCBIN "raw/pttoggleoff.raw"
	CNOP 0,4
S_BoxData	INCBIN "raw/ptletters.raw"
	
A_BoxData	EQU	S_BoxData+22
T_BoxData	EQU	S_BoxData+44
P_BoxData	EQU	S_BoxData+66
H_BoxData	EQU	S_BoxData+88
C_BoxData	EQU	S_BoxData+110
N_BoxData	EQU	S_BoxData+132
O_BoxData	EQU	S_BoxData+154

	; Converts pattern-period to LUT index for NotesNames1/NoteNames2 (dword)
Period2Note:
        dc.b 140,148,148,148,148,148,148,136,148,148,148,148,148,148,132,148
        dc.b 148,148,148,148,148,148,128,148,148,148,148,148,148,148,124,148
        dc.b 148,148,148,148,148,148,120,148,148,148,148,148,148,148,148,116
        dc.b 148,148,148,148,148,148,148,148,148,112,148,148,148,148,148,148
        dc.b 148,148,148,108,148,148,148,148,148,148,148,148,148,104,148,148
        dc.b 148,148,148,148,148,148,148,148,148,100,148,148,148,148,148,148
        dc.b 148,148,148,148,148, 96,148,148,148,148,148,148,148,148,148,148
        dc.b 148, 92,148,148,148,148,148,148,148,148,148,148,148,148,148, 88
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148, 84,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148, 80,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148, 76,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148, 72,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148, 68
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148, 64,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148, 60,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148, 56,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148, 52,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148, 48,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148, 44,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148, 40
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148, 36,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148, 32,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148, 28,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148, 24,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148, 20
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148, 16,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148, 12
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,  8,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,  4,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,148,148,148,148,148,148,148,148,148
        dc.b 148,148,148,148,148,148,148,  0
	EVEN

; -----------------------------------------------------------------------------
;                                 CHIPMEM DATA
; -----------------------------------------------------------------------------

	SECTION ptdata,DATA_C
	
	CNOP 0,4
BitplaneData	INCBIN "raw/ptmainscreen.raw"
	
TopMenusPos	EQU	BitplaneData+55
Setup2Menus	EQU	BitplaneData+506
SpectrumAnaPos	EQU	BitplaneData+1815
FormatBoxPos	EQU	BitplaneData+2090
SureBoxPos	EQU	BitplaneData+2100
SamScrPos	EQU	BitplaneData+4880
VolBoxPos	EQU	BitplaneData+6209

TToneData	; Tuning Tone (Sine Wave)
	dc.b    0,  25,  49,  71,  91, 106, 118, 126
	dc.b  127, 126, 118, 106,  91,  71,  49,  25
	dc.b    0, -25, -49, -71, -91,-106,-118,-126
	dc.b -127,-126,-118,-106, -91, -71, -49, -25

	CNOP 0,4
CopperList1
	; ---------------
	; video mode
	; ---------------
	dc.w	$008E	; DIWSTRT ($DFF08E)
	dc.w	$2C81	; "Normal" value
	dc.w	$0090	; DIWSTOP ($DFF090)
	dc.w	$2CC1	; "Normal" value
	dc.w	$0092	; DDFSTRT ($DFF092)
	dc.w	$0038	; "Normal" value
	dc.w	$0094	; DDFSTOP ($DFF094)
	dc.w	$00D0	; "Normal" value
	dc.w	$0102	; BPLCON1 ($DFF102)
	dc.w	$0000
	dc.w	$0104	; BPLCON2 ($DFF104)
	dc.w	$0024
	dc.w	$0106	; BPLCON3 ($DFF106)
	dc.w	$0C40
	dc.w	$0108	; BPL1MOD ($DFF108)
	dc.w	$0000
	dc.w	$010A	; BPL2MOD ($DFF10A)
	dc.w	$0000
	dc.w	$010C	; BPLCON4 ($DFF10C)
	dc.w	$0011
	dc.w	$01DC	; BEAMCON0 ($DFF1DC)
	dc.w	$0020	; = PAL flag set
	dc.w	$01FC	; FMODE ($DFF1FC)
	dc.w	$0000	; slow fetch (AGA compatible)
	; ---------------
	; sprites
	; ---------------
CopperSpriteList
	dc.w	$0120	; Sprite 0 high
	dc.w	0
	dc.w	$0122	; Sprite 0 low
	dc.w	0
	dc.w	$0124	; Sprite 1 high
	dc.w	0
	dc.w	$0126	; Sprite 1 low
	dc.w	0
	dc.w	$0128	; Sprite 2 high
	dc.w	0
	dc.w	$012A	; Sprite 2 low
	dc.w	0
	dc.w	$012C	; Sprite 3 high
	dc.w	0
	dc.w	$012E	; Sprite 3 low
	dc.w	0
	dc.w	$0130	; Sprite 4 high
	dc.w	0
	dc.w	$0132	; Sprite 4 low
	dc.w	0
	dc.w	$0134	; Sprite 5 high
	dc.w	0
	dc.w	$0136	; Sprite 5 low
	dc.w	0
	dc.w	$0138	; Sprite 6 high
	dc.w	0
	dc.w	$013A	; Sprite 6 low
	dc.w	0
	dc.w	$013C	; Sprite 7 high
	dc.w	0
	dc.w	$013E	; Sprite 7 low
	dc.w	0
	; ---------------
	; palette
	; ---------------
	dc.w	$0180	; Color 0
CopCol0 dc.w	$000
	dc.w	$0182	; Color 1
	dc.w	$AAA
	dc.w	$0184	; Color 2
	dc.w	$777
	dc.w	$0186	; Color 3
	dc.w	$444
	dc.w	$0188	; Color 4
	dc.w	$CCC
	dc.w	$018A	; Color 5
	dc.w	$A00
	dc.w	$018C	; Color 6
	dc.w	$000
	dc.w	$018E	; Color 7
	dc.w	$04D
CopCol1 dc.w	$01A2	; Color 1
	dc.w	$AAA
	dc.w	$01A4	; Color 2
	dc.w	$888
	dc.w	$01A6	; Color 3
	dc.w	$666
	dc.w	$01A0	; Color 4
	dc.w	$000
	dc.w	$01BA	; Color 5
	dc.w	$C00
	dc.w	$01BC	; Color 6
	dc.w	$900
	dc.w	$01BE	; Color 7
	dc.w	$F00
	; ---------------
	; bitplane pointers
	; ---------------
CopListBitplanes
	dc.w	$00E0	; Bitplane 0 high
	dc.w	0
	dc.w	$00E2	; Bitplane 0 low
	dc.w	0
	dc.w	$00E4	; Bitplane 1 high
	dc.w	0
	dc.w	$00E6	; Bitplane 1 low
	dc.w	0
	dc.w	$00E8	; Bitplane 2 high
NoteBplptrHigh
	dc.w	0
	dc.w	$00EA	; Bitplane 2 low
NoteBplptrLow
	dc.w	0
	; ---------------
	; misc
	; ---------------
	dc.w	$0100
	dc.w	$3200
CopListAnalyzer
	dcb.w	320,0
CopListInsPos
	dc.w	$B807	; Wait for line $88, pos $07
	dc.w	$FFFE
	dc.w	$0100	; bplcon0
	dc.w	$2200
CopListBpl4
	dc.w	$00E8	; Bitplane 4 high
	dc.w	0
	dc.w	$00EA	; Bitplane 4 low
	dc.w	0
	dc.w	$0188	; Color 4
NoteCol	dc.w	$004D
	dc.w	$B907	; Wait for line $89, pos $07
	dc.w	$FFFE
	dc.w	$0100	; bplcon0
	dc.w	$3200
CopListMark2	
	dcb.w	672,0
	dc.w	$E907	; Wait for line $E9, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	$FFD8
	dc.w	$0108	; bpl1mod
	dc.w	$FFD8
	dc.w	$EA07	; Wait for line $EA, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	0
	dc.w	$0108	; bpl1mod
	dc.w	0
	dc.w	$EB07	; Wait for line $E8, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	$FFD8
	dc.w	$0108	; bpl1mod
	dc.w	$FFD8
	dc.w	$EC07	; Wait for line $EC, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	0
	dc.w	$0108	; bpl1mod
	dc.w	0
	dc.w	$ED07	; Wait for line $ED, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	$FFD8
	dc.w	$0108	; bpl1mod
	dc.w	$FFD8
	dc.w	$EE07	; Wait for line $EE, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	0
	dc.w	$0108	; bpl1mod
	dc.w	0
	dc.w	$EF07	; Wait for line $EF, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	$FFD8
	dc.w	$0108	; bpl1mod
	dc.w	$FFD8
	dc.w	$F007	; Wait for line $F0, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	0
	dc.w	$0108	; bpl1mod
	dc.w	0
	dc.w	$F107	; Wait for line $F1, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	$FFD8
	dc.w	$0108	; bpl1mod
	dc.w	$FFD8
	dc.w	$F207	; Wait for line $F2, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	0
	dc.w	$0108	; bpl1mod
	dc.w	0
	dc.w	$F307	; Wait for line $F3, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	$FFD8
	dc.w	$0108	; bpl1mod
	dc.w	$FFD8
	dc.w	$F407	; Wait for line $F4, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	0
	dc.w	$0108	; bpl1mod
	dc.w	0
	dc.w	$F507	; Wait for line $F5, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	$FFD8
	dc.w	$0108	; bpl1mod
	dc.w	$FFD8
	dc.w	$F607	; Wait for line $F6, pos $07
	dc.w	$FFFE
	dc.w	$010A	; bpl2mod
	dc.w	0
	dc.w	$0108	; bpl1mod
	dc.w	0
	dc.w	$FFDF	; Wait for line $FF, pos $DF
	dc.w	$FFFE
	dc.w	$2907	; Wait for line $29, pos $07
	dc.w	$FFFE
	dc.w	$0100	; bplcon0
	dc.w	$2200
	dc.w	$2C07	; Wait for line $2C, pos $07
	dc.w	$FFFE
	dc.w	$0100	; bplcon0
	dc.w	$0200
	dc.w	$FFFF	; Wait for line $FF, pos $FF
	dc.w	$FFFE	; End of copperlist
	
CopperList2
	dc.w	$B607	; Wait for line $B6, pos $07
	dc.w	$FFFE
	dc.w	$0100	; bplcon0
	dc.w	$2200
CopList2Bpl4Ptr
	dc.w	$00E8	; Bitplane 4 high
	dc.w	0
	dc.w	$00EA	; Bitplane 4 low
	dc.w	0
	dc.w	$0188	; Color 4
	dc.w	$004D
	dc.w	$01AA	; Color 21
	dc.w	$00F0
	dc.w	$01B2	; LoopSprite color
	dc.w	$00FF
	dc.w	$B707	; Wait for line $B7, pos $07
	dc.w	$FFFE
	dc.w	$0100	; bplcon0
	dc.w	$3200
	dc.w	$FFDF	; Wait for line $FF, pos $DF
	dc.w	$FFFE
	dc.w	$2907	; Wait for line $29, pos $07
	dc.w	$FFFE
	dc.w	$0100	; bplcon0
	dc.w	$2200
	dc.w	$2C07	; Wait for line $2C, pos $07
	dc.w	$FFFE
	dc.w	$0100	; bplcon0
	dc.w	$0200
	dc.w	$FFFF	; Wait for line $FF, pos $FF
	dc.w	$FFFE	; End of copperlist
	
PointerSpriteData
	dc.w	0,0
	dc.w	$FFFF,$FFFF,$8002,$FFFE,$BFF4,$C00C,$BFE8,$C018
	dc.w	$BFD0,$C030,$BFE8,$C018,$BFF4,$C00C,$BFFA,$C006
	dc.w	$BFFD,$C003,$BFFA,$C006,$B7F4,$C80C,$ABE8,$DC18
	dc.w	$95D0,$F630,$A2A0,$E360,$C140,$C1C0,$8080,$8080
NoSpriteData
	dc.w	0,0,0,0
CursorSpriteData
	dc.w	0,0
	dc.w	$FFE0,$FFE0,$FFE0,$FFE0,$8020,$0000,$8020,$0000
	dc.w	$8020,$0000,$8020,$0000,$8020,$0000,$8020,$0000
	dc.w	$8020,$0000,$8020,$0000,$8020,$0000,$8020,$0000
	dc.w	$0000,$FFE0,$0000,$FFE0
	dc.w	0,0
LineCurSpriteData
	dc.w	0,0,$0000,$FE00,$0000,$FE00,$0000,$0000,0,0
VUSpriteData1
	dc.w	$E85B,$E901
	dcb.l	48,$C0C03FC0
	dc.w	0,0
VUSpriteData2
	dc.w	$E87F,$E901
	dcb.l	48,$C0C03FC0
	dc.w	0,0
VUSpriteData3
	dc.w	$E8A3,$E901
	dcb.l	48,$C0C03FC0
	dc.w	0,0
VUSpriteData4
	dc.w	$E8C7,$E901
	dcb.l	48,$C0C03FC0
	dc.w	0,0
LoopSpriteData1
	dc.w	0,0
	dc.w	$F000,0,$F000,0,$F000,0,$F000,0,$1000,0,$1000,0,$1000,0,$1000,0
	dc.w	$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0
	dc.w	$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0
	dc.w	$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$7000,0
	dc.w	$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0
	dc.w	$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0
	dc.w	$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0
	dc.w	$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0,$1000,0
	dc.w	0,0
LoopSpriteData2
	dc.w	0,0
	dc.w	$F000,0,$F000,0,$F000,0,$F000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$E000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	0,0
PlayPosSpriteData
	dc.w	0,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
	dc.w	0,0

; -----------------------------------------------------------------------------
;                                   CHIPMEM BSS DATA
; -----------------------------------------------------------------------------

	SECTION ptbssc,BSS_C
	
	CNOP 0,4
TextBitplane	ds.b (320*685)/8 ; 685 scanlines (exactly enough!)

; -----------------------------------------------------------------------------
;                                   BSS DATA
; -----------------------------------------------------------------------------

	SECTION ptbss,BSS

	CNOP 0,4
FileInfoBlock	ds.b	256
FIB_EntryType	EQU	FileInfoBlock+4
FIB_FileName	EQU	FileInfoBlock+8
FIB_FileSize	EQU	FileInfoBlock+124
FIB_DateStamp	EQU	FileInfoBlock+132

InfoData	ds.b	36
TopMenusBuffer	ds.b	2200
TextDataBuffer	ds.b	546
TrackBuffer	ds.b	256
TrackReadBuffer	ds.b	256
CmdsBuffer	ds.b	256
BlockBuffer	ds.b	256
PatternBuffer	ds.b	1024
PattDiskBuffer	ds.b	1024
UndoBuffer	ds.b	1024

TrackdiskIOExtTD
		ds.w	1
		ds.l	3
TDPortPtr	ds.l	1
		ds.w	1
Fmt_tja		ds.w	1
		ds.l	2
		ds.b	3
Fmt_hmmm	ds.b	1
		ds.w	1
FmtDataSize	ds.w	2
FmtDataPtr	ds.w	2
FmtDiskOffset	ds.l	9

SplitTransTable	ds.b	38
SplitInstrTable	ds.b	38

ModulesPath2	ds.b	64
SongsPath2	ds.b	64
SamplePath2	ds.b	64
TrackPath2	ds.b	64
PattPath2	ds.b	64
	EVEN

; Setup Data
SetupData	ds.b	26
SongsPath	ds.b	32
ModulesPath	ds.b	32
SamplePath	ds.b	32
PrintPath	ds.b	32
ColorTable	ds.w	8
PackMode	ds.b	1
ModPackMode	ds.b	1
SplitFlag	ds.b	1
FilterFlag	ds.b	1
TransDelFlag	ds.b	1
ShowDecFlag	ds.b	1
AutoDirFlag	ds.b	1
AutoExitFlag	ds.b	1
ModOnlyFlag	ds.b	1
MIDIFlag	ds.b	1
SplitData	ds.b	4
		ds.b	4
		ds.b	4
		ds.b	4
KeyRepDelay	ds.w	1
KeyRepSpeed	ds.w	1
Accidental	ds.b	1
		ds.b	1	; not in use
ExtCommands	ds.b	32*8	; setup data now at 256 bytes
		ds.w	1	; not in use
MaxPLSTEntries	ds.w	1
MultiModeNext	ds.b	4
EffectMacros	ds.w	10
RawIFFPakMode	ds.b	1
IntMode		ds.b	1
OverrideFlag	ds.b	1
NosamplesFlag	ds.b	1
BlankZeroFlag	ds.b	1
ShowDirsFlag	ds.b	1
ShowPublicFlag	ds.b	1
CutToBufFlag	ds.b	1
IFFLoopFlag	ds.b	1
SysReqFlag	ds.b	1
Tempo		ds.w	1
DMAWait		ds.w	1	; not used
TuneNote	ds.w	1
TToneVol	ds.w	1
LoadTrackToBufferFlag	ds.b	1
LoadPattToBufferFlag	ds.b	1
SalvageAddress	ds.b	6
PTPath		ds.b	32  ;  setup data now at 512 bytes
DefaultSpeed	ds.w	1
VUmeterColors	ds.w	48
AnalyzerColors	ds.w	40
TrackPath	ds.b	32
PattPath	ds.b	32
SalvageFlag	ds.b	1
OneHundredPattFlag	ds.b	1
SaveIconsFlag	ds.b	1
LoadNamesFlag	ds.b	1
SaveNamesFlag	ds.b	1
LoadPLSTFlag	ds.b	1
ScreenAdjustFlag	ds.b	1
SamplePackFlag	ds.b	1
RealVUMetersFlag ds.b	1
		ds.b	229 ; pad to 1024 bytes
; End of Setup Data

	CNOP 0,4
HelpTextIndex	ds.l	256
HelpTextData	ds.b	656

InpEvPort	ds.b	34
InpEvIOReq	ds.b	48
	CNOP 0,4
ScopeInfo	ds.b	ScopeInfoSize*4
	CNOP 0,4
ScopeSamInfo	ds.b	16*31
BlankSample	ds.b	314
FileName	ds.b	96
NewFileName	ds.b	96
SampleFileName	ds.b	28
PresetNameText	ds.b	22
DirInputName	ds.b	DirNameLength
InputFileName	ds.b	20
NewInputName	ds.b	DirNameLength
TempSampArea	ds.w	380
SaveColors	ds.w	40+48
BeamCONTemp	ds.w	2
PaulaDMAWaitScanlines	ds.w	1
GUIDelayScanlines	ds.w	1
VolToolBoxShown	ds.b	1
ShowRasterbar	ds.b	1

END

; /* End of File */
