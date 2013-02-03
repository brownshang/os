DUMMY
	dw	0
	dw	0
	db	0
	db	0
	db	0
	db	0
Code
	;; code_desc:
	;; base addr:	0x0000,0000
	;; limit:	0xffff,ffff = 4Gb
	;; Present:	1
	;; DPL:		00
	;; TYPE:	11CRA
	;; C:	Conforming = 0
	;; R:	Readable = 1
	;; A:	Accessed = 0
	dw	0ffffH
	dw	0000H
	db	00H
	db	10011010B
	db	11001111B
	db	00H
Data
	;; data_desc:
	;; base addr:	0x0000,0000
	;; limit:	0xffff,ffff = 4Gb
	;; Present:	1
	;; DPL:		00
	;; TYPE:	10EWA
	;; E:	Expand-down = 0
	;; W:	Writable = 1
	;; A:	Accessed = 0
	dw 	0ffffH
	dw 	0000H
	db 	00H
	db 	10010010B
	db 	11001111B
	db 	00H
times 512-($-$$) db 0