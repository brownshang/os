%macro  IDT_ITEM 5
	dw	%1	;32λƫ�Ƶ�ַ��16λ
	dw	%2	;�������������GDT�е�λ��
	db	%3	;˫�ּ����ֶ�
	db	%4	;����
	dw	%5	;32λƫ�Ƶ�ַ��16λ
%endmacro
IDT		;�˴�������256���ж�������
	;%rep	9
	;IDT_ITEM 8c00H,8H,0,10001110b,0
	;%endrep
	%rep	256	
	IDT_ITEM 8e00H,8H,0,10001110b,0	;���е��жϷ�����ƫ�ƶ�ָ��kb���ڴ�λ��
	%endrep
IDTEND