[ORG 8c00H]
[BITS 32]
clock_int:
 pushad
 cmp cx,300		;�ж��Ƿ�ﵽ��ʾʱ��
 jnl beeb		;���ﵽ����ת��beeb��ʾ�ַ�
 mov al,20H		;�������˳��жϲ�Ϊcx��1
 out 20H,al
 popad
 add cx,1		;Ϊcx��1
 jmp return		;�˳��ж�
beeb: cmp bl,3aH	;�ж��Ƿ�Ϊ9
 jnl clean		;��������ת��clean������blΪ0
 mov word [gs:158],bx	;��blС�ڵ���9������ʾ
 mov al,20H
 out 20H,al
 popad
 add bl,1		;Ϊbl��1
 mov cx,0		;��cxΪ0
 jmp return
clean: mov al,20H
 out 20H,al
 popad
 mov bl,30H		;����blΪ0
 jmp return 
return: iret

times 512-($-$$) db 0