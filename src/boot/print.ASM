
;mov bx, prepare ;TEST ONLY

print_string:  ;PREPARING FOR FUNCTION

mov ah,0x0e     ;int 10/ah = 0eh -> scrolling teletype BIOS routine
push es
push ax
;push cl

;push bx
;mov bx,0x7c0
;mov es, bx
;pop bx

print19856:  ;SET al EQUAL TO THE VALUE AT THE CURRENT ADDRESS OF THE STRING
mov al, [es: bx]

cmp al, 0x00    ;CHECK IF THE STRING HAS ENDED
je print2

int 0x10        ;STRING HASN'T ENDED
inc bx
inc cl

jmp print19856

print2:  ;STRING HAS ENDED

pop ax
pop es
;pop bx
ret


;prepare db "Preparing to launch...", 0x00 ;TEST ONLY
;times 510 -( $ - $$ ) db 0 ;Pad the boot sector out with zeros
;dw 0xaa55