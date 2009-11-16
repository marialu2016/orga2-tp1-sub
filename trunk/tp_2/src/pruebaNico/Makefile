NASMFLAGS=-f elf
main: main.c asmPrewitt.o
	gcc main.c -g -o main asmPrewitt.o `pkg-config --cflags --libs opencv`

asmPrewitt.o: asmPrewitt.asm
	nasm -f elf -g -o asmPrewitt.o asmPrewitt.asm

