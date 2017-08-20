DelayFrame::
	push af
	xor a
	ld [hVBlankOccurred], a
.loop
	halt
	ld a, [hVBlankOccurred]
	and a
	jr z, .loop
	pop af
	ret

VBlankBusyWait::
	; same as DelayFrame, but it can be called in di mode
	; and therefore burns through the CPU
	; unless the LCD is disabled, in which case we don't care, and we return carry to tell the caller that we don't care
	; basically the only practical use ever for this function is actually waiting to disable the LCD, so the carry flag doesn't matter
	; but we get the flag for free, since it comes from the control flow, so why not
	; well I guess it's not as free if we need a ccf, but I'm too lazy to change the flow now
	; this function has a lot of comments, doesn't it
	ld a, [rLCDC]
	add a, a
	ccf
	ret c
.loop
	ld a, [rLY]
	cp $90
	ret nc
	jr .loop

CopyBytesUntilMatch::
	push bc
	ld c, a
	jr .handle_loop
.loop
	ld [de], a
	inc de
.handle_loop
	ld a, [hli]
	cp c
	jr nz, .loop
	pop bc
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
