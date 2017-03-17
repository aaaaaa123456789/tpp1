MainTestingMenu::
	menu "Main menu", MainTestingMenu
	option "ROM bank tests", OPTION_MENU, ROMTestingMenu
	option "RAM bank tests", OPTION_EXEC, NotImplemented
	end_menu

ROMTestingMenu:
	menu "ROM bank tests", MainTestingMenu
	option "Test bank sample", OPTION_EXEC, TestROMBankSampleOption
	option "Test bank range", OPTION_EXEC, TestROMBankRangeOption
	option "Test all banks", OPTION_EXEC, TestAllROMBanksOption
	option "Back", OPTION_MENU, MainTestingMenu
	end_menu

NotImplemented:
	ld hl, .text
	call MessageBox
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	ret

.text
	db "Not implemented.<@>"
