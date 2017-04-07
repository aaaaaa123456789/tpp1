TurnRTCOff::
	ld a, MR3_RTC_OFF
	ld [rMR3w], a
	ld hl, .text
	ret

.text
	db "RTC turned off.<@>"

ClearRTCOverflowOption::
	ld a, MR3_CLEAR_RTC_OVERFLOW
	ld [rMR3w], a
	ld hl, .text
	ret

.text
	db "RTC overflow flag<LF>"
	db "cleared.<@>"

RTCOnOffTest::
	ld hl, .initial_test_text
	rst Print
	ld hl, EmptyString
	rst Print
	ld a, 3
	ld [hMax], a
.loop
	ld hl, rMR3w
	ld [hl], MR3_RTC_OFF
	ld [hl], MR3_MAP_RTC
	call SetRTCRandomly
	ld [hl], MR3_SET_RTC
	ld [hl], MR3_RTC_ON
	call WaitForRTCChange
	call z, .on_failed
	ld [hl], MR3_RTC_OFF
	call WaitForRTCChange
	call nz, .off_failed
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	ld hl, EmptyString
	rst Print
	jp ReinitializeMRRegisters

.on_failed
	push hl
	ld hl, .on_error_text
	rst Print
	call IncrementErrorCount
	pop hl
	ret

.off_failed
	push hl
	ld hl, .off_error_text
	rst Print
	call IncrementErrorCount
	pop hl
	ret

.initial_test_text
	db "Testing RTC on/off<LF>"
	db "controls...<@>"

.on_error_text
	db "FAILED: RTC stood<LF>"
	db "unchanged while on<@>"

.off_error_text
	db "FAILED: RTC ticked<LF>"
	db "while off<@>"

RTCSetWhileOnTest::
	ld hl, RTCSetTestingString
	ld de, wTextBuffer
	rst CopyString
	ld h, d
	ld l, e
	ld a, "n"
	ld [hli], a
	ld a, MR3_RTC_ON
	jr RTCSetTest

RTCSetWhileOffTest::
	ld hl, RTCSetTestingString
	ld de, wTextBuffer
	rst CopyString
	ld h, d
	ld l, e
	ld a, "f"
	ld [hli], a
	ld [hli], a
	ld a, MR3_RTC_OFF
RTCSetTest:
	push af
	ld a, ")"
	ld [hli], a
	ld a, "."
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], "<@>"
	ld hl, wTextBuffer
	rst Print
	ld hl, EmptyString
	rst Print
	pop af
	ld [rMR3w], a
	ld a, 5
	ld [hMax], a
.loop
	ld a, MR3_MAP_RTC
	ld [rMR3w], a
.resample
	call GenerateRandomRTCSetting
	ld a, e
	cp 59
	jr nc, .resample
	call SetRTCToValue
	push hl
	call LatchReadRTC
	pop hl
	ld a, [hli]
	cp b
	jr nz, .error
	ld a, [hli]
	cp c
	jr nz, .error
	ld a, [hli]
	cp d
	jr nz, .error
	ld a, [hl]
	sub e
	jr z, .ok
	dec a
	jr z, .ok
.error
	push de
	ld hl, .error_text
	ld de, wTextBuffer
	rst CopyString
	ld h, d
	ld l, e
	pop de
	call GenerateTimeString
	ld hl, wTextBuffer
	rst Print
	call IncrementErrorCount
.ok
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	ld hl, EmptyString
	rst Print
	jp ReinitializeMRRegisters

.error_text
	db "FAILED: could not<LF>"
	db "set RTC to<LF>"
	db "<@>"

RTCRolloversTest::
	ld hl, .initial_test_text
	rst Print
	ld hl, EmptyString
	rst Print
	ld a, MR3_RTC_ON
	ld [rMR3w], a
.resample_minute_rollover
	call GenerateRandomRTCSetting
	ld a, d
	cp 59
	jr nc, .resample_minute_rollover
	ld e, 59
	call SetRTCToValue
	inc d
	ld e, 0
	call WaitForRTCChange
	call CheckRTCForValue
.resample_hour_rollover
	call GenerateRandomRTCSetting
	ld a, c
	and $1f
	cp 23
	jr nc, .resample_hour_rollover
	lb de, 59, 59
	call SetRTCToValue
	inc c
	ld de, 0
	call WaitForRTCChange
	call CheckRTCForValue
.resample_day_rollover
	call Random
	or $1f
	ld c, a
	inc a
	jr z, .resample_day_rollover
	res 3, c
	call Random
	ld b, a
	lb de, 59, 59
	call SetRTCToValue
	set 3, c
	inc c
	ld de, 0
	call WaitForRTCChange
	call CheckRTCForValue
