HexadecimalEntry::
	ld a, l
	ld [hHexEntryData], a
	ld a, h
	ld [hHexEntryData + 1], a
	call CountHexDataEntries
	ld [hHexEntryCount], a
	hlcoord 0, 14
	ld de, wSavedScreenData
	ld bc, SCREEN_WIDTH * 4
	rst CopyBytes
	xor a
	ld [hHexEntryByte], a
	ld [hHexEntryRow], a
	ld [hHexEntryColumn], a
	dec a
	ld [hHexEntryCurrent], a
	call UpdateHexDigits
	call DrawHexEntryMenu
	ld a, 3
	rst DelayFrames
.loop
	ld a, 12
	ld [hVBlankLine], a
	call DelayFrame
	call GetMenuJoypad
	jr z, .loop
	cp MENU_UP
	jr c, .action
	cp MENU_START
	jr z, .done
	call UpdateHexEntryCursor
	jr .loop
.action
	call ExecuteHexEntryAction
	jr c, .done
	call UpdateHexDigits
	ld a, 2
	rst DelayFrames
	jr .loop
.done
	xor a
	ld [hVBlankLine], a
	ld hl, wSavedScreenData
	decoord 0, 14
	ld bc, SCREEN_WIDTH * 4
	rst CopyBytes
	ld a, [hHexEntryCount]
	ld c, a
	ld a, [hHexEntryByte]
	cp c
	ret

CountHexDataEntries:
	ld de, 3
	ld c, d
.loop
	ld a, [hli]
	or [hl]
	jr z, .done
	inc c
	add hl, de
	jr .loop
.done
	ld a, c
	ret

DrawHexEntryMenu:
	ld hl, .hex_entry_menu_data
	decoord 0, 14
	ld bc, SCREEN_WIDTH * 4 - 4
	rst CopyBytes
	ret

.hex_entry_menu_data
	rept SCREEN_WIDTH
		db "<->"
	endr
	db "<RIGHT>0  3  6  9  C  F   "
	db " 1  4  7  A  D  back"
	db " 2  5  8  B  E  "

UpdateHexDigits:
	xor a
	ld [hVBlankLine], a
	ld a, [hHexEntryByte]
	ld b, a
	ld hl, hHexEntryData
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld c, 0
	jr .handle_initial_loop
.initial_loop
	call .print_byte
	inc c
.handle_initial_loop
	ld a, c
	cp b
	jr c, .initial_loop
	ld a, [hHexEntryCount]
	sub b
	jr z, .finished_entry
	ld b, a
	inc hl
	inc hl
	call .print_current
.clear_loop
	dec b
	jr z, .done
	inc hl
	inc hl
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, "_"
	ld [de], a
	inc de
	ld [de], a
	jr .clear_loop
.done
	ld hl, .exit_string
.update_option
	decoord 16, 17
	rst CopyString
	ret

.finished_entry
	ld hl, .done_string
	jr .update_option

.exit_string
	db "exit<@>"
.done_string
	db "done<@>"

.print_byte
	; ...
	ret

.print_current
	; ...
	ret

UpdateHexEntryCursor:
	push af
	call CalculateCurrentCursorPosition
	ld [hl], " "
	pop af

	sub MENU_UP
	jr nz, .not_up
	ld a, [hHexEntryRow]
	sub 1
	jr nc, .row_ok
	ld a, 2
.row_ok
	ld [hHexEntryRow], a
	jr .done

.not_up
	dec a
	jr nz, .not_down
	ld a, [hHexEntryRow]
	inc a
	cp 3
	jr c, .row_ok
	xor a
	jr .row_ok

.not_down
	dec a
	jr nz, .not_left
	ld a, [hHexEntryColumn]
	sub 1
	jr nc, .col_ok
	ld a, 5
	jr .col_ok

.not_left
	dec a
	ret nz
	ld a, [hHexEntryColumn]
	inc a
	cp 6
	jr c, .col_ok
	xor a
.col_ok
	ld [hHexEntryColumn], a
.done
	call CalculateCurrentCursorPosition
	ld [hl], "<RIGHT>"
	ret

CalculateCurrentCursorPosition:
	hlcoord 0, 15
	ld a, [hHexEntryRow]
	ld bc, SCREEN_WIDTH
	rst AddNTimes
	ld a, [hHexEntryColumn]
	ld c, a
	add a, a
	add a, c
	add a, l
	ld l, a
	ret nc
	inc h
	ret

CalculateCurrentCursorValue:
	; returns 16 for back, and 17 for OK/exit
	ld a, [hHexEntryColumn]
	ld c, a
	ld a, [hHexEntryRow]
	add a, c
	sla c
	add a, c
	ret

ExecuteHexEntryAction:
	dec a
	jr nz, .back
	call CalculateCurrentCursorValue
	cp 16
	jr z, .back
	ccf
	ret c
	ld c, a
	ld a, [hHexEntryByte]
	ld b, a
	ld a, [hHexEntryCount]
	cp b
	ret z
	ld a, [hHexEntryCurrent]
	cp 16
	jr c, .enter_byte
	ld a, c
	ld [hHexEntryCurrent], a
	ret
.enter_byte
	swap a
	or c
	ld c, a
	ld e, b
	ld d, 0
	sla e
	rl d
	sla e
	rl d
	ld hl, hHexEntryData
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld [hl], c
	inc b
	ld a, $ff
	ld [hHexEntryCurrent], a
	ld a, b
	ld [hHexEntryByte], a
	ld a, [hHexEntryCount]
	cp b
	ret nz
	ld a, 2
	ld [hHexEntryRow], a
	ld a, 5
	ld [hHexEntryColumn], a
	ret

.cancel_current_byte
	ld a, $ff
	ld [hHexEntryCurrent], a
	and a
	ret

.back
	ld a, [hHexEntryByte]
	ld b, a
	and a
	jr z, .cancel_current_byte
	ld a, [hHexEntryCurrent]
	cp 16
	jr c, .cancel_current_byte
	dec b
	ld a, b
	ld [hHexEntryByte], a
	ld d, 0
	add a, a
	rl d
	add a, a
	rl d
	ld e, a
	ld hl, hHexEntryData
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hl]
	swap a
	and 15
	ld [hHexEntryCurrent], a
	ret
