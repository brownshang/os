;--------------------------------------------------------------------------------------------------
;版权所有 (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha版本
;只用作测试,请用NASM编译
;打开A20地址线、设置8259A、进入保护模式、设置键盘中断和时钟中断
;--------------------------------------------------------------------------------------------------
jmp start
ignore_int:
 iret
GDTR
	dw 4*8-1
	dd 8200H
IDTR
	dw 256*8-1
	dd 8400H
start:
 xor ax,ax
 mov ds,ax
 mov ax,0b800H
 mov es,ax

 cli		;禁止中断
opena20:
 in al,92h
 or al,00000010b
 out 92h,al

init8259:
 mov al,11H	;11H表示初始化命令开始，是ICW1命令字，表示边沿触发、多片8259级连、最后要发送ICW4命令字
 out 20H,al	;向主芯片送ICW1命令字
 jmp $+2
 mov al,11H
 out 0a0H,al	;向从芯片送ICW1命令字
 jmp $+2
 mov al,20H
 out 21H,al	;向主芯片送ICW2命令字，主芯片起始中断号，要送奇地址
 jmp $+2
 mov al,28H
 out 0a1H,al	;向从芯片送ICW2命令字，从芯片起始中断号
 jmp $+2
 mov al,04H
 out 21H,al	;向主芯片送ICW3命令字，主芯片的IR2连从芯片INT
 jmp $+2
 mov al,02H
 out 0a1H,al	;向从芯片送ICW3命令字，表示从芯片INT连接到主芯片IR2引脚上
 jmp $+2
 mov al,01H
 out 21H,al	;向主芯片送ICW4命令字，8086模式，普通EOI方式
 jmp $+2
 mov al,01H
 out 0a1H,al	;向从芯片送ICW4命令字，8086模式，普通EOI方式
 jmp $+2
 mov al,0ffH
 out 21H,al	;屏蔽所有中断
 jmp $+2
 mov al,0ffH
 out 0a1H,al	;屏蔽所有中断

 lgdt [8000H+GDTR]

 mov eax,cr0
 inc al
 mov cr0,eax	;进入保护模式

 jmp dword 08H:pm+8000H

[BITS 32]
pm:
 mov ax,10H
 mov ds,ax 	;初始化ds和es，使其指向数据段
 mov es,ax
 mov ebp,eax
 mov ax,18H	;初始化gs，使其指向显示内存
 mov gs,ax

 lidt [8000H+IDTR]

 ;mov al,0fcH	;允许键盘中断和时钟中断;;;;;;;;;;;;;;;;;;;;;;;mov al,0fcH
 ;out 21H,al
 ;sti		;允许中断

init:
mov ax,0010H
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
;-------------------------------------------
mov cx,2;字的个数
mov esi,9200H;字符串首地址
mov edi,[7c0fH];要写入显存地址
mov eax,0ffffffffH;颜色
call putstr
jmp $
;----------------------------------------------------------------------------------------
putstr:
push cx
mov cx,16
call putchar
pop cx
loop putstr
ret
;*******************************************
putchar:
push cx
mov cx,16
mov dx,[esi]
inc esi
inc esi
call putcharline
add edi,(800-16)*4
pop cx
loop putchar
ret
;*******************************************
putcharline:
cmp cx,0
jz putcharlineok
shl dx,1
jnb putnopixelchar
mov [edi],eax
putnopixelchar:
inc edi
inc edi
inc edi
inc edi
dec cx
jmp putcharline
;*******************************************
putcharlineok:
ret

 times 512-($-$$) db 0