SECTION "HRAM", HRAM[$ff80]

hGBType:: db ;ff80, do not relocate

hButtonsHeld:: db ;ff81
hButtonsPressed:: db ;ff82
hButtonsLast:: db ;ff83

hProduct:: ds 4 ;ff84

hCurrent:: dw ;ff88
hCurrentTest EQU hCurrent + 1 ;ff89, overlapping with previous
hMax:: dw ;ff8a

hMemoryBank:: dw ;ff8c
hMemoryCursor EQU hMemoryBank + 1 ;ff8d, overlapping with previous
hMemoryAddress:: dw ;ff8e

hInitialTestNumber:: db ;ff90
hInitialTestResult:: db ;ff91

hComplianceTestRun:: db ;ff92
hComplianceErrors:: ds 3 ;ff93

hInitialBank:: dw ;ff96
hFinalBank:: dw ;ff98
hBankStep:: db ;ff9a

hSelectedRAMBank:: db ;ff9b
hSelectedROMBank:: dw ;ff9c

	ds $42

hTimesetSecond:: db ;ffe0
hTimesetMinute:: db ;ffe1
hTimesetHour:: db ;ffe2
hTimesetDay:: db ;ffe3
hTimesetWeek:: db ;ffe4
hTimesetCursor:: db ;ffe5

hRAMBanks:: db ;ffe6
hRAMInitialized:: db ;ffe7

hTextboxPointer:: dw ;ffe8
hTextboxWidth:: db ;ffea
hTextboxHeight:: db ;ffeb
hTextboxLine:: db ;ffec

hHexEntryCount:: db ;ffed
hHexEntryData:: dw ;ffee
hHexEntryByte:: db ;fff0
hHexEntryCurrent:: db ;fff1
hHexEntryRow:: db ;fff2
hHexEntryColumn:: db ;fff3

hSelectedMenu:: dw ;fff4
hFirstOption:: db ;fff6
hSelectedOption:: db ;fff7
hOptionCount:: db ;fff8
hNextMenuAction:: db ;fff9

hFrameCounter:: dw ;fffa

hRandomCalls:: db ;fffc

hVBlankLine:: db ;fffd
hVBlankOccurred:: db ;fffe
