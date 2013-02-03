[ORG 7c00H]
[BITS 16]
jmp start
bootdrv	db 0
vesaversion db 'VESA  . '
vesaaddr dd 0
msgnovesa db 'No VESA mode options are availabe yet.'

start:
 mov [bootdrv],dl	;���������豸��

 mov di,1000H
 mov ax,4f00H
 int 10H
 cmp ax,004fH
 jnz near novesa
 call getvesainfo
 call putvesainfo

read:			;������ʧ�ܣ���λ������������
 xor ah,ah
 mov dl,[bootdrv]
 int 13H
read_rt:
 mov ah,02H
 mov al,11		;Ҫ��ȡ��������
 mov bx,8000H		;ES:BX=���ݻ�������ַ
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
 jmp $

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
 mov [vesaversion+7],al
 mov al,dh	;get high digit
 and ax,0FH	;mask low nibble
 add al,90H
 daa
 adc al,40H
 daa	
 mov [vesaversion+5],al
getvesaddr:
 mov di,2000H
 mov ax,4f01H
 mov cx,0114H
 int 10H
 mov eax,[di+40]
 mov [vesaaddr],eax
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
 ret

putvesainfo:
 xor ax,ax
 mov es,ax
 mov bx,0007H
 mov ah,0eH
 mov cx,64
putname:
 mov si,1800H
 mov al,[si]
 int 10H
 add si,1
 dec cx
 jnz putname

 mov ah,03H
 xor bh,bh
 int 10H
 add dh,1
 xor dl,dl
 mov ax,1301H
 mov bp,vesaversion
 mov cx,8
 int 10H
 ret

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