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
	db $00

_FillByte::
	jp FillByteFunction

_ContinueDelayFrames:
	pop af
	dec a
	jr nz, _LoopDelayFrames
	ret

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
