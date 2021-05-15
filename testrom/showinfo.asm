AboutBox::
	call ClearScreen
	ld de, TitleString
	hlcoord 1, 0
	rst PrintString
	ld de, AboutString
	hlcoord 0, 6
	rst PrintString
PrintBackMessageAndWait:
	ld hl, AButtonBackString
	decoord 7, 17
	rst CopyString
	jp WaitForAPress

DisplaySystemInformation::
	call ClearScreenAndStopUpdates
	ld hl, .system_info_text
	decoord 1, 0
	rst CopyString
	hlcoord 0, 2
	lb de, SCREEN_WIDTH, 6
	call Textbox
	ld hl, .build_params_text
	decoord 1, 2
	rst CopyString
	ld hl, MaxROMBankString
	decoord 1, 3
	rst CopyString
	ld hl, MaxRAMBankString
	decoord 1, 4
	rst CopyString
	ld de, .rumble_RTC_text
	hlcoord 1, 5
	rst PrintString
	hlcoord 0, 8
	lb de, SCREEN_WIDTH, 4
	push de
	call Textbox
	ld de, .hardware_text
	hlcoord 1, 8
	rst PrintString
	hlcoord 0, 12
	pop de
	call Textbox
	hlcoord 1, 12
	ld de, .compliance_text
	rst PrintString
	hlcoord 14, 3
	call GetMaxValidROMBank
	jr c, .invalid_max_ROM_bank
	ld a, "$"
	ld [hli], a
	ld a, d
	call PrintHexByte
	ld a, e
	call PrintHexByte
	jr .printed_max_ROM_bank
.invalid_max_ROM_bank
	inc hl
	inc hl
	ld a, "?"
	ld [hli], a
	ld [hli], a
	ld [hl], a
.printed_max_ROM_bank
	hlcoord 16, 4
	call GetMaxValidRAMBank
	jr c, .invalid_max_RAM_bank
	ld a, "$"
	ld [hli], a
	ld a, c
	call PrintHexByte
	jr .printed_max_RAM_bank
.invalid_max_RAM_bank
	ld a, [TPP1RAMSize]
	and a
	jr z, .no_RAM
	ld a, "?"
	ld [hli], a
	ld [hli], a
	ld [hl], a
	jr .printed_max_RAM_bank
.no_RAM
	dec hl
	ld de, .none_text
	rst PrintString
.printed_max_RAM_bank
	hlcoord 18, 5
	call GetMaxRumbleSpeed
	jr z, .no_rumble
	add a, "0"
	ld [hl], a
	jr .printed_rumble
.no_rumble
	ld a, "o"
	ld [hld], a
	ld [hl], "n"
.printed_rumble
	hlcoord 18, 6
	call CheckRTCAllowed
	jr c, .no_RTC
	ld a, "s"
	ld [hld], a
	ld a, "e"
	ld [hld], a
	ld [hl], "y"
	jr .printed_RTC
.no_RTC
	ld a, "o"
	ld [hld], a
	ld [hl], "n"
.printed_RTC
	hlcoord 18, 9
	ldh a, [hGBType]
	cp $11
	ld a, "C"
	jr nz, .not_GBC
	ld [hld], a
.not_GBC
	dec a
	ld [hld], a
	ld [hl], "G"
	call GetCurrentSpeed
	ld a, "1"
	adc 0
	hlcoord 17, 10
	ld [hli], a
	ld [hl], "x"
	ldh a, [hComplianceTestRun]
	dec a
	jr z, .tested_once
	inc a
	jr z, .never_tested_compliance
	hlcoord 10, 13
	lb bc, 3, $ff
	call PrintByte
	inc hl
	ld de, .times_text
	jr .test_count_done
.tested_once
	hlcoord 15, 13
	ld de, .once_text
.test_count_done
	rst PrintString
	ld hl, hComplianceErrors
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld c, [hl]
	or c
	or e
	jr z, .compliant
	ld b, 0
	ld hl, wDigitsBuffer
	push hl
	call PrintNumber
	ld [hl], "<@>"
	ld a, LOW(wDigitsBuffer)
	sub l
	ld c, a
	ld b, $ff
	hlcoord 19, 14
	add hl, bc
	pop de
	rst PrintString
	jr .display_done
.compliant
	decoord 15, 14
	ld hl, .none_text
	rst CopyString
.display_done
	xor a
	ldh [hVBlankLine], a
	ld a, 3
	rst DelayFrames
	jp PrintBackMessageAndWait

.never_tested_compliance
	decoord 14, 13
	ld hl, .never_text
	rst CopyString
	hlcoord 16, 14
	ld a, "N"
	ld [hli], a
	ld a, "/"
	ld [hli], a
	ld [hl], "A"
	jr .display_done

.system_info_text
	db "System information<@>"
.build_params_text
	db "Build parameters<@>"
.rumble_RTC_text
	db "Rumble speeds:<LF>"
	db "RTC:<@>"
.hardware_text
	db "Hardware<LF>"
	db "Gameboy type:<LF>"
	db "CPU speed:<@>"
.compliance_text
	db "TPP1 compliance<LF>"
	db "Tested:<LF>"
	db "Errors:<@>"
.none_text
	db "none<@>"
.never_text
	db "never<@>"
.once_text
	db "once<@>"
.times_text
	db "times<@>"
