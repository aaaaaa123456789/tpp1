Timeset::
	call ClearScreenAndStopUpdates
	hlcoord 0, 0
	lb de, SCREEN_WIDTH, 3
	call Textbox
	hlcoord 0, 3
	lb de, SCREEN_WIDTH, 7
	call Textbox
	hlcoord 0, 10
	lb de, SCREEN_WIDTH, 8
	call Textbox
	ld hl, .title_string
	decoord 1, 1
	rst CopyString
	ld de, .help_text
	hlcoord 1, 11
	rst PrintString
	call Timeset_ClearTime ;returns with a = 0
	ldh [hVBlankLine], a
	ld a, 3
	rst DelayFrames
	call Timeset_LoadTimeFromRTC
.loop
	call Timeset_UpdateScreen
	ld a, 4
	ldh [hVBlankLine], a
	call DelayFrame
	call GetMenuJoypad
	jr z, .loop
	call Timeset_DoJoypadAction
	jr nc, .loop
	xor a
	ldh [hVBlankLine], a
	call ClearScreen
	ld a, 3
	rst DelayFrames
	ld a, ACTION_REDRAW
	ldh [hNextMenuAction], a
	ret

.title_string
	db "RTC manual setting<@>"

.help_text
	db "L/R: move cursor<LF>"
	db "U/D: set time<LF>"
	db "A: confirm<LF>"
	db "B: cancel/go back<LF>"
	db "SELECT: randomize<LF>"
	db "START: reload<@>"

Timeset_UpdateScreen:
	ld hl, hTimesetSecond
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	swap a
	rlca
	or c
	ld c, a
	ld b, [hl]
	ld hl, wTextBuffer
	push hl
	call GenerateTimeString
	pop hl
	decoord 1, 6
	rst CopyString
	hlcoord 1, 5
	ld bc, SCREEN_WIDTH - 2
	push bc
	ld a, " "
	rst FillByte
	pop bc
	hlcoord 1, 7
	rst FillByte
	ld hl, Timeset_CursorPositions
	ld bc, 5
	ldh a, [hTimesetCursor]
	rst AddNTimes
	ld c, [hl]
	ld b, 0
	hlcoord 1, 5
	add hl, bc
	ld [hl], "<UP>"
	ld c, 2 * SCREEN_WIDTH
	add hl, bc
	ld [hl], "<DOWN>"
	ret

Timeset_DoJoypadAction:
	dec a
	jr nz, .not_confirm
	ld a, MR3_MAP_RTC
	ld [rMR3w], a
	ld hl, rRTCW
	ldh a, [hTimesetWeek]
	ld [hli], a
	ldh a, [hTimesetDay]
	swap a
	rlca
	ld b, a
	ldh a, [hTimesetHour]
	or b
	ld [hli], a
	ldh a, [hTimesetMinute]
	ld [hli], a
	ldh a, [hTimesetSecond]
	ld [hl], a
	ld hl, rMR3w
	ld [hl], MR3_SET_RTC
	ld [hl], MR3_RTC_ON
	ld [hl], MR3_MAP_REGS
	ld hl, .time_set_text
	jp MessageBox

.not_confirm
	dec a
	jr nz, .not_cancel
	scf
	ret

.not_cancel
	dec a
	jr z, .up
	dec a
	jr z, .down
	dec a
	jr z, .left
	dec a
	jr z, .right
	dec a
	jr nz, .load_time
	call GenerateRandomRTCSetting
	call Timeset_SetTimeFromValues
	and a
	ret

.load_time
	call Timeset_LoadTimeFromRTC
	and a
	ret

.up
	ld hl, Timeset_CursorPositions + 1
	jr Timeset_ExecuteCursor
.down
	ld hl, Timeset_CursorPositions + 3
	jr Timeset_ExecuteCursor
.left
	ldh a, [hTimesetCursor]
	inc a
	ldh [hTimesetCursor], a
	cp 10
	ccf
	ret nc
	xor a
	ldh [hTimesetCursor], a
	ret
.right
	ldh a, [hTimesetCursor]
	sub 1
	ldh [hTimesetCursor], a
	ret nc
	ld a, 9
	ldh [hTimesetCursor], a
	and a
	ret

.time_set_text
	db "RTC time updated.<@>"

Timeset_ExecuteCursor:
	ld bc, 5
	ldh a, [hTimesetCursor]
	rst AddNTimes
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call _hl_
	and a
	ret

Timeset_LoadTimeFromRTC:
	call LatchMapRTC
	ld hl, rRTCW
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld d, a
	ld e, [hl]
	call ValidateRTCTime
	jr nc, Timeset_SetTimeFromValues
	ld hl, .error_text
	jp MessageBox

.error_text
	db "The current RTC<LF>"
	db "time is invalid!<@>"

Timeset_SetTimeFromValues:
	ld hl, hTimesetSecond
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld a, c
	and $1f
	ld [hli], a
	ld a, c
	swap a
	rrca
	and 7
	ld [hli], a
	ld [hl], b
	ret

