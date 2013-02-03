[ORG 8c00H]
[BITS 32]
clock_int:
 pushad
 cmp cx,300		;判断是否达到显示时间
 jnl beeb		;若达到则跳转到beeb显示字符
 mov al,20H		;若否则退出中断并为cx加1
 out 20H,al
 popad
 add cx,1		;为cx加1
 jmp return		;退出中断
beeb: cmp bl,3aH	;判断是否为9
 jnl clean		;若是则跳转到clean处重置bl为0
 mov word [gs:158],bx	;若bl小于等于9，则显示
 mov al,20H
 out 20H,al
 popad
 add bl,1		;为bl赠1
 mov cx,0		;置cx为0
 jmp return
clean: mov al,20H
 out 20H,al
 popad
 mov bl,30H		;重置bl为0
 jmp return 
return: iret

times 512-($-$$) db 0