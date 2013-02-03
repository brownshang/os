;--------------------------------------------------------------------------------------------------
;版权所有 (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha版本
;只用作测试,请用NASM编译
;打开A20地址线、设置8259A、进入保护模式、设置键盘中断和时钟中断
;--------------------------------------------------------------------------------------------------
jmp start
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
 mov di,323
 mov cx,8
msg1:
 mov byte[es:di],2
 add di,2
 loop msg1

opena20:
 in al,92h
 or al,00000010b
 out 92h,al

;seta20_1:	;打开a20地址线,可以访问更多内存了
; in al,64H
; test al,02H
; jnz seta20_1
; mov al,0d1H
; out 64H,al
;seta20_2:
; in al,64H
; test al,02H
; jnz seta20_2
; mov al,0dfH
; out 60H,al

 mov di,345
 mov cx,19
msg2:
 mov byte[es:di],2
 add di,2
 loop msg2

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

 mov di,389
 mov cx,8
msg3:
 mov byte[es:di],2
 add di,2
 loop msg3

 lgdt [8000H+GDTR]

 mov di,411
 mov cx,17
msg4:
 mov byte[es:di],2
 add di,2
 loop msg4

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

 mov di,451
 mov ecx,8
msg5:
 mov byte[gs:di],2
 add di,2
 loop msg5

 lidt [8000H+IDTR]

 mov al,0fdH	;允许键盘中断和时钟中断;;;;;;;;;;;;;;;;;;;;;;;mov al,0fcH
 out 21H,al
 sti		;允许中断

 mov esi,480

 mov di,473
 mov ecx,3
msg6:
 mov byte[gs:di],2
 add di,2
 loop msg6

 jmp $

 times 512-($-$$) db 0