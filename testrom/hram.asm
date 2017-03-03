hGBType          EQU $ff80

hButtonsHeld     EQU $ff81
hButtonsPressed  EQU $ff82
hButtonsLast     EQU $ff83

hProduct         EQU $ff84 ;4 bytes

hSelectedMenu    EQU $fff4 ;2 bytes
hFirstOption     EQU $fff6
hSelectedOption  EQU $fff7
hOptionCount     EQU $fff8
hNextMenuAction  EQU $fff9 ;0 = nothing, 1 = clear and render, 2 = update options

hFrameCounter    EQU $fffa ;2 bytes

hRandomCalls     EQU $fffc

hVBlankLine      EQU $fffd
hVBlankOccurred  EQU $fffe
