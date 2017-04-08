ROMViewer::
	call GetMaxValidROMBank
	jr nc, .ok
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	ld hl, UnknownLastROMBankString
	jp MessageBox
.ok
	push de
	call ClearScreen
	ld hl, ParenthesisMaxBankString
	decoord 2, 1
	rst CopyString
	ld h, d
	ld l, e
	pop de
	push de
	ld a, d
	push af
	ld a, e
	call PrintByte
	pop af
	call PrintByte
	ld [hl], ")"
	ld hl, .address_text
	decoord 0, 2
	rst CopyString
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
	ret c
	ld a, [hMemoryAddress + 1]
	and $c0
	cp $40
	ld hl, InvalidAddressString
	jr nz, .error
	ld hl, BankTooHighString
	ld a, [hMemoryBank + 1]
	cp d
	jr c, .go
	jr nz, .error
	ld a, [hMemoryBank]
	cp e
	jr c, .go
	jr z, .go
.error
	call MessageBox
	jr .loop
.go
	ld a, [hMemoryAddress]
	and $c0
	ld [hMemoryAddress], a
	jp MemoryViewer

.address_text
	db "(address: 4000-7FFF)<@>"

.hex_inputs
	hex_input_dw 2, 0, hMemoryBank
	hex_input_dw 7, 0, hMemoryAddress
	dw 0
