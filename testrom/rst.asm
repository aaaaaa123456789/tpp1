_Reset::
	; @ = 0
	di
	xor a
	ld sp, StackTop
	jp Restart

_CopyString::
	; @ = 8
	push af
	xor a
	call CopyBytesUntilMatch
	pop af
	ret
	
_hl_::
	jp hl

_FillByte::
	; @ = 10
	jp FillByteFunction

_FinishPopping:
	pop de
	jr _PopAFBC

_ContinueDelayFrames:
	pop af
	dec a

_DelayFrames::
	; @ = 18
	and a
	ret z
	push af
	call DelayFrame
	jr _ContinueDelayFrames

_PrintString::
	; @ = 20
	push bc
	push af
	call PrintStringFunction
_PopAFBC:
	pop af
	pop bc
	ret

_AddNTimes::
	; @ = 28
	and a
	ret z
	push bc
	call AddNTimesFunction
	pop bc
	ret

_CopyBytes::
	; @ = 30
	push af
	inc b
	inc c
	call CopyBytesFunction
	pop af
	ret

_Print::
	; @ = 38
	push bc
	push af
	push de
	call PrintFunction
	jr _FinishPopping