.resample_week_rollover
	call Random
	ld b, a
	inc a
	jr z, .resample_week_rollover
	ld c, (6 << 5) | 23
	lb de, 59, 59
	call SetRTCToValue
	ld de, 0
	ld c, d
	inc b
	call WaitForRTCChange
	call CheckRTCForValue
	ld hl, EmptyString
	rst Print
	jp ReinitializeMRRegisters

.initial_test_text
	db "Testing RTC value<LF>"
	db "rollovers...<@>"

RTCOverflowTest::
	ld hl, .initial_test_text
	rst Print
	ld hl, EmptyString
	rst Print
	ld hl, rMR3w
	ld [hl], MR3_RTC_OFF
	ld [hl], MR3_CLEAR_RTC_OVERFLOW
	ld [hl], MR3_MAP_RTC
	ld hl, rRTCS
	ld a, 59
	ld [hld], a
	ld [hld], a
	ld a, (6 << 5) | 23
	ld [hld], a
	ld [hl], $ff
	ld a, MR3_RTC_ON
	ld [rMR3w], a
	call WaitForRTCChange
	call LatchReadRTC
	ld hl, rRTCW
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	inc hl
	or [hl]
	jr z, .no_time_error
	ld hl, .time_error_text
	rst Print
	call IncrementErrorCount
.no_time_error
	ld hl, rMR3w
	ld de, rMR4r
	ld [hl], MR3_MAP_REGS
	ld a, [de]
	and 8
	jr nz, .overflow_is_on
	push hl
	ld hl, .overflow_on_error_text
	rst Print
	call IncrementErrorCount
	pop hl
.overflow_is_on
	ld [hl], MR3_CLEAR_RTC_OVERFLOW
	ld a, [de]
	and 8
	jr z, .overflow_is_off
	ld hl, .overflow_off_error_text
	rst Print
	call IncrementErrorCount
.overflow_is_off
	ld hl, EmptyString
	rst Print
	jp ReinitializeMRRegisters

.initial_test_text
	db "Testing RTC<LF>"
	db "overflow behavior<LF>"
	db "and flag...<@>"
.time_error_text
	db "FAILED: RTC value<LF>"
	db "did not fully<LF>"
	db "roll over<@>"
.overflow_on_error_text
	db "FAILED: overflow<LF>"
	db "flag is not on<@>"
.overflow_off_error_text
	db "FAILED: overflow<LF>"
	db "flag did not clear<@>"

RTCLatchTest::
	ld hl, .initial_test_text
	rst Print
	ld hl, EmptyString
	rst Print
	ld a, 3
	ld [hMax], a
.loop
	call GenerateRandomRTCSetting
	ld a, e
	cp 57 ;make sure the test doesn't involve rollovers
	jr nc, .loop
	ld a, MR3_RTC_OFF
	ld [rMR3w], a
	call SetRTCToValue
	ld hl, rRTCW
	call Random
	ld [hli], a
	call Random
	ld [hli], a
	call Random
	ld [hli], a
	call Random
	ld [hli], a
	call CheckRTCForValue
	ld hl, WaitingString
	rst Print
	ld hl, rMR3w
	ld [hl], MR3_RTC_ON
	ld a, 80
	rst DelayFrames
	ld [hl], MR3_MAP_RTC
	call CheckRTCLatchForValue
	inc e
	inc e
	call LatchReadRTC
	ld a, [rRTCS]
	cp e
	jr z, .seconds_match
	dec e
.seconds_match
	call CheckRTCLatchForValue
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	ld hl, EmptyString
	rst Print
	jp ReinitializeMRRegisters

.initial_test_text
	db "Testing RTC<LF>"
	db "latching...<@>"

RTCRunningFlagTest::
	ld hl, .initial_test_text
	rst Print
	ld hl, EmptyString
	rst Print
	ld a, MR3_MAP_RTC
	ld [rMR3w], a
	xor a
	ld hl, rRTCW
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	; hl = $a003
	ld h, a
	; hl = $0003
	ld [hl], MR3_SET_RTC
	ld [hl], a ;a = MR3_MAP_REGS
	ld [hl], MR3_RTC_ON
	ld a, [rMR4r]
	and 4
	jr nz, .on
	push hl
	ld hl, .on_error_text
	rst Print
	call IncrementErrorCount
	pop hl
.on
	ld [hl], MR3_RTC_OFF
	ld a, [rMR4r]
	and 4
	jr nz, .off
	ld hl, .off_error_text
	rst Print
	call IncrementErrorCount
.off
	ld hl, EmptyString
	rst Print
	jp ReinitializeMRRegisters

.initial_test_text
	db "Testing MR4 RTC<LF>"
	db "on/off flag...<@>"
.on_error_text
	db "FAILED: MR4 RTC<LF>"
	db "flag is off while<LF>"
	db "running<@>"
.off_error_text
	db "FAILED: MR4 RTC<LF>"
	db "flag is on while<LF>"
	db "stopped<@>"
