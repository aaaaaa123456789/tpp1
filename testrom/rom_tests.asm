TestROMBankRangeOption::
	call ClearScreen
	hlcoord 0, 0
	lb de, SCREEN_WIDTH, SCREEN_HEIGHT - 4
	call Textbox
	ld a, 3
	rst DelayFrames
	ld de, .screen_text
	hlcoord 1, 2
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
	db "Max ROM bank:<LF><LF>"
	db "Initial bank:<LF>"
	db "Final bank:<LF>"
	db "Step:<@>"

.inputs
	hex_input_dw 15, 4, wInitialROMBank
	hex_input_dw 15, 5, wFinalROMBank
	hex_input 17, 6, wROMBankStep
	dw 0

GetMaxValidROMBank:
	; returns max bank in de, carry if the ROM size is invalid
	ld a, [MR3ROMSize]
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
	ret

TestAllROMBanksOption::
	call GetMaxValidROMBank
	jr nc, .go
	ld hl, .error_text
	jp MessageBox
.error_text
	db "Could not detect<LF>"
	db "last ROM bank.<@>"

.go
	xor a
	ld hl, wInitialROMBank
	ld [hli], a
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hl], 1
	; fallthrough

TestROMBankRange:
	ld a, [wROMBankStep]
	ld hl, .zero_step_text
	and a
	jr z, .message_box
	ld hl, wInitialROMBank
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
	ld hl, .no_banks_selected_text
.message_box
	jp MessageBox

.no_banks_selected_text
	db "No ROM banks have<LF>"
	db "been selected.<@>"

.zero_step_text
	db "The step cannot<LF>"
	db "be zero.<@>"

.go
	call MakeFullscreenTextbox
	xor a
	ld hl, wROMBankErrors
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld hl, .testing_text
	rst Print
	call GetMaxValidROMBank
	call c, .unknown_max_bank
	ld a, e
	ld [hMax], a
	ld a, d
	ld [hMax + 1], a
	ld a, b
	or c
	call z, .test_home_bank
.loop
	ld hl, wFinalROMBank + 1
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
	call .increment_error_count
	ld hl, .invalid_bank_text
	rst Print
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
	jr nc, .handle_loop
	call .increment_error_count
	ld hl, .failed_text
	rst Print
.handle_loop
	ld a, [wROMBankStep]
	add a, c
	ld c, a
	jr nc, .loop
	inc b
	jr nz, .loop
.done
	ld hl, EmptyString
	rst Print
	ld hl, wROMBankErrors
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld c, [hl]
	or c
	or e
	ld hl, TestsPassedString
	jr z, .print_message
	ld b, 0
	call GenerateErrorCountString
.print_message
	rst Print
	jp EndFullscreenTextbox

.testing_text
	db "Testing ROM banks<LF>"
	db "$"
	bigdw wInitialROMBank + 1, wInitialROMBank
	db "-$"
	bigdw wFinalROMBank + 1, wFinalROMBank
	db ", every<LF>"
	db "$"
	bigdw wROMBankStep
	db " bank(s)...<@>"

.failed_text
	db "FAILED: bank $"
	bigdw hCurrent + 1, hCurrent
	db "<@>"

.invalid_bank_text
	db "ERROR: bank $"
	bigdw hCurrent + 1, hCurrent
	db "<LF>"
	db "is not valid<@>"

.test_home_bank
	xor a
	ld h, a
	ld l, a ;hl = rMR0w
	ld [hli], a
	ld [hl], a
	call TestROMHomeBank
	ld a, [wROMBankStep]
	ld c, a
	ret nc
	xor a
	ld [hCurrent], a
	ld [hCurrent + 1], a
	ld hl, .failed_text
	rst Print
.increment_error_count
	ld hl, wROMBankErrors
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret

.unknown_max_bank
	ld de, $ffff
	ld hl, .unknown_max_bank_text
	rst Print
	jr .increment_error_count

.unknown_max_bank_text
	db "ERROR: could not<LF>"
	db "obtain highest ROM<LF>"
	db "bank number<@>"

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
	jr .random_testing_loop
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
