%include "address.asm"
[BITS 16]
jmp start
msgnovesa db 'No VESA mode options are availabe yet.'

start:
 xor ax,ax
 mov ds,ax
 mov [bootdrv],dl	;储存引导设备号
;------------------------------------------------
;读取VESA信息，放到1000H处，并判断是否有VESA显卡
;------------------------------------------------
 mov di,2000H
 mov ax,4f00H
 int 10H
 cmp ax,004fH
 jnz near novesa
 call getvesainfo
;------------------------------------------------
;读取扇区程序，所有模块一次读完
;------------------------------------------------
 xor ax,ax
 mov es,ax
read:			;读扇区失败，复位驱动器后重试
 xor ah,ah
 mov dl,[bootdrv]
 int 13H
read_rt:
 mov ah,02H
 mov al,12		;要读取的扇区数
 mov bx,setup		;ES:BX=数据缓冲区地址
 mov ch,0		;磁道号
 mov cl,2		;扇区号
 xor dh,dh		;磁头号
 mov dl,[bootdrv]	;驱动器号
 int 13H
 jc read
kill_motor:
 mov dx,03f2H
 xor al,al
 out dx,al		;关闭驱动器马达
;------------------------------------------------
;设置VESA显示模式
;------------------------------------------------
 mov ax,4F02H		;设置中断功能号，表示使用4F02H号功能
 mov bx,4114H		;设置显示模式号，表示使用114H(16bit)显示模式
 int 10H		;调用BIOS的10H号中断，设置显卡功能

 jmp 0000:setup
;------------------------------------------------
;获取VESA信息子程序
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
;无VESA显卡
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