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

ClearMR4:
	ld hl, rMR3w
	ld [hl], MR3_RUMBLE_OFF
	ld [hl], MR3_RTC_OFF
	ld [hl], MR3_CLEAR_RTC_OVERFLOW
	ret

MRWritesTest::
	ld hl, .initial_text
	rst Print
	ld hl, EmptyString
	rst Print
	call ReinitializeMRRegisters ;also maps regs to $a000
	call ClearMR4
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
	dec a
	push af
	call .select_value
	ld [hCurrent + 1], a
	pop af
	call PrintMRMismatch
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

PrintMRMismatch:
	push de
	push af
	ld hl, wTextBuffer
	push hl
	ld bc, 56
	xor a
	rst FillByte
	pop de
	ld hl, .mismatch_string
	rst CopyString
	pop af
	add a, "0"
	cp "3"
	jr nz, .not_three
	inc a
.not_three
	ld [wTextBuffer + 10], a
	ld hl, wTextBuffer
	rst Print
	pop de
	ret

.mismatch_string
	db "FAILED: MR? = $"
	bigdw hCurrent
	db "<LF>"
	db "(expected: $"
	bigdw hCurrent + 1
	db ")<@>"

MRMirroringTest::
	ld hl, .initial_text
	rst Print
	ld hl, EmptyString
	rst Print
	call ClearMR4
	ld a, 5
	ld [hMax], a
.loop
	ld hl, wValueBuffer
	push hl
	ld de, rMR0w
	call Random
	ld [hli], a
	ld [de], a
	inc de
	call Random
	ld [hli], a
	ld [de], a
	inc de
	call Random
	ld [hl], a
	ld [de], a
.resample
	call Random
	and $fc
	ld e, a
	call Random
	and $1f
	ld c, a
	or $a0
	ld d, a
	ld a, c
	or e
	jr z, .resample
	pop hl
	ld c, 4
.check_loop
	ld a, [de]
	inc de
	cp [hl]
	inc hl
	jr nz, .error
	dec c
	jr nz, .check_loop
.done_checking
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	ld hl, EmptyString
	rst Print
	jp ReinitializeMRRegisters

.error
	ld a, e
	and $fc
	ld [hCurrent], a
	ld a, d
	ld [hCurrent + 1], a
	ld hl, .error_text
	rst Print
	call IncrementErrorCount
	jr .done_checking

.initial_text
	db "Testing MR address<LF>"
	db "mirroring...<@>"

.error_text
	db "FAILED: address<LF>"
	db "$"
	bigdw hCurrent + 1, hCurrent
	db " did not<LF>"
	db "match MR values<@>"

MRReadingTest::
	ld hl, .initial_text
	rst Print
	ld hl, EmptyString
	rst Print
	ld a, 2
	ld [hMax], a
.loop
	ld hl, rMR0r
	ld d, l
	ld e, l
.inner_loop
	call Random
	ld [de], a
	ld b, [hl]
	ld c, a
	cp b
	call nz, .error
	inc de
	inc hl
	ld a, e
	cp 3
	jr c, .inner_loop
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	ld hl, EmptyString
	rst Print
	jp ReinitializeMRRegisters

.error
	ld a, b
	ld [hCurrent], a
	ld a, c
	ld [hCurrent + 1], a
	ld a, l
	call PrintMRMismatch
	ld l, e
	ld h, rMR0r >> 8
	jp IncrementErrorCount

.initial_text
	db "Testing MR reading<LF>"
	db "speed...<@>"

RunAllMRTests::
	call MRMappingTest
	call MRMirroringTest
	call MRReadingTest
	call MRWritesTest
	jp ReinitializeMRRegisters
