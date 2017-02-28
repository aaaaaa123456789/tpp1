RGBDS := rgbds

ROMSIZE := 0

all: padder.c testrom/banktest.asm testrom/charmap.asm testrom/copy.asm testrom/font.asm testrom/fontext.asm testrom/gbhw.asm testrom/hram.asm testrom/interrupt.asm testrom/macros.asm testrom/main.asm testrom/math.asm testrom/menu.asm testrom/random.asm testrom/rom.asm testrom/rst.asm testrom/text.asm testrom/util.asm testrom/wram.asm
	gcc -O3 padder.c -o padder
	cd testrom && ../${RGBDS}/rgbasm -o ../testrom.o rom.asm
	${RGBDS}/rgblink -o testrom.gb -p 0xff -n testrom.sym testrom.o
	./padder testrom.gb ${ROMSIZE}

