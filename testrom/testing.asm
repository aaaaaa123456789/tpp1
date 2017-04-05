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

LoadRumbleTestingMenu::
	call GetMaxRumbleSpeed
	and a
	ld hl, NoRumbleString
	ret z
	ldopt hl, OPTION_MENU, RumbleTestingMenu
	ret

NotImplemented::
	ld hl, .text
	ret

.text
	db "Not implemented.<@>"
