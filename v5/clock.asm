[ORG 8c00H]
[BITS 32]
jmp clock_int
char db '0'
count dw 0
clock_int:
 pushad
 cmp word[count],500	;�ж��Ƿ�ﵽ��ʾʱ��
 jnl beeb		;���ﵽ����ת��beeb��ʾ�ַ�
 mov al,20H		;�������˳��жϲ�Ϊcx��1
 out 20H,al
 popad
 add word[count],1	;Ϊcx��1
 iret			;�˳��ж�
beeb:
 cmp byte[char],3aH	;�ж��Ƿ�Ϊ9
 jnl clean		;��������ת��clean������blΪ0
 mov bl,[char]
 mov [gs:158],bl	;��blС�ڵ���9������ʾ
 mov al,20H
 out 20H,al
 popad
 add byte[char],1		;Ϊbl��1
 mov word[count],0		;��cxΪ0
 iret
clean:
 mov al,20H
 out 20H,al
 popad
 mov byte[char],30H		;����blΪ0
 iret

times 512-($-$$) db 0