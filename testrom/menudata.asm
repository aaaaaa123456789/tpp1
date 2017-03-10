MainTestingMenu::
	menu "Test menu", MainTestingMenu
	option "Option 0", OPTION_MENU, MainTestingMenu
	option "Option 1", OPTION_MENU, MainTestingMenu
	option "Option 2", OPTION_MENU, MainTestingMenu
	option "Option 3", OPTION_MENU, MainTestingMenu
	option "Test hex entry", OPTION_EXEC, TestHexEntry
	option "Option 5", OPTION_MENU, MainTestingMenu
	option "Option 6", OPTION_MENU, MainTestingMenu
	option "Option 7", OPTION_MENU, MainTestingMenu
	option "Option 8", OPTION_MENU, MainTestingMenu
	option "Option 9", OPTION_MENU, MainTestingMenu
	option "Option 10", OPTION_MENU, MainTestingMenu
	option "Option 11", OPTION_MENU, MainTestingMenu
	option "Option 12", OPTION_MENU, MainTestingMenu
	option "Option 13", OPTION_MENU, MainTestingMenu
	option "Option 14", OPTION_MENU, MainTestingMenu
	option "Option 15", OPTION_MENU, MainTestingMenu
	option "Option 16", OPTION_MENU, MainTestingMenu
	option "Option 17", OPTION_MENU, MainTestingMenu
	option "Option 18", OPTION_MENU, MainTestingMenu
	option "Option 19", OPTION_MENU, MainTestingMenu
	option "Option 20", OPTION_MENU, MainTestingMenu
	option "Option 21", OPTION_MENU, MainTestingMenu
	option "Option 22", OPTION_MENU, MainTestingMenu
	option "Option 23", OPTION_MENU, MainTestingMenu
	option "Option 24", OPTION_MENU, MainTestingMenu
	option "Option 25", OPTION_MENU, MainTestingMenu
	option "Option 26", OPTION_MENU, MainTestingMenu
	option "Option 27", OPTION_MENU, MainTestingMenu
	option "Option 28", OPTION_MENU, MainTestingMenu
	option "Option 29", OPTION_MENU, MainTestingMenu
	end_menu

TestHexEntry:
	hlcoord 0, 0
	lb de, SCREEN_WIDTH, SCREEN_HEIGHT
	call Textbox
	hlcoord 2, 2
	ld de, .screen_text
	rst PrintString
	ld hl, .hex_entries
	call HexadecimalEntry
	ret c
	ld hl, .confirmation_text
	decoord 5, 16
	rst CopyString
	call WaitForAPress
	ret

.screen_text
	db "C600:<LF><LF>"
	db "C640:<LF><LF>"
	db "C800:<@>"

.hex_entries
	hex_input 8, 2, $c601
	hex_input 10, 2, $c600
	hex_input 8, 4, $c641
	hex_input 10, 4, $c640
	hex_input 8, 6, $c801
	hex_input 10, 6, $c800
	dw 0

.confirmation_text
	db "<A> Continue<@>"
