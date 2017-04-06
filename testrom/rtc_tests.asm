CheckRTCAllowed::
	ld a, [TPP1Features]
	and 4
	ret nz
	scf
	ret

LatchReadRTC::
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
