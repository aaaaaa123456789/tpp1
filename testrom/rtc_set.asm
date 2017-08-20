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
	ld [hVBlankLine], a
	ld a, 3
	rst DelayFrames
	call Timeset_LoadTimeFromRTC
.loop
	call Timeset_UpdateScreen
	ld a, 4
	ld [hVBlankLine], a
	call DelayFrame
	call GetMenuJoypad
	jr z, .loop
	call Timeset_DoJoypadAction
	jr nc, .loop
	xor a
	ld [hVBlankLine], a
	call ClearScreen
	ld a, 3
	rst DelayFrames
	ld a, ACTION_REDRAW
	ld [hNextMenuAction], a
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
	ld a, [hTimesetCursor]
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
	ld a, [hTimesetWeek]
	ld [hli], a
	ld a, [hTimesetDay]
	swap a
	rlca
	ld b, a
	ld a, [hTimesetHour]
	or b
	ld [hli], a
	ld a, [hTimesetMinute]
	ld [hli], a
	ld a, [hTimesetSecond]
	ld [hl], a
	ld hl, rMR3w
	ld [hl], MR3_SET_RTC
	ld [hl], MR3_RTC_ON
	ld [hl], MR3_MAP_REGS
	ld hl, .time_set_text
	call MessageBox
	scf
	ret

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
	ld a, [hTimesetCursor]
	inc a
	ld [hTimesetCursor], a
	cp 10
	ccf
	ret nc
	xor a
	ld [hTimesetCursor], a
	ret
.right
	ld a, [hTimesetCursor]
	sub 1
	ld [hTimesetCursor], a
	ret nc
	ld a, 9
	ld [hTimesetCursor], a
	and a
	ret

.time_set_text
	db "RTC time updated.<@>"

Timeset_ExecuteCursor:
	ld bc, 5
	ld a, [hTimesetCursor]
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
	ld a, [hTimesetSecond]
	add a, 10
	jr Timeset_CheckSecondsAfterIncrement

Timeset_AddTenMinutes:
	ld a, [hTimesetMinute]
	add a, 10
	jr Timeset_CheckMinutesAfterIncrement

Timeset_AddTenHours:
	ld a, [hTimesetHour]
	add a, 10
	jr Timeset_CheckHoursAfterIncrement

Timeset_IncrementSeconds:
	ld a, [hTimesetSecond]
	inc a
Timeset_CheckSecondsAfterIncrement:
	ld [hTimesetSecond], a
	sub 60
	ret c
	ld [hTimesetSecond], a
Timeset_IncrementMinutes:
	ld a, [hTimesetMinute]
	inc a
Timeset_CheckMinutesAfterIncrement:
	ld [hTimesetMinute], a
	sub 60
	ret c
	ld [hTimesetMinute], a
Timeset_IncrementHours:
	ld a, [hTimesetHour]
	inc a
Timeset_CheckHoursAfterIncrement:
	ld [hTimesetHour], a
	sub 24
	ret c
	ld [hTimesetHour], a
Timeset_IncrementDay:
	ld a, [hTimesetDay]
	inc a
	ld [hTimesetDay], a
	sub 7
	ret c
	ld [hTimesetDay], a
Timeset_IncrementWeek:
	ld a, [hTimesetWeek]
	add a, 1
Timeset_CheckWeeksAfterIncrement:
	ld [hTimesetWeek], a
	ret nc
	ld a, $ff
	ld [hTimesetWeek], a
	ld a, 6
	ld [hTimesetDay], a
	ld a, 23
	ld [hTimesetHour], a
	ld a, 59
	ld [hTimesetMinute], a
	ld [hTimesetSecond], a
	ret

Timeset_AddTenWeeks:
	ld a, [hTimesetWeek]
	add a, 10
	jr Timeset_CheckWeeksAfterIncrement

Timeset_AddOneHundredWeeks:
	ld a, [hTimesetWeek]
	add a, 100
	jr Timeset_CheckWeeksAfterIncrement

Timeset_SubtractTenSeconds:
	ld a, [hTimesetSecond]
	sub 10
	jr Timeset_CheckSecondsAfterDecrement

Timeset_SubtractTenMinutes:
	ld a, [hTimesetMinute]
	sub 10
	jr Timeset_CheckMinutesAfterDecrement

Timeset_SubtractTenHours:
	ld a, [hTimesetHour]
	sub 10
	jr Timeset_CheckHoursAfterDecrement

Timeset_DecrementSeconds:
	ld a, [hTimesetSecond]
	dec a
Timeset_CheckSecondsAfterDecrement:
	ld [hTimesetSecond], a
	add a, 60
	ret nc
	ld [hTimesetSecond], a
Timeset_DecrementMinutes:
	ld a, [hTimesetMinute]
	dec a
Timeset_CheckMinutesAfterDecrement:
	ld [hTimesetMinute], a
	add a, 60
	ret nc
	ld [hTimesetMinute], a
Timeset_DecrementHours:
	ld a, [hTimesetHour]
	dec a
Timeset_CheckHoursAfterDecrement:
	ld [hTimesetHour], a
	add a, 24
	ret nc
	ld [hTimesetHour], a
Timeset_DecrementDay:
	ld a, [hTimesetDay]
	dec a
	ld [hTimesetDay], a
	add a, 7
	ret nc
	ld [hTimesetDay], a
Timeset_DecrementWeek:
	ld a, [hTimesetWeek]
	sub 1
Timeset_CheckWeeksAfterDecrement:
	ld [hTimesetWeek], a
	ret nc
Timeset_ClearTime:
	xor a
	ld [hTimesetWeek], a
	ld [hTimesetDay], a
	ld [hTimesetHour], a
	ld [hTimesetMinute], a
	ld [hTimesetSecond], a
	ret

Timeset_SubtractTenWeeks:
	ld a, [hTimesetWeek]
	sub 10
	jr Timeset_CheckWeeksAfterDecrement

Timeset_SubtractOneHundredWeeks:
	ld a, [hTimesetWeek]
	sub 100
	jr Timeset_CheckWeeksAfterDecrement
