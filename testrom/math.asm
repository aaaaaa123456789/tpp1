Multiply16::
	; multiplies bc times hl, stores the result in hProduct (little-endian) and preserves all registers
	push af
	push bc
	push de
	push hl
	ld d, h
	ld e, l
	xor a
	ld hl, hProduct
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld h, a
	ld l, a
.loop
	srl d
	rr e
	jr nc, .next
	ld a, [hProduct]
	add a, c
	ld [hProduct], a
	ld a, [hProduct + 1]
	adc b
	ld [hProduct + 1], a
	ld a, [hProduct + 2]
	adc l
	ld [hProduct + 2], a
	ld a, [hProduct + 3]
	adc h
	ld [hProduct + 3], a
.next
	sla c
	rl b
	rl l
	rl h
	ld a, e
	or d
	jr nz, .loop
	pop hl
	pop de
	pop bc
	pop af
	ret

AddNTimesFunction::
	; adds a * bc to hl
	rra ; and a from below and above resets carry
	jr nc, .no_add
	add hl, bc
.no_add
	sla c
	rl b
	and a
	ret z
	jr AddNTimesFunction

DivideByTen::
	; divides bcde by 10, remainder in a
	push hl
	ld h, 0
	ld l, b
	call .divide
	ld b, l
	ld l, c
	call .divide
	ld c, l
	ld l, d
	call .divide
	ld d, l
	ld l, e
	call .divide
	ld e, l
	ld a, h
	pop hl
	ret

.divide
	; divides hl by 10, quotient in l, remainder in h
	; required h < 10
	push bc
	ld bc, 0
	srl h
	rr l
	rr c
	ld a, l
	and 15
	add a, c
	ld c, a
	ld a, l
	swap a
	and 15
	ld b, a
	add a, c
	ld c, a
	ld a, h
	swap a
	add a, h
	add a, b
	ld b, a
	add a, a
	add a, b
	ld l, a
	ld a, h
	add a, c
	rlca
	pop bc
.loop
	ld h, a
	cp 10
	ret c
	sub 10
	inc l
	jr .loop

CountLeadingZeros::
	; counts the leading 0 bits in bcde, returns in a (0 - 32)
	push hl
	xor a
	ld l, b
	call .count
	jr c, .done
	ld l, c
	call .count
	jr c, .done
	ld l, d
	call .count
	jr c, .done
	ld l, e
	call .count
.done
	pop hl
	ret

.count
	ld h, 8
.loop
	sla l
	ret c
	inc a
	dec h
	jr nz, .loop
	ret
