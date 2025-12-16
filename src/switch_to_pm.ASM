use16

switch_to_pm:

cli
mov bx, empty
call print_string

;call clear_screen
;jmp $
lgdt [gdt_descriptor]
mov eax, cr0
or eax, 0x1
mov cr0, eax


jmp CODE_SEG:init_pm

;--------------------------SWITCH TO 32 BIT------------------------------------

use32

init_pm:

;push bx
;jmp $
;mov bx, the_secret
;call print_string_pm
;pop bx



mov ax, DATA_SEG
mov ds, ax
mov ss , ax ; data selector we defined in our GDT
mov es , ax
mov fs , ax
mov gs , ax
mov ebp , 0x90000 ; Update our stack position so it is right
mov esp , ebp ; at the top of the free space.
call BEGIN_PM ; Finally , call some well - known label


the_secret db 0x0D, 0x0A, "Gorilla", 0x0D, 0x0A, 0x00