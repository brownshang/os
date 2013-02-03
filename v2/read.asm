;--------------------------------------------------------------------------------------------------
;版权所有 (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha版本
;只用作测试,请用NASM编译
;输出文字、读取扇区、关闭马达
;--------------------------------------------------------------------------------------------------
jmp start

msg db 'Loading kernel part...'
bootdrv	db 0

start:
 xor ax,ax
 mov ds,ax
 mov es,ax
 mov [bootdrv],dl	;储存引导设备号

 xor al,al
 mov ah,06H
 xor bx,bx
 xor cx,cx
 mov dx,194fH
 int 10H		;屏幕初始化

 mov ax,07c0H
 mov es,ax
 mov bp,msg
 mov ax,1301H
 mov bx,0002H
 mov cx,22
 xor dx,dx
 int 10H		;输出“Loading system...”这段文字

read:
 xor ax,ax
 mov es,ax
bad_rt:			;读扇区失败，复位驱动器后重试
 xor ah,ah
 mov dl,[bootdrv]
 int 0x13
read_1:
 mov ah,02H
 mov al,5		;要读取的扇区数
 mov bx,9000H		;ES:BX=数据缓冲区地址
 mov ch,0		;磁道号
 mov cl,2		;扇区号
 xor dh,dh		;磁头号
 mov dl,[bootdrv]	;驱动器号
 int 13H
 jc bad_rt
read_2:
 mov ah,02H
 mov al,1
 mov bx,9a01H
 mov ch,0
 mov cl,7
 xor dh,dh
 mov dl,[bootdrv]
 int 13H
 jc bad_rt
kill_motor:
 mov dx,03f2H
 xor al,al		;"mov al,0cH"，有待查证
 out dx,al		;关闭驱动器马达

 jmp 0000:8000H

times 510-($-$$) db 0
db 55H
db 0AAH