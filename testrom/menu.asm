MainMenu::
	ld a, MainTestingMenu & $ff
	ld [hSelectedMenu], a
	ld a, MainTestingMenu >> 8
	ld [hSelectedMenu + 1], a
	ld a, ACTION_RELOAD
	ld [hNextMenuAction], a
	jr .loop_tail
.loop
	call DelayFrame
	call GetMenuJoypad
	call nz, UpdateMenuContents
.loop_tail
	call RenderMenu
	jr .loop

RenderMenu:
	ld a, [hSelectedMenu]
	ld l, a
	ld a, [hSelectedMenu + 1]
	ld h, a
	ld a, [hNextMenuAction]
	and a
	ret z
	dec a
	jr nz, .not_full_reload
	; reload
	xor a
	ld [hFirstOption], a
	ld [hSelectedOption], a
	push hl
	ld c, -1
	ld a, [hli]
	ld h, [hl]
	ld l, a
.option_count_loop
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc c
	and h
	inc a
	jr nz, .option_count_loop
	pop hl
	ld a, c
	ld [hOptionCount], a
.not_full_reload
	ld a, [hNextMenuAction]
	cp ACTION_UPDATE
	jr nc, .not_full_redraw
	push hl
	call ClearScreen
	ld a, 6
	rst DelayFrames
	pop hl
	push hl
	hlcoord 0, 0
	lb de, SCREEN_WIDTH, 3
	call Textbox
	pop hl
	push hl
	ld de, 4
	add hl, de
	decoord 1, 1
	rst CopyString
	pop hl
.not_full_redraw
	push hl
	hlcoord 0, 4
	lb de, SCREEN_WIDTH, 14
	call Textbox
	pop hl
	ld a, [hFirstOption]
	call FindOptionByNumber
	ld bc, 0
.loop
	inc hl
	ld a, [hld]
	and [hl]
	inc a
	jr z, .done
	push hl
	hlcoord 2, 5
	ld a, SCREEN_WIDTH
	rst AddNTimes
	ld d, h
	ld e, l
	pop hl
	push hl
	inc hl
	inc hl
	inc hl
	inc hl
	rst CopyString
	pop hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc c
	ld a, c
	cp OPTIONS_PER_SCREEN
	jr c, .loop
.done
	ld a, [hFirstOption]
	ld e, a
	ld a, [hSelectedOption]
	sub e
	cp OPTIONS_PER_SCREEN
	jr nc, .invalid_cursor_position
	ld c, SCREEN_WIDTH
	hlcoord 1, 5
	rst AddNTimes
	ld [hl], "<RIGHT>"
.invalid_cursor_position
	hlcoord 18, 4
	ld a, [hFirstOption]
	and a
	ld [hl], "<->"
	jr z, .cannot_scroll_up
	ld [hl], "<UP>"
.cannot_scroll_up
	hlcoord 18, 17
	ld [hl], "<->"
	add a, OPTIONS_PER_SCREEN + 1
	ld e, a
	ld a, [hOptionCount]
	cp e
	jr c, .cannot_scroll_down
	ld [hl], "<DOWN>"
.cannot_scroll_down
	xor a
	ld [hVBlankLine], a
	ld a, 3
	rst DelayFrames
	xor a
	ld [hNextMenuAction], a
	ret

GetMenuJoypad::
	; reacts to only buttons pressed alone, other than A and B (B taking priority). That way we eliminate combined presses
	push hl
	ld a, [hButtonsPressed]
	ld h, MENU_START
	cp START
	jr z, .done
	dec h
	cp SELECT
	jr z, .done
	dec h
	cp D_RIGHT
	jr z, .done
	dec h
	cp D_LEFT
	jr z, .done
	dec h
	cp D_DOWN
	jr z, .done
	dec h
	cp D_UP
	jr z, .done
	dec h
	ld l, a
	and B_BUTTON
	jr nz, .done
	dec h
	ld a, l
	and A_BUTTON
	jr nz, .done
	dec h
.done
	ld a, h
	pop hl
	and a
	ret

FindOptionByNumber:
	push bc
	ld c, a
	inc c
.loop
	ld a, [hli]
	ld h, [hl]
	ld l, a
	dec c
	jr nz, .loop
	pop bc
	ret

