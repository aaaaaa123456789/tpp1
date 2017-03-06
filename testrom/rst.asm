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

_ContinueDelayFrames:
	pop af
	dec a
	ret z
	jr _LoopDelayFrames

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
