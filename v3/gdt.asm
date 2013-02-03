DUMMY
	dw	0
	dw	0
	db	0
	db	0
	db	0
	db	0
Code
	dw	0ffffH
	dw	0000H
	db	00H
	db	10011010B
	db	11001111B
	db	00H
DataS
	dw 	0ffffH
	dw 	0000H
	db 	00H
	db 	10010010B
	db 	11001111B
	db 	00H
Video
	dw	3999
	dw	8000H	;基址是b8000H
	db	0bH	;0bH与上面的8000H合成为b8000H
	db	10010010B
	db	00H
	db	00H


times 512-($-$$) db 0