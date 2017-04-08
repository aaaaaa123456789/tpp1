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
	cp 60
	jr nc, .minute_second_overflow
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
.minute_second_overflow
	ld a, "?"
	ld [hli], a
	ld [hli], a
	ret

DisplayRTCState::
	call LatchMapRTC
	ld hl, rRTCW
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld d, a
	ld e, [hl]
	xor a ;ld a, MR3_MAP_REGS
	ld [rMR3w], a
	ld a, [rMR4r]
	push af
	ld hl, wTextBuffer
	ld a, b
	call PrintHexByte
	ld a, c
	call PrintHexByte
	ld a, d
	call PrintHexByte
	ld a, e
	call PrintHexByte
	pop af
	rra
	rra
	rra
	push af
	ld a, " "
	ld [hli], a
	ld a, "o"
	ld [hli], a
	jr c, .on
	ld a, "f"
	ld [hli], a
	ld [hli], a
	jr .printed_on_off
.on
	ld a, "n"
	ld [hli], a
	ld a, " "
	ld [hli], a
.printed_on_off
	pop af
	rra
	jr nc, .no_overflow
	push de
	ld d, h
	ld e, l
	ld hl, .overflow_text
	rst CopyString
	ld h, d
	ld l, e
	pop de
.no_overflow
	ld a, "<LF>"
	ld [hli], a
	call GenerateTimeString
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	ld hl, wTextBuffer
	jp MessageBox

.overflow_text
	db " ovflw<@>"
