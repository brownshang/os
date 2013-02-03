;--------------------------------------------------------------------------------------------------
;版权所有 (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha版本
;只用作测试,请用NASM编译
;输出文字、读取扇区、关闭马达
;--------------------------------------------------------------------------------------------------
jmp start

msgos db '                                YY TEXT 0.1 Beta'
msgcopy db '                     (C)Copyright Shang BaoLiang 2004-2005.'
msggo db ' Open A20 > Initialize 8259 PIC > Load GDT > In Protected Mode > Load IDT > END '
bootdrv	db 0

start:
 xor ax,ax
 mov ds,ax
 mov [bootdrv],dl	;储存引导设备号

 mov ax,0600H
 xor bh,bh
 xor cx,cx
 mov dx,184FH
 int 10h

 mov ax,07c0H
 mov es,ax
 mov ax,1301H
 mov bx,0007H

 mov bp,msgos
 mov cx,48
 xor dx,dx
 int 10H		;输出“YY TEXT 0.1 Beta”这段文字

 mov bp,msgcopy
 mov cx,59
 mov dh,1
 xor dl,dl
 int 10H		;输出“(C)Copyright Shang BaoLiang 2004-2005.”这段文字

 mov bp,msggo
 mov cx,80
 mov dh,2
 xor dl,dl
 int 10H

read:
 xor ax,ax
 mov es,ax
bad_rt:			;读扇区失败，复位驱动器后重试
 xor ah,ah
 mov dl,[bootdrv]
 int 13H
read_rt:
 mov ah,02H
 mov al,10		;要读取的扇区数
 mov bx,8000H		;ES:BX=数据缓冲区地址
 mov ch,0		;磁道号
 mov cl,2		;扇区号
 xor dh,dh		;磁头号
 mov dl,[bootdrv]	;驱动器号
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