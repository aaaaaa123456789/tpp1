GetMaxRumbleSpeed::
	ld a, [MR3Features]
	rra
	jr nc, .no
	rra
	sbc a
	and 2
	inc a
	ret
.no
	xor a
	ret

SetRumbleOff::
	ld c, 0
	jr SetRumble

SetRumbleLow::
	ld c, 1
	jr SetRumble

SetRumbleMedium::
	ld c, 2
	jr SetRumble

SetRumbleHigh::
	ld c, 3
SetRumble:
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	call GetMaxRumbleSpeed
	and a
	ld hl, NoRumbleString
	jp z, MessageBox
	cp c
	ld hl, .speed_too_high_text
	jp c, MessageBox
	ld a, c
	add a, MR3_RUMBLE_OFF
	ld [rMR3w], a
	ret

.speed_too_high_text
	db "The selected speed<LF>"
	db "is not allowed.<@>"
