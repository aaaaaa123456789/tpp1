TestROMBankSampleOption::
	call ClearErrorCount
	call MakeFullscreenTextbox
	ld hl, .testing_text
	rst Print
	call PrintEmptyString
	call GetMaxValidROMBank
	jr nc, .valid_max
	ld de, $ffff
	ld hl, UnknownMaxBankString
	call PrintAndIncrementErrorCount
.valid_max
	xor a
	ld [hCurrent], a
	ld [hCurrent + 1], a
	ld h, a
	ld l, a
	ld [hli], a ; MR0 = 0
	ld [hl], a
	call TestROMHomeBank
	ld hl, BankFailedString
	call c, PrintAndIncrementErrorCount
	ld bc, 0
	call CountLeadingZeros
	cpl
	add a, 33
	add a, a
	dec a
	ld [hMax], a ;test between 1 and 63 random banks based on ROM size
.loop
	call Random
	and d
	ld b, a
	call Random
	and e
	ld c, a
	or b
	jr z, .loop
	ld a, c
	ld hl, rMR0w
	ld [hli], a
	ld [hl], b
	ld [hCurrent], a
	ld a, b
	ld [hCurrent + 1], a
	call TestROMBank
	ld hl, BankFailedString
	call c, PrintAndIncrementErrorCount
	ld a, [hMax]
	dec a
	ld [hMax], a
	jr nz, .loop
	call PrintEmptyString
	jp PrintErrorCountAndEnd

.testing_text
	db "Testing random ROM<LF>"
	db "banks in range...<@>"

TestROMBankRangeOption::
	call ClearScreen
	hlcoord 0, 0
	lb de, SCREEN_WIDTH, SCREEN_HEIGHT - 4
	call Textbox
	ld a, 3
	rst DelayFrames
	ld hl, MaxROMBankString
	decoord 1, 2
	rst CopyString
	ld de, .screen_text
	hlcoord 1, 4
	rst PrintString
	call GetMaxValidROMBank
	hlcoord 15, 2
	jr c, .invalid_max
	ld a, d
	call PrintHexByte
	ld a, e
	call PrintHexByte
	jr .max_printed
.invalid_max
	ld a, "?"
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
.max_printed
	ld hl, .inputs
	call HexadecimalEntry
	ret c
	jp TestROMBankRange

.screen_text
	db "Initial bank:<LF>"
	db "Final bank:<LF>"
	db "Step:<@>"

.inputs
	hex_input_dw 15, 4, wInitialBank
	hex_input_dw 15, 5, wFinalBank
	hex_input 17, 6, wBankStep
	dw 0

GetMaxValidROMBank::
	; returns max bank in de, carry if the ROM size is invalid
	ld a, [TPP1ROMSize]
	cp 16
	ccf
	ret c
	inc a
	ld de, 2
	jr .handle_loop
.loop
	sla e
	rl d
.handle_loop
	dec a
	jr nz, .loop
	dec de
	and a
	ret

TestROMBankRange:
	ld a, [wBankStep]
	ld hl, ZeroStepString
	and a
	jr z, .message_box
	ld hl, wInitialBank
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, b
	cp [hl]
	jr c, .go
	jr nz, .nope
	ld a, e
	cp c
	jr nc, .go
.nope
	ld hl, NoBanksSelectedString
.message_box
	jp MessageBox

.go
	ld hl, ROMBankRangeTest
	jp ExecuteTest

CheckLastROMBankExists:
	call GetMaxValidROMBank
	ret nc
	ld hl, UnknownLastROMBankString
	rst Print
	call PrintEmptyString
	call IncrementErrorCount
	scf
	ret

TestAllROMBanks::
	call CheckLastROMBankExists
	ret c
	xor a
	ld hl, wInitialBank
	ld [hli], a
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hl], 1
	; fallthrough
