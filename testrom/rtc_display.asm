GenerateTimeString::
	; in: hl = pointer to string; bcde = time data
	; format: wk??? ??? ??:??:??
	ld a, "w"
	ld [hli], a
	ld a, "k"
	ld [hli], a
	push de
	push bc
	ld a, b
	lb bc, 3, 255
	call PrintByte
	ld a, " "
	ld [hli], a
	pop bc
	push bc
	push hl
	ld a, c
	swap a
	rrca
	and 7
	ld bc, 3
	ld hl, .days_of_the_week
	rst AddNTimes
	pop de
	rst CopyBytes
	ld h, d
	ld l, e
	ld a, " "
	ld [hli], a
	pop bc
	ld a, c
	and $1f
	lb bc, 2, 23
	call PrintByte
	pop de
	ld a, d
	call .print_minutes_or_seconds
	ld a, e
	call .print_minutes_or_seconds
	ld [hl], "<@>"
	ret

.days_of_the_week
	db "SunMonTueWedThuFriSat???"

.print_minutes_or_seconds
	ld [hl], ":"
	inc hl
	ld c, "0"
.division_loop
	cp 10
	jr c, .done_dividing
	inc c
	sub 10
	jr .division_loop
.done_dividing
	ld [hl], c
	inc hl
	add a, "0"
	ld [hli], a
	ret
