;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha�汾
;ֻ��������,����NASM����
;��A20��ַ�ߡ�����8259A�����뱣��ģʽ�����ü����жϺ�ʱ���ж�
;--------------------------------------------------------------------------------------------------
jmp start
ignore_int:
 iret
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
opena20:
 in al,92h
 or al,00000010b
 out 92h,al

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

 lgdt [8000H+GDTR]

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

 lidt [8000H+IDTR]

 ;mov al,0fcH	;��������жϺ�ʱ���ж�;;;;;;;;;;;;;;;;;;;;;;;mov al,0fcH
 ;out 21H,al
 ;sti		;�����ж�

init:
mov ax,0010H
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
;-------------------------------------------
mov cx,2;�ֵĸ���
mov esi,9200H;�ַ����׵�ַ
mov edi,[7c0fH];Ҫд���Դ��ַ
mov eax,0ffffffffH;��ɫ
call putstr
jmp $
;----------------------------------------------------------------------------------------
putstr:
push cx
mov cx,16
call putchar
pop cx
loop putstr
ret
;*******************************************
putchar:
push cx
mov cx,16
mov dx,[esi]
inc esi
inc esi
call putcharline
add edi,(800-16)*4
pop cx
loop putchar
ret
;*******************************************
putcharline:
cmp cx,0
jz putcharlineok
shl dx,1
jnb putnopixelchar
mov [edi],eax
putnopixelchar:
inc edi
inc edi
inc edi
inc edi
dec cx
jmp putcharline
;*******************************************
putcharlineok:
ret

 times 512-($-$$) db 0