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

PrintByte::
	; prints a to hl, as long as it's <= c, using b digits (b = 1-3)
	; if a > c, prints b question marks instead
	; returns with hl pointing to the end, abc clobbered
	cp c
	jr c, .go
	jr z, .go
	ld a, "?"
.question_mark_loop
	ld [hli], a
	dec b
	jr nz, .question_mark_loop
	ret
.go
	push de
	ld e, 0
	ld c, b
	dec c
	jr z, .no_hundreds
	dec c
	jr z, .no_hundreds
	ld c, e
.hundreds_loop
	sub 100
	jr c, .done_hundreds
	inc c
	jr .hundreds_loop
.done_hundreds
	add a, 100
	ld e, c
	call .print_digit
.no_hundreds
	dec b
	jr z, .no_tens
	ld c, 0
.tens_loop
	sub 10
	jr c, .done_tens
	inc c
	jr .tens_loop
.done_tens
	add a, 10
	inc e
	dec e
	jr nz, .print_tens_always
	call .print_digit
	jr .no_tens
.print_tens_always
	push af
	ld a, c
	add a, "0"
	ld [hli], a
	pop af
.no_tens
	add a, "0"
	ld [hli], a
	pop de
	ret

.print_digit
	push af
	ld a, c
	and a
	jr nz, .digit_OK
	ld a, (" " - "0") & $ff
.digit_OK
	add a, "0"
	ld [hli], a
	pop af
	ret
