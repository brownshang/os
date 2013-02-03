%macro  IDT_ITEM 5
	dw	%1	;32位偏移地址低16位
	dw	%2	;代码段描述符在GDT中的位置
	db	%3	;必须设为0
	db	%4	;10001110B for interrupt gate,10001111B for trap gate
	dw	%5	;32位偏移地址高16位
%endmacro
IDT		;此处定义了256个中断描述符
	%rep	32
	IDT_ITEM 8003H,8H,0,10001110b,0
	%endrep
	IDT_ITEM 8c00H,8H,0,10001110b,0	;IRQ0，时钟中断
	IDT_ITEM 8e00H,8H,0,10001110b,0	;IRQ1，键盘中断
	%rep	222
	IDT_ITEM 8003H,8H,0,10001110b,0
	%endrep
IDTEND