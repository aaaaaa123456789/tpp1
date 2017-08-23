GetMaxRumbleSpeed::
	ld a, [TPP1Features]
	rra
	jr nc, .no
	rra
	sbc a
	and 2
	inc a
	ret
.no
	xor a
	ret

SetRumbleOff::
	ld c, 0
	jr SetRumble

SetRumbleLow::
	ld c, 1
	jr SetRumble

SetRumbleMedium::
	ld c, 2
	jr SetRumble

SetRumbleHigh::
	ld c, 3
SetRumble:
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	call GetMaxRumbleSpeed
	and a
	ld hl, NoRumbleString
	jp z, MessageBox
	cp c
	ld hl, .speed_too_high_text
	jp c, MessageBox
	ld a, c
	add a, MR3_RUMBLE_OFF
	ld [rMR3w], a
	ret

.speed_too_high_text
	db "The selected speed<LF>"
	db "is not allowed.<@>"

TestRumbleMR4::
	ld hl, .initial_test_text
	call PrintWithBlankLine
	call GetMaxRumbleSpeed
	and a
	ld c, a
	jr nz, .go
	ld hl, NoRumbleString
	rst Print
	jr .done
.go
	ld hl, .device_will_rumble_text
	rst Print
	call ClearMR4 ;exits with hl = rMR3w
	ld [hl], MR3_MAP_REGS
.loop
	ld a, MR3_RUMBLE_OFF
	add a, c
	ld [hl], a
	ld a, [rMR4r]
	and 3
	cp c
	jr z, .ok
	call nc, .error
.ok
	ld a, c
	dec c
	and a
	jr nz, .loop
.done
	ld a, MR3_RUMBLE_OFF
	ld [rMR3w], a
	jp PrintEmptyString

.error
	push hl
	ld [hCurrent], a
	ld a, c
	ld [hMax], a
	ld hl, .error_text
	rst Print
	call IncrementErrorCount
	pop hl
	ret

.initial_test_text
	db "Testing rumble<LF>"
	db "speeds and MR4<LF>"
	db "register values<...><@>"
.device_will_rumble_text
	db "WARNING: device<LF>"
	db "may vibrate during<LF>"
	db "rumble test!<@>"
.error_text
	db "FAILED: selected<LF>"
	db "speed "
	bigdw hCurrent
	db " when "
	bigdw hMax
	db "<LF>"
	db "was requested<@>"
