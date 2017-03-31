RestoreMRValues::
	call ReinitializeMRRegisters
	ld hl, .text
	call MessageBox
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	ret

.text
	db "MR registers set<LF>"
	db "to default values.<@>"

ReinitializeMRRegisters::
	xor a
	ld hl, rMR3w
	ld [hld], a
	ld [hld], a
	ld [hld], a
	ld [hl], 1
	ret

MRMappingTest::
	ld hl, .initial_text
	rst Print
	ld hl, EmptyString
	rst Print
	xor a ;ld a, MR3_MAP_REGS
	ld [rMR3w], a
	call .test_random
	call .test_random
	call .test_random
	call ReinitializeMRRegisters ;exits with a = hl = 0
	ld [hCurrent + 2], a
	ld [hCurrent + 1], a
	inc a
	ld [hCurrent], a
	ld h, rMR0r >> 8
	ld a, [hli]
	dec a
	or [hl]
	inc hl
	or [hl]
	call nz, .error
	ld hl, EmptyString
	rst Print
	ret

.initial_text
	db "Testing default MR<LF>"
	db "register mapping<LF>"
	db "addresses...<@>"

.error_text
	db "FAILED: MR values<LF>"
	db "did not match<LF>"
	db "expected (ROM bank<LF>"
	db "$"
	bigdw hCurrent + 1, hCurrent
	db ", RAM<LF>"
	db "bank $"
	bigdw hCurrent + 2
	db ")<@>"

.test_random
	ld hl, rMR0w
	call Random
	ld [hli], a
	ld [hCurrent], a
	ld c, a
	call Random
	ld [hli], a
	ld [hCurrent + 1], a
	ld b, a
	call Random
	ld [hl], a
	ld [hCurrent + 2], a
	ld hl, rMR2r
	cp [hl]
	jr nz, .error
	dec hl
	ld a, [hld]
	cp b
	jr nz, .error
	ld a, [hl]
	cp c
	ret z
.error
	ld hl, .error_text
	rst Print
	jp IncrementErrorCount

MRWritesTest::
	ld hl, .initial_text
	rst Print
	ld hl, EmptyString
	rst Print
	call ReinitializeMRRegisters ;also maps regs to $a000
	ld hl, rMR3w
	ld [hl], MR3_RUMBLE_OFF
	ld [hl], MR3_RTC_OFF
	ld [hl], MR3_CLEAR_RTC_OVERFLOW
	ld bc, 1
	ld e, b
	ld a, 10
	ld [hMax], a
	jr .check
.loop
	ld hl, rMR0w
	call Random
	ld [hli], a
	ld c, a
	call Random
	ld [hli], a
	ld b, a
	call Random
	ld [hl], a
	ld e, a
.check
	ld hl, rMR0r
	call Random
	ld [hli], a
	call Random
	ld [hli], a
	call Random
	ld [hli], a
	call Random
	ld [hl], a
	ld l, rMR0r & $ff
	ld a, [hli]
	cp c
	jr nz, .error
	ld a, [hli]
	cp b
	jr nz, .error
	ld a, [hli]
	cp e
	jr nz, .error
	ld a, [hli]
	and $f
	jr z, .handle_loop
.error
	ld [hCurrent], a
	ld a, l
	add a, "0" - 1
	push af
	call .select_value
	ld [hCurrent + 1], a
	ld hl, wTextBuffer
	push hl
	ld bc, 56
	xor a
	rst FillByte
	pop de
	push de
	ld hl, .error_text
	rst CopyString
	pop af
	cp "3"
	jr z, .not_three
	inc a
.not_three
	ld [wTextBuffer + 10], a
	pop hl
	rst Print
	call IncrementErrorCount
.handle_loop
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	ld hl, EmptyString
	rst Print
	jp ReinitializeMRRegisters

.initial_text
	db "Testing writes on<LF>"
	db "MR read-only<LF>"
	db "addresses...<@>"

.error_text
	db "FAILED: MR? = $"
	bigdw hCurrent
	db "<LF>"
	db "(expected: $"
	bigdw hCurrent + 1
	db ")<@>"

.select_value
	ld a, c
	dec l
	ret z
	ld a, b
	dec l
	ret z
	ld a, e
	dec l
	ret z
	xor a
	ret
