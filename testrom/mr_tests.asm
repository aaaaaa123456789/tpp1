RestoreMRValues::
	call ReinitializeMRRegisters
	ld hl, .text
	call MessageBox
	jp UpdateMenuScreen

.text
	db "MR registers set<LF>"
	db "to default values.<@>"

PrintEmptyStringAndReinitializeMRRegisters::
	call PrintEmptyString
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
	call PrintWithBlankLine
	xor a ;ld a, MR3_MAP_REGS
	ld [rMR3w], a
	call .test_random
	call .test_random
	call .test_random
	call ReinitializeMRRegisters ;exits with a = hl = 0
	ld [hSelectedRAMBank], a
	ld [hSelectedROMBank + 1], a
	inc a
	ld [hSelectedROMBank], a
	ld h, rMR0r >> 8
	ld a, [hli]
	dec a
	or [hl]
	inc hl
	or [hl]
	call nz, PrintMRReadErrorAndIncrementCount
	jp PrintEmptyString

.initial_text
	db "Testing default MR<LF>"
	db "register mapping<LF>"
	db "addresses<...><@>"

.test_random
	call GenerateRandomMRValues
	ld hl, rMR2r
	cp [hl]
	jr nz, PrintMRReadErrorAndIncrementCount
	dec hl
	ld a, [hld]
	cp b
	jr nz, PrintMRReadErrorAndIncrementCount
	ld a, [hl]
	cp c
	ret z
PrintMRReadErrorAndIncrementCount:
	ld hl, .error_text
	jp PrintAndIncrementErrorCount

.error_text
	db "FAILED: MR values<LF>"
	db "did not match<LF>"
	db "(ROM bank $"
	bigdw hSelectedROMBank + 1, hSelectedROMBank
	db ",<LF>"
	db "RAM bank $"
	bigdw hSelectedRAMBank
	db ")<@>"

ClearMR4::
	ld hl, rMR3w
	ld [hl], MR3_RUMBLE_OFF
	ld [hl], MR3_RTC_OFF
	ld [hl], MR3_CLEAR_RTC_OVERFLOW
	ret

MRWritesTest::
	ld hl, .initial_text
	rst Print
	call PrintEmptyStringAndReinitializeMRRegisters ;also maps regs to $a000
	call ClearMR4
	ld bc, 1
	ld e, b
	ld a, 10
	ld [hMax], a
	jr .check
.loop
	call GenerateRandomMRValues
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
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_text
	db "Testing writes on<LF>"
	db "MR read-only<LF>"
	db "addresses<...><@>"

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

GenerateRandomMRValues:
	ld hl, rMR0w
	call Random
	ld [hli], a
	ld [hSelectedROMBank], a
	ld c, a
	call Random
	ld [hli], a
	ld [hSelectedROMBank + 1], a
	ld b, a
	call Random
	ld [hl], a
	ld [hSelectedRAMBank], a
	ld e, a
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
	cp 3
	ccf
	adc "0"
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

MRMirroringReadTest::
	ld hl, .initial_text
	call PrintWithBlankLine
	call ClearMR4 ;exits with hl = rMR3w
	ld [hl], MR3_MAP_REGS
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
	ld d, a
	or e
	jr z, .resample
	set 7, d
	set 5, d
	pop hl
	ld c, 3
.check_loop
	ld a, [de]
	inc de
	cp [hl]
	inc hl
	jr nz, .error
	dec c
	jr nz, .check_loop
	ld a, [de]
	and $f
	jr z, .done_checking
.error
	ld a, e
	and $fc
	ld [hCurrent], a
	ld a, d
	ld [hCurrent + 1], a
	ld hl, .error_text
	call PrintAndIncrementErrorCount
.done_checking
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_text
	db "Testing MR address<LF>"
	db "read mirroring<...><@>"

.error_text
	db "FAILED: address<LF>"
	db "$"
	bigdw hCurrent + 1, hCurrent
	db " did not<LF>"
	db "match MR values<@>"

MRMirroringWriteTest::
	ld hl, .initial_text
	call PrintWithBlankLine
	xor a ;ld a, MR3_MAP_REGS
	ld [rMR3w], a
	ld a, 5
	ld [hMax], a
.loop
	call Random
	and $3f
	ld h, a
	call Random
	and $fc
	ld l, a
	or h
	jr z, .loop
	call Random
	ld c, a
	ld [hli], a
	call Random
	ld b, a
	ld [hli], a
	call Random
	ld [hld], a
	dec hl
	ld d, h
	ld e, l
	ld hl, rMR2r
	cp [hl]
	jr nz, .error
	dec hl
	ld a, [hld]
	cp b
	jr nz, .error
	ld a, [hl]
	cp c
	jr z, .ok
.error
	ld a, e
	ld [hCurrent], a
	ld a, d
	ld [hCurrent + 1], a
	ld hl, .error_text
	call PrintAndIncrementErrorCount
.ok
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_text
	db "Testing MR address<LF>"
	db "write mirroring<...><@>"
.error_text
	db "FAILED: writing to<LF>"
	db "address $"
	bigdw hCurrent + 1, hCurrent
	db " did<LF>"
	db "not write to MR<LF>"
	db "registers<@>"

MRReadingTest::
	ld hl, .initial_text
	call PrintWithBlankLine
	xor a ;ld a, MR3_MAP_REGS
	ld [rMR3w], a
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
	jp PrintEmptyStringAndReinitializeMRRegisters

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
	db "speed<...><@>"

MRPoppingTest::
	ld hl, .initial_text
	call PrintWithBlankLine
	call ClearMR4 ;exits with hl = rMR3w
	ld [hl], MR3_MAP_REGS
	ld a, 3
	ld [hMax], a
.loop
	call GenerateRandomMRValues
	call .test_values
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_text
	db "Testing popping<LF>"
	db "MR registers<...><@>"

.test_values
	di
	ld hl, sp + 0
	ld sp, rMR0r
	pop de
	ld a, c
	cp e
	jr nz, .done
	ld a, b
	cp d
	jr nz, .done
	pop de
	ld a, [hSelectedRAMBank]
	cp e
	jr nz, .done
	ld a, d
	and $f
.done
	ld sp, hl
	ei
	jp nz, PrintMRReadErrorAndIncrementCount
	ret

RunAllMRTests::
	call MRMappingTest
	call MRReadingTest
	call MRWritesTest
	call MRMirroringReadTest
	call MRMirroringWriteTest
	call MRPoppingTest
	jp ReinitializeMRRegisters
