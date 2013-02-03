;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha�汾
;ֻ��������,����NASM����
;��A20��ַ�ߡ�����8259A�����뱣��ģʽ�����ü����жϺ�ʱ���ж�
;--------------------------------------------------------------------------------------------------
%include "address.asm"
jmp start
ignore_int:
 iret
GDTR
	dw 4*8-1
	dd gdt
IDTR
	dw 256*8-1
	dd idt
start:
 xor ax,ax
 mov ds,ax

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

 lgdt [setup+GDTR]

 mov eax,cr0
 inc al
 mov cr0,eax	;���뱣��ģʽ

 jmp dword 08H:pm+setup

[BITS 32]
pm:
 lidt [setup+IDTR]
 sti		;�����ж�
 mov al,0fcH	;��������жϺ�ʱ���ж�;;;;;;;;;;;;;;;;;;;;;;;mov al,0fcH
 out 21H,al

 mov eax,0010H
 mov ds,ax
 mov es,ax
 mov fs,ax
 mov gs,ax

 mov word[pixely],0
 mov word[pixelx],0

 mov esi,9400H;�ַ����׵�ַ	;��
 mov edi,[vesaddr];Ҫд���Դ��ַ
 add edi,800*2*50+70*2
 mov eax,0000011111100000B;��ɫ
 call putchar
 mov esi,9400H+18H		;ӭ
 mov edi,[vesaddr]
 add edi,800*2*50+90*2
 call putchar
 mov esi,9400H+30H		;��
 mov edi,[vesaddr]
 add edi,800*2*50+110*2
 call putchar
 mov esi,9400H+48H		;��
 mov edi,[vesaddr]
 add edi,800*2*50+130*2
 call putchar
 mov esi,9400H+60H		;��
 mov edi,[vesaddr]
 add edi,800*2*50+150*2
 call putchar
 mov esi,9400H+78H		;��
 mov edi,[vesaddr]
 add edi,800*2*50+170*2
 call putchar
 mov esi,9400H+90H		;��
 mov edi,[vesaddr]
 add edi,800*2*50+190*2
 call putchar
 mov esi,9400H+0A8H		;��
 mov edi,[vesaddr]
 add edi,800*2*100+110*2
 call putchar
 mov esi,9400H+0C0H		;��
 mov edi,[vesaddr]
 add edi,800*2*100+130*2
 call putchar
 mov esi,9400H+0D8H		;��
 mov edi,[vesaddr]
 add edi,800*2*100+150*2
 call putchar
 mov esi,9400H+0F0H		;��
 mov edi,[vesaddr]
 add edi,800*2*100+170*2
 call putchar
 mov esi,9400H+108H		;��
 mov edi,[vesaddr]
 add edi,800*2*100+190*2
 call putchar
 mov esi,9400H+120H		;��
 mov edi,[vesaddr]
 add edi,800*2*100+210*2
 call putchar
 mov esi,9400H+138H		;��
 mov edi,[vesaddr]
 add edi,800*2*100+230*2
 call putchar
 mov esi,9400H+150H		;��
 mov edi,[vesaddr]
 add edi,800*2*100+250*2
 call putchar
 mov esi,9400H+168H		;ϵ
 mov edi,[vesaddr]
 add edi,800*2*100+270*2
 call putchar
 mov esi,9400H+180H		;ͳ
 mov edi,[vesaddr]
 add edi,800*2*100+290*2
 call putchar

 mov word[pixely],125
 mov word[pixelx],130

 jmp $
;--------------------------------------------------------------------
putchar:
 mov ecx,12
putcharnext:
 push ecx
 mov ecx,12
 mov dx,[esi]
 inc esi
 inc esi
 call putcharline
 add edi,(800-12)*2
 pop ecx
 loop putcharnext
 ret
;*******************************************
putcharline:
 cmp ecx,0
 jz putcharlineok
 shl dx,1
 jnb putnopixelchar
 mov [edi],ax
putnopixelchar:
 inc edi
 inc edi
 dec ecx
 jmp putcharline
;*******************************************
putcharlineok:
 ret
;--------------------------------------------------------------------
 times 1024-($-$$) db 0