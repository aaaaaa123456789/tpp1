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
