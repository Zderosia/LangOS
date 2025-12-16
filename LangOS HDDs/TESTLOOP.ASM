org 0x7c00

mov ah,0x0e ;int 10/ah = 0eh -> scrolling teletype BIOS routine
mov bh, 0x0A
mov bl, 0x0A
mov cl, 0x00

;mov ebx, 0x7c00
lea ebx, [prepare]

print1:
mov al, [ebx]
int 0x10
inc ebx
inc cl

cmp cl, 30
jne print1

mov al, 0
mov al, 1
mov al, 2

prepare db 0xA,"Preparing to launch LangOS...", 0x00

times 510 -( $ - $$ ) db 0 ;Pad the boot sector out with zeros
dw 0xaa55
time 1024 db 0

