;--------------------------------------------------------------------------------------------------
;��Ȩ���� (C) 2005 http://ksc.go.nease.net <sbl5027@sina.com> <79403828>
;Alpha�汾
;ֻ��������,����NASM����
;������֡���ȡ�������ر����
;--------------------------------------------------------------------------------------------------
jmp start

msg db 'Loading kernel part...'
bootdrv	db 0

start:
 xor ax,ax
 mov ds,ax
 mov es,ax
 mov [bootdrv],dl	;���������豸��

 xor al,al
 mov ah,06H
 xor bx,bx
 xor cx,cx
 mov dx,194fH
 int 10H		;��Ļ��ʼ��

 mov ax,07c0H
 mov es,ax
 mov bp,msg
 mov ax,1301H
 mov bx,0002H
 mov cx,22
 xor dx,dx
 int 10H		;�����Loading system...���������

read:
 xor ax,ax
 mov es,ax
bad_rt:			;������ʧ�ܣ���λ������������
 xor ah,ah
 mov dl,[bootdrv]
 int 0x13
read_1:
 mov ah,02H
 mov al,5		;Ҫ��ȡ��������
 mov bx,9000H		;ES:BX=���ݻ�������ַ
 mov ch,0		;�ŵ���
 mov cl,2		;������
 xor dh,dh		;��ͷ��
 mov dl,[bootdrv]	;��������
 int 13H
 jc bad_rt
read_2:
 mov ah,02H
 mov al,1
 mov bx,9a01H
 mov ch,0
 mov cl,7
 xor dh,dh
 mov dl,[bootdrv]
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