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
