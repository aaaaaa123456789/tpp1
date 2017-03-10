_Reset::
	di
	xor a
	ld sp, StackTop
	jp $0154

_CopyString::
	push af
	xor a
	call CopyBytesUntilMatch
	pop af
	ret
	
EmptyString::
	db "<@>"

_FillByte::
	jp FillByteFunction

_FinishPopping:
	pop de
	jr _PopAFBC

_ContinueDelayFrames:
	pop af
	dec a

_DelayFrames::
	and a
	ret z
_LoopDelayFrames:
	push af
	call DelayFrame
	jr _ContinueDelayFrames

_PrintString::
	push bc
	push af
	call PrintStringFunction
_PopAFBC:
	pop af
	pop bc
	ret

_AddNTimes::
	and a
	ret z
	push bc
	call AddNTimesFunction
	pop bc
	ret

_CopyBytes::
	push af
	inc b
	inc c
	call CopyBytesFunction
	pop af
	ret

_Print::
	push bc
	push af
	push de
	call PrintFunction
	jr _FinishPopping