UpdateMenuContents:
	; called with the last input in a; known to be non-zero
	dec a
	jr nz, .not_execute
	ld a, -1
	ld [hNextMenuAction], a
	call ExecuteSelectedOption
	ld a, [hNextMenuAction]
	inc a
	ret nz
	ld a, ACTION_REDRAW
	ld [hNextMenuAction], a
	ret

.not_execute
	dec a
	jr nz, .not_cancel
	ld a, [hSelectedMenu]
	ld l, a
	ld a, [hSelectedMenu + 1]
	ld h, a
	inc hl
	inc hl
	ld a, [hli]
	ld [hSelectedMenu], a
	ld a, [hl]
	ld [hSelectedMenu + 1], a
	ld a, ACTION_RELOAD
	ld [hNextMenuAction], a
	ret

.not_cancel
	dec a
	jr nz, .not_up
	ld a, [hSelectedOption]
	and a
	ret z
	dec a
	ld [hSelectedOption], a
	ld e, a
	ld a, [hFirstOption]
	cp e
	jr c, .update_menu
	ld a, e
	ld [hFirstOption], a
	jr .update_menu

.not_up
	dec a
	jr nz, .not_down
	ld a, [hOptionCount]
	ld e, a
	ld a, [hSelectedOption]
	inc a
	cp e
	ret nc
	ld [hSelectedOption], a
	ld e, a
	ld a, [hFirstOption]
	add a, OPTIONS_PER_SCREEN - 1
	cp e
	jr nc, .update_menu
	ld a, e
	sub OPTIONS_PER_SCREEN - 1
	ld [hFirstOption], a
.update_menu
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	ret

.not_down
	dec a
	jr nz, .not_left
	ld a, [hSelectedOption]
	sub OPTIONS_PER_SCREEN
	jr nc, .no_selection_underflow
	xor a
.no_selection_underflow
	ld [hSelectedOption], a
	ld a, [hFirstOption]
	sub OPTIONS_PER_SCREEN
	jr nc, .no_first_underflow
	xor a
.no_first_underflow
	ld [hFirstOption], a
	jr .update_menu

.not_left
	dec a
	ret nz ;not right
	ld a, [hOptionCount]
	ld c, a
	ld a, [hSelectedOption]
	add a, OPTIONS_PER_SCREEN
	cp c
	jr c, .no_selection_overflow
	ld a, c
	dec a
.no_selection_overflow
	ld [hSelectedOption], a
	ld a, c
	sub OPTIONS_PER_SCREEN + 1
	ld c, a
	ld a, 0
	jr c, .first_option_chosen
	ld a, [hFirstOption]
	add a, OPTIONS_PER_SCREEN
	inc c
	cp c
	jr c, .first_option_chosen
	ld a, c
.first_option_chosen
	ld [hFirstOption], a
	jr .update_menu

ExecuteSelectedOption:
	ld a, [hSelectedMenu]
	ld l, a
	ld a, [hSelectedMenu + 1]
	ld h, a
	ld a, [hSelectedOption]
	call FindOptionByNumber
	inc hl
	inc hl
	inc hl
	ld a, [hld]
	ld l, [hl]
	ld b, a
	and $3f
	ld h, a
	xor a
	sla b
	rla
	sla b
	rla

	and a
	jr nz, .not_exec
	push hl
	ld a, [hFirstOption]
	ld e, a
	ld a, [hSelectedOption]
	sub e
	ld bc, SCREEN_WIDTH
	hlcoord 1, 5
	rst AddNTimes
	ld [hl], "<HRIGHT>"
	ld a, 12
	rst DelayFrames
	ret ;jump to the pushed hl

.not_exec
	dec a
	jr z, LoadMenu

	dec a
	jp z, ExecuteTest

	call _hl_
	ld a, h
	res 6, h
	res 7, h
	rlca
	rlca
	and 3
	jr nz, .not_exec
	ld a, h
	or l
	ret z
	call MessageBox
UpdateMenuScreen::
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	ret

LoadMenu::
	ld a, l
	ld [hSelectedMenu], a
	ld a, h
	ld [hSelectedMenu + 1], a
	ld a, ACTION_RELOAD
	ld [hNextMenuAction], a
	ret
