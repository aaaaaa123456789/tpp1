ExecuteTest::
	push hl
	call MakeFullscreenTextbox
	call ClearErrorCount
	pop hl
	call _hl_
PrintErrorCountAndEnd::
	call GenerateErrorCountString
	rst PrintText
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

CheckInitialTests::
	ld hl, .initial_test_text
	call PrintWithBlankLine
	ldh a, [hInitialTestResult]
	and $f
	ld hl, .initial_MR_failed_text
	call nz, PrintAndIncrementErrorCount
	ldh a, [hInitialTestResult]
	and $10
	ld hl, .initial_bank_failed_text
	call nz, PrintAndIncrementErrorCount
	jp PrintEmptyString

.initial_test_text
	db "Checking initial<LF>"
	db "test results<...><@>"
.initial_MR_failed_text
	db "FAILED: initial<LF>"
	db "values for MR<LF>"
	db "registers were not<LF>"
	db "the expected ones<@>"
.initial_bank_failed_text
	db "FAILED: ROM bank<LF>"
	db "$0001 was not<LF>"
	db "initially mapped<@>"

RunAllTests::
	; we don't use ExecuteTest because we want to print a special compliance message
	call MakeFullscreenTextbox
	call ClearErrorCount
	call RunAllROMTests
	call .run_RAM_tests
	call .run_RTC_tests
	call .run_rumble_test
	call RunAllMRTests
	call CheckInitialTests
	call ClearMR4 ;exits with hl = rMR3w
	ld [hl], MR3_MAP_REGS
	call GenerateErrorCountString
	rst PrintText
	ld hl, wErrorCount
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr nz, .no_compliance_message
	call PrintEmptyString
	ld hl, .compliance_text
	rst PrintText
.no_compliance_message
	ld hl, hComplianceTestRun
	inc [hl]
	jr nz, .no_compliance_overflow
	dec [hl]
.no_compliance_overflow
	ld hl, wErrorCount
	ld a, [hli]
	ldh [hComplianceErrors], a
	ld a, [hli]
	ldh [hComplianceErrors + 1], a
	ld a, [hl]
	ldh [hComplianceErrors + 2], a
	jp EndFullscreenTextbox

.run_RAM_tests
	call GetMaxValidRAMBank
	jp nc, RunAllRAMTests
	ld hl, NoRAMString
.print_and_return
	jp PrintWithBlankLine

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

.compliance_text
	db "The current engine<LF>"
	db "under test seems<LF>"
	db "to be compliant<LF>"
	db "with the TPP1<LF>"
	db "specification.<@>"
