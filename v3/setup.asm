;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha�汾
;ֻ��������,����NASM����
;��A20��ַ�ߡ�����8259A�����뱣��ģʽ�����ü����жϺ�ʱ���ж�
;--------------------------------------------------------------------------------------------------
jmp start
GDTR
	dw 4*8-1
	dd 8200H
IDTR
	dw 256*8-1
	dd 8400H
start:
 xor ax,ax
 mov ds,ax
 mov ax,0b800H
 mov es,ax

 cli		;��ֹ�ж�
 mov di,323
 mov cx,8
msg1:
 mov byte[es:di],2
 add di,2
 loop msg1

opena20:
 in al,92h
 or al,00000010b
 out 92h,al

;seta20_1:	;��a20��ַ��,���Է��ʸ����ڴ���
; in al,64H
; test al,02H
; jnz seta20_1
; mov al,0d1H
; out 64H,al
;seta20_2:
; in al,64H
; test al,02H
; jnz seta20_2
; mov al,0dfH
; out 60H,al

 mov di,345
 mov cx,19
msg2:
 mov byte[es:di],2
 add di,2
 loop msg2

init8259:
 mov al,11H	;11H��ʾ��ʼ�����ʼ����ICW1�����֣���ʾ���ش�������Ƭ8259���������Ҫ����ICW4������
 out 20H,al	;����оƬ��ICW1������
 jmp $+2
 mov al,11H
 out 0a0H,al	;���оƬ��ICW1������
 jmp $+2
 mov al,20H
 out 21H,al	;����оƬ��ICW2�����֣���оƬ��ʼ�жϺţ�Ҫ�����ַ
 jmp $+2
 mov al,28H
 out 0a1H,al	;���оƬ��ICW2�����֣���оƬ��ʼ�жϺ�
 jmp $+2
 mov al,04H
 out 21H,al	;����оƬ��ICW3�����֣���оƬ��IR2����оƬINT
 jmp $+2
 mov al,02H
 out 0a1H,al	;���оƬ��ICW3�����֣���ʾ��оƬINT���ӵ���оƬIR2������
 jmp $+2
 mov al,01H
 out 21H,al	;����оƬ��ICW4�����֣�8086ģʽ����ͨEOI��ʽ
 jmp $+2
 mov al,01H
 out 0a1H,al	;���оƬ��ICW4�����֣�8086ģʽ����ͨEOI��ʽ
 jmp $+2
 mov al,0ffH
 out 21H,al	;���������ж�
 jmp $+2
 mov al,0ffH
 out 0a1H,al	;���������ж�

 mov di,389
 mov cx,8
msg3:
 mov byte[es:di],2
 add di,2
 loop msg3

 lgdt [8000H+GDTR]

 mov di,411
 mov cx,17
msg4:
 mov byte[es:di],2
 add di,2
 loop msg4

 mov eax,cr0
 inc al
 mov cr0,eax	;���뱣��ģʽ

 jmp dword 08H:pm+8000H

[BITS 32]
pm:
 mov ax,10H
 mov ds,ax 	;��ʼ��ds��es��ʹ��ָ�����ݶ�
 mov es,ax
 mov ebp,eax
 mov ax,18H	;��ʼ��gs��ʹ��ָ����ʾ�ڴ�
 mov gs,ax

 mov di,451
 mov ecx,8
msg5:
 mov byte[gs:di],2
 add di,2
 loop msg5

 lidt [8000H+IDTR]

 mov al,0fdH	;��������жϺ�ʱ���ж�;;;;;;;;;;;;;;;;;;;;;;;mov al,0fcH
 out 21H,al
 sti		;�����ж�

 mov esi,480

 mov di,473
 mov ecx,3
msg6:
 mov byte[gs:di],2
 add di,2
 loop msg6

 jmp $

 times 512-($-$$) db 0