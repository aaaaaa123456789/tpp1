lb: MACRO
	ld \1, (((\2) & $ff) << 8) | ((\3) & $ff)
ENDM

tile EQUS " + $10 * "

coord: MACRO
	ld \1, wScreenBuffer + (\2) + ((\3) * SCREEN_WIDTH)
ENDM

hlcoord EQUS "coord hl, "
decoord EQUS "coord de, "

LINES_PER_VBLANK EQU 6

SCREEN_WIDTH EQU 20
SCREEN_HEIGHT EQU 18

; shamelessly stolen from Prism, again
A_BUTTON   EQU $01
B_BUTTON   EQU $02
SELECT     EQU $04
START      EQU $08
D_RIGHT    EQU $10
D_LEFT     EQU $20
D_UP       EQU $40
D_DOWN     EQU $80

Reset EQU $00
CopyString EQU $08
FillByte EQU $10
