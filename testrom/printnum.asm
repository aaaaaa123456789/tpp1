PrintNumber::
	; prints bcde to hl; returns hl incremented
	push bc
	push de
	push hl
	ld hl, wDigitsBuffer + 10
	xor a ;ld a, "<@>"
	ld [hld], a
.loop
	call DivideByTen
	add a, "0"
	ld [hld], a
	ld a, b
	or c
	or d
	or e
	jr nz, .loop
	inc hl
	pop de
	rst CopyString
	ld h, d
	ld l, e
	pop de
	pop bc
	ret

PrintHexByte::
	; prints a (as a two-digit hex value) to hl; returns hl incremented
	push af
	swap a
	call .print_nibble
	pop af
.print_nibble
	and 15
	add a, "0"
	cp "9" + 1
	jr c, .digit
	add a, "A" - ("9" + 1)
.digit
	ld [hli], a
	ret
