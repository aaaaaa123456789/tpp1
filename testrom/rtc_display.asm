GenerateTimeString::
	; in: hl = pointer to string; bcde = time data
	; format: wk??? ??? ??:??:??
	ld a, "w"
	ld [hli], a
	ld a, "k"
	ld [hli], a
	push de
	push bc
	ld a, b
	lb bc, 3, 255
	call PrintByte
	ld a, " "
	ld [hli], a
	pop bc
	push bc
	push hl
	ld a, c
	swap a
	rrca
	and 7
	ld bc, 3
	ld hl, .days_of_the_week
	rst AddNTimes
	pop de
	rst CopyBytes
	ld h, d
	ld l, e
	ld a, " "
	ld [hli], a
	pop bc
	ld a, c
	and $1f
	lb bc, 2, 23
	call PrintByte
	pop de
	ld a, d
	call .print_minutes_or_seconds
	ld a, e
	call .print_minutes_or_seconds
	ld [hl], "<@>"
	ret

.days_of_the_week
	db "SunMonTueWedThuFriSat???"

.print_minutes_or_seconds
	ld [hl], ":"
	inc hl
	cp 60
	jr nc, .minute_second_overflow
	ld c, "0"
	add a, c
	jr .handle_division_loop
.division_loop
	sub 10
	inc c
.handle_division_loop
	cp "0" + 10
	jr nc, .division_loop
	ld [hl], c
	inc hl
	ld [hli], a
	ret

.minute_second_overflow
	ld a, "?"
	ld [hli], a
	ld [hli], a
	ret

DisplayRTCState::
	call ClearScreenAndStopUpdates
	hlcoord 0, 0
	lb de, SCREEN_WIDTH, 3
	call Textbox
	hlcoord 0, 3
	lb de, SCREEN_WIDTH, 9
	call Textbox
	hlcoord 0, 12
	lb de, SCREEN_WIDTH, 6
	call Textbox
	ld hl, .title_text
	decoord 1, 1
	rst CopyString
	hlcoord 1, 6
	ld de, .display_text
	rst PrintString
	hlcoord 2, 13
	ld de, .options_text
	rst PrintString
	xor a
	ld [hTimesetCursor], a
	ld [hVBlankLine], a
	call UpdateDisplayedRTCState
	ld a, 2
	rst DelayFrames
.loop
	call UpdateDisplayedRTCState
	call DelayFrame
	call GetMenuJoypad
	jr z, .loop
	cp MENU_LEFT
	call c, ProcessRTCDisplayJoypad
	jr nc, .loop
	jp ClearScreen

.title_text
	db "RTC status<@>"
.display_text
	db "Raw RTC values:<LF><LF><LF>"
	db "RTC enabled:<LF>"
	db "RTC overflow:<@>"
.options_text
	db "Turn on<LF>"
	db "Turn off<LF>"
	db "Clear overflow<LF>"
	db "Back<@>"

UpdateDisplayedRTCState:
	hlcoord 1, 13
	ld bc, SCREEN_WIDTH
	ld e, b ;= 0
	ld a, [hTimesetCursor]
.cursor_loop
	ld [hl], " "
	cp e
	jr nz, .not_selected
	ld [hl], "<RIGHT>"
.not_selected
	add hl, bc
	inc e
	bit 2, e
	jr z, .cursor_loop
	call LatchMapRTC
	ld hl, rRTCW
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld d, a
	ld e, [hl]
	hlcoord 11, 7
	ld a, b
	call PrintHexByte
	ld a, c
	call PrintHexByte
	ld a, d
	call PrintHexByte
	ld a, e
	call PrintHexByte
	ld hl, wTextBuffer
	push hl
	call GenerateTimeString
	pop hl
	decoord 1, 4
	rst CopyString
	xor a ;ld a, MR3_MAP_REGS
	ld [rMR3w], a
	ld a, [rMR4r]
	swap a
	add a, a
	hlcoord 18, 10
	push af
	call .print_yes_no
	pop af
	add a, a
	hlcoord 18, 9
.print_yes_no
	jr c, .print_yes
	ld a, "o"
	ld [hld], a
	dec a
	ld [hld], a
	ld [hl], " "
	ret
.print_yes
	ld a, "s"
	ld [hld], a
	ld a, "e"
	ld [hld], a
	ld [hl], "y"
	ret

ProcessRTCDisplayJoypad:
	dec a
	jr nz, .not_a
	ld a, [hTimesetCursor]
	and a
	jr z, .turn_on
	dec a
	jr z, .turn_off
	dec a
	jr nz, .exit
	ld a, MR3_CLEAR_RTC_OVERFLOW
	jr .MR3_action

.not_a
	dec a
	jr nz, .not_b
.exit
	scf
	ret

.not_b
	dec a
	jr nz, .not_up
	ld a, [hTimesetCursor]
	dec a
	jr .set_cursor

.not_up
	ld a, [hTimesetCursor]
	inc a
.set_cursor
	and 3
	ld [hTimesetCursor], a
	ret

.turn_on
	ld a, MR3_RTC_ON
	jr .MR3_action

.turn_off
	ld a, MR3_RTC_OFF
.MR3_action
	ld [rMR3w], a
	and a
	ret
