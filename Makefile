RGBDS := rgbds

all: testrom/charmap.asm testrom/font.asm testrom/fontext.asm testrom/gbhw.asm testrom/hram.asm testrom/interrupt.asm testrom/macros.asm testrom/main.asm testrom/rom.asm testrom/rst.asm testrom/util.asm testrom/wram.asm
	cd testrom && ../${RGBDS}/rgbasm -o ../testrom.o rom.asm
	${RGBDS}/rgblink -o testrom.gb -p 0xff -n testrom.sym testrom.o
