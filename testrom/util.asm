ClearScreen::
	ld bc, SCREEN_HEIGHT * SCREEN_WIDTH
	ld hl, wScreenBuffer
	ld a, " "
	rst FillByte
	ret

CopyBytesFunctionLoop:
	ld a, [hli]
	ld [de], a
	inc de
CopyBytesFunction::
	dec c
	jr nz, CopyBytesFunctionLoop
	dec b
	jr nz, CopyBytesFunctionLoop
	ret

Load1bpp::
	; loads a 1bpp from de at tile hl, a tiles long
	push bc
	ld b, a
	ld c, 8
.loop
	ld a, [de]
	call InvertByte
	ld [hli], a
	ld [hli], a
	inc de
	dec c
	jr nz, .loop
	ld c, 8
	dec b
	jr nz, .loop
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
	; D-Pad keys seem to take six reads to stabilize. Source: lots of probably unverified code in the wild that probably also took each other as source
	rept 6
		ld a, [c]
	endr
	; ...and we invert it, because remember, bits are *cleared* to indicate a button pressed!
	cpl
	and 15
	swap a
	ld b, a
	; ...now with buttons...
	ld a, $1f
	ld [c], a
	; ...which seem to take 6 reads to stabilize as well... (source: voodoo incantations found in most code out there)
	rept 6
		ld a, [c]
	endr
	; ...and another inversion
	cpl
	and 15
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

WaitForAPress::
	ld a, [hButtonsPressed]
	and A_BUTTON
	jr z, .loop
	call DelayFrame
	jr WaitForAPress
.loop
	ld a, [hButtonsPressed]
	and A_BUTTON
	ret nz
	call DelayFrame
	jr .loop

DoubleSpeed::
	; set double speed if we're on a GBC. This should make some stuff faster.
	ld a, [hGBType]
	cp $11
	ret nz
	; if we're already in double speed, do nothing
	ld a, [rKEY1]
	cp $80
	ret nc
	; otherwise, prepare a speed switch
	or 1
	ld [rKEY1], a
	ld a, $3f
	ld [rJOYP], a
	xor a
	ld [rIF], a
	ld [rIE], a
	; and do it
	stop
	; finally, restore rIE
	inc a
	ld [rIE], a
	ret

LoadPalettes::
	; only load them if we're on a GBC
	ld a, [hGBType]
	cp $11
	ret nz
	; initialize the register to a convenient location
	ld a, $be
	ld [rBGPI], a
	; and load all palettes just in case, so we don't have to care about a dirty attribute map
	lb bc, 8, rBGPD & $ff
.loop
	; we load an actual four-shade grayscale just in case some code eventually uses shades 1 and 2
	xor a
	ld [c], a
	ld [c], a
	dec a
	ld [c], a
	ld [c], a
	ld a, $b5
	ld [c], a
	ld a, $56
	ld [c], a
	ld a, $4a
	ld [c], a
	ld a, $29
	ld [c], a
	dec b
	jr nz, .loop
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
