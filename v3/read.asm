;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha�汾
;ֻ��������,����NASM����
;������֡���ȡ�������ر����
;--------------------------------------------------------------------------------------------------
jmp start

msgos db '                                YY TEXT 0.1 Beta'
msgcopy db '                     (C)Copyright Shang BaoLiang 2004-2005.'
msggo db ' Open A20 > Initialize 8259 PIC > Load GDT > In Protected Mode > Load IDT > END '
bootdrv	db 0

start:
 xor ax,ax
 mov ds,ax
 mov [bootdrv],dl	;���������豸��

 mov ax,0600H
 xor bh,bh
 xor cx,cx
 mov dx,184FH
 int 10h

 mov ax,07c0H
 mov es,ax
 mov ax,1301H
 mov bx,0007H

 mov bp,msgos
 mov cx,48
 xor dx,dx
 int 10H		;�����YY TEXT 0.1 Beta���������

 mov bp,msgcopy
 mov cx,59
 mov dh,1
 xor dl,dl
 int 10H		;�����(C)Copyright Shang BaoLiang 2004-2005.���������

 mov bp,msggo
 mov cx,80
 mov dh,2
 xor dl,dl
 int 10H

read:
 xor ax,ax
 mov es,ax
bad_rt:			;������ʧ�ܣ���λ������������
 xor ah,ah
 mov dl,[bootdrv]
 int 13H
read_rt:
 mov ah,02H
 mov al,10		;Ҫ��ȡ��������
 mov bx,8000H		;ES:BX=���ݻ�������ַ
 mov ch,0		;�ŵ���
 mov cl,2		;������
 xor dh,dh		;��ͷ��
 mov dl,[bootdrv]	;��������
 int 13H
 jc bad_rt
kill_motor:
 mov dx,03f2H
 xor al,al		;"mov al,0cH"���д���֤
 out dx,al		;�ر����������

 jmp 0000:8000H

times 510-($-$$) db 0
 db 55H
 db 0AAH