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
	call PrintMemoryLine
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

PrintMemoryLine:
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
	ret

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
	xor a
	ld [hMemoryCursor], a
	call MemoryViewer_EditMode_UpdateCursor
.loop
	call DelayFrame
	call GetMenuJoypad
	jr z, .loop
	cp MENU_LEFT
	jr nc, .loop
	call MemoryViewer_EditMode_ProcessJoypad
	jr c, .done
	call MemoryViewer_EditMode_UpdateCursor
	jr .loop
.done
	jp ClearScreen

MemoryViewer_EditMode_UpdateCursor:
	hlcoord 3, 2
	ld a, [hMemoryCursor]
	ld e, a
	ld bc, SCREEN_WIDTH
	xor a
.loop
	ld [hl], " "
	cp e
	jr nz, .ok
	ld [hl], "<RIGHT>"
.ok
	add hl, bc
	inc a
	cp 16
	jr c, .loop
	ret

MemoryViewer_EditMode_ProcessJoypad:
	dec a
	jr nz, .not_edit
	ld a, [hMemoryAddress + 1]
	cp $a0
	jr nz, .not_first
	ld a, [hMemoryAddress]
	and a
	jr nz, .not_first
	ld a, [hMemoryCursor]
	and a
	jr z, .error
.not_first
	ld a, [hMemoryAddress + 1]
	cp $bf
	jr nz, .not_last
	ld a, [hMemoryAddress]
	cp $c0
	jr nz, .not_last
	ld a, [hMemoryCursor]
	cp 15
	jr z, .error
.not_last
	ld a, [hMemoryAddress]
	ld b, a
	ld a, [hMemoryCursor]
	add a, a
	add a, a
	add a, b
	ld [hMemoryAddress], a
	call MemoryEditor
	ld a, [hMemoryAddress]
	and $c0
	ld [hMemoryAddress], a
	scf
	ret

.error
	ld hl, .error_text
	call MessageBox
	and a
	ret

.not_edit
	dec a
	jr nz, .not_cancel
	scf
	ret

.not_cancel
	dec a
	jr nz, .not_up
	ld a, [hMemoryCursor]
	dec a
	and $f
	ld [hMemoryCursor], a
	ret

.not_up
	; must be down
	ld a, [hMemoryCursor]
	inc a
	and $f
	ld [hMemoryCursor], a
	ret

.error_text
	db "That address must<LF>"
	db "remain unmodified.<@>"

MemoryEditor:
	ld a, -1
	ld [hVBlankLine], a
	call ClearScreen
	hlcoord 0, 0
	lb de, SCREEN_WIDTH, 3
	call Textbox
	ld hl, .title_text
	decoord 1, 1
	rst CopyString
	ld de, .instructions_text
	hlcoord 0, 4
	rst PrintString
	ld hl, .editing_text
	decoord 2, 8
	rst CopyString
	hlcoord 11, 8
	ld a, [hMemoryBank]
	call PrintHexByte
	ld a, ":"
	ld [hli], a
	ld a, [hMemoryAddress + 1]
	call PrintHexByte
	ld a, [hMemoryAddress]
	call PrintHexByte
.loop
	call MemoryEditor_DisplayDataAndGetInputs
	call HexadecimalEntry
	ret c
	call MemoryEditor_UpdateDisplayedData
	hlcoord 0, 14
	ld a, "<->"
	ld bc, SCREEN_WIDTH
	rst FillByte
	ld de, .confirmation_text
	hlcoord 2, 15
	rst PrintString
	call MemoryEditor_ConfirmationLoop
	jr c, .loop
	ld a, MR3_MAP_SRAM_RW
	ld [rMR3w], a
	ld a, [hMemoryAddress]
	ld e, a
	ld a, [hMemoryAddress + 1]
	ld d, a
	ld hl, wDataBuffer
	ld bc, 4
	rst CopyBytes
	ld a, MR3_MAP_SRAM_RO
	ld [rMR3w], a
	ld hl, .done_text
	jp MessageBox

.title_text
	db "RAM editor<@>"
.instructions_text
	db "Enter the new values<LF>"
	db "  for the selected<LF>"
	db "      address.<@>"
.editing_text
	db "Address:<@>"
.confirmation_text
	db "Confirm?<LF>"
	db " Yes<LF>"
	db " No<@>"
.done_text
	db "The memory address<LF>"
	db "has been updated.<@>"

MemoryEditor_DisplayDataAndGetInputs:
	hlcoord 0, 10
	ld a, [hMemoryAddress]
	ld e, a
	ld a, [hMemoryAddress + 1]
	ld d, a
	ld a, [hMemoryCursor]
	and a
	jr z, .first_line
	cp 15
	jr z, .last_line
	ld a, e
	sub 4
	ld e, a
	call PrintMemoryLine
	ld a, e
	call PrintHexByte
	ld [hl], ":"
	ld a, e
	add a, 4
	ld e, a
	hlcoord 16, 11
	call .add_spaces
	call PrintMemoryLine
	ld hl, .middle_line_hex_inputs
	ret

.first_line
	ld a, e
	call PrintHexByte
	ld [hl], ":"
	hlcoord 16, 10
	call .add_spaces
	ld a, e
	add a, 4
	ld e, a
	call PrintMemoryLine
	call PrintMemoryLine
	ld hl, .first_line_hex_inputs
	ret

.last_line
	ld a, e
	sub 8
	ld e, a
	call PrintMemoryLine
	call PrintMemoryLine
	ld a, e
	call PrintHexByte
	ld [hl], ":"
	hlcoord 16, 12
	call .add_spaces
	ld hl, .last_line_hex_inputs
	ret

.add_spaces
	ld a, " "
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ret

.first_line_hex_inputs
	hex_input  4, 10, wDataBuffer
	hex_input  7, 10, wDataBuffer + 1
	hex_input 10, 10, wDataBuffer + 2
	hex_input 13, 10, wDataBuffer + 3
	dw 0
.middle_line_hex_inputs
	hex_input  4, 11, wDataBuffer
	hex_input  7, 11, wDataBuffer + 1
	hex_input 10, 11, wDataBuffer + 2
	hex_input 13, 11, wDataBuffer + 3
	dw 0
.last_line_hex_inputs
	hex_input  4, 12, wDataBuffer
	hex_input  7, 12, wDataBuffer + 1
	hex_input 10, 12, wDataBuffer + 2
	hex_input 13, 12, wDataBuffer + 3
	dw 0

MemoryEditor_UpdateDisplayedData:
	ld de, wDataBuffer
	hlcoord 16, 10
	ld bc, SCREEN_WIDTH
	ld a, [hMemoryCursor]
	and a
	jr z, .selected
	add hl, bc
	cp 15
	jr nz, .selected
	add hl, bc
.selected
	ld b, 4
.loop
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
	jr nz, .loop
	ret

MemoryEditor_ConfirmationLoop:
	decoord 2, 16
	hlcoord 2, 17
	ld [hl], "<RIGHT>"
.loop
	call DelayFrame
	call GetMenuJoypad
	jr z, .loop
	cp MENU_LEFT
	jr nc, .loop
	dec a
	jr z, .done
	dec a
	scf
	ret z
	ld a, [de]
	cp "<RIGHT>"
	jr z, .selected_yes
	ld a, "<RIGHT>"
	ld [de], a
	ld [hl], " "
	jr .loop
.selected_yes
	ld a, " "
	ld [de], a
	ld [hl], "<RIGHT>"
	jr .loop
.done
	ld a, [de]
	cp "<RIGHT>"
	ret z
	scf
	ret
