NASMFLAGS=-f elf

.PHONY: all clean

all: clean bordes

main: main.o asmBordes.o
	gcc  main.o -g -o main asmBordes.o `pkg-config --cflags --libs opencv` 

bordes: bordes.o asmBordes.o
	gcc  bordes.o -g -o bordes asmBordes.o `pkg-config --cflags --libs opencv`

bordes.o: bordes.c asmBordes.o
	gcc -g -c bordes.c -o bordes.o `pkg-config --cflags opencv`
	
asmBordes.o: asmBordes.asm
	nasm -f elf -g -o asmBordes.o asmBordes.asm

clean:
	rm -f bordes
	rm -f *.o
