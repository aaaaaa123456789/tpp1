InitializeRAMBanks::
	call CheckRAMPresent
	ret c
	call MakeFullscreenTextbox
	ld hl, .initial_text
	rst Print
	ld hl, EmptyString
	rst Print
.resample
	call Random
	and a
	jr z, .resample
	ld [hRAMInitialized], a
	call GetMaxValidRAMBank
	ld a, c
	ld [hRAMBanks], a
	ld hl, .selected_seed
	rst Print
	ld hl, EmptyString
	rst Print
	ld a, MR3_MAP_SRAM_RW
	ld [rMR3w], a
	ld c, 0
.loop
	ld a, c
	ld [rMR2w], a
	ld hl, $a000
	xor a
	ld [hli], a
	ld [hli], a
	ld a, [hRAMInitialized]
	ld [hli], a
	ld [hl], c
	ld hl, 0
	ld b, h
	ld a, [hRAMInitialized]
	rst AddNTimes
	ld b, h
	ld a, l
	ld hl, $bffc
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, $ff
	ld [hli], a
	ld [hl], a
	ld a, [hRAMBanks]
	cp c
	jr z, .done
	inc c
	jr .loop
.done
	xor a ;ld a, MR3_MAP_REGS
	ld [rMR3w], a
	ld hl, .done_text
	rst Print
	jp EndFullscreenTextbox

.initial_text
	db "Initializing RAM,<LF>"
	db "please wait...<@>"

.selected_seed
	db "Selected seed $"
	bigdw hRAMInitialized
	db "<LF>"
	db "for RAM content<LF>"
	db "initialization.<@>"

.done_text
	db "Initialized RAM<LF>"
	db "banks $00-$"
	bigdw hRAMBanks
	db ".<@>"

CheckRAMPresent:
	; prints an error box if there is no SRAM
	call GetMaxValidRAMBank
	ret nc
	ld hl, .text
	call MessageBox
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	scf
	ret
	
.text
	db "No RAM present in<LF>"
	db "the current build.<@>"

GetMaxValidRAMBank:
	; returns the max valid RAM bank in c
	; returns carry if invalid/zero (i.e., no SRAM)
	ld a, [MR3RAMSize]
	and a
	scf
	ret z
	cp 10
	ccf
	ret c
	ld c, a
	ld a, 1
	jr .handle_loop
.loop
	add a, a
.handle_loop
	dec c
	jr nz, .loop
	ld c, a
	dec c
	and a
	ret

CheckRAMInitialized:
	call CheckRAMPresent
	ret c
	ld a, [hRAMInitialized]
	and a
	ret nz
	ld hl, .text
	call MessageBox
	ld a, ACTION_UPDATE
	ld [hNextMenuAction], a
	scf
	ret

.text
	db "RAM contents are<LF>"
	db "not initialized.<@>"

TestRAMReadsReadOnlyOption::
	call CheckRAMInitialized
	ret c
	ld hl, TestRAMReadsReadOnly
	jp ExecuteTest

TestRAMReadsReadOnly:
	ld hl, RAMReadOnlyTestDescriptionString
	rst Print
	ld a, MR3_MAP_SRAM_RO
TestRAMReads:
	ld [rMR3w], a
	ld hl, TestingAmountOfRAMBanksString
	rst Print
	ld c, -1
.loop
	inc c
	ld a, c
	ld [hCurrent], a
	ld [rMR2w], a
	call TestReadContentsFromRAMBank
	jr nc, .not_failed
	ld hl, RAMBankFailedString
	rst Print
	call IncrementErrorCount
.not_failed
	ld a, [hRAMBanks]
	cp c
	jr nz, .loop
	ret

TestRAMReadsReadWriteOption::
	call CheckRAMInitialized
	ret c
	ld hl, TestRAMReadsReadWrite
	jp ExecuteTest

TestRAMReadsReadWrite:
	ld hl, .test_description_string
	rst Print
	ld a, MR3_MAP_SRAM_RW
	jr TestRAMReads

.test_description_string
	db "RAM reads in read/<LF>"
	db "write mode test:<@>"

TestReadContentsFromRAMBank:
	; tests reading from RAM bank a
	; returns carry if failed
	ld hl, $a000
	ld a, [hli]
	and a
	jr nz, .failed
	ld a, [hli]
	and a
	jr nz, .failed
	ld a, [hRAMInitialized]
	cp [hl]
	jr nz, .failed
	inc hl
	ld a, [hl]
	cp c
	jr nz, .failed
	ld hl, 0
	ld b, h
	ld a, [hRAMInitialized]
	rst AddNTimes
	ld a, l
	ld b, h
	ld hl, $bffc
	cp [hl]
	jr nz, .failed
	inc hl
	ld a, [hli]
	cp b
	jr nz, .failed
	ld a, [hli]
	and [hl]
	inc a
	jr nz, .failed
	ret
.failed
	scf
	ret
