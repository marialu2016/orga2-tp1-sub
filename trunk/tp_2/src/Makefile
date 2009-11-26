.PHONY= clean clean_all build

OBJ = main.o cImpl.o asmRoberts.o asmPrewitt.o asmSobel.o simdRoberts.o simdPrewitt.o simdSobel.o simdFreichen.o


# Compila para debugging y elimina los *.o
build: main clean

# Compila para debugging
main: $(OBJ)
	gcc -o main $(OBJ) `pkg-config --cflags --libs opencv`
	

main.o:
	gcc -c main.c -o main.o `pkg-config --cflags --libs opencv` 
	
cImpl.o:
	gcc -c cImpl.c -o cImpl.o
	
%.o: %.asm
	nasm -felf -o $@ $^

clean:
	rm -f *.o
	
clean_all: clean
	rm -f main
	
