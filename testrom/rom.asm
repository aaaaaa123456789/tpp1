INCLUDE "charmap.asm"
INCLUDE "macros.asm"
INCLUDE "wram.asm"
INCLUDE "gbhw.asm"
INCLUDE "hram.asm"

SECTION "VRAM stuff", VRAM[$8000]

vTilesLow:: ds $1000
vTilesHigh:: ds $800
vBGMap:: ds $400
vWindowMap:: ds $400

SECTION "RSTs", ROM0[0]

INCLUDE "rst.asm"

SECTION "Interrupts", ROM0[$40]

INCLUDE "interrupt.asm"
INCLUDE "highhome.asm"

SECTION "Header", ROM0[$100]
	ld [hGBType], a
	db $18, $50 ; jr $0154, but rgbds doesn't like compiling a jr across section boundaries
	
	rept $50
		db $00
	endr

SECTION "Main", ROM0[$154]

INCLUDE "main.asm"
INCLUDE "menu.asm"
INCLUDE "util.asm"
INCLUDE "text.asm"
INCLUDE "hexentry.asm"
INCLUDE "math.asm"
INCLUDE "random.asm"
INCLUDE "printnum.asm"
INCLUDE "error_count.asm"

INCLUDE "menudata.asm"
INCLUDE "strings.asm"

INCLUDE "testing.asm"
INCLUDE "rom_tests.asm"
INCLUDE "ram_tests.asm"
INCLUDE "mr_tests.asm"

Font:: INCLUDE "font.asm"
ExtendedFont:: INCLUDE "fontext.asm"
