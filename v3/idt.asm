%macro  IDT_ITEM 5
	dw	%1	;32位偏移地址低16位
	dw	%2	;代码段描述符在GDT中的位置
	db	%3	;双字计数字段
	db	%4	;类型
	dw	%5	;32位偏移地址高16位
%endmacro
IDT		;此处定义了256个中断描述符
	;%rep	9
	;IDT_ITEM 8c00H,8H,0,10001110b,0
	;%endrep
	%rep	256	
	IDT_ITEM 8e00H,8H,0,10001110b,0	;所有的中断符都的偏移都指向kb的内存位置
	%endrep
IDTEND