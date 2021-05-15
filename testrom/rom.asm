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

SECTION "RSTs", ROM0[$0000]

INCLUDE "rst.asm"

SECTION "Interrupts", ROM0[$0040]

INCLUDE "interrupt.asm"
INCLUDE "highhome.asm"

SECTION "Header", ROM0[$0100]
	ldh [hGBType], a
	jr Init
	
	ds $50, 0

SECTION "Main", ROM0[$0154]

INCLUDE "main.asm"
INCLUDE "menu.asm"
INCLUDE "util.asm"
INCLUDE "text.asm"
INCLUDE "hexentry.asm"
INCLUDE "math.asm"
INCLUDE "random.asm"
INCLUDE "printnum.asm"
INCLUDE "error_count.asm"
INCLUDE "showinfo.asm"

INCLUDE "menudata.asm"
INCLUDE "strings.asm"

INCLUDE "testing.asm"
INCLUDE "rom_tests.asm"
INCLUDE "ram_tests.asm"
INCLUDE "rtc_tests.asm"
INCLUDE "rtc_test_utils.asm"
INCLUDE "rtc_display.asm"
INCLUDE "rtc_set.asm"
INCLUDE "rumble_tests.asm"
INCLUDE "mr_tests.asm"

INCLUDE "memory_viewer.asm"
INCLUDE "memory_viewer_loader.asm"

Font:: INCLUDE "font.asm"
ExtendedFont:: INCLUDE "fontext.asm"

ContentEnd::
