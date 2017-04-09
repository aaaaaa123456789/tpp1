MemoryViewer::
	ld a, -1
	ld [hVBlankLine], a
	call MemoryViewer_PrepareBanks
	call ClearScreen
	call MemoryViewer_UpdateScreen
	xor a
	ld [hVBlankLine], a
	ld a, 2
	rst DelayFrames
.loop
	call DelayFrame
	call GetMenuJoypad
	jr z, .loop
	cp MENU_SELECT
	jr nc, .loop
	cp MENU_B
	jr z, .done
	call MemoryViewer_ProcessJoypad
	call MemoryViewer_UpdateScreen
	jr .loop
.done
	call ClearScreen
	ld a, 3
	rst DelayFrames
	jp ReinitializeMRRegisters

MemoryViewer_PrepareBanks:
	ld a, [hMemoryAddress + 1]
	add a, a
	jr c, .RAM
	ld hl, rMR0w
	ld a, [hMemoryBank]
	ld [hli], a
	ld a, [hMemoryBank + 1]
	ld [hl], a
	ret
.RAM
	ld a, [hMemoryBank]
	ld hl, rMR2w
	ld [hli], a
	ld [hl], MR3_MAP_SRAM_RO
	ret

MemoryViewer_UpdateScreen:
	ld a, [hMemoryAddress + 1]
	add a, a
	hlcoord 2, 0
	jr c, .RAM
	ld a, [hMemoryBank + 1]
	call PrintHexByte
	jr .go
.RAM
	inc hl
.go
	ld a, [hMemoryBank]
	call PrintHexByte
	ld a, ":"
	ld [hli], a
	ld a, [hMemoryAddress + 1]
	ld d, a
	call PrintHexByte
	ld a, [hMemoryAddress]
	ld e, a
	call PrintHexByte
	inc hl
	ld a, "-"
	ld [hli], a
	inc hl
	ld a, d
	call PrintHexByte
	ld a, e
	add a, $3f
	call PrintHexByte
	hlcoord 0, 2
	ld c, 16
.line_loop
	ld a, e
	call PrintHexByte
	ld a, ":"
	ld [hli], a
	push de
	ld b, 4
.digits_loop
	inc hl
	ld a, [de]
	inc de
	call PrintHexByte
	dec b
	jr nz, .digits_loop
	pop de
	inc hl
	ld b, 4
.characters_loop
	ld a, [de]
	inc de
	sub $20
	cp $5f
	jr c, .printable
	ld a, "<DOT>" - $20
.printable
	add a, $20
	ld [hli], a
	dec b
	jr nz, .characters_loop
	dec c
	jr nz, .line_loop
	ld a, [hMemoryAddress + 1]
	add a, a
	ret nc
	decoord 7, 1
	ld hl, .edit_text
	rst CopyString
	ret

.edit_text
	db "<A> Edit<@>"

MemoryViewer_WrapAddress:
	ld a, [hMemoryAddress + 1]
	cp $90
	jr nc, .RAM
	and $3f
	add a, $40
	jr .done
.RAM
	and $1f
	add a, $a0
.done
	ld [hMemoryAddress + 1], a
	ret

MemoryViewer_ProcessJoypad:
	dec a
	jr nz, .not_edit
	ld a, [hMemoryAddress + 1]
	add a, a
	ret nc
	jr MemoryViewer_EditMode

.not_edit
	ld hl, hMemoryAddress
	dec a
	dec a
	jr nz, .not_up
	ld a, [hl]
	sub $40
	ld [hli], a
	ret nc
	dec [hl]
	jr MemoryViewer_WrapAddress

.not_up
	dec a
	jr nz, .not_down
	ld a, [hl]
	add a, $40
	ld [hli], a
	ret nc
	inc [hl]
	jr MemoryViewer_WrapAddress

.not_down
	inc hl
	dec a
	jr nz, .not_left
	dec [hl]
	dec [hl]
	jr MemoryViewer_WrapAddress

.not_left
	; must be right
	inc [hl]
	inc [hl]
	jr MemoryViewer_WrapAddress

MemoryViewer_EditMode:
	ld hl, .not_implemented_text
	jp MessageBox

.not_implemented_text
	db "Not implemented.<@>"
