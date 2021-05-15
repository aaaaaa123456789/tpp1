RGBASM ?= rgbasm
RGBLINK ?= rgblink
RGBFIX ?= rgbfix
CC ?= gcc

ROMSIZE := 9
RAMSIZE := 5
RTC     := ON
RUMBLE  := MULTI

# This line simply sets the ROMFLAGS variable to a string like +RTC+MULTIRUMBLE to pass to RGBFIX.
ROMFLAGS := $(if $(RTC),+RTC,)$(if $(RUMBLE),+$(and $(findstring $(RUMBLE),MULTI),$(findstring MULTI,$(RUMBLE)))RUMBLE,)

all: padder.c $(wildcard testrom/*.asm)
	${CC} -O3 padder.c -o padder
	cd testrom && ${RGBASM} -o ../testrom.o rom.asm
	${RGBLINK} -o testrom.gb -p 0xff -n testrom.sym testrom.o
	./padder testrom.gb ${ROMSIZE}
	${RGBFIX} -cv -p 0xff -r ${RAMSIZE} -m TPP1_1.0+BATTERY${ROMFLAGS} -l 0x33 -k TP -t TPP1TESTROM -i TPP1 testrom.gb
	sort testrom.sym -o testrom.sym

clean:
	rm -rf testrom.o testrom.gb testrom.sym padder
