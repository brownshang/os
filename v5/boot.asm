%include "address.asm"
[BITS 16]
jmp start
msgnovesa db 'No VESA mode options are availabe yet.'

start:
 xor ax,ax
 mov ds,ax
 mov [bootdrv],dl	;���������豸��
;------------------------------------------------
;��ȡVESA��Ϣ���ŵ�1000H�������ж��Ƿ���VESA�Կ�
;------------------------------------------------
 mov di,2000H
 mov ax,4f00H
 int 10H
 cmp ax,004fH
 jnz near novesa
 call getvesainfo
;------------------------------------------------
;��ȡ������������ģ��һ�ζ���
;------------------------------------------------
 xor ax,ax
 mov es,ax
read:			;������ʧ�ܣ���λ������������
 xor ah,ah
 mov dl,[bootdrv]
 int 13H
read_rt:
 mov ah,02H
 mov al,12		;Ҫ��ȡ��������
 mov bx,setup		;ES:BX=���ݻ�������ַ
 mov ch,0		;�ŵ���
 mov cl,2		;������
 xor dh,dh		;��ͷ��
 mov dl,[bootdrv]	;��������
 int 13H
 jc read
kill_motor:
 mov dx,03f2H
 xor al,al
 out dx,al		;�ر����������
;------------------------------------------------
;����VESA��ʾģʽ
;------------------------------------------------
 mov ax,4F02H		;�����жϹ��ܺţ���ʾʹ��4F02H�Ź���
 mov bx,4114H		;������ʾģʽ�ţ���ʾʹ��114H(16bit)��ʾģʽ
 int 10H		;����BIOS��10H���жϣ������Կ�����

 jmp 0000:setup
;------------------------------------------------
;��ȡVESA��Ϣ�ӳ���
;------------------------------------------------
getvesainfo:
getvesaversion:
 mov si,2000H
 mov ax,[si+4]
 mov dx,ax	;save digits into dx
 and ax,0FH	;mask low nibble
 add al,90H
 daa
 adc al,40H
 daa
 mov [vesaversion+1],al
 mov al,dh	;get high digit
 and ax,0FH	;mask low nibble
 add al,90H
 daa
 adc al,40H
 daa
 mov [vesaversion],al
getvesaddr:
 mov di,3000H
 mov ax,4f01H
 mov cx,0114H
 int 10H
 mov eax,[di+40]
 mov [vesaddr],eax
getvesaname:
 mov ax,[si+6]
 mov dx,[si+8]
 mov [vesaname],dx
 mov [vesaname+2],ax
getvesainfo_end:
 ret
;------------------------------------------------
;��VESA�Կ�
;------------------------------------------------
novesa:
 mov ah,03H
 xor bh,bh
 int 10H
 mov ax,1301H
 mov bx,0007H
 mov bp,msgnovesa
 mov cx,38
 int 10H
 mov dx,03f2H
 xor al,al
 out dx,al
 jmp $

 times 510-($-$$) db 0
 db 55H
 db 0AAH