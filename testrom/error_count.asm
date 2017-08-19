ClearErrorCount::
	push hl
	xor a
	ld hl, wErrorCount
	ld [hli], a
	ld [hli], a
	ld [hl], a
	pop hl
	ret

IncrementErrorCount::
	push hl
	ld hl, wErrorCount
	inc [hl]
	jr nz, .done
	inc hl
	inc [hl]
	jr nz, .done
	inc hl
	inc [hl]
	jr nz, .done
	dec [hl]
	dec hl
	dec [hl]
	dec hl
	dec [hl]
.done
	pop hl
	ret

GenerateErrorCountString::
	push bc
	push de
	ld hl, wErrorCount
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld c, [hl]
	or c
	or e
	ld hl, TestsPassedString
	jr z, .done
	ld b, 0
	ld hl, wTextBuffer
	push hl
	call PrintNumber
	ld d, h
	ld e, l
	ld hl, .error_text
	rst CopyString
	ld a, "<@>"
	ld [de], a
	pop hl
.done
	pop de
	pop bc
	ret

.error_text
	db " error(s)<LF>"
	db "were encountered!<@>"
