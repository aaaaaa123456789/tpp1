VBlank::
	push bc
	push de
	push hl
	push af
	ld a, 1
	db $18, $01 ;skip the next instruction
	
	reti ; $48 handler
	
	ld [hVBlankOccurred], a
	ld a, [hVBlankLine]
	ld c, a
	db $18, $01 ;skip the next instruction
	
	reti ; $50 handler
	
	cp SCREEN_HEIGHT
	jr nc, .no_screen_update
	add a, a
	db $18, $01 ;skip the next instruction
	
	reti ; $58 handler

	add a, a
	add a, c
	add a, a
	add a, a	
	ld c, a
	db $18, $01 ;skip the next instruction

	reti ; $60 handler

	ld b, 0
	rl b	
	ld hl, wScreenBuffer
	add hl, bc
	ld a, [hVBlankLine]
	swap a
	rlca
	ld e, a
	and $1f
	add a, vBGMap >> 8
	ld d, a
	ld a, e
	and $e0
	ld e, a
	lb bc, LINES_PER_VBLANK, SCREEN_WIDTH / 5

.loop
	rept 5
		ld a, [hli]
		ld [de], a
		inc de
	endr
	dec c
	jr nz, .loop
	ld a, e
	add a, $20 - SCREEN_WIDTH
	ld e, a
	jr nc, .no_pointer_carry
	inc d
.no_pointer_carry
	ld a, [hVBlankLine]
	inc a
	cp SCREEN_HEIGHT
	jr c, .line_OK
	ld hl, wScreenBuffer
	ld de, vBGMap
	xor a
.line_OK
	ld [hVBlankLine], a
	ld c, SCREEN_WIDTH / 5
	dec b
	jr nz, .loop
.no_screen_update

	call UpdateJoypad
	
	ld hl, hFrameCounter
	inc [hl]
	jr nz, .frame_counter_done
	inc hl
	inc [hl]
.frame_counter_done

	pop af
	pop hl
	pop de
	pop bc
	reti
