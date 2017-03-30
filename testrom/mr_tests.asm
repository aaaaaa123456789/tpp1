RestoreMRValues::
	call ReinitializeMRRegisters
	ld hl, .text
	call MessageBox
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	ret

.text
	db "MR registers set<LF>"
	db "to default values.<@>"

ReinitializeMRRegisters::
	xor a
	ld hl, rMR3w
	ld [hld], a
	ld [hld], a
	ld [hld], a
	ld [hl], 1
	ret