ROMBankRangeTest:
	ld hl, .testing_text
	rst Print
	call GetMaxValidROMBank
	call c, .unknown_max_bank
	ld a, e
	ld [hMax], a
	ld a, d
	ld [hMax + 1], a
	ld hl, wInitialBank
	ld a, [hli]
	ld c, a
	ld b, [hl]
	or b
	call z, .test_home_bank
.loop
	ld hl, wFinalBank + 1
	ld a, [hld]
	cp b
	jr c, .done
	jr nz, .in_range
	ld a, [hl]
	cp c
	jr c, .done
.in_range
	ld a, c
	ld [hCurrent], a
	ld a, b
	ld [hCurrent + 1], a
	ld a, [hMax]
	cpl
	and c
	ld e, a
	ld a, [hMax + 1]
	cpl
	and b
	or e
	jr z, .valid_bank
	ld hl, InvalidBankString
	call PrintAndIncrementErrorCount
	jr .handle_loop
.valid_bank
	ld hl, rMR0w
	ld a, c
	ld [hli], a
	ld [hl], b
	call TestROMBank
	ld a, [hCurrent]
	ld c, a
	ld a, [hCurrent + 1]
	ld b, a
	ld hl, BankFailedString
	call c, PrintAndIncrementErrorCount
.handle_loop
	ld a, [wBankStep]
	add a, c
	ld c, a
	jr nc, .loop
	inc b
	jr nz, .loop
.done
	jp PrintEmptyString

.testing_text
	db "Testing ROM banks<LF>"
	db "$"
	bigdw wInitialBank + 1, wInitialBank
	db "-$"
	bigdw wFinalBank + 1, wFinalBank
	db ", every<LF>"
	db "$"
	bigdw wBankStep
	db " bank(s)...<@>"

.test_home_bank
	xor a
	ld h, a
	ld l, a ;hl = rMR0w
	ld [hli], a
	ld [hl], a
	call TestROMHomeBank
	ld a, [wBankStep]
	ld c, a
	ld b, 0
	ret nc
	xor a
	ld [hCurrent], a
	ld [hCurrent + 1], a
	ld hl, BankFailedString
	jr PrintAndIncrementErrorCount

.unknown_max_bank
	ld de, $ffff
	ld hl, UnknownMaxBankString
PrintAndIncrementErrorCount::
	rst Print
	jp IncrementErrorCount

TestROMHomeBank:
	; test ROM bank 0 in $4000-$7fff
	; we can use any data to test since it should always be mapped to $0000-3fff; for convenience, we'll use this very function, as well as some random addresses
	; return carry if failed (hl pointing to the failed address)
	; assume that the bank has already been selected
	push de
	push bc
	ld c, .end - TestROMHomeBank
	ld hl, TestROMHomeBank | $4000
	ld de, TestROMHomeBank
.initial_loop
	ld a, [de]
	inc de
	cp [hl]
	jr nz, .mismatch
	inc hl
	dec c
	jr nz, .initial_loop
	ld c, 8
.random_testing_loop
	call Random
	and $3f
	ld d, a
	or $40
	ld h, a
	call Random
	and $fc
	ld e, a
	ld l, a
	ld b, 4
.inner_loop
	ld a, [de]
	inc de
	cp [hl]
	jr nz, .mismatch
	inc hl
	dec b
	jr nz, .inner_loop
	dec c
	jr nz, .random_testing_loop
	; carry must be clear here
.done
	pop bc
	pop de
	ret
.mismatch
	scf
	jr .done
.end

TestROMBank::
	; test ROM bank bc; return carry if invalid (with hl containing the invalid address)
	; assume that the bank is already selected (so we can test ROM bank 1 on boot)
	; we assume that every bank (other than 0) is loaded with a simple pattern based on the bank number
	; namely, every bank (starting from 1) is filled so that every four-byte value is the number of the bank multiplied by the address
	; values are 32-bit little endian
	; we don't test the full bank because that would be silly; we just test the start and the end, and a few random addresses inbetween
	push de
	ld hl, $4000
	ld e, 4
