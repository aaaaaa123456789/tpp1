ClearScreen::
	ld bc, SCREEN_HEIGHT * SCREEN_WIDTH
	ld hl, wScreenBuffer
	ld a, " "
	rst FillByte
	ret

ClearScreenAndStopUpdates::
	call ClearScreen
	ld a, 3
	rst DelayFrames
	ld a, -1
	ldh [hVBlankLine], a
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

FillByteFunction::
	inc b
	inc c
	jr .handle_loop
.loop
	ld [hli], a
.handle_loop
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

Load1bpp::
	; loads a 1bpp from de at tile hl, a tiles long
	push bc
	ld b, a
	ld c, 8
.loop
	ld a, [de]
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
	ldh a, [hButtonsHeld]
	ldh [hButtonsLast], a
	ld c, LOW(rJOYP)
	; for some reason I don't quite understand, the joypad register uses 0 as yes and 1 as no
	; so in order to select direction keys (bit 4), we need to set bit 4 to 0... don't even ask
	ld a, $2f
	ldh [c], a
	; D-Pad keys seem to take six reads to stabilize. Source: lots of probably unverified code in the wild that probably also took each other as source
	rept 6
		ldh a, [c]
	endr
	; ...and we invert it, because remember, bits are *cleared* to indicate a button pressed!
	cpl
	and 15
	swap a
	ld b, a
	; ...now with buttons...
	ld a, $1f
	ldh [c], a
	; ...which seem to take 6 reads to stabilize as well... (source: voodoo incantations found in most code out there)
	rept 6
		ldh a, [c]
	endr
	; ...and another inversion
	cpl
	and 15
	; combine with the previous result...
	or b
	ldh [hButtonsHeld], a
	; ...and we're almost done
	ld b, a
	ldh a, [hButtonsLast]
	cpl
	and b
	ldh [hButtonsPressed], a
	; now we check for soft reset
	ldh a, [hButtonsHeld]
	or ~(A_BUTTON | B_BUTTON | SELECT | START)
	inc a
	ret nz
DoReset::
	call ReinitializeMRRegisters
	rst Reset ;does not return

WaitForAPress::
	ldh a, [hButtonsPressed]
	and A_BUTTON
	jr z, .loop
	call DelayFrame
	jr WaitForAPress
.loop
	ldh a, [hButtonsPressed]
	and A_BUTTON
	ret nz
	call DelayFrame
	jr .loop

WaitForButtonPress::
	; returns carry if B is pressed or nc if A is pressed
	push bc
	ldh a, [hButtonsPressed]
	cpl
	ld b, a
.loop
	call DelayFrame
	ldh a, [hButtonsPressed]
	ld c, a
	cpl
	or b
	ld b, a
	and c
	and A_BUTTON | B_BUTTON
	jr z, .loop
	pop bc
	cp B_BUTTON ;carry if only A was pressed
	scf
	ret

DoubleSpeed::
	; set double speed if we're on a GBC. This should make some stuff faster.
	ldh a, [hGBType]
	cp $11
	ret nz
	; if we're already in double speed, do nothing
	ldh a, [rKEY1]
	cp $80
	ret nc
DoSpeedSwitch::
	; otherwise, prepare a speed switch
	or 1
	ldh [rKEY1], a
	ld a, $3f
	ldh [rJOYP], a
	xor a
	ldh [rIF], a
	ldh [rIE], a
	; and do it
	stop
	; finally, restore rIE
	inc a
	ldh [rIE], a
	ret

GetCurrentSpeed::
	; returns carry if we're running on double speed
	ldh a, [hGBType]
	xor $11 ;xor clears carry
	; this is not even a GBC at all
	ret nz
	ldh a, [rKEY1]
	add a, a
	ret

ClearMemory::
	ld hl, $c000
	ld bc, Stack - $c000 ; don't touch the stack, we don't care about it
	assert LOW(Stack) == 0
	xor a
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	assert hGBType == $ff80
	ld c, LOW(hGBType + 1)
.hram_loop
	ldh [c], a
	inc c
	jr nz, .hram_loop
	reti ;this also clears rIE, so we just return with interrupts on after that

FillRandomBuffer::
	push bc
	push de
	push hl
	call Random
	ld b, a
	call Random
	ld c, a
	call Random
	ld d, a
	call Random
	ld e, a
	ld a, $10
	di
	ld hl, sp + 0
	ld sp, wRandomBuffer + $40
.loop
	push de
	push bc
	dec a
	jr nz, .loop
	ld sp, hl
	pop hl
	pop de
	pop bc
	xor a
	ldh [rIF], a ;if we're in vblank, discard it
	reti
