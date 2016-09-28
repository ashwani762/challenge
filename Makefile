OBJ=.obj
SRC = ./kernel
SRC_ASM = ./asm
SRC_LIB = ./lib
INCLUDE = ./include
COPY_ME = /boot  

#
# Setting up Compiler
# ---------------------------------------------------------
CC=gcc
AS=nasm
LD=ld
#
# Debug compilation option
# ---------------------------------------------------------
OPT_C= -m32 -O -Wall  -nostdlib -nostartfiles -nodefaultlibs -Wimplicit-function-declaration
OPT_ASM=-s -f elf -w+orphan-labels -o 
#
# Release compilation option 
#--------------------------------------------------------

#
# link option 
#--------------------------------------------------------
OPT_LD=-T link.ld --build-id=none -m elf_i386 
#
# Main Targets
#--------------------------------------------------------
all: ${OBJ} kernel.bin

default: ${OBJ} install

build-iso: kernel.bin
	cp -rf kernel.bin isofiles/boot/kernel.bin
	grub-mkrescue -o os.iso isofiles

run-iso:
	qemu-system-i386 -cdrom os.iso

run-bin:
	qemu-system-i386 -kernel kernel.bin

clean: 
	rm -rf .obj/*
	rm -rf kernel.bin 
	rm -rf isofiles/boot/kernel.bin
	rm -rf os.iso
	
${OBJ}: 
	mkdir .obj
	
#
# Compilation directive
#--------------------------------------------------------
kernel.bin: 	${OBJ}/start.o \
                ${OBJ}/main.o \
				${OBJ}/functions.o
	${LD} ${OPT_LD}	-o kernel.bin ${OBJ}/start.o \
					${OBJ}/functions.o \
					${OBJ}/main.o
									
#--------------------------------------------------------
${OBJ}/start.o: ${SRC_ASM}/start.asm
	${AS} ${OPT_ASM} ${OBJ}/start.o ${SRC_ASM}/start.asm
#--------------------------------------------------------
${OBJ}/functions.o: ${SRC_LIB}/functions.c \
		${INCLUDE}/functions.h
	${CC} ${OPT_C} -c -o ${OBJ}/functions.o -I${INCLUDE} ${SRC_LIB}/functions.c 
#--------------------------------------------------------
${OBJ}/main.o:  ${SRC}/main.c \
		${INCLUDE}/functions.h
	${CC} ${OPT_C} -c -o ${OBJ}/main.o -I${INCLUDE} ${SRC}/main.c 

