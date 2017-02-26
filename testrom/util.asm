ClearScreen::
	ld bc, SCREEN_HEIGHT * SCREEN_WIDTH
	ld hl, wScreenBuffer
	ld a, " "
	rst FillByte
	ret

InvertByte::
	push bc
	lb bc, 0, 8
.loop
	add a, a
	rr b
	dec c
	jr nz, .loop
	ld a, b
	pop bc
	ret

UpdateJoypad::
	ld a, [hButtonsHeld]
	ld [hButtonsLast], a
	ld c, rJOYP & $ff
	; for some reason I don't quite understand, the joypad register uses 0 as yes and 1 as no
	; so in order to select direction keys (bit 4), we need to set bit 4 to 0... don't even ask
	ld a, $2f
	ld [c], a
	; D-Pad keys seem to take two reads to stabilize. Source: lots of probably unverified code in the wild that probably also took each other as source
	ld a, [c]
	ld a, [c]
	; ...and we invert it, because remember, bits are *cleared* to indicate a button pressed!
	cpl
	and 15
	swap a
	ld b, a
	; ...now with buttons...
	ld a, $1f
	ld [c], a
	; ...which seem to take 6 reads to stabilize... (source: voodoo incantations found in most code out there)
	rept 6
		ld a, [c]
	endr
	; ...and another inversion
	cpl
	; combine with the previous result...
	or b
	ld [hButtonsHeld], a
	; ...and we're almost done
	ld b, a
	ld a, [hButtonsLast]
	cpl
	and b
	ld [hButtonsPressed], a
	ret
