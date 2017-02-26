; TPP1 registers, at base addresses.
rMR0w       EQU $0000
rMR1w       EQU $0001
rMR2w       EQU $0002
rMR3w       EQU $0003
rMR0r       EQU $a000
rMR1r       EQU $a001
rMR2r       EQU $a002
rMR4r       EQU $a003
rRTCW       EQU $a000
rRTCDH      EQU $a001
rRTCM       EQU $a002
rRTCS       EQU $a003

MR3_MAP_REGS            EQU $00
MR3_MAP_SRAM_RO         EQU $02
MR3_MAP_SRAM_RW         EQU $03
MR3_MAP_RTC             EQU $05
MR3_LATCH_RTC           EQU $10
MR3_SET_RTC             EQU $11
MR3_CLEAR_RTC_OVERFLOW  EQU $14
MR3_RTC_OFF             EQU $18
MR3_RTC_ON              EQU $19
MR3_RUMBLE_OFF          EQU $20
MR3_RUMBLE_LOW          EQU $21
MR3_RUMBLE_MED          EQU $22
MR3_RUMBLE_HIGH         EQU $23

; GB hardware registers. Mostly stolen from Prism.
; Only kept the ones which might have some relevance.

rJOYP       EQU $ff00 ; Joypad (R/W)
rDIV        EQU $ff04 ; Divider Register (R/W)
rTIMA       EQU $ff05 ; Timer counter (R/W)
rTMA        EQU $ff06 ; Timer Modulo (R/W)
rTAC        EQU $ff07 ; Timer Control (R/W)
rTAC_ON        EQU 2
rTAC_4096_HZ   EQU 0
rTAC_262144_HZ EQU 1
rTAC_65536_HZ  EQU 2
rTAC_16384_HZ  EQU 3
rIF         EQU $ff0f ; Interrupt Flag (R/W)
rLCDC       EQU $ff40 ; LCD Control (R/W)
rSTAT       EQU $ff41 ; LCDC Status (R/W)
rLY         EQU $ff44 ; LCDC Y-Coordinate (R)
rLYC        EQU $ff45 ; LY Compare (R/W)
rDMA        EQU $ff46 ; DMA Transfer and Start Address (W)
rWY         EQU $ff4a ; Window Y Position (R/W)
rWX         EQU $ff4b ; Window X Position minus 7 (R/W)
rIE         EQU $ffff ; Interrupt Enable (R/W)
