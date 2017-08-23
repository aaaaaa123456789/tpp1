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
	ld c, 10
.random_mixing_loop
	call Random
	dec c
	jr nz, .random_mixing_loop
	ld de, Font
	ld hl, vTilesLow tile $20
	ld a, $5f
	call Load1bpp
	ld de, ExtendedFont
	ld hl, vTilesLow tile $10
	ld a, $d
	call Load1bpp
	xor a
	ld [rSTAT], a
	dec a
	ld bc, $a0
	ld hl, $fe00
	ld [rWY], a
	ld [rWX], a
	rst FillByte
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
	ld de, TitleString
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
	call .handle_pass_fail_from_zero
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
	call .handle_pass_fail_from_zero
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
	call .handle_pass_fail_from_zero
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
	call .handle_pass_fail_from_zero
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
	call .handle_pass_fail_from_zero
	ld a, 10
	rst DelayFrames
	decoord 5, 17
	ld hl, ContinueString
	rst CopyString
	call WaitForAPress
	call DoubleSpeed
	ld hl, wRandomSeed
	ld e, 8
.random_reseed_loop
	ld a, [rDIV]
	xor [hl]
	ld [hli], a
	call Random
	dec e
	jr nz, .random_reseed_loop
	jp MainMenu

.handle_pass_fail_from_zero
	push af
	ld a, [hInitialTestNumber]
	inc a
	ld b, a
	ld [hInitialTestNumber], a
	pop af
	ld hl, .pass_string
	jr z, .print
	xor a
	scf
.flag_loop
	rla
	dec b
	jr nz, .flag_loop
	ld b, a
	ld a, [hInitialTestResult]
	or b
	ld [hInitialTestResult], a
	ld hl, .fail_string
.print
	rst CopyString
	ret

.testing_initial_values
	db "Testing initial<LF>"
	db "values<...><@>"

.pass_string
	db "PASS<@>"
.fail_string
	db "FAIL<@>"

.mr0_string
	db "MR0 = $01:<@>"
.mr1_string
	db "MR1 = $00:<@>"
.mr2_string
	db "MR2 = $00:<@>"
.mr4_string
	db "MR4[0:1] = 0:<@>"
.rom1_string
	db "ROM1 mapped:<@>"

Restart::
	ld hl, wRandomSeed + 7
	ld c, 4
.random_saving_loop
	ld a, [hld]
	ld e, a
	ld a, [hld]
	ld d, a
	push de
	dec c
	jr nz, .random_saving_loop
	ld a, [hInitialTestResult]
	ld b, a
	ld hl, hFrameCounter
	ld a, [hli]
	ld c, a
	push bc
	ld a, [hli]
	ld c, a
	ld b, [hl]
	push bc
	push hl
	call ClearMemory
	pop hl
	pop bc
	ld a, b
	ld [hld], a
	ld a, c
	ld [hld], a
	pop bc
	ld [hl], c
	ld a, b
	ld [hInitialTestResult], a
	ld hl, wRandomSeed
	ld c, 4
.random_reloading_loop
	pop de
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a
	dec c
	jr nz, .random_reloading_loop
	call ClearScreen
	ld a, 1
	ld [rIE], a
	jp MainMenu
