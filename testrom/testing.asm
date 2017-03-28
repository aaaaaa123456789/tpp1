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

NotImplemented::
	ld hl, .text
	ret

.text
	db "Not implemented.<@>"
