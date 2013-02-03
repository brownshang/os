;--------------------------------------------------------------------------------------------------
;版权所有 (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha版本
;只用作测试,请用NASM编译
;打开A20地址线、设置8259A、进入保护模式、设置键盘中断和时钟中断
;--------------------------------------------------------------------------------------------------
%macro  IDT_ITEM 5
	dw	%1	;32位偏移地址低16位
	dw	%2	;代码段描述符在GDT中的位置
	db	%3	;双字计数字段
	db	%4	;类型
	dw	%5	;32位偏移地址高16位
%endmacro
jmp start
msg db 'Starting system...'
GDT
	DUMMY
		dw	0
		dw	0
		db	0
		db	0
		db	0
		db	0
	Code
		dw	0ffffH
	 	dw	0000H
	 	db	00H
	 	db	10011010B
	 	db	11001111B
	 	db	00H
	DataS
		dw 	0ffffH
		dw 	0000H
		db 	00H
		db 	10010010B
		db 	11001111B
		db 	00H
	Video
		dw	3999
		dw	8000H	;基址是0xb8000
		db	0bH	;0x0b与上面的0x8000合成为0xb8000
		db	92H
		db	00H
		db	00H
GDTEND
GDTR
	dw GDTEND-GDT
	dd GDT+9000H
IDTR
	dw 256*8-1
	dd IDT+9000H
start:
 xor ax,ax
 mov ds,ax

 mov ax,0900H
 mov es,ax
 mov bp,msg
 mov ax,1301H
 mov bx,0002H
 mov cx,17
 mov dh,1
 xor dl,dl
 int 10H	;输出“Starting system...”这段文字

 cli		;禁止中断

 seta20_1:	;打开a20地址线,可以访问更多内存了
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
 out 60H,al

 setpic:	;设置8259A可编程中断控制器的子程序
 mov al,11H
 out 20H,al	;向0x20端口发送ICW1 (0x11)
 jmp $+2
 mov al,11H
 out 0a0H,al	;向0xA0端口发送ICW1 (0x11)
 jmp $+2
 mov al,20H
 out 21H,al	;向0x21端口发送ICW2 (0x20)
 jmp $+2
 mov al,28H
 out 0a1H,al	;向0xa1端口发送ICW2 (0x28)
 jmp $+2
 mov al,04H
 out 21H,al	;向0x21端口发送ICW3 (0x4)
 jmp $+2
 mov al,02H
 out 0a1H,al	;向0xa1端口发送ICW3 (0x2)
 jmp $+2
 mov al,01H
 out 21H,al	;向0x21端口发送ICW4 (0x1)
 jmp $+2
 mov al,01H
 out 0a1H,al	;向0xa1端口发送ICW4 (0x1)
 jmp $+2
 mov al,0ffH
 out 21H,al	;屏蔽所有中断
 jmp $+2
 mov al,0ffH
 out 0a1H,al	;屏蔽所有中断

 lgdt [9000H+GDTR]

 mov eax,cr0
 inc al
 mov cr0,eax	;进入保护模式

 jmp dword 08H:pm+9000H

[BITS 32]
pm:
 mov ax,10H
 mov ds,ax 	;初始化ds和es，使其指向数据段
 mov es,ax
 mov ebp,eax
 mov ax,18H	;初始化gs，使其指向显示内存
 mov gs,ax
 
 lidt [9000H+IDTR]

 mov al,0fcH	;允许键盘中断 
 out 21H,al
 sti		;允许中断

 mov esi,320

 jmp $
;--------------------时钟中断---------------------------------------------------------------
bits 32
clock_int:
	pushad
	cmp cx,300		;判断是否达到显示时间
	jnl beeb		;若达到则跳转到beeb显示字符
	mov al,0x20		;若否则退出中断并为cx加1
	out 0x20,al	
	popad
	add cx,1		;为cx加1
	jmp return 		;退出中断
beeb:	cmp bl,0x3a		;判断是否为9
	jnl clean		;若是则跳转到clean处重置bl为0
	mov word [gs:158],bx	;若bl小于等于9，则显示
	mov al,0x20
	out 0x20,al
	popad
	add bl,1		;为bl赠1
	mov cx,0		;置cx为0
	jmp return	
clean:	mov al,0x20	
	out 0x20,al
	popad
	mov bl,0x30		;重置bl为0
	jmp return 
return:	iret
;--------------------------------------------------------------------------------------------
IDT		;此处定义了256个中断描述符
	%rep	9
	IDT_ITEM clock_int,0x8,0,10001110b,0
	%endrep
	%rep	247	
	IDT_ITEM 0x9a01,0x8,0,10001110b,0	;所有的中断符都的偏移都指向kb的内存位置
	%endrep
IDTEND

 times 2560-($-$$) db 0