RTCOnOffTest::
	ld hl, .initial_test_text
	call PrintWithBlankLine
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
	jp PrintEmptyStringAndReinitializeMRRegisters

.on_failed
	push hl
	ld hl, .on_error_text
	jr .continue_error_message

.off_failed
	push hl
	ld hl, .off_error_text
.continue_error_message
	jp PrintAndIncrementErrorCount_HLPushed

.initial_test_text
	db "Testing RTC on/off<LF>"
	db "controls<...><@>"

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
	ld a, "<...>"
	ld [hli], a
	ld [hl], "<@>"
	ld hl, wTextBuffer
	call PrintWithBlankLine
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
	call LatchMapRTC
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
	call PrintAndIncrementErrorCount
.ok
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.error_text
	db "FAILED: could not<LF>"
	db "set RTC to<LF>"
	db "<@>"

RTCRolloversTest::
	ld hl, .initial_test_text
	call PrintWithBlankLine
	ld a, MR3_RTC_ON
	ld [rMR3w], a
	ld a, 4
	ld [hMax], a
.loop
	call GenerateRandomRTCSetting
	ld e, 59
	ld a, d
	cp e
	jr nc, .loop
	call SetRTCToValue
	inc d
	ld e, 0
	call CheckRTCForNewValue
.resample_hour_rollover
	call GenerateRandomRTCSetting
	ld a, c
	and $1f
	cp 23
	jr nc, .resample_hour_rollover
	call .do_day_rollover_settings
	inc c
	call CheckRTCForNewValue
.resample_day_rollover
	call Random
	and $e0
	cp $c0
	jr nc, .resample_day_rollover
	add a, 23
	ld c, a
	call Random
	ld b, a
	call .do_day_rollover_settings
	set 3, c
	inc c
	call CheckRTCForNewValue
.resample_week_rollover
	call Random
	ld b, a
	inc a
	jr z, .resample_week_rollover
	ld c, (6 << 5) | 23
	call .do_day_rollover_settings
	ld c, d
	inc b
	call CheckRTCForNewValue
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_test_text
	db "Testing RTC value<LF>"
	db "rollovers<...><@>"

.do_day_rollover_settings
	lb de, 59, 59
	call SetRTCToValue
	ld de, 0
	ret

RTCOverflowTest::
	ld hl, .initial_test_text
	call PrintWithBlankLine
	ld hl, rMR3w
	ld [hl], MR3_RTC_OFF
	ld [hl], MR3_CLEAR_RTC_OVERFLOW
	call .set_and_check
	call .set_and_check
	ld [hl], MR3_CLEAR_RTC_OVERFLOW
	ld a, [rMR4r]
	and 8
	call nz, PrintAndIncrementErrorCount
	jp PrintEmptyStringAndReinitializeMRRegisters

.set_and_check
	ld [hl], MR3_MAP_RTC
	push hl
	ld hl, rRTCS
	ld a, 59
	ld [hld], a
	ld [hld], a
	ld a, (6 << 5) | 23
	ld [hld], a
	ld [hl], $ff
	pop hl
	ld [hl], MR3_SET_RTC
	ld [hl], MR3_RTC_ON
	push hl
	call WaitForRTCChange
	call LatchMapRTC
	ld hl, rRTCW
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	inc hl
	or [hl]
	ld hl, .time_error_text
	call nz, PrintAndIncrementErrorCount
	pop hl
	ld [hl], MR3_MAP_REGS
	ld a, [rMR4r]
	and 8
	push hl
	ld hl, .overflow_on_error_text
	call z, PrintAndIncrementErrorCount
	pop hl
	ret

.initial_test_text
	db "Testing RTC<LF>"
	db "overflow behavior<LF>"
	db "and flag<...><@>"
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
	call PrintWithBlankLine
	ld a, 3
	ld [hMax], a
.loop
	call GenerateRandomRTCSetting
	ld a, e
	cp 57 ;make sure the test doesn't involve rollovers
	jr nc, .loop
	ld a, MR3_RTC_OFF
	ld [rMR3w], a
	call SetRTCToValue ;exits with hl = rRTCW
	push hl
	pop hl ;delay
	call Random
	ld [hli], a
	call Random
	ld [hli], a
	call Random
	ld [hli], a
	call Random
	ld [hl], a
	push bc
	push de
	call CheckRTCForValue
	pop de
	pop bc
	ld hl, WaitingString
	rst Print
	ld hl, rMR3w
	ld [hl], MR3_RTC_ON
	ld a, 80
	rst DelayFrames
	ld [hl], MR3_MAP_RTC
	push bc
	push de
	call CheckRTCLatchForValue
	pop de
	pop bc
	inc e
	call LatchMapRTC
	ld a, [rRTCS]
	cp e
	jr z, .seconds_match
	inc e
.seconds_match
	call CheckRTCLatchForValue
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_test_text
	db "Testing RTC<LF>"
	db "latching<...><@>"

