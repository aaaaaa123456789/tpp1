MainTestingMenu::
	menu "Main menu", MainTestingMenu
	option "Run all tests", OPTION_CHECK, NotImplemented
	option "ROM bank tests", OPTION_MENU, ROMTestingMenu
	option "RAM bank tests", OPTION_CHECK, LoadRAMTestingMenu
	option "RTC tests", OPTION_CHECK, NotImplemented
	option "Rumble tests", OPTION_CHECK, NotImplemented
	option "MR register tests", OPTION_MENU, MRTestingMenu
	option "Memory viewer", OPTION_CHECK, NotImplemented
	option "About", OPTION_EXEC, AboutBox
	option "Reset", OPTION_EXEC, DoReset
	end_menu

ROMTestingMenu::
	menu "ROM bank tests", MainTestingMenu
	option "Test bank sample", OPTION_EXEC, TestROMBankSampleOption
	option "Test bank range", OPTION_EXEC, TestROMBankRangeOption
	option "Test all banks", OPTION_TEST, TestAllROMBanks
	option "Bankswitch speed", OPTION_CHECK, NotImplemented
	option "Back", OPTION_MENU, MainTestingMenu
	end_menu

RAMTestingMenu::
	menu "RAM bank tests", MainTestingMenu
	option "Initialize banks", OPTION_EXEC, InitializeRAMBanks
	option "Run all tests", OPTION_TEST, RunAllRAMTests
	option "Test reads R/O", OPTION_TEST, TestRAMReadsReadOnly
	option "Test reads R/W", OPTION_TEST, TestRAMReadsReadWrite
	option "Write and verify", OPTION_TEST, TestRAMWrites
	option "Test writes R/O", OPTION_TEST, TestRAMWritesReadOnly
	option "Write deselected", OPTION_TEST, TestRAMWritesDeselected
	option "Swap banks desel.", OPTION_TEST, TestSwapRAMBanksDeselected
	option "R/W test (1 bank)", OPTION_EXEC, TestOneRAMBankReadWriteOption
	option "R/W test (range)", OPTION_EXEC, TestRAMBankRangeReadWriteOption
	option "R/W test (all)", OPTION_EXEC, TestAllRAMBanksReadWriteOption
	option "In-bank aliasing", OPTION_TEST, TestRAMInBankAliasing
	option "Cross-bank alias.", OPTION_TEST, TestRAMCrossBankAliasing
	option "Back", OPTION_MENU, MainTestingMenu
	end_menu

MRTestingMenu::
	menu "MR register tests", MainTestingMenu
	option "Run all tests", OPTION_CHECK, NotImplemented
	option "Mapping test", OPTION_TEST, MRMappingTest
	option "Mirroring test", OPTION_CHECK, NotImplemented
	option "Reading test", OPTION_CHECK, NotImplemented
	option "Writing test", OPTION_TEST, MRWritesTest
	option "Restore values", OPTION_EXEC, RestoreMRValues
	option "Back", OPTION_MENU, MainTestingMenu
	end_menu
