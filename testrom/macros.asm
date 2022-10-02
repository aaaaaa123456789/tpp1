MACRO lb
	ld \1, (LOW(\2) << 8) | LOW(\3)
ENDM

MACRO bigdw
	rept _NARG
		db HIGH(\1), LOW(\1)
		shift
	endr
ENDM

MACRO dbww
	db \1
	dw \2, \3
ENDM

tile EQUS " + $10 * "

MACRO coord
	ld \1, wScreenBuffer + (\2) + ((\3) * SCREEN_WIDTH)
ENDM

MACRO dwcoord
	dw wScreenBuffer + (\1) + ((\2) * SCREEN_WIDTH)
ENDM

MACRO writecoord
	db $ea ;ld [nnnn], a
	dwcoord \1, \2
ENDM

MACRO const_def
  DEF const_value = 0
ENDM

MACRO const
  DEF \1 EQU const_value
  DEF const_value = const_value + 1
ENDM

MACRO shift_const
  DEF \1 EQU (1 << const_value)
  DEF const_value = const_value + 1
ENDM

MACRO option_label
.option_\1
ENDM

MACRO option_link
	dw .option_\1
ENDM

MACRO menu
  DEF option_number = 0
	option_link {d:option_number}
	dw \2
	db \1, "<@>"
ENDM

MACRO option
	option_label {d:option_number}
  DEF option_number = option_number + 1
	if _NARG > 3
		dw \4
	else
		option_link {d:option_number}
	endc
	dw (\3) | ((\2) << 14)
	db \1, "<@>"
ENDM

MACRO ldopt
	ld \1, (\3) | ((\2) << 14)
ENDM

MACRO end_menu
	option_label {d:option_number}
	dw -1
ENDM

MACRO hex_input
	dw \3
	dwcoord \1, \2
ENDM

MACRO hex_input_dw
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
	const OPTION_CHECK

; menu actions
	const_def
	const ACTION_NOTHING
	const ACTION_RELOAD
	const ACTION_REDRAW
	const ACTION_UPDATE
