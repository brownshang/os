 mov ah,03H
 xor bh,bh
 int 10H
 mov ax,07c0H
 mov es,ax
 mov ax,1301H
 mov bx,0002H
 mov bp,msgnovesa
 mov cx,38
 int 10H
 jmp $

 times 510-($-$$) db 0
 db 55H
 db 0AAH