Timeset_CursorPositions:
	dbww 17, Timeset_IncrementSeconds,   Timeset_DecrementSeconds
	dbww 16, Timeset_AddTenSeconds,      Timeset_SubtractTenSeconds
	dbww 14, Timeset_IncrementMinutes,   Timeset_DecrementMinutes
	dbww 13, Timeset_AddTenMinutes,      Timeset_SubtractTenMinutes
	dbww 11, Timeset_IncrementHours,     Timeset_DecrementHours
	dbww 10, Timeset_AddTenHours,        Timeset_SubtractTenHours
	dbww  7, Timeset_IncrementDay,       Timeset_DecrementDay
	dbww  4, Timeset_IncrementWeek,      Timeset_DecrementWeek
	dbww  3, Timeset_AddTenWeeks,        Timeset_SubtractTenWeeks
	dbww  2, Timeset_AddOneHundredWeeks, Timeset_SubtractOneHundredWeeks

Timeset_AddTenSeconds:
	ldh a, [hTimesetSecond]
	add a, 10
	jr Timeset_CheckSecondsAfterIncrement

Timeset_AddTenMinutes:
	ldh a, [hTimesetMinute]
	add a, 10
	jr Timeset_CheckMinutesAfterIncrement

Timeset_AddTenHours:
	ldh a, [hTimesetHour]
	add a, 10
	jr Timeset_CheckHoursAfterIncrement

Timeset_IncrementSeconds:
	ldh a, [hTimesetSecond]
	inc a
Timeset_CheckSecondsAfterIncrement:
	ldh [hTimesetSecond], a
	sub 60
	ret c
	ldh [hTimesetSecond], a
Timeset_IncrementMinutes:
	ldh a, [hTimesetMinute]
	inc a
Timeset_CheckMinutesAfterIncrement:
	ldh [hTimesetMinute], a
	sub 60
	ret c
	ldh [hTimesetMinute], a
Timeset_IncrementHours:
	ldh a, [hTimesetHour]
	inc a
Timeset_CheckHoursAfterIncrement:
	ldh [hTimesetHour], a
	sub 24
	ret c
	ldh [hTimesetHour], a
Timeset_IncrementDay:
	ldh a, [hTimesetDay]
	inc a
	ldh [hTimesetDay], a
	sub 7
	ret c
	ldh [hTimesetDay], a
Timeset_IncrementWeek:
	ldh a, [hTimesetWeek]
	add a, 1
Timeset_CheckWeeksAfterIncrement:
	ldh [hTimesetWeek], a
	ret nc
	ld a, $ff
	ldh [hTimesetWeek], a
	ld a, 6
	ldh [hTimesetDay], a
	ld a, 23
	ldh [hTimesetHour], a
	ld a, 59
	ldh [hTimesetMinute], a
	ldh [hTimesetSecond], a
	ret

Timeset_AddTenWeeks:
	ldh a, [hTimesetWeek]
	add a, 10
	jr Timeset_CheckWeeksAfterIncrement

Timeset_AddOneHundredWeeks:
	ldh a, [hTimesetWeek]
	add a, 100
	jr Timeset_CheckWeeksAfterIncrement

Timeset_SubtractTenSeconds:
	ldh a, [hTimesetSecond]
	sub 10
	jr Timeset_CheckSecondsAfterDecrement

Timeset_SubtractTenMinutes:
	ldh a, [hTimesetMinute]
	sub 10
	jr Timeset_CheckMinutesAfterDecrement

Timeset_SubtractTenHours:
	ldh a, [hTimesetHour]
	sub 10
	jr Timeset_CheckHoursAfterDecrement

Timeset_DecrementSeconds:
	ldh a, [hTimesetSecond]
	dec a
Timeset_CheckSecondsAfterDecrement:
	ldh [hTimesetSecond], a
	add a, 60
	ret nc
	ldh [hTimesetSecond], a
Timeset_DecrementMinutes:
	ldh a, [hTimesetMinute]
	dec a
Timeset_CheckMinutesAfterDecrement:
	ldh [hTimesetMinute], a
	add a, 60
	ret nc
	ldh [hTimesetMinute], a
Timeset_DecrementHours:
	ldh a, [hTimesetHour]
	dec a
Timeset_CheckHoursAfterDecrement:
	ldh [hTimesetHour], a
	add a, 24
	ret nc
	ldh [hTimesetHour], a
Timeset_DecrementDay:
	ldh a, [hTimesetDay]
	dec a
	ldh [hTimesetDay], a
	add a, 7
	ret nc
	ldh [hTimesetDay], a
Timeset_DecrementWeek:
	ldh a, [hTimesetWeek]
	sub 1
Timeset_CheckWeeksAfterDecrement:
	ldh [hTimesetWeek], a
	ret nc
Timeset_ClearTime:
	xor a
	ldh [hTimesetWeek], a
	ldh [hTimesetDay], a
	ldh [hTimesetHour], a
	ldh [hTimesetMinute], a
	ldh [hTimesetSecond], a
	ret

Timeset_SubtractTenWeeks:
	ldh a, [hTimesetWeek]
	sub 10
	jr Timeset_CheckWeeksAfterDecrement

Timeset_SubtractOneHundredWeeks:
	ldh a, [hTimesetWeek]
	sub 100
	jr Timeset_CheckWeeksAfterDecrement
