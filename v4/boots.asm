;--------------------------------------------------------------------------------------------------
;版权所有 (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha版本
;只用作测试,请用NASM编译
;输出文字、读取扇区、关闭马达
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
 mov [7c00H+bootdrv],dl	;储存引导设备号

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
bad_rt:			;读扇区失败，复位驱动器后重试
 xor ah,ah
 mov dl,[7c00H+bootdrv]
 int 13H
read_rt:
 mov ah,02H
 mov al,11		;要读取的扇区数
 mov bx,8000H		;ES:BX=数据缓冲区地址
 mov ch,0		;磁道号
 mov cl,2		;扇区号
 xor dh,dh		;磁头号
 mov dl,[7c00H+bootdrv]	;驱动器号
 int 13H
 jc bad_rt
kill_motor:
 mov dx,03f2H
 xor al,al		;"mov al,0cH"，有待查证
 out dx,al		;关闭驱动器马达

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
 int 10H		;读取vesa信息
 mov eax,[di+40]
 mov [7c00H+vesaddr],eax	;将vesa显存地址存入ds:[0500H]处
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