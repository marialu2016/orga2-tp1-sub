NASMFLAGS=-f elf

.PHONY: all clean

all: clean main

main: bordes.o asmRoberts.o asmPrewitt.o asmSobel.o asmRobertsPush.o asmRobertsSIMD.o asmPrewittSIMD.o
	gcc main.c -o ../exe/main gpr/asmRoberts.o gpr/asmPrewitt.o gpr/asmSobel.o gpr/asmRobertsPush.o simd/asmRoberts.o simd/asmPrewitt.o `pkg-config --cflags --libs opencv` -ggdb

main.o: main.c
	gcc -ggdb -c  main.c -o main.o `pkg-config --cflags --libs opencv`

bordes.o: gpr/bordes.c
	gcc -ggdb -c gpr/bordes.c -o gpr/bordes.o

asmRoberts.o: gpr/asmRoberts.asm
	nasm -f elf -o gpr/asmRoberts.o gpr/asmRoberts.asm -ggdb
asmRobertsPush.o: gpr/asmRobertsPush.asm
	nasm -f elf -ggdb -o gpr/asmRobertsPush.o gpr/asmRobertsPush.asm
	
asmPrewitt.o: gpr/asmPrewitt.asm
	nasm -f elf -ggdb -o gpr/asmPrewitt.o gpr/asmPrewitt.asm
asmSobel.o: gpr/asmSobel.asm
	nasm -f elf -ggdb -o gpr/asmSobel.o gpr/asmSobel.asm


# targets de la versión SIMD

asmRobertsSIMD.o: simd/asmRoberts.asm
	nasm -f elf -o simd/asmRoberts.o simd/asmRoberts.asm -ggdb

asmPrewittSIMD.o: simd/asmPrewitt.asm
	nasm -f elf -ggdb -o simd/asmPrewitt.o simd/asmPrewitt.asm

asmSobelSIMD.o: simd/asmSobel.asm
	nasm -f elf -ggdb -o simd/asmSobel.o simd/asmSobel.asm

asmFreiChenSIMD.o:
	nasm -f elf -ggdb -o simd/asmFreiChen.o simd/asmFreiChen.asm

#clean:
#	rm -f main
#	rm -f *.o
