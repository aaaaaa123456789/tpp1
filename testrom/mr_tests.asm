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
