;--------------------------------------------------------------------------------------------------
;版权所有 (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha版本
;只用作测试,请用NASM编译
;打开A20地址线、设置8259A、进入保护模式、设置键盘中断和时钟中断
;--------------------------------------------------------------------------------------------------
%include "address.asm"
jmp start
ignore_int:
 iret
GDTR
	dw 4*8-1
	dd gdt
IDTR
	dw 256*8-1
	dd idt
start:
 xor ax,ax
 mov ds,ax

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

 lgdt [setup+GDTR]

 mov eax,cr0
 inc al
 mov cr0,eax	;进入保护模式

 jmp dword 08H:pm+setup

[BITS 32]
pm:
 lidt [setup+IDTR]
 sti		;允许中断
 mov al,0fcH	;允许键盘中断和时钟中断;;;;;;;;;;;;;;;;;;;;;;;mov al,0fcH
 out 21H,al

 mov eax,0010H
 mov ds,ax
 mov es,ax
 mov fs,ax
 mov gs,ax

 mov word[pixely],0
 mov word[pixelx],0

 mov esi,9400H;字符串首地址	;欢
 mov edi,[vesaddr];要写入显存地址
 add edi,800*2*50+70*2
 mov eax,0000011111100000B;颜色
 call putchar
 mov esi,9400H+18H		;迎
 mov edi,[vesaddr]
 add edi,800*2*50+90*2
 call putchar
 mov esi,9400H+30H		;打
 mov edi,[vesaddr]
 add edi,800*2*50+110*2
 call putchar
 mov esi,9400H+48H		;开
 mov edi,[vesaddr]
 add edi,800*2*50+130*2
 call putchar
 mov esi,9400H+60H		;计
 mov edi,[vesaddr]
 add edi,800*2*50+150*2
 call putchar
 mov esi,9400H+78H		;算
 mov edi,[vesaddr]
 add edi,800*2*50+170*2
 call putchar
 mov esi,9400H+90H		;机
 mov edi,[vesaddr]
 add edi,800*2*50+190*2
 call putchar
 mov esi,9400H+0A8H		;·
 mov edi,[vesaddr]
 add edi,800*2*100+110*2
 call putchar
 mov esi,9400H+0C0H		;请
 mov edi,[vesaddr]
 add edi,800*2*100+130*2
 call putchar
 mov esi,9400H+0D8H		;输
 mov edi,[vesaddr]
 add edi,800*2*100+150*2
 call putchar
 mov esi,9400H+0F0H		;入
 mov edi,[vesaddr]
 add edi,800*2*100+170*2
 call putchar
 mov esi,9400H+108H		;密
 mov edi,[vesaddr]
 add edi,800*2*100+190*2
 call putchar
 mov esi,9400H+120H		;码
 mov edi,[vesaddr]
 add edi,800*2*100+210*2
 call putchar
 mov esi,9400H+138H		;进
 mov edi,[vesaddr]
 add edi,800*2*100+230*2
 call putchar
 mov esi,9400H+150H		;入
 mov edi,[vesaddr]
 add edi,800*2*100+250*2
 call putchar
 mov esi,9400H+168H		;系
 mov edi,[vesaddr]
 add edi,800*2*100+270*2
 call putchar
 mov esi,9400H+180H		;统
 mov edi,[vesaddr]
 add edi,800*2*100+290*2
 call putchar

 mov word[pixely],125
 mov word[pixelx],130

 jmp $
;--------------------------------------------------------------------
putchar:
 mov ecx,12
putcharnext:
 push ecx
 mov ecx,12
 mov dx,[esi]
 inc esi
 inc esi
 call putcharline
 add edi,(800-12)*2
 pop ecx
 loop putcharnext
 ret
;*******************************************
putcharline:
 cmp ecx,0
 jz putcharlineok
 shl dx,1
 jnb putnopixelchar
 mov [edi],ax
putnopixelchar:
 inc edi
 inc edi
 dec ecx
 jmp putcharline
;*******************************************
putcharlineok:
 ret
;--------------------------------------------------------------------
 times 1024-($-$$) db 0