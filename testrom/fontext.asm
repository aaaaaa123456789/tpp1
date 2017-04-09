; extra characters (e.g., box lines) as a font
; same source as the regular font
	db $00, $00, $00, $FF, $FF, $00, $00, $00 ;horizontal line
	db $18, $18, $18, $18, $18, $18, $18, $18 ;vertical line
	db $00, $00, $00, $F8, $F8, $18, $18, $18 ;top-left corner
	db $00, $00, $00, $1F, $1F, $18, $18, $18 ;top-right corner
	db $18, $18, $18, $F8, $F8, $00, $00, $00 ;bottom-left corner
	db $18, $18, $18, $1F, $1F, $00, $00, $00 ;bottom-right corner

; custom characters
	db $0C, $1C, $3C, $7C, $3C, $1C, $0C, $00 ;arrow pointing right
	db $0C, $14, $24, $44, $24, $14, $0C, $00 ;hollow arrow pointing right
	db $00, $08, $1C, $3E, $7F, $7F, $00, $00 ;arrow pointing up
	db $00, $00, $7F, $7F, $3E, $1C, $08, $00 ;arrow pointing down
	db $00, $00, $00, $18, $18, $00, $00, $00 ;middle dot
	db $3C, $42, $99, $A5, $BD, $A5, $42, $3C ;A button
;	db $3C, $42, $81, $81, $81, $81, $42, $3C ;button
