;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha�汾
;ֻ��������,����NASM����
;��A20��ַ�ߡ�����8259A�����뱣��ģʽ�����ü����жϺ�ʱ���ж�
;--------------------------------------------------------------------------------------------------
%macro  IDT_ITEM 5
	dw	%1	;32λƫ�Ƶ�ַ��16λ
	dw	%2	;�������������GDT�е�λ��
	db	%3	;˫�ּ����ֶ�
	db	%4	;����
	dw	%5	;32λƫ�Ƶ�ַ��16λ
%endmacro
jmp start
msg db 'Starting system...'
GDT
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
		dw	8000H	;��ַ��0xb8000
		db	0bH	;0x0b�������0x8000�ϳ�Ϊ0xb8000
		db	92H
		db	00H
		db	00H
GDTEND
GDTR
	dw GDTEND-GDT
	dd GDT+9000H
IDTR
	dw 256*8-1
	dd IDT+9000H
start:
 xor ax,ax
 mov ds,ax

 mov ax,0900H
 mov es,ax
 mov bp,msg
 mov ax,1301H
 mov bx,0002H
 mov cx,17
 mov dh,1
 xor dl,dl
 int 10H	;�����Starting system...���������

 cli		;��ֹ�ж�

 seta20_1:	;��a20��ַ��,���Է��ʸ����ڴ���
 in al,64H
 test al,02H
 jnz seta20_1
 mov al,0d1H
 out 64H,al
seta20_2:
 in al,64H
 test al,02H
 jnz seta20_2
 mov al,0dfH
 out 60H,al

 setpic:	;����8259A�ɱ���жϿ��������ӳ���
 mov al,11H
 out 20H,al	;��0x20�˿ڷ���ICW1 (0x11)
 jmp $+2
 mov al,11H
 out 0a0H,al	;��0xA0�˿ڷ���ICW1 (0x11)
 jmp $+2
 mov al,20H
 out 21H,al	;��0x21�˿ڷ���ICW2 (0x20)
 jmp $+2
 mov al,28H
 out 0a1H,al	;��0xa1�˿ڷ���ICW2 (0x28)
 jmp $+2
 mov al,04H
 out 21H,al	;��0x21�˿ڷ���ICW3 (0x4)
 jmp $+2
 mov al,02H
 out 0a1H,al	;��0xa1�˿ڷ���ICW3 (0x2)
 jmp $+2
 mov al,01H
 out 21H,al	;��0x21�˿ڷ���ICW4 (0x1)
 jmp $+2
 mov al,01H
 out 0a1H,al	;��0xa1�˿ڷ���ICW4 (0x1)
 jmp $+2
 mov al,0ffH
 out 21H,al	;���������ж�
 jmp $+2
 mov al,0ffH
 out 0a1H,al	;���������ж�

 lgdt [9000H+GDTR]

 mov eax,cr0
 inc al
 mov cr0,eax	;���뱣��ģʽ

 jmp dword 08H:pm+9000H

[BITS 32]
pm:
 mov ax,10H
 mov ds,ax 	;��ʼ��ds��es��ʹ��ָ�����ݶ�
 mov es,ax
 mov ebp,eax
 mov ax,18H	;��ʼ��gs��ʹ��ָ����ʾ�ڴ�
 mov gs,ax
 
 lidt [9000H+IDTR]

 mov al,0fcH	;��������ж� 
 out 21H,al
 sti		;�����ж�

 mov esi,320

 jmp $
;--------------------ʱ���ж�---------------------------------------------------------------
bits 32
clock_int:
	pushad
	cmp cx,300		;�ж��Ƿ�ﵽ��ʾʱ��
	jnl beeb		;���ﵽ����ת��beeb��ʾ�ַ�
	mov al,0x20		;�������˳��жϲ�Ϊcx��1
	out 0x20,al	
	popad
	add cx,1		;Ϊcx��1
	jmp return 		;�˳��ж�
beeb:	cmp bl,0x3a		;�ж��Ƿ�Ϊ9
	jnl clean		;��������ת��clean������blΪ0
	mov word [gs:158],bx	;��blС�ڵ���9������ʾ
	mov al,0x20
	out 0x20,al
	popad
	add bl,1		;Ϊbl��1
	mov cx,0		;��cxΪ0
	jmp return	
clean:	mov al,0x20	
	out 0x20,al
	popad
	mov bl,0x30		;����blΪ0
	jmp return 
return:	iret
;--------------------------------------------------------------------------------------------
IDT		;�˴�������256���ж�������
	%rep	9
	IDT_ITEM clock_int,0x8,0,10001110b,0
	%endrep
	%rep	247	
	IDT_ITEM 0x9a01,0x8,0,10001110b,0	;���е��жϷ�����ƫ�ƶ�ָ��kb���ڴ�λ��
	%endrep
IDTEND

 times 2560-($-$$) db 0