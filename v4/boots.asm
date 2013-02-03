;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha�汾
;ֻ��������,����NASM����
;������֡���ȡ�������ر����
;--------------------------------------------------------------------------------------------------
jmp start
bootdrv	db 0
vesaversion db 'VESA  . '
vesa_ram dw 0
vesa_name db 0
vesaddr dd 0
msgnovesa db 'No VESA mode options are availabe yet.'

start:
 xor ax,ax
 mov ds,ax
 mov es,ax
 mov [7c00H+bootdrv],dl	;���������豸��

 mov ax,0600H
 xor bh,bh
 xor cx,cx
 mov dx,184fH
 int 10h

 mov di,1000H
 mov ax,4f00H
 int 10H
 cmp ax,004fH
 jnz near novesa
 call getvesainfo
read:
 xor ax,ax
 mov es,ax
bad_rt:			;������ʧ�ܣ���λ������������
 xor ah,ah
 mov dl,[7c00H+bootdrv]
 int 13H
read_rt:
 mov ah,02H
 mov al,11		;Ҫ��ȡ��������
 mov bx,8000H		;ES:BX=���ݻ�������ַ
 mov ch,0		;�ŵ���
 mov cl,2		;������
 xor dh,dh		;��ͷ��
 mov dl,[7c00H+bootdrv]	;��������
 int 13H
 jc bad_rt
kill_motor:
 mov dx,03f2H
 xor al,al		;"mov al,0cH"���д���֤
 out dx,al		;�ر����������

 mov ax,4f02H
 mov ebx,114H
 int 10H

 jmp 0000:8000H

getvesainfo:
getvesaversion:
 mov si,1000H
 mov ax,[si+4]
 mov dx,ax	;save digits into dx
 and ax,0FH	;mask low nibble
 add al,90H
 daa
 adc al,40H
 daa
 mov [7c00H+vesaversion+7],al
 mov al,dh	;get high digit
 and ax,0FH	;mask low nibble
 add al,90H
 daa
 adc al,40H
 daa	
 mov [7c00H+vesaversion+5],al
getvesaramsize:
 mov ax,[si+18]
 mov [7c00H+vesa_ram],ax
getvesaname:
 mov ax,[si+6]
 mov dx,[si+8]
 mov es,dx
 mov si,ax
 mov di,1800H
 mov cx,64
getname:
 mov al,[es:si]
 test al,al
 jz getname_end
 mov [di],al
 inc di
 inc si
 dec cx
 jnz getname
getname_end:
 mov ax,64
 sub ax,cx
 mov [7c00H+vesa_name],ax
getvesaddr:
 xor ax,ax
 mov es,ax
 mov di,2000H
 mov ax,4f01H
 mov cx,0114H
 int 10H		;��ȡvesa��Ϣ
 mov eax,[di+40]
 mov [7c00H+vesaddr],eax	;��vesa�Դ��ַ����ds:[0500H]��
 ret

novesa:
 mov ax,07c0H
 mov es,ax
 mov ax,1301H
 mov bx,0007H
 mov bp,msgnovesa
 mov cx,38
 xor dx,dx
 int 10H
 jmp $

times 510-($-$$) db 0
 db 55H
 db 0AAH