;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha�汾
;ֻ��������
;--------------------------------------------------------------------------------------------------
jmp start

msg db 'Starting system...'
bootdrv	db 0
gdt:
 dw 0000H,0000H,0000H,0000H
 dw 0ffffH,0000H,9a00H,00cfH
 dw 0ffffH,0000H,9200H,00cfH
 dw 0ffffH,0000H,9a00H,0000H
 dw 0ffffH,0000H,9200H,0000H
gdtp:
 dw 4*8-1
 dd 7c00H+gdt

start:

 xor ax,ax
 mov ds,ax
 mov [bootdrv],dl	;���������豸��

 mov ah,03H
 xor bh,bh
 int 10H		;��ȡ���λ��

 mov ax,07c0H
 mov es,ax
 mov bp,msg
 mov ax,1301H
 mov bx,0002H
 mov cx,12H
 int 10H		;�����Starting system...�������Ի�

 mov ax,4f02H
 mov bx,4115H
 int 10H		;����vesa��ɫ��ʾģʽ,����Ҳ���ɺڰ��ı�ģʽ,^_^
 xor ax,ax
 mov ds,ax
 mov es,ax
 mov di,0500H
 mov ax,4f01H
 mov cx,0115H
 int 10H		;��ȡvesa��Ϣ
 mov eax,[0500H+40]
 mov [0500H],eax	;��vesa�Դ��ַ����ds:[0500H]��

 call read		;�����ں˺ͺ����ֿ�

 cli			;��ֹ�ж�

seta20_1:
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
 out 60H,al		;��a20��ַ��,���Է��ʸ����ڴ���

 call setpic		;����8259A�ɱ���жϿ���оƬ

 lgdt [7c00H+gdtp]	;�����ж�GDT

 mov eax,cr0
 inc al
 mov cr0,eax		;���뱣��ģʽ����ս

 sti			;�����ж�

 jmp 0008H:1000H
 jmp $

read:			;��ȡ�����ӳ���
read_kernel:		;���ں�
 mov ax,0201H
 mov bx,1000H
 mov cx,0002H
 xor dh,dh
 mov dl,[bootdrv]
 int 13H
 jc bad_rt
read_font:		;���ֿ�
 mov ax,0201H
 mov bx,0600H
 mov cx,0003H
 xor dh,dh
 mov dl,[bootdrv]
 int 13H
 jc bad_rt
 mov dx,03f2H
 xor al,al		;"mov al,0cH"���д���֤
 out dx,al		;�ر����������
 ret
bad_rt:		;������ʧ�ܣ���λ������������
 xor ah,ah
 mov dl,[bootdrv]
 int 0x13
 jmp read

setpic:			;����8259A�ɱ���жϿ��������ӳ���
 mov al,11H
 out 20H,al		;��0x20�˿ڷ���ICW1 (0x11)
 jmp $+2
 mov al,11H
 out 0a0H,al		;��0xA0�˿ڷ���ICW1 (0x11)
 jmp $+2
 mov al,20H
 out 21H,al		;��0x21�˿ڷ���ICW2 (0x20)
 jmp $+2
 mov al,28H
 out 0a1H,al		;��0xa1�˿ڷ���ICW2 (0x28)
 jmp $+2
 mov al,04H
 out 21H,al		;��0x21�˿ڷ���ICW3 (0x4)
 jmp $+2
 mov al,02H
 out 0a1H,al		;��0xa1�˿ڷ���ICW3 (0x2)
 jmp $+2
 mov al,01H
 out 21H,al		;��0x21�˿ڷ���ICW4 (0x1)
 jmp $+2
 mov al,01H
 out 0a1H,al		;��0xa1�˿ڷ���ICW4 (0x1)
 jmp $+2
 mov al,0ffH
 out 21H,al		;���������ж�
 jmp $+2
 mov al,0ffH
 out 0a1H,al		;���������ж�
 ret

times 510-($-$$) db 0
db 55H
db 0AAH