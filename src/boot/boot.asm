; Boot sector that loads a kernel from disk and jumps to it
; Assemble with: nasm -f bin boot.asm -o boot.bin
; Test with: qemu-system-x86_64 boot.bin

[BITS 16]
[ORG 0x7C00]

KERNEL_OFFSET equ 0x1000    ; Load kernel at 64KB

start:
    ; Initialize segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Print "Booting..." message in 16-bit real mode
    mov si, msg_boot
    call print_string_16

    ; Load kernel from disk
    call load_kernel

    ; Print "Loading kernel..." message
    mov si, msg_loading
    call print_string_16

    ; Load GDT
    cli
    lgdt [gdt_descriptor]

    ; Enable protected mode by setting bit 0 of CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to flush CPU pipeline and enter 32-bit mode
    jmp CODE_SEG:protected_mode_start

; Load kernel from disk
load_kernel:
    pusha
    mov bx, KERNEL_OFFSET   ; Load kernel to 0x1000
    mov dh, 15              ; Load 15 sectors (enough for a small kernel)
    mov dl, [BOOT_DRIVE]    ; Boot drive number
    call disk_load
    popa
    ret

; Read sectors from disk using BIOS interrupt
; Parameters: bx = destination offset, dh = number of sectors, dl = drive
disk_load:
    push dx
    
    mov ah, 0x02            ; BIOS read sector function
    mov al, dh              ; Number of sectors to read
    mov ch, 0x00            ; Cylinder 0
    mov dh, 0x00            ; Head 0
    mov cl, 0x02            ; Start from sector 2 (sector 1 is boot sector)
    
    int 0x13                ; Call BIOS disk interrupt
    jc disk_error           ; Jump if carry flag set (error)
    
    pop dx
    cmp al, dh              ; Check if we read the correct number of sectors
    jne disk_error
    ret

disk_error:
    mov si, msg_disk_error
    call print_string_16
    jmp $

; 16-bit print function
print_string_16:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    popa
    ret

%include "./src/boot/gdt.asm"  ; Include GDT definitions

; --- 32-bit Protected Mode Code ---
[BITS 32]
protected_mode_start:
    ; Set up segment registers for protected mode
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Set up IDT
    call setup_idt

    ; Load IDT
    lidt [idt_descriptor]

    ; Clear the screen
    call clear_screen_32

    ; Print success message in 32-bit mode
    mov esi, msg_protected
    call print_string_32

    ; Enable interrupts
    sti

    ; Jump to kernel
    call KERNEL_OFFSET

    ; If kernel returns, halt
    jmp $

; Set up IDT with default handlers
setup_idt:
    pusha
    mov edi, IDT_BASE       ; IDT located at 0x8000 in memory
    mov ecx, 256            ; 256 IDT entries
    mov eax, default_isr
    
.loop:
    mov word [edi], ax      ; Lower 16 bits of handler address
    mov word [edi+2], CODE_SEG  ; Code segment selector
    mov byte [edi+4], 0     ; Reserved
    mov byte [edi+5], 0x8E  ; Flags: present, ring 0, 32-bit interrupt gate
    shr eax, 16
    mov word [edi+6], ax    ; Upper 16 bits of handler address
    shl eax, 16
    or eax, default_isr     ; Restore eax
    add edi, 8              ; Move to next IDT entry
    loop .loop
    
    popa
    ret

; Default interrupt service routine
default_isr:
    pushad
    
    ; Send EOI to PIC if needed (for IRQs)
    mov al, 0x20
    out 0x20, al
    
    popad
    iret

; 32-bit print function (writes directly to VGA text buffer)
print_string_32:
    pusha
    mov edx, 0xB8000        ; VGA text buffer address
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0F            ; White text on black background
    mov [edx], ax
    add edx, 2
    jmp .loop
.done:
    popa
    ret

; 32-bit screen clear function
clear_screen_32:
    pusha
    mov edx, 0xB8000        ; VGA text buffer address
    mov ecx, 80 * 25        ; 80 columns x 25 rows
    mov ax, 0x0F20          ; White on black space character
.loop:
    mov [edx], ax
    add edx, 2
    loop .loop
    popa
    ret

; --- Data ---
BOOT_DRIVE: db 0            ; Store boot drive number
msg_boot: db "Booting...", 13, 10, 0
msg_loading: db "Loading kernel from disk...", 13, 10, 0
msg_disk_error: db "Disk read error!", 13, 10, 0
msg_protected: db "Bootloader: In APE mode, jumping to kernel...", 0

; --- IDT Location and Descriptor ---
IDT_BASE equ 0x8000             ; IDT will be built at address 0x8000
IDT_SIZE equ 256 * 8            ; 256 entries, 8 bytes each

idt_descriptor:
    dw IDT_SIZE - 1             ; Size of IDT
    dd IDT_BASE                 ; Address of IDT

; --- Boot Signature ---
times 510-($-$$) db 0
dw 0xAA55