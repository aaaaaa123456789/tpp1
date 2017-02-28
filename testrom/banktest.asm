TestROMBank:
	; test ROM bank bc; return carry if invalid (with hl containing the invalid address)
	; assume that the bank is already selected (so we can test ROM bank 1 on boot)
	; we assume that every bank (other than 0) is loaded with a simple pattern based on the bank number
	; namely, every bank (starting from 1) is filled so that every four-byte value is the number of the bank multiplied by the address
	; values are 32-bit little endian
	; we don't test the full bank because that would be silly; we just test the start and the end, and a few random addresses inbetween
	push hl
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
	pop hl
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
