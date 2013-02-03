%include "address.asm"
[ORG 8e00H]
[BITS 32]
jmp start
;mode是键盘标志，表示键盘功能键的状态，如功能键被按下，则相应位置1，各位标志如下：
;0位：左shift键,1位：右shift键,2位：左ctrl键,3位：右ctrl键
;4位：左alt键,5位：右alt键,6位：caps键,7位：Ins键
mode	db	0
;当0位为1表示扫描码为0xe0,当1位为1表示扫描码为0xe1，初始值为0
e_0_1 db 	0
;键盘映射表
key_map:
index0		db 0			;0x01的键盘映射(esc键）
index1		db "1234567890-="	;0x02--0x0d的键盘映射
index2		db 0,0			;0x0e--0x0f(BKSP键，TAB键 )
index3		db "qwertyuiop[]"	;0x10--0x1b
index4		db 0,0			;0x1c--0x1d(enter键，Lctrl键)
index5		db "asdfghjkl;'`"	;0x1e--0x29
index6		db 0			;0x2a(Lshift)
index7		db "\zxcvbnm,./"	;0x2b--0x35
index8		db 0			;0x36(Rshift)
index9		db "*"			;0x37(kp*)
index10		db 0			;0x38(Lalt)
index11		db 0			;0x39(space)
index12		db 0			;0x3a(caps)
;index13--index25是当Lshift被make时的键盘映射表
index13		db 0
index14		db "!@#$%^&*()_+"
index15		db 0,0
index16		db "QWERTYUIOP{}"
index17		db 0,0
index18		db 'ASDFGHJKL:"~'
index19		db 0
index20		db "|ZXCVBNM<>?"
index21		db 0
index22		db "*"
index23		db 0
index24		db 0
index25		db 0

start:
 pushad
 xor eax,eax
 mov edi,[vesaddr]
 mov ax,[pixely]
 mov ebx,1600
 mul ebx
 add edi,eax
 xor eax,eax
 mov ax,[pixelx]
 mov ebx,2
 mul ebx
 add edi,eax
 mov ebx,key_map			;得到键盘映射表的地址(key_map)
 in al,60H				;获得键盘扫描码
 cmp al,0e0H				;al是否为前导码0xe0，表示后面还跟随1个或2个扫描码
 je near set_e0
 cmp al,0e1H				;al是否等于0xe1，0xe1亦为前导码，到set_e1处
 je near set_e1
 cmp al,0eH				;Backspace
 je near Backspace
 cmp al,0fH				;Tab
 je near Tab
 cmp al,1cH				;Enter
 je near Enterk
 cmp al,2aH				;Lshift
 je near Lshift
 cmp al,36H				;Rshift
 je near Rshift
 cmp al,39H				;Space
 je near Space
 cmp al,48H				;↑
 je near Up
 cmp al,4bH				;←
 je near Left
 cmp al,4dH				;→
 je near Right
 cmp al,50H				;↓
 je near Down
 cmp al,0aaH				;Lshift释放
 je near BLshift
 cmp al,0B6H				;Rshift释放
 je near BLshift
 jmp get_key
 mov byte [e_0_1],0x00			;恢复e_0_1为初始值
outscreen:
 mov ah,07H
 mov word [edi],ax
 mov al,20H
 out 20H,al
 popad
 add edi,2
 iret
int_end:				;中断结束
 mov al,20H
 out 20H,al
 popad
 iret
set_e0:
 mov byte [e_0_1],0x01			;设置e_0_1中对于e0的标志位
 jmp int_end
set_e1:
 mov byte [e_0_1],0x08			;设置e_0_1中对于e0的标志位
 jmp int_end
get_key:
 cmp byte [e_0_1],0x01
 je near e0
 cmp byte [e_0_1],0x08
 je near e1
 cmp al,0x0d				;比较扫描码是否小于0x0d,若是则跳到set1
 jbe set1
 cmp al,0x1b				;比较扫描码是否小于0x1b,若是则跳到set2
 jbe set2
 cmp al,0x29				;比较扫描码是否小于0x29,若是则跳到set3
 jbe set3
 cmp al,0x35				;比较扫描码是否小于0x35,若是则跳到set4
 jbe set4
 jmp int_end
set1:
 xor ebx,ebx				;扫描码在0x02与0x0d之间，转换成的ASCII码在‘1’与‘=’之间
 mov bl,al
 sub bl,0x02
 cmp byte [mode],00000001B		;lshift是否make
 je shifted1
 cmp byte [mode],00000010B		;rshift是否make
 je shifted1
 mov al,byte [index1+ebx]
 jmp outscreen
shifted1:
 mov al,byte [index14+ebx]		;取得Lshift被make时的键盘映射表
 jmp outscreen
set2:
 xor ebx,ebx				;扫描码在0x10与0x1b之间，转换成的ASCII码在‘q’与‘]’之间
 mov bl,al
 sub bl,0x10 
 cmp byte [mode],00000001B
 je shifted2
 mov al,byte [index3+ebx]
 jmp outscreen
shifted2:
 mov al,byte [index16+ebx]
 jmp outscreen
set3:
 xor ebx,ebx				;扫描码在0x1e与0x29之间，转换成的ASCII码在‘a’与‘`’之间
 mov bl,al
 sub bl,0x1e 
 cmp byte [mode],00000001b
 je shifted3
 mov al,byte [index5+ebx]
 jmp outscreen
shifted3:
 mov al,byte [index18+ebx]
 jmp outscreen
set4:
 xor ebx,ebx				;扫描码在0x2b与0x35之间，转换成的ASCII码在‘\’与‘/’之间
 mov bl,al
 sub bl,0x2b 
 cmp byte [mode],00000001b
 je shifted4
 mov al,byte [index7+ebx]
 jmp outscreen
shifted4:
 mov al,byte [index20+ebx]
 jmp outscreen
e0:
 mov byte [e_0_1],0x00	
 jmp int_end
e1:
 mov byte [e_0_1],0x08	
 jmp int_end
kb_wait:
 push eax
kb_wait1:
 in al,64H
 test al,02H
 jne kb_wait1
 pop eax
 ret
;--------------------------------------------------------------------------------------------------
Backspace:
 sub edi,2
 xor ax,ax
 mov word [edi],ax
 mov al,0x20
 out 0x20,al
 popad
 sub edi,2
 iret
Tab:
 mov al,0x20
 out 0x20,al
 popad
 add edi,8
 iret
Enterk:
 mov al,0x20
 out 0x20,al
 popad
 add edi,160
 iret
Lshift:
 mov byte [mode],00000001B
 jmp int_end
Rshift:
 mov byte [mode],00000010B
 jmp int_end
Space:
 mov al,0x20
 out 0x20,al
 popad
 add edi,2
 iret
Up:
 mov al,0x20
 out 0x20,al
 popad
 sub edi,160
 iret
Left:
 mov al,0x20
 out 0x20,al
 popad
 sub edi,2
 iret
Right:
 mov al,0x20
 out 0x20,al
 popad
 add edi,2
 iret
Down:
 mov al,0x20
 out 0x20,al
 popad
 add edi,160
 iret
BLshift:
 mov byte [mode],00000000b
 jmp int_end
BRshift:
 mov byte [mode],00000000b
 jmp int_end
times 1024-($-$$) db 0