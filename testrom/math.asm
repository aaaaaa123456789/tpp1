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

AddNTimes::
	; adds a * bc to hl, preserving bc
	and a
	ret z
	push bc
.loop
	rra ; and a from below and above resets carry
	jr nc, .no_add
	add hl, bc
.no_add
	sla c
	rl b
	and a
	jr nz, .loop
.done
	pop bc
	ret
