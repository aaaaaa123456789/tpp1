CheckRTCAllowed::
	ld a, [TPP1Features]
	and 4
	ret nz
	scf
	ret

LatchReadRTC:
	ld hl, rMR3w
	ld [hl], MR3_MAP_REGS
	ld [hl], MR3_LATCH_RTC
	push hl
	pop hl
	ld [hl], MR3_MAP_RTC
	ret

TurnRTCOff::
	ld a, MR3_RTC_OFF
	ld [rMR3w], a
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	ld hl, .text
	jp MessageBox

.text
	db "RTC turned off.<@>"

WaitForRTCChange:
	; returns frame count in a and zero flag indicating change
	push hl
	push de
	push bc
	call LatchReadRTC
	ld hl, rRTCW
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld d, a
	ld e, [hl]
	ld hl, WaitingString
	rst Print
	xor a
.loop
	push af
	call DelayFrame
	call LatchReadRTC
	ld hl, rRTCW
	ld a, [hli]
	cp b
	jr nz, .changed
	ld a, [hli]
	cp c
	jr nz, .changed
	ld a, [hli]
	cp d
	jr nz, .changed
	ld a, [hl]
	cp e
	jr nz, .changed
	pop af
	inc a
	and $3f
	jr nz, .loop
.done
	pop bc
	pop de
	pop hl
	ret

.changed
	pop af
	inc a
	jr .done

GenerateRandomRTCSetting:
	call Random
	ld b, a
.resample_day_hour
	call Random
	cp 7 << 5
	jr nc, .resample_day_hour
	ld c, a
	or $e7 ;set all bits that aren't the top two hour bits
	inc a
	jr z, .resample_day_hour
.resample_minutes
	call Random
	and $3f
	ld d, a
	cp 60
	jr nc, .resample_minutes
.resample_seconds
	call Random
	and $3f
	ld e, a
	cp 60
	jr nc, .resample_seconds
	ret

SetRTCRandomly:
	push bc
	push de
	push hl
	call GenerateRandomRTCSetting
	ld hl, rRTCW
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hl], e
	pop hl
	pop de
	pop bc
	ret

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
	ld hl, .initial_test_text
	ld a, MR3_RTC_ON
	jr RTCSetTest
	
.initial_test_text
	db "Testing setting<LF>"
	db "the RTC (while<LF>"
	db "turned on)...<@>"

RTCSetWhileOffTest::
	ld hl, .initial_test_text
	ld a, MR3_RTC_OFF
	jr RTCSetTest

.initial_test_text
	db "Testing setting<LF>"
	db "the RTC (while<LF>"
	db "turned off)...<@>"

RTCSetTest:
	push af
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
	ld hl, rRTCW
	push hl
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hl], e
	ld a, MR3_SET_RTC
	ld [rMR3w], a
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
