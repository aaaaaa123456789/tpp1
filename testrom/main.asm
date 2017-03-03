Init::
	di
	ld sp, StackTop
	call VBlankBusyWait
	ld a, $51
	ld [rLCDC], a
	ld hl, $c000
	call GetRandomSeed
	push bc
	push de
	ld hl, $ca46
	call GetRandomSeed
	push bc
	push de
	call ClearMemory
	ld hl, wRandomSeed
	ld c, 4
.random_loading_loop
	pop de
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a
	dec c
	jr nz, .random_loading_loop
	ld de, Font
	ld hl, vTilesLow tile $20
	ld a, $5f
	call Load1bpp
	ld de, ExtendedFont
	ld hl, vTilesLow tile $10
	ld a, $c
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
	call LoadPalettes
	ld a, 1
	ld [rIE], a
	ld hl, rLCDC
	set 7, [hl]
	; fallthrough

Main::
	ld de, .title_string
	hlcoord 1, 0
	rst PrintString
	hlcoord 0, 6
	lb de, 20, 10
	call Textbox
	ld de, .testing_initial_values
	hlcoord 1, 7
	rst PrintString
	ld a, 10
	rst DelayFrames
	decoord 1, 10
	ld hl, .mr0_string
	rst CopyString
	ld a, 5
	rst DelayFrames
	ld a, [rMR0r]
	cp 1
	decoord 15, 10
	call .print_pass_fail_from_zero
	ld a, 10
	rst DelayFrames
	decoord 1, 11
	ld hl, .mr1_string
	rst CopyString
	ld a, 5
	rst DelayFrames
	ld a, [rMR1r]
	and a
	decoord 15, 11
	call .print_pass_fail_from_zero
	ld a, 10
	rst DelayFrames
	decoord 1, 12
	ld hl, .mr2_string
	rst CopyString
	ld a, 5
	rst DelayFrames
	ld a, [rMR2r]
	and a
	decoord 15, 12
	call .print_pass_fail_from_zero
	ld a, 10
	rst DelayFrames
	decoord 1, 13
	ld hl, .mr4_string
	rst CopyString
	ld a, 5
	rst DelayFrames
	ld a, [rMR4r]
	and 3
	decoord 15, 13
	call .print_pass_fail_from_zero
	ld a, 20
	rst DelayFrames
	ld hl, .rom1_string
	decoord 1, 14
	rst CopyString
	ld a, 3
	rst DelayFrames
	ld bc, 1
	call TestROMBank
	sbc a ;transfer !carry into zero
	decoord 15, 14
	call .print_pass_fail_from_zero
	ld a, 10
	rst DelayFrames
	decoord 5, 17
	ld hl, .continue_string
	rst CopyString
	call WaitForAPress
	call DoubleSpeed
	jp MainMenu

.print_pass_fail_from_zero
	ld hl, .pass_string
	jr z, .print
	ld hl, .fail_string
.print
	rst CopyString
	ret

.title_string
	db " TPP1 testing ROM<LF>"
	db "<LF>"
	db "http://github.com/<LF>"
	db "TwitchPlaysPokemon<LF>"
	db "      /tpp1/<@>"

.testing_initial_values
	db "Testing initial<LF>"
	db "values...<@>"

.pass_string
	db "PASS<@>"
.fail_string
	db "FAIL<@>"

.mr0_string
	db "MR0 = 01h:<@>"
.mr1_string
	db "MR1 = 00h:<@>"
.mr2_string
	db "MR2 = 00h:<@>"
.mr4_string
	db "MR4[0:1] = 0:<@>"
.rom1_string
	db "ROM1 mapped:<@>"

.continue_string
	db "<A> Continue<@>"
