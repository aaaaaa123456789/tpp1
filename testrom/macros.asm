lb: MACRO
	ld \1, (((\2) & $ff) << 8) | ((\3) & $ff)
ENDM

LINES_PER_VBLANK EQU 6
SCREEN_WIDTH EQU 20
SCREEN_HEIGHT EQU 18
