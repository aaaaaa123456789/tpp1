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
