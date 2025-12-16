print_hex:
        pusha

        mov bx, 2      ;Position for most significant digit
    .Next:
        rol dx, 4      ;Bring digit in lowest 4 bits
        mov al, dl     ;Copy number
        and al, 15     ;Keep 4 bits
        add al, '0'    ;Make text
        cmp al, '9'
        jbe .LessA     ;Already fine for '0' to '9'
        add al, 7      ;Bridge the gap to reach 'A' to 'F'
    .LessA:
        mov [HEX_OUT + bx], al
        inc bx
        cmp bx, 6      ;Did we fill chars at +2 +3 +4 +5 ?
        jb  .Next      ;Not yet

        mov bx,HEX_OUT
        call print_string
        popa
        ret

HEX_OUT db '0x0000',0x0D, 0x0A, 0x00





