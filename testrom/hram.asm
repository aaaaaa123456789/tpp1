hGBType          EQU $ff80

hButtonsHeld     EQU $ff81
hButtonsPressed  EQU $ff82
hButtonsLast     EQU $ff83

hProduct         EQU $ff84 ;4 bytes

hTemp            EQU $ff88 ;4 bytes

hTextboxPointer  EQU $ffe8 ;2 bytes
hTextboxWidth    EQU $ffea
hTextboxHeight   EQU $ffeb
hTextboxLine     EQU $ffec

hHexEntryCount   EQU $ffed
hHexEntryData    EQU $ffee ;2 bytes
hHexEntryByte    EQU $fff0
hHexEntryCurrent EQU $fff1
hHexEntryRow     EQU $fff2
hHexEntryColumn  EQU $fff3

hSelectedMenu    EQU $fff4 ;2 bytes
hFirstOption     EQU $fff6
hSelectedOption  EQU $fff7
hOptionCount     EQU $fff8
hNextMenuAction  EQU $fff9

hFrameCounter    EQU $fffa ;2 bytes

hRandomCalls     EQU $fffc

hVBlankLine      EQU $fffd
hVBlankOccurred  EQU $fffe