RTCRunningFlagTest::
	ld hl, .initial_test_text
	call PrintWithBlankLine
	ld a, MR3_MAP_RTC
	ld [rMR3w], a
	xor a
	ld hl, rRTCW
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	; hl = $a003
	ld d, h
	ld e, l
	ld h, a
	; hl = $0003, de = $a003
	ld [hl], MR3_SET_RTC
	ld [hl], a ;a = MR3_MAP_REGS
	ld [hl], MR3_RTC_ON
	ld a, [de]
	and 4
	push hl
	ld hl, .on_error_text
	call z, PrintAndIncrementErrorCount
	pop hl
	ld [hl], MR3_RTC_OFF
	ld a, [de]
	and 4
	ld hl, .off_error_text
	call nz, PrintAndIncrementErrorCount
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_test_text
	db "Testing MR4 RTC<LF>"
	db "on/off flag<...><@>"
.on_error_text
	db "FAILED: MR4 RTC<LF>"
	db "flag is off while<LF>"
	db "running<@>"
.off_error_text
	db "FAILED: MR4 RTC<LF>"
	db "flag is on while<LF>"
	db "stopped<@>"

RTCSingleSpeedTiming::
	call GetCurrentSpeed
	ld hl, .error_text
	ret nc
	ldopt hl, OPTION_TEST, RTCSingleSpeedTimingTest
	ret

.error_text
	db "This test requires<LF>"
	db "double speed mode.<@>"

RTCSingleSpeedTimingTest:
	ld hl, .initial_test_text
	call PrintWithBlankLine
	ld hl, .switching_speeds_text
	call .print_message_and_switch
	ld hl, .testing_text
	call PrintWithBlankLine
	call RTCTimingTest_NoInitialBanner
	ld hl, .restoring_text
.print_message_and_switch
	call PrintWithBlankLine
	jp DoSpeedSwitch
	
.initial_test_text
	db "Testing RTC latch<LF>"
	db "timing in single<LF>"
	db "speed CPU mode<...><@>"
.switching_speeds_text
	db "Switching CPU<LF>"
	db "speeds<...><@>"
.testing_text
	db "Testing<...><@>"
.restoring_text
	db "Restoring double<LF>"
	db "speed mode<...><@>"

RTCTimingTest::
	ld hl, RTCTimingInitialTestString
	call PrintWithBlankLine
RTCTimingTest_NoInitialBanner:
	ld a, MR3_RTC_ON
	ld [rMR3w], a
	ld a, 3
	ld [hMax], a
.loop
	call GenerateRandomRTCSetting
	ld a, e
	cp 59
	jr nc, .loop ;ensure there are no rollovers
	call SetRTCToValue
	ld hl, wDataBuffer
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hl], e
	ld hl, rRTCW
	call Random
	ld [hli], a
	call Random
	ld [hli], a
	call Random
	ld [hli], a
	call Random
	ld [hl], a
	xor a ;ld a, MR3_MAP_REGS
	ld bc, rMR3w
	ld [bc], a
	call .do_timing_test
	ld hl, wDataBuffer
	ld a, [hli]
	cp b
	jr nz, .error
	ld a, [hli]
	cp c
	jr nz, .error
	ld a, [hli]
	cp d
	jr nz, .error
	ld a, e
	sub [hl]
	jr z, .ok
	dec a
	jr z, .ok
.error
	ld hl, wDataBuffer
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld d, a
	ld e, [hl]
	call RTCMismatchError
.ok
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.do_timing_test
	call GetCurrentSpeed
	jr c, .double_speed_test
	ld a, MR3_LATCH_RTC
	ld [bc], a
	ld a, MR3_MAP_RTC
	nop
	ld [bc], a
	ld a, [hld]
	ld d, [hl]
	ld e, a
	dec hl
	ld a, [hld]
	ld b, [hl]
	ld c, a
	ret

.double_speed_test
	ld a, MR3_LATCH_RTC
	ld [bc], a
	ld a, MR3_MAP_RTC
	inc de
	dec de
	ld [bc], a
	ld a, [hld]
	ld d, [hl]
	ld e, a
	dec hl
	ld a, [hld]
	ld b, [hl]
	ld c, a
	ret

RTCWritingMR4Test::
	ld hl, .initial_test_text
	call PrintWithBlankLine
	ld hl, rMR3w
	ld de, rMR4r
	ld [hl], MR3_RTC_OFF
	ld [hl], MR3_CLEAR_RTC_OVERFLOW
	ld [hl], MR3_MAP_RTC
	push hl
	ld h, d ;hl = rRTCS
	xor a
	ld [hld], a
	ld [hld], a
	ld [hld], a
	ld [hl], a
	pop hl
	ld [hl], MR3_SET_RTC
	ld [hl], a ;MR3_MAP_REGS
	ld a, [de]
	and $c
	call nz, .initial_error
	ld a, [de]
	xor $c
	ld [de], a
	ld a, [de]
	and $c
	call nz, .write_error
	ld [hl], MR3_RTC_ON
	ld a, [de]
	xor $c
	ld [de], a
	ld a, [de]
	and $c
	cp 4
	call nz, .write_error
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_error
	push hl
	ld hl, .initial_state_error_text
	jr .continue_error

