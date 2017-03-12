ContinueString::
	db "<A> Continue<@>"

TestsPassedString::
	db "All tests passed.<@>"

GenerateErrorCountString::
	ld hl, wTextBuffer
	push hl
	call PrintNumber
	push de
	ld d, h
	ld e, l
	ld hl, .text
	rst CopyString
	ld h, d
	ld l, e
	pop de
	ld [hl], "<@>"
	pop hl
	ret
.text
	db " error(s)<LF>"
	db "were encountered!<@>"
