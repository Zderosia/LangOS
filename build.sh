#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR=./build
BOOT_DIR=./src/boot
KERNEL_DIR=./src/kernel

mkdir -p "$BUILD_DIR"

# Compile kernel
nasm -f elf32 $BOOT_DIR/kernel_entry.asm -o "$BUILD_DIR/kernel_entry.o"
gcc -m32 -ffreestanding -fno-pie -c $KERNEL_DIR/kernel.c -o "$BUILD_DIR/kernel.o"
ld -m elf_i386 -Ttext 0x1000 -o "$BUILD_DIR/kernel.bin" \
   "$BUILD_DIR/kernel_entry.o" "$BUILD_DIR/kernel.o" --oformat binary

# Assemble bootloader
nasm -f bin $BOOT_DIR/boot.asm -o "$BUILD_DIR/boot.bin"

# Combine into disk image
cat "$BUILD_DIR/boot.bin" "$BUILD_DIR/kernel.bin" > $BUILD_DIR/os-image.bin
