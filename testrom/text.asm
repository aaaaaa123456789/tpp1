MakeFullscreenTextbox::
	hlcoord 0, 0
	lb de, SCREEN_WIDTH, SCREEN_HEIGHT
	; fallthrough

MakeCurrentTextbox::
	; same as Textbox, but it also sets it as current
	ld a, l
	ld [hTextboxPointer], a
	ld a, h
	ld [hTextboxPointer + 1], a
	ld a, d
	ld [hTextboxWidth], a
	ld a, e
	ld [hTextboxHeight], a
	xor a
	ld [hTextboxLine], a
	; fallthrough

Textbox::
	; draw at hl, d tiles wide, e tiles tall
	; minimum values for each are 2
	dec d
	ret z
	dec e
	ret z
	push bc
	ld c, SCREEN_WIDTH
	push hl
	ld [hl], "<TL>"
	inc hl
	ld b, d
	ld a, "<->"
	jr .handle_top_loop
.top_loop
	ld [hli], a
.handle_top_loop
	dec b
	jr nz, .top_loop
	ld [hl], "<TR>"
	pop hl
	jr .handle_line_loop
.line_loop
	push hl
	ld [hl], "<|>"
	inc hl
	ld b, d
	ld a, " "
	jr .handle_inner_loop
.inner_loop
	ld [hli], a
.handle_inner_loop
	dec b
	jr nz, .inner_loop
	ld [hl], "<|>"
	pop hl
.handle_line_loop
	add hl, bc
	dec e
	jr nz, .line_loop
	ld [hl], "<BL>"
	inc hl
	ld a, "<->"
	jr .handle_bottom_loop
.bottom_loop
	ld [hli], a
.handle_bottom_loop
	dec d
	jr nz, .bottom_loop
	ld [hl], "<BR>"
	pop bc
	ret

PrintStringFunction:
	ld bc, SCREEN_WIDTH
	push hl
.loop
	ld a, [de]
	inc de
	and a
	jr z, .done
	cp "<LF>"
	jr z, .line_feed
	ld [hli], a
	jr .loop

.line_feed
	pop hl
	add hl, bc
	push hl
	jr .loop

.done
	add sp, 2
	ret

ScrollTextbox::
	push hl
	push de
	push bc
	ld a, [hTextboxPointer]
	ld l, a
	ld a, [hTextboxPointer + 1]
	ld h, a
	ld de, SCREEN_WIDTH
	add hl, de
	inc hl
	push hl
	add hl, de
	pop de
	ld a, [hTextboxHeight]
	sub 2
	ld b, a
.loop
	dec b
	jr z, .done
	ld a, [hTextboxWidth]
	sub 2
	ld c, a
	push hl
.inner_loop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .inner_loop
	pop de
	ld hl, SCREEN_WIDTH
	add hl, de
	jr .loop
.done
	ld a, [hTextboxWidth]
	sub 2
	ld c, a
	ld a, " "
	ld h, d
	ld l, e
.clear_loop
	ld [hli], a
	dec c
	jr nz, .clear_loop
	pop bc
	pop de
	pop hl
	ld a, [hTextboxLine]
	sub 1
	ret c
	ld [hTextboxLine], a
	ret

PrintFunction::
	ld d, h
	ld e, l
	ld a, [hTextboxHeight]
	sub 2
	ld b, a
.line_loop
	call .print_line
	and a
	jr nz, .line_loop
	ret

.print_line
	ld a, [hTextboxLine]
	cp b
	jr c, .go
	call ScrollTextbox
	jr .print_line
.go
	push bc
	ld c, a
	ld a, [hTextboxPointer]
	ld l, a
	ld a, [hTextboxPointer + 1]
	ld h, a
	ld a, c
	inc hl
	inc a
	ld [hTextboxLine], a
	ld bc, SCREEN_WIDTH
	rst AddNTimes
	pop bc
	ld a, [hTextboxWidth]
	sub 2
	ld c, a
.loop
	ld a, [de]
	inc de
	and a
	ret z
	cp "<LF>"
	ret z
	cp $a0
	jr nc, .print_value
	ld [hli], a
.handle_loop
	dec c
	jr nz, .loop
	ld a, [de]
	inc de
	and a
	ret z
	cp "<LF>"
	ret z
	dec de
	ret

.print_value
	push bc
	ld b, a
	ld a, [de]
	inc de
	ld c, a
	ld a, [bc]
	call PrintHexByte
	pop bc
	ld a, c ;non-zero
	dec c
	ret z
	jr .handle_loop

MessageBox:
	push bc
	push de
	push hl
	hlcoord 0, 8
	ld de, wSavedScreenData
	ld bc, 4 * SCREEN_WIDTH
	push hl
	rst CopyBytes
	pop hl
	lb de, SCREEN_WIDTH, 4
	call Textbox
	pop de
	hlcoord 1, 9
	rst PrintString
	ld a, 6
	ld [hVBlankLine], a
	call WaitForButtonPress
	xor a
	ld [hVBlankLine], a
	ld hl, wSavedScreenData
	decoord 0, 8
	ld bc, 4 * SCREEN_WIDTH
	rst CopyBytes
	ld a, 2
	rst DelayFrames
	pop de
	pop bc
	ret

EndFullscreenTextbox::
	ld hl, EmptyString
	push hl
	rst Print
	pop hl
	rst Print
	ld hl, ContinueString
	decoord 5, 16
	rst CopyString
	jp WaitForAPress
