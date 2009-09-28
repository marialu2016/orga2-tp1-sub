NASMFLAGS=-f elf

.PHONY: all clean

all: clean bordes

bordes: bordes.o asmRoberts.o
	gcc  bordes.o -g -o bordes asmRoberts.o `pkg-config --cflags --libs opencv`

bordes.o: bordes.c asmRoberts.o
	gcc -g -c bordes.c -o bordes.o `pkg-config --cflags opencv`
	
asmRoberts.o: asmRoberts.asm
	nasm -f elf -g -o asmRoberts.o asmRoberts.asm

clean:
	rm -f bordes
	rm -f *.o
