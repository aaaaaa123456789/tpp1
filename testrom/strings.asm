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

UnknownLastROMBankString::
	db "Could not detect<LF>"
	db "last ROM bank.<@>"

NoRAMString::
	db "No RAM present in<LF>"
	db "the current build.<@>"

UninitializedRAMString::
	db "RAM contents are<LF>"
	db "not initialized.<@>"

OneRAMBankString::
	db "Only one bank of<LF>"
	db "RAM is present.<@>"

NoRumbleString::
	db "This build has<LF>"
	db "rumble disabled.<@>"

NoRTCString::
	db "This build has<LF>"
	db "the RTC disabled.<@>"

WaitingString::
	db "Waiting...<@>"

RTCSetTestingString::
	db "Testing setting<LF>"
	db "the RTC (while<LF>"
	db "turned o<@>"

RTCMirrorFailString::
	db "FAILED: address<LF>"
	db "$"
	bigdw hCurrent + 1, hCurrent
	db " did not<LF>"
	db "contain a mirror<LF>"
	db "of the RTC data<@>"

ParenthesisMaxBankString::
	db "(max bank: <@>"

MemoryViewerDescriptionString::
	db "Enter the address<LF>"
	db " that you want to<LF>"
	db " view. An area of<LF>"
	db "memory containing<LF>"
	db "your address will<LF>"
	db "be loaded. Use the<LF>"
	db " arrow buttons to<LF>"
	db " move around the<LF>"
	db "   memory bank.<@>"

InvalidAddressString::
	db "The address is not<LF>"
	db "within range!<@>"

BankTooHighString::
	db "The selected bank<LF>"
	db "does not exist!<@>"

TitleString::
	db " TPP1 testing ROM<LF>"
	db "<LF>"
	db "http://github.com/<LF>"
	db "TwitchPlaysPokemon<LF>"
	db "      /tpp1/<@>"

AboutString::
	db "  Designed to test<LF>"
	db "  compliance of an<LF>"
	db "emulator or hardware<LF>"
	db "implementation with<LF>"
	db "   the TPP1 spec.<LF>"
	db "For more information<LF>"
	db "refer to the speci-<LF>"
	db "   fication file.<LF>"
	db "<LF>"
	db "   TPPDevs - 2017<LF>"
	db "<LF>"
	db "       <A> Back<@>"
