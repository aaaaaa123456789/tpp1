MainMenu::
	ld hl, hSelectedMenu
	ld a, MainTestingMenu & $ff
	ld [hli], a
	ld a, MainTestingMenu >> 8
	ld [hli], a
	xor a
	ld [hli], a
	ld [hl], a
	inc a
	ld [hNextMenuAction], a
	call RenderMenu
.loop
	call DelayFrame
	call GetMenuJoypad
	call nz, UpdateMenuContents
	call RenderMenu
	jr .loop

RenderMenu:
	ld a, [hNextMenuAction]
	and a
	ret z
	dec a
	jr nz, .not_full_redraw
	call ClearScreen
	ld a, 6
	rst DelayFrames
.not_full_redraw
	; ...
	ret

GetMenuJoypad:
	; ...
	ret

UpdateMenuContents:
	; ...
	ret
