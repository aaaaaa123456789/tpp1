Init::
	di
	ld sp, StackTop
	call VBlankBusyWait
	ld a, $51
	ld [rLCDC], a
	call ClearMemory
	ld de, Font
	ld hl, vTilesLow tile $20
	ld a, $5f
	call Load1bpp
	ld de, ExtendedFont
	ld hl, vTilesLow tile $10
	ld a, $10
	call Load1bpp
	ld a, $ff
	ld bc, $a0
	ld hl, $fe00
	ld [rWY], a
	ld [rWX], a
	rst FillByte
	xor a
	ld [rSTAT], a
	call ClearScreen
	ld hl, vBGMap
	ld bc, $400
	ld a, " "
	rst FillByte
	ld a, 1
	ld [rIE], a
	ld hl, rLCDC
	set 7, [hl]
	; fallthrough

Main::
	decoord 5, 8
	ld hl, .testing
	rst CopyString
	jr @

.testing
	db "Testing...<@>"
