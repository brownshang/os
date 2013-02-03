[ORG 8c00H]
[BITS 32]
jmp clock_int
char db '0'
count dw 0
clock_int:
 pushad
 cmp word[count],500	;判断是否达到显示时间
 jnl beeb		;若达到则跳转到beeb显示字符
 mov al,20H		;若否则退出中断并为cx加1
 out 20H,al
 popad
 add word[count],1	;为cx加1
 iret			;退出中断
beeb:
 cmp byte[char],3aH	;判断是否为9
 jnl clean		;若是则跳转到clean处重置bl为0
 mov bl,[char]
 mov [gs:158],bl	;若bl小于等于9，则显示
 mov al,20H
 out 20H,al
 popad
 add byte[char],1		;为bl赠1
 mov word[count],0		;置cx为0
 iret
clean:
 mov al,20H
 out 20H,al
 popad
 mov byte[char],30H		;重置bl为0
 iret

times 512-($-$$) db 0