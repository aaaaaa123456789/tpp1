ExecuteTest::
	push hl
	call MakeFullscreenTextbox
	call ClearErrorCount
	pop hl
	call _hl_
	call GenerateErrorCountString
	rst Print
	jp EndFullscreenTextbox

LoadRAMTestingMenu::
	call GetMaxValidRAMBank
	ld hl, NoRAMString
	ret c
	ldopt hl, OPTION_MENU, RAMTestingMenu
	ret

LoadRTCTestingMenu::
	call CheckRTCAllowed
	ld hl, NoRTCString
	ret c
	ldopt hl, OPTION_MENU, RTCTestingMenu
	ret

LoadRumbleTestingMenu::
	call GetMaxRumbleSpeed
	and a
	ld hl, NoRumbleString
	ret z
	ldopt hl, OPTION_MENU, RumbleTestingMenu
	ret

RunAllTests::
	; we don't use ExecuteTest because we want to print a special compliance message
	call MakeFullscreenTextbox
	call ClearErrorCount
	call RunAllROMTests
	call .run_RAM_tests
	call .run_RTC_tests
	call .run_rumble_test
	call RunAllMRTests
	ld hl, rMR3w
	ld [hl], MR3_RTC_OFF
	ld [hl], MR3_RUMBLE_OFF
	ld [hl], MR3_MAP_REGS
	call .check_initial_test_results
	call GenerateErrorCountString
	rst Print
	ld hl, wErrorCount
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr nz, .no_compliance_message
	ld hl, EmptyString
	rst Print
	ld hl, .compliance_text
	rst Print
.no_compliance_message
	jp EndFullscreenTextbox

.run_RAM_tests
	call GetMaxValidRAMBank
	jp nc, RunAllRAMTests
	ld hl, NoRAMString
.print_and_return
	rst Print
	ld hl, EmptyString
	rst Print
	ret

.run_RTC_tests
	call CheckRTCAllowed
	jp nc, RunAllRTCTests
	ld hl, NoRTCString
	jr .print_and_return

.run_rumble_test
	call GetMaxRumbleSpeed
	and a
	jp nz, TestRumbleMR4
	ld hl, NoRumbleString
	jr .print_and_return

.check_initial_test_results
	ld a, [hInitialTestResult]
	and $f
	jr z, .initial_MR_passed
	ld hl, .initial_MR_failed_text
	rst Print
	ld hl, EmptyString
	rst Print
	call IncrementErrorCount
.initial_MR_passed
	ld a, [hInitialTestResult]
	and $10
	ret z
	ld hl, .initial_bank_failed_text
	rst Print
	ld hl, EmptyString
	rst Print
	jp IncrementErrorCount

.compliance_text
	db "The current engine<LF>"
	db "under test seems<LF>"
	db "to be compliant<LF>"
	db "with the TPP1<LF>"
	db "specification.<@>"

.initial_MR_failed_text
	db "FAILED: initial<LF>"
	db "values for MR<LF>"
	db "registers did not<LF>"
	db "match the expected<LF>"
	db "values<@>"
.initial_bank_failed_text
	db "FAILED: ROM bank<LF>"
	db "$0001 was not<LF>"
	db "initially mapped<@>"
