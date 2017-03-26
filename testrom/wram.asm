; note: bank 1 is used as a randomness source

SECTION "Main WRAM", WRAM0[$c000]

wScreenBuffer:: ds SCREEN_HEIGHT * SCREEN_WIDTH ;c000

wRandomSeed:: ds 8 ;c168

wSavedScreenData:: ds SCREEN_WIDTH * 4 ;c170

wTextBuffer:: ds 45 ;c1c0
wDigitsBuffer:: ds 11 ;c1ed

wInitialBank:: ds 2 ;c1f8
wFinalBank:: ds 2 ;c1fa
wBankStep:: ds 1 ;c1fc

wErrorCount:: ds 3 ;c1fd

wRandomBuffer:: ds $40 ;c200

SECTION "Program stack", WRAM0[$cf00]

Stack:: ds $100
StackTop::
