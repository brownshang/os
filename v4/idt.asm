%macro  IDT_ITEM 5
	dw	%1	;32λƫ�Ƶ�ַ��16λ
	dw	%2	;�������������GDT�е�λ��
	db	%3	;������Ϊ0
	db	%4	;10001110B for interrupt gate,10001111B for trap gate
	dw	%5	;32λƫ�Ƶ�ַ��16λ
%endmacro
IDT		;�˴�������256���ж�������
	%rep	32
	IDT_ITEM 8003H,8H,0,10001110b,0
	%endrep
	IDT_ITEM 8c00H,8H,0,10001110b,0	;IRQ0��ʱ���ж�
	IDT_ITEM 8e00H,8H,0,10001110b,0	;IRQ1�������ж�
	%rep	222
	IDT_ITEM 8003H,8H,0,10001110b,0
	%endrep
IDTEND