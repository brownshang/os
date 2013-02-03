;--------------------------------------------------------------------------------------------------
;版权所有 (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha版本
;只用作测试
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
 mov [bootdrv],dl	;储存引导设备号

 mov ah,03H
 xor bh,bh
 int 10H		;读取光标位置

 mov ax,07c0H
 mov es,ax
 mov bp,msg
 mov ax,1301H
 mov bx,0002H
 mov cx,12H
 int 10H		;输出“Starting system...”，人性化

 mov ax,4f02H
 mov bx,4115H
 int 10H		;设置vesa彩色显示模式,将来也许换成黑白文本模式,^_^
 xor ax,ax
 mov ds,ax
 mov es,ax
 mov di,0500H
 mov ax,4f01H
 mov cx,0115H
 int 10H		;读取vesa信息
 mov eax,[0500H+40]
 mov [0500H],eax	;将vesa显存地址存入ds:[0500H]处

 call read		;读入内核和汉字字库

 cli			;禁止中断

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
 out 60H,al		;打开a20地址线,可以访问更多内存了

 call setpic		;设置8259A可编程中断控制芯片

 lgdt [7c00H+gdtp]	;加载中断GDT

 mov eax,cr0
 inc al
 mov cr0,eax		;进入保护模式，挑战

 sti			;允许中断

 jmp 0008H:1000H
 jmp $

read:			;读取磁盘子程序
read_kernel:		;读内核
 mov ax,0201H
 mov bx,1000H
 mov cx,0002H
 xor dh,dh
 mov dl,[bootdrv]
 int 13H
 jc bad_rt
read_font:		;读字库
 mov ax,0201H
 mov bx,0600H
 mov cx,0003H
 xor dh,dh
 mov dl,[bootdrv]
 int 13H
 jc bad_rt
 mov dx,03f2H
 xor al,al		;"mov al,0cH"，有待查证
 out dx,al		;关闭驱动器马达
 ret
bad_rt:		;读扇区失败，复位驱动器后重试
 xor ah,ah
 mov dl,[bootdrv]
 int 0x13
 jmp read

setpic:			;设置8259A可编程中断控制器的子程序
 mov al,11H
 out 20H,al		;向0x20端口发送ICW1 (0x11)
 jmp $+2
 mov al,11H
 out 0a0H,al		;向0xA0端口发送ICW1 (0x11)
 jmp $+2
 mov al,20H
 out 21H,al		;向0x21端口发送ICW2 (0x20)
 jmp $+2
 mov al,28H
 out 0a1H,al		;向0xa1端口发送ICW2 (0x28)
 jmp $+2
 mov al,04H
 out 21H,al		;向0x21端口发送ICW3 (0x4)
 jmp $+2
 mov al,02H
 out 0a1H,al		;向0xa1端口发送ICW3 (0x2)
 jmp $+2
 mov al,01H
 out 21H,al		;向0x21端口发送ICW4 (0x1)
 jmp $+2
 mov al,01H
 out 0a1H,al		;向0xa1端口发送ICW4 (0x1)
 jmp $+2
 mov al,0ffH
 out 21H,al		;屏蔽所有中断
 jmp $+2
 mov al,0ffH
 out 0a1H,al		;屏蔽所有中断
 ret

times 510-($-$$) db 0
db 55H
db 0AAH