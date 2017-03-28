ContinueString::
	db "<A> Continue<@>"

BankFailedString::
	db "FAILED: bank $"
	bigdw hCurrent + 1, hCurrent
EmptyString::
	db "<@>"

InvalidBankString::
	db "ERROR: bank $"
	bigdw hCurrent + 1, hCurrent
	db "<LF>"
	db "is not valid<@>"

UnknownMaxBankString::
	db "ERROR: could not<LF>"
	db "obtain highest ROM<LF>"
	db "bank number<@>"

TestsPassedString::
	db "All tests passed.<@>"

TestingAmountOfRAMBanksString::
	db "Testing RAM banks<LF>"
	db "$00-$"
	bigdw hRAMBanks
	db "...<@>"

RAMBankFailedString::
	db "FAILED: RAM bank<LF>"
	db "$"
	bigdw hCurrent
	db " did not match<LF>"
	db "the expected data<@>"

RAMReadOnlyTestDescriptionString::
	db "RAM reads in read-<LF>"
	db "only mode test:<@>"

TestingThreeBanksString::
	db "Testing 3 banks...<@>"

RAMBankOutOfRangeString::
	db "The selected RAM<LF>"
	db "bank is too high!<@>"

ZeroStepString::
	db "The step cannot<LF>"
	db "be zero.<@>"

NoBanksSelectedString::
	db "No banks have been<LF>"
	db "selected.<@>"

NoRAMString::
	db "No RAM present in<LF>"
	db "the current build.<@>"

UninitializedRAMString::
	db "RAM contents are<LF>"
	db "not initialized.<@>"

OneRAMBankString::
	db "Only one bank of<LF>"
	db "RAM is present.<@>"
