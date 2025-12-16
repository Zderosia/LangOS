org 0x7c00

mov bx, the_secret2
call print_string

mov [BOOT_DRIVE], dl

mov bx, 0x8200
mov dh, 5
mov dl, [BOOT_DRIVE]
call disk_load

mov bp, 0x9000
mov sp, bp

mov bx, MSG_REAL_MODE
call print_string

call switch_to_pm


mov dx, [0x8200]
call print_hex

mov dx, [0x8200 + 512]
call print_hex

jmp $

mov ah , 0x0e ; int 10/ ah = 0eh -> scrolling teletype BIOS routine

mov bx, the_secret2
call print_string

jmp $ ; Jump forever.

include "print.asm"
include "print_hex.asm"
include "read_disk.asm"
include "gdt.asm"
include "switch_to_pm.asm"
include "print_string_pm.asm"
include "clear_screen.asm"

use32

BEGIN_PM:
mov ebx, MSG_PROT_MODE
call print_string_pm

jmp $

; Global variables

MSG_REAL_MODE db "Started in 16 - bit Real Mode " , 0
MSG_PROT_MODE db 0x0D, 0x0A, "Successfully landed in 32 - bit Protected Mode " , 0


the_secret2 db "MASSIVE GORILLA", 0x0D, 0x0A, 0x00

BOOT_DRIVE db 0


; Padding and magic BIOS number.
times 510 -( $ - $$ ) db 0
dw 0xaa55
times 256 dw 0xdada
times 256 dw 0xface
