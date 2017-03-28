lb: MACRO
	ld \1, (((\2) & $ff) << 8) | ((\3) & $ff)
ENDM

bigdw: MACRO
	rept _NARG
		db (\1) >> 8, (\1) & $ff
		shift
	endr
ENDM

tile EQUS " + $10 * "

coord: MACRO
	ld \1, wScreenBuffer + (\2) + ((\3) * SCREEN_WIDTH)
ENDM

dwcoord: MACRO
	dw wScreenBuffer + (\1) + ((\2) * SCREEN_WIDTH)
ENDM

writecoord: MACRO
	db $ea ;ld [nnnn], a
	dwcoord \1, \2
ENDM

const_def: MACRO
const_value = 0
ENDM

const: MACRO
\1 EQU const_value
const_value = const_value + 1
ENDM

shift_const: MACRO
\1 EQU (1 << const_value)
const_value = const_value + 1
ENDM

option_label: MACRO
.option_\1
ENDM

option_link: MACRO
	dw .option_\1
ENDM

menu: MACRO
option_number = 0
	option_link {option_number}
	dw \2
	db \1, "<@>"
ENDM

option: MACRO
	option_label {option_number}
option_number = option_number + 1
	option_link {option_number}
	dw (\3) | ((\2) << 14)
	db \1, "<@>"
ENDM

end_menu: MACRO
	option_label {option_number}
	dw -1
ENDM

hex_input: MACRO
	dw \3
	dwcoord \1, \2
ENDM

hex_input_dw: MACRO
	hex_input \1, \2, (\3) + 1
	hex_input (\1) + 2, \2, \3
ENDM

hlcoord EQUS "coord hl, "
decoord EQUS "coord de, "

LINES_PER_VBLANK EQU 6
OPTIONS_PER_SCREEN EQU 12

SCREEN_WIDTH EQU 20
SCREEN_HEIGHT EQU 18

; shamelessly stolen from Prism, again
	const_def
	shift_const A_BUTTON
	shift_const B_BUTTON
	shift_const SELECT
	shift_const START
	shift_const D_RIGHT
	shift_const D_LEFT
	shift_const D_UP
	shift_const D_DOWN

; menu buttons
	const_def
	const MENU_NOINPUT
	const MENU_A
	const MENU_B
	const MENU_UP
	const MENU_DOWN
	const MENU_LEFT
	const MENU_RIGHT
	const MENU_SELECT
	const MENU_START

; option types
	const_def
	const OPTION_EXEC
	const OPTION_MENU
	const OPTION_TEST

; menu actions
	const_def
	const ACTION_NOTHING
	const ACTION_RELOAD
	const ACTION_REDRAW
	const ACTION_UPDATE

; RSTs
Reset EQU $00
CopyString EQU $08
FillByte EQU $10
DelayFrames EQU $18
PrintString EQU $20
AddNTimes EQU $28
CopyBytes EQU $30
Print EQU $38
