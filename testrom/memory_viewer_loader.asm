ROMViewer::
	; execute as OPTION_CHECK
	call GetMaxValidROMBank
	ld hl, UnknownLastROMBankString
	ret c
	push de
	call ClearScreen
	ld hl, ParenthesisMaxBankString
	decoord 2, 1
	rst CopyString
	ld h, d
	ld l, e
	pop de
	push de
	ld a, e
	push af
	ld a, d
	call PrintHexByte
	pop af
	call PrintHexByte
	ld [hl], ")"
	ld hl, .address_text
	decoord 0, 2
	rst CopyString
	ld de, MemoryViewerDescriptionString
	hlcoord 1, 4
	rst PrintString
	hlcoord 6, 0
	ld [hl], ":"
	ld a, ACTION_REDRAW
	ld [hNextMenuAction], a
	pop de
.loop
	ld hl, .hex_inputs
	push de
	call HexadecimalEntry
	pop de
	jr c, ExitMemoryViewer
	ld a, [hMemoryAddress + 1]
	and $c0
	cp $40
	ld hl, InvalidAddressString
	jr nz, .error
	ld hl, BankTooHighString
	ld a, [hMemoryBank + 1]
	cp d
	jr c, OpenMemoryViewer
	jr nz, .error
	ld a, [hMemoryBank]
	cp e
	jr c, OpenMemoryViewer
	jr z, OpenMemoryViewer
.error
	call MessageBox
	jr .loop

.address_text
	db "(address: 4000-7FFF)<@>"

.hex_inputs
	hex_input_dw 2, 0, hMemoryBank
	hex_input_dw 7, 0, hMemoryAddress
	dw 0

OpenMemoryViewer:
	ld a, [hMemoryAddress]
	and $c0
	ld [hMemoryAddress], a
	call MemoryViewer
ExitMemoryViewer:
	ldopt hl, OPTION_MENU, MainTestingMenu
	ret

RAMViewer::
	; execute as OPTION_CHECK
	call GetMaxValidRAMBank
	ld hl, NoRAMString
	ret c
	ld a, c
	push af
	call ClearScreen
	ld hl, ParenthesisMaxBankString
	decoord 3, 1
	rst CopyString
	ld h, d
	ld l, e
	pop af
	push af
	call PrintHexByte
	ld [hl], ")"
	ld hl, .address_text
	decoord 0, 2
	rst CopyString
	ld de, MemoryViewerDescriptionString
	hlcoord 1, 4
	rst PrintString
	hlcoord 5, 0
	ld [hl], ":"
	ld a, ACTION_REDRAW
	ld [hNextMenuAction], a
	pop bc
.loop
	ld hl, .hex_inputs
	push bc
	call HexadecimalEntry
	pop bc
	jr c, ExitMemoryViewer
	ld a, [hMemoryAddress + 1]
	and $e0
	cp $a0
	ld hl, InvalidAddressString
	jr nz, .error
	ld a, [hMemoryBank]
	cp b
	jr c, OpenMemoryViewer
	jr z, OpenMemoryViewer
	ld hl, BankTooHighString
.error
	call MessageBox
	jr .loop

.address_text
	db "(address: A000-BFFF)<@>"

.hex_inputs
	hex_input 3, 0, hMemoryBank
	hex_input_dw 6, 0, hMemoryAddress
	dw 0