.write_error
	push hl
	ld hl, .error_text
.continue_error
	jp PrintAndIncrementErrorCount_HLPushed

.initial_test_text
	db "Testing MR4 RTC-<LF>"
	db "related fields for<LF>"
	db "writing<...><@>"
.initial_state_error_text
	db "FAILED: initial<LF>"
	db "MR4 state was<LF>"
	db "incorrect<@>"
.error_text
	db "FAILED: MR4 fields<LF>"
	db "could be written<@>"

RTCUnmapLatchTest::
	ld hl, .initial_test_text
	call PrintWithBlankLine
	ld a, MR3_RTC_OFF
	ld [rMR3w], a
	ld a, 5
	ld [hMax], a
.loop
	call GenerateRandomRTCSetting
	call SetRTCToValue
	ld hl, rMR3w - 1
	inc hl ;ensure that there is enough delay
	ld [hl], MR3_MAP_RTC
	push hl
	ld h, rRTCS >> 8 ;hl = rRTCS
	call Random
	ld [hld], a
	call Random
	ld [hld], a
	call Random
	ld [hld], a
	call Random
	ld [hl], a
	pop hl
	ld [hl], h ;MR3_MAP_REGS
	ld [hl], MR3_LATCH_RTC
	push hl
	pop hl ;delay
	ld [hl], MR3_MAP_RTC
	call CheckRTCLatchForValue
	ld hl, hMax
	dec [hl]
	jr nz, .loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_test_text
	db "Testing RTC value<LF>"
	db "latching while<LF>"
	db "unmapped<...><@>"

RTCMirroringTestRead::
	ld hl, .initial_test_text
	call PrintWithBlankLine
	ld a, MR3_MAP_RTC
	ld [rMR3w], a
	ld hl, rRTCW
	call Random
	ld e, a
	ld [hli], a
	call Random
	ld d, a
	ld [hli], a
	call Random
	ld c, a
	ld [hli], a
	call Random
	ld b, a
	ld [hli], a
.loop
	call TestRTCMirroring
	inc hl
	bit 6, h
	jr z, .loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.initial_test_text
	db "Testing RTC value<LF>"
	db "mirroring when<LF>"
	db "reading<...><@>"

RTCMirroringTestWrite::
	ld hl, .initial_test_text
	call PrintWithBlankLine
	ld a, MR3_MAP_RTC
	ld [rMR3w], a
	ld a, 5
	ld [hMax], a
.outer_loop
	call .generate_random_address
	ld a, l
	ld [hCurrent], a
	ld a, h
	ld [hCurrent + 1], a
	push hl
	ld hl, .writing_to_text
	rst Print
	pop hl
	call Random
	ld e, a
	ld [hli], a
	call Random
	ld d, a
	ld [hli], a
	call Random
	ld c, a
	ld [hli], a
	call Random
	ld b, a
	ld [hl], a
	ld a, 5
	ld [hMax + 1], a
.inner_loop
	call .generate_random_address
	call TestRTCMirroring
	ld hl, hMax + 1
	dec [hl]
	jr nz, .inner_loop
	dec hl
	dec [hl]
	jr nz, .outer_loop
	jp PrintEmptyStringAndReinitializeMRRegisters

.generate_random_address
	call Random
	and $1f
	add a, $a0
	ld h, a
	call Random
	and $fc
	ld l, a
	ret

.initial_test_text
	db "Testing RTC value<LF>"
	db "mirroring after<LF>"
	db "writing<...><@>"
.writing_to_text
	db "Writing: $"
	bigdw hCurrent + 1, hCurrent
	db "<...><@>"

TestRTCMirroring:
	ld a, [hli]
	cp e
	jr nz, .error
	ld a, [hli]
	cp d
	jr nz, .error
	ld a, [hli]
	cp c
	jr nz, .error
	ld a, [hl]
	cp b
	ret z
.error
	ld a, l
	and $fc
	ld [hCurrent], a
	or 3
	ld l, a
	ld a, h
	ld [hCurrent + 1], a
	push hl
	ld hl, .error_text
	jp PrintAndIncrementErrorCount_HLPushed

.error_text
	db "FAILED: address<LF>"
	db "$"
	bigdw hCurrent + 1, hCurrent
	db " did not<LF>"
	db "contain a mirror<LF>"
	db "of the RTC data<@>"

RunAllRTCTests::
	call RTCOnOffTest
	call RTCSetWhileOnTest
	call RTCSetWhileOffTest
	call RTCRolloversTest
	call RTCOverflowTest
	call RTCTimingTest
	call GetCurrentSpeed
	call c, RTCSingleSpeedTimingTest
	call RTCLatchTest
	call RTCRunningFlagTest
	call RTCWritingMR4Test
	call RTCUnmapLatchTest
	call RTCMirroringTestRead
	call RTCMirroringTestWrite
	ld a, MR3_RTC_OFF
	ld [rMR3w], a
	ret
