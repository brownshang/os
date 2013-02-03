%include "address.asm"
[ORG 8e00H]
[BITS 32]
jmp start
;mode�Ǽ��̱�־����ʾ���̹��ܼ���״̬���繦�ܼ������£�����Ӧλ��1����λ��־���£�
;0λ����shift��,1λ����shift��,2λ����ctrl��,3λ����ctrl��
;4λ����alt��,5λ����alt��,6λ��caps��,7λ��Ins��
mode	db	0
;��0λΪ1��ʾɨ����Ϊ0xe0,��1λΪ1��ʾɨ����Ϊ0xe1����ʼֵΪ0
e_0_1 db 	0
;����ӳ���
key_map:
index0		db 0			;0x01�ļ���ӳ��(esc����
index1		db "1234567890-="	;0x02--0x0d�ļ���ӳ��
index2		db 0,0			;0x0e--0x0f(BKSP����TAB�� )
index3		db "qwertyuiop[]"	;0x10--0x1b
index4		db 0,0			;0x1c--0x1d(enter����Lctrl��)
index5		db "asdfghjkl;'`"	;0x1e--0x29
index6		db 0			;0x2a(Lshift)
index7		db "\zxcvbnm,./"	;0x2b--0x35
index8		db 0			;0x36(Rshift)
index9		db "*"			;0x37(kp*)
index10		db 0			;0x38(Lalt)
index11		db 0			;0x39(space)
index12		db 0			;0x3a(caps)
;index13--index25�ǵ�Lshift��makeʱ�ļ���ӳ���
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
 mov ebx,key_map			;�õ�����ӳ���ĵ�ַ(key_map)
 in al,60H				;��ü���ɨ����
 cmp al,0e0H				;al�Ƿ�Ϊǰ����0xe0����ʾ���滹����1����2��ɨ����
 je near set_e0
 cmp al,0e1H				;al�Ƿ����0xe1��0xe1��Ϊǰ���룬��set_e1��
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
 cmp al,48H				;��
 je near Up
 cmp al,4bH				;��
 je near Left
 cmp al,4dH				;��
 je near Right
 cmp al,50H				;��
 je near Down
 cmp al,0aaH				;Lshift�ͷ�
 je near BLshift
 cmp al,0B6H				;Rshift�ͷ�
 je near BLshift
 jmp get_key
 mov byte [e_0_1],0x00			;�ָ�e_0_1Ϊ��ʼֵ
outscreen:
 mov ah,07H
 mov word [edi],ax
 mov al,20H
 out 20H,al
 popad
 add edi,2
 iret
int_end:				;�жϽ���
 mov al,20H
 out 20H,al
 popad
 iret
set_e0:
 mov byte [e_0_1],0x01			;����e_0_1�ж���e0�ı�־λ
 jmp int_end
set_e1:
 mov byte [e_0_1],0x08			;����e_0_1�ж���e0�ı�־λ
 jmp int_end
get_key:
 cmp byte [e_0_1],0x01
 je near e0
 cmp byte [e_0_1],0x08
 je near e1
 cmp al,0x0d				;�Ƚ�ɨ�����Ƿ�С��0x0d,����������set1
 jbe set1
 cmp al,0x1b				;�Ƚ�ɨ�����Ƿ�С��0x1b,����������set2
 jbe set2
 cmp al,0x29				;�Ƚ�ɨ�����Ƿ�С��0x29,����������set3
 jbe set3
 cmp al,0x35				;�Ƚ�ɨ�����Ƿ�С��0x35,����������set4
 jbe set4
 jmp int_end
set1:
 xor ebx,ebx				;ɨ������0x02��0x0d֮�䣬ת���ɵ�ASCII���ڡ�1���롮=��֮��
 mov bl,al
 sub bl,0x02
 cmp byte [mode],00000001B		;lshift�Ƿ�make
 je shifted1
 cmp byte [mode],00000010B		;rshift�Ƿ�make
 je shifted1
 mov al,byte [index1+ebx]
 jmp outscreen
shifted1:
 mov al,byte [index14+ebx]		;ȡ��Lshift��makeʱ�ļ���ӳ���
 jmp outscreen
set2:
 xor ebx,ebx				;ɨ������0x10��0x1b֮�䣬ת���ɵ�ASCII���ڡ�q���롮]��֮��
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
 xor ebx,ebx				;ɨ������0x1e��0x29֮�䣬ת���ɵ�ASCII���ڡ�a���롮`��֮��
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
 xor ebx,ebx				;ɨ������0x2b��0x35֮�䣬ת���ɵ�ASCII���ڡ�\���롮/��֮��
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