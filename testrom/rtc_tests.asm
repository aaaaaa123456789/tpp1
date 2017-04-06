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

SetRTCRandomly:
	push hl
	ld hl, rRTCW
	call Random
	ld [hli], a
.resample_day_hour
	call Random
	cp 7 << 5
	jr nc, .resample_day_hour
	bit 4, a
	jr z, .hour_OK
	bit 3, a
	jr nz, .resample_day_hour
.hour_OK
	ld [hli], a
.resample_minutes
	call Random
	and $3f
	cp 60
	jr nc, .resample_minutes
	ld [hli], a
.resample_seconds
	call Random
	and $3f
	cp 60
	jr nc, .resample_seconds
	ld [hl], a
	pop hl
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
