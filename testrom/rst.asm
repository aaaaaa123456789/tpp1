Reset::
	di
	xor a
	ld sp, StackTop
	jp Restart

CopyString::
	push af
	xor a
	call CopyBytesUntilMatch
	pop af
	ret
	
_hl_::
	jp hl

FillByte::
	jp FillByteFunction

_FinishPopping:
	pop de
	jr _PopAFBC

_ContinueDelayFrames:
	pop af
	dec a
DelayFrames::
	and a
	ret z
	push af
	call DelayFrame
	jr _ContinueDelayFrames

PrintString::
	push bc
	push af
	call PrintStringFunction
_PopAFBC:
	pop af
	pop bc
	ret

AddNTimes::
	and a
	ret z
	push bc
	call AddNTimesFunction
	pop bc
	ret

CopyBytes::
	push af
	inc b
	inc c
	call CopyBytesFunction
	pop af
	ret

PrintText::
	push bc
	push af
	push de
	call PrintFunction
	jr _FinishPopping