.initial_loop
	call .check_value
	jr nz, .error
	dec e
	jr nz, .initial_loop
	ld hl, $7fe0
	ld e, 8
.final_loop
	call .check_value
	jr nz, .error
	dec e
	jr nz, .final_loop
	ld e, 8
.random_loop
	call Random
	and $fc
	ld l, a
	call Random
	and $3f
	or $40
	ld h, a
	call .check_value
	jr nz, .error
	dec e
	jr nz, .random_loop
	jr .ok
.error
	scf
.ok
	pop de
	ret

.check_value
	call Multiply16
	ld a, [hProduct]
	cp [hl]
	ret nz
	inc hl
	ld a, [hProduct + 1]
	cp [hl]
	ret nz
	inc hl
	ld a, [hProduct + 2]
	cp [hl]
	ret nz
	inc hl
	ld a, [hProduct + 3]
	cp [hl]
	ret nz
	inc hl
	ret

RunAllROMTests::
	call TestAllROMBanks
	; fallthrough

TestROMBankswitchSpeed::
	ld hl, TestingROMBankSwitchingSpeedString
	rst Print
	call PrintEmptyString
	call CheckLastROMBankExists
	ret c
	call GetMaxValidROMBank
	ld a, 5
	ld [hMax], a
	xor a
	ld h, a
	ld l, a
	ld [hli], a
	ld [hl], a ;bankswitch to home
	ld [hCurrent], a
	ld [hCurrent + 1], a
.loop
	call Random
	and e
	ld c, a
	call Random
	and d
	ld b, a
	ld a, [hCurrent]
	cp c
	jr nz, .go
	ld a, [hCurrent + 1]
	cp b
	jr z, .loop
.go
	push de
	ld a, c
	ld [hCurrent], a
	ld a, b
	ld [hCurrent + 1], a
	ld hl, $4004
	ld de, rMR0w
	ld a, b
	ld [rMR1w], a
	ld a, c
	ld [de], a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	call ValidateROMBankDataAt4004
	pop de
	ld hl, hMax
	dec [hl]
	jr nz, .loop
PrintEmptyString::
	ld hl, EmptyString
	rst Print
	ret

ValidateROMBankDataAt4004:
	ld a, [hCurrent]
	ld l, a
	ld a, [hCurrent + 1]
	ld h, a
	or l
	jr z, .validate_home
	push bc
	ld bc, $4004
	call Multiply16
	pop bc
.do_validation
	ld hl, hProduct
	ld a, [hli]
	cp e
	jr nz, .error
	ld a, [hli]
	cp d
	jr nz, .error
	ld a, [hli]
	cp c
	jr nz, .error
	ld a, [hl]
	cp b
	ret z
.error
	ld hl, wDataBuffer
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld a, c
	ld [hli], a
	ld [hl], b
	ld hl, .error_text
	jp PrintAndIncrementErrorCount

.validate_home
	; the ROM begins with di ($f3), xor a ($af), ld sp, $d000 ($31 $00 $d0), jp Restart ($c3 $f3 $02)
	ld hl, hProduct ;just use it as storage for the "correct" values
	ld a, $d0
	ld [hli], a
	ld a, $c3
	ld [hli], a
	ld a, Restart & $ff
	ld [hli], a
	ld [hl], Restart >> 8
	jr .do_validation

.error_text
	db "FAILED: switching<LF>"
	db "to bank $"
	bigdw hCurrent + 1, hCurrent
	db "<LF>"
	db "(at $4004 expected<LF>"
	db "$"
	bigdw hProduct + 3, hProduct + 2, hProduct + 1, hProduct
	db ", got<LF>"
	db "$"
	bigdw wDataBuffer + 3, wDataBuffer + 2, wDataBuffer + 1, wDataBuffer
	db ")<@>"
