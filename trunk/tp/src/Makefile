NASMFLAGS=-f elf

.PHONY: all clean

all: clean main

main: main.o bordes.o asmRoberts.o asmPrewitt.o asmSobel.o asmRobertsPush.o
	gcc main.o -ggdb -o main asmRoberts.o asmPrewitt.o asmSobel.o   asmRobertsPush.o `pkg-config --cflags --libs opencv` 

main.o: main.c
	gcc -ggdb -c main.c -o main.o `pkg-config --cflags --libs opencv`

bordes.o: bordes.c
	gcc -ggdb -c bordes.c -o bordes.o

asmRoberts.o: asmRoberts.asm
	nasm -f elf -g -o asmRoberts.o asmRoberts.asm
asmRobertsPush.o: asmRobertsPush.asm
	nasm -f elf -g -o asmRobertsPush.o asmRobertsPush.asm
	
asmPrewitt.o: asmPrewitt.asm
	nasm -f elf -g -o asmPrewitt.o asmPrewitt.asm
asmSobel.o: asmSobel.asm
	nasm -f elf -g -o asmSobel.o asmSobel.asm

clean:
	rm -f main
	rm -f *.o
