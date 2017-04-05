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
