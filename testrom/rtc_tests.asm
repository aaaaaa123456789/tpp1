CheckRTCAllowed::
	ld a, [TPP1Features]
	and 4
	ret nz
	scf
	ret
