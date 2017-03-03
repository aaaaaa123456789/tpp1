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

ClearMemory::
	ld hl, $c000
	ld bc, Stack - $c000 ; don't touch the stack, we don't care about it
	;(also, stack must be aligned to $100 for this code to work nicely)
	xor a
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ld c, $81 ;skip hGBType
.hram_loop
	ld [c], a
	inc c
	jr nz, .hram_loop
	reti ;this also clears rIE, so we just return with interrupts on after that

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
.loop
	ld a, [hli]
	cp c
	jr z, .done
	ld [de], a
	inc de
	jr .loop
.done
	pop bc
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
