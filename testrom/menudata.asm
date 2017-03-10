MainTestingMenu::
	menu "Main menu", MainTestingMenu
	option "ROM bank tests", OPTION_MENU, ROMTestingMenu
	end_menu

ROMTestingMenu:
	menu "ROM bank tests", MainTestingMenu
	option "Test bank range", OPTION_EXEC, TestROMBankRange
	option "Back", OPTION_MENU, MainTestingMenu
	end_menu
