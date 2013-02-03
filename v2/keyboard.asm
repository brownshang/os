;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha�汾
;ֻ��������
;����NASM����
;--------------------------------------------------------------------------------------------------
org 0x9a01
bits 32
jmp start
;mode�Ǽ��̱�־����ʾ���̹��ܼ���״̬���繦�ܼ������£���������Ӧλ��1����λ��־���£�
;0λ����shift��,1λ����shift��,2λ����ctrl��,3λ����ctrl��
;4λ����alt��,5λ����alt��,6λ��caps��,7λ��Ins��
mode	db	0
;��0λΪ1��ʾɨ����Ϊ0xe0,��1λΪ1��ʾɨ����Ϊ0xe1����ʼֵΪ0
e_0_1 db 	0										
;����ӳ���
key_map:
index0		db 0																							;0x01�ļ���ӳ��(esc����
index1		db "1234567890-="																	;0x02--0x0d�ļ���ӳ��
index2		db 0,0																						;0x0e--0x0f(BKSP����TAB�� )
index3		db 'qwertyuiop[]'																	;0x10--0x1b
index4		db 0,0 																						;0x1c--0x1d(enter����Lctrl��)
index5		db "asdfghjkl;'`"																	;0x1e--0x29
index6		db 0 																							;0x2a(Lshift)
index7		db '\zxcvbnm,./'																	;0x2b--0x35
index8		db 0																							;0x36(Rshift)
index9		db '*'																						;0x37(kp*)
index10		db 0																							;0x38(Lalt)
index11		db 0																							;0x39(space)
index12		db 0																							;0x3a(caps)
;index13--index25�ǵ�Lshift��makeʱ�ļ���ӳ���
index13		db 0
index14		db "!@#$%^&*()_+"
index15		db 0,0
index16		db 'QWERTYUIOP{}'
index17		db 0,0
index18		db 'ASDFGHJKL:"~'
index19		db 0
index20		db '|ZXCVBNM<>?'
index21		db 0
index22		db '*'
index23		db 0
index24		db 0
index25		db 0
start:		pushad
					mov ebx,key_map																		;�õ�����ӳ���ĵ�ַ(key_map)
					in  al,0x60																				;��ü���ɨ����
 					cmp al,0xe0
 					je 	set_e0																				;al�Ƿ����0xe0��ɨ����0xe0Ϊǰ���룬��ʾ���滹����1����2��ɨ����
 																														;���в��ּ���ɨ��������2����3��8λ����ʾ�ģ�,��alΪɨ���룬����ת
 																														;��set_e0��
 					cmp al,0xe1																				;al�Ƿ����0xe1��0xe1��Ϊǰ���룬��set_e1��
 					je	set_e1
 					cmp al,0x2a																				;ɨ�����Ƿ�ΪLshift	
 					je near Lshift																		;��ת��Lshift
 					cmp al,0xaa																				;Lshift�ͷ�	
 					je	near BLshift																	;��ת��BLshift
 					cmp al,0x39																				;�ո���Ƿ񱻰���
 					je  near Space
 					cmp	al,0x0f																				;Tab�������� 
 					je	near Tab
					jmp	get_key
 					mov byte [e_0_1],0x00															;�ָ�e_0_1Ϊ��ʼֵ	
outscreen:
					mov ah,0x07
					mov word [gs:esi],ax
					mov al,0x20																				;�жϽ���
					out 0x20,al
					popad
					add esi,2
					iret
int_end:	mov al,0x20																				;�жϽ���
					out 0x20,al
					popad
					iret
set_e0:		mov byte [e_0_1],0x01															;����e_0_1�ж���e0�ı�־λ 	
 					jmp	int_end																				;�жϽ���
set_e1:		mov byte [e_0_1],0x08															;����e_0_1�ж���e0�ı�־λ 
					jmp int_end																				;�жϽ��� 	
get_key:	cmp byte [e_0_1],0x01
					je near	e0
					cmp byte [e_0_1],0x08
					je near e1
					cmp al,0x0d																				;�Ƚ�ɨ�����Ƿ�С��0x0d,����������set1
					jbe	set1
					cmp	al,0x1b																				;�Ƚ�ɨ�����Ƿ�С��0x1b,����������set2
					jbe	set2
					cmp al,0x29																				;�Ƚ�ɨ�����Ƿ�С��0x29,����������set3
					jbe	set3
					cmp al,0x35																				;�Ƚ�ɨ�����Ƿ�С��0x35,����������set4
					jbe	set4
					jmp int_end
		set1:	mov ebx,0																					;ɨ������0x02��0x0d֮�䣬ת���ɵ�ASCII���ڡ�1���롮=��֮��
					mov bl,al
 					sub bl,0x02 	
 					cmp byte [mode],00000001b													;lshift�Ƿ�make
 					je	BIG1
 					mov al,byte [index1+ebx]
 	 				jmp outscreen
 	 	BIG1:	mov al,byte [index14+ebx]													;ȡ��Lshift��makeʱ�ļ���ӳ���
 	 				jmp outscreen
 		set2:	mov ebx,0																					;ɨ������0x10��0x1b֮�䣬ת���ɵ�ASCII���ڡ�q���롮]��֮��
					mov bl,al
 					sub bl,0x10 
 					cmp byte [mode],00000001b								
 					je	BIG2
 					mov al,byte [index3+ebx]
 	 				jmp outscreen
 	 	BIG2:	mov al,byte [index16+ebx]
 	 				jmp outscreen
 		set3:	mov ebx,0																					;ɨ������0x1e��0x29֮�䣬ת���ɵ�ASCII���ڡ�a���롮`��֮��
					mov bl,al
 					sub bl,0x1e 
 					cmp byte [mode],00000001b
 					je	BIG3
 					mov al,byte [index5+ebx]
 	 				jmp outscreen
 	 	BIG3:	mov al,byte [index18+ebx]
 	 				jmp outscreen
 		set4:mov ebx,0																					;ɨ������0x2b��0x35֮�䣬ת���ɵ�ASCII���ڡ�\���롮/��֮��
					mov bl,al
 					sub bl,0x2b 
 					cmp byte [mode],00000001b
 					je	BIG4
 					mov al,byte [index7+ebx]
 	 				jmp outscreen
 	 	BIG4: mov al,byte [index20+ebx]
 	 				jmp outscreen
e0:				mov byte [e_0_1],0x00	
					jmp int_end
e1: 			mov byte [e_0_1],0x08	
					jmp int_end
Lshift:		mov byte [mode],00000001b													;mode0λ��1�������ж�
					jmp int_end								
BLshift:	mov byte [mode],00000000b													;mode0λ��0�������ж�	
					jmp int_end
Space:		mov al,0x20																				;�жϽ���
					out 0x20,al
					popad
					add esi,2
					iret
Tab:			mov al,0x20																				;�жϽ���
					out 0x20,al
					popad
					add esi,8
					iret
times 512-($-$$) db 0