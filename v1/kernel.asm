;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com>
;Alpha�汾
;ֻ��������
;--------------------------------------------------------------------------------------------------
[BITS 32]
init:
mov ax,0010H
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
;-------------------------------------------
call slopeline
call fillblock
mov cx,2;�ֵĸ���
mov esi,0600H;�ַ����׵�ַ
mov edi,[0500H];Ҫд���Դ��ַ
mov eax,0ffffffffH;��ɫ
call putstr
dieloop:
jmp dieloop
;----------------------------------------------------------------------------------------
putstr:
push cx
call putcharpre
pop cx
loop putstr
ret
;*******************************************
putcharpre:
mov cx,16
putchar:
push cx
mov cx,16
mov dx,[esi]
inc esi
inc esi
call putcharline
add edi,(800-16)*4
pop cx
loop putchar
ret
;*******************************************
putcharline:
cmp cx,0
jz putcharlineok
shl dx,1
jb putpixelchar
inc edi
inc edi
inc edi
inc edi
dec cx
jmp putcharline
;*******************************************
putpixelchar:
mov [edi],eax
inc edi
inc edi
inc edi
inc edi
dec cx
jmp putcharline
;*******************************************
putcharlineok:
ret
;----------------------------------------------------------------------------------------
fillblock:
mov eax,0ffffffffH
mov edi,[0500H]
add edi,500*800*4
mov ecx,100*800
fillblockloop:
call putpixel
loop fillblockloop
ret
;*******************************************
putpixel:
mov [edi],eax
inc edi
inc edi
inc edi
inc edi
ret
;*******************************************
slopeline:
mov eax,0ffff0000H
mov edi,[0500H]
add edi,100*800*4
mov ecx,400
slopelineloop:
mov [edi],eax
inc edi
inc edi
inc edi
inc edi
add edi,(800+1)*4
loop slopelineloop
ret
