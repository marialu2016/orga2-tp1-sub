NASMFLAGS=-f elf

.PHONY: all clean

all: clean main

main: bordes.o asmRoberts.o asmPrewitt.o asmSobel.o asmRobertsPush.o
	gcc main.c -o ../exe/main asmRoberts.o asmPrewitt.o asmSobel.o asmRobertsPush.o `pkg-config --cflags --libs opencv` -ggdb

#main.o: main.c
#	gcc -ggdb -c  main.c -o main.o `pkg-config --cflags --libs opencv`

bordes.o: bordes.c
	gcc -ggdb -c bordes.c -o bordes.o

asmRoberts.o: asmRoberts.asm
	nasm -f elf -o asmRoberts.o asmRoberts.asm -ggdb
asmRobertsPush.o: asmRobertsPush.asm
	nasm -f elf -ggdb -o asmRobertsPush.o asmRobertsPush.asm
	
asmPrewitt.o: asmPrewitt.asm
	nasm -f elf -ggdb -o asmPrewitt.o asmPrewitt.asm
asmSobel.o: asmSobel.asm
	nasm -f elf -ggdb -o asmSobel.o asmSobel.asm

clean:
	rm -f main
	rm -f *.o
