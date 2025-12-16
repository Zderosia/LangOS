clear_screen:
    pusha

    ;mov ah, 0x00  ; function 07, AL=0 means scroll whole window

    mov ax, 0
clear_screen1:

    add ax, 1
    mov bx, empty    ; character attribute = white on black
    call print_string

    cmp ax, 100
    jne clear_screen1
    ;mov cx, 0x0000  ; row = 0, col = 0
    ;mov dx, 0x184f  ; row = 24 (0x18), col = 79 (0x4f)
    int 0x10        ; call BIOS video interrupt

    popa
    ret

empty db 0x0D, 0x0A, 0x00