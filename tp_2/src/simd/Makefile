.PHONY= clean clean_all build

OBJ = main.o cImpl.o asmRoberts.o asmPrewitt.o asmSobel.o simdRoberts.o simdPrewitt.o simdSobel.o simdFreichen.o


# Compila para debugging y elimina los *.o
build: main clean

# Compila para debugging
main: $(OBJ)
	gcc -g -o main $(OBJ) `pkg-config --cflags --libs opencv`
	

main.o:
	gcc -g -c main.c -o main.o `pkg-config --cflags --libs opencv` 
	
cImpl.o:
	gcc -g -c cImpl.c -o cImpl.o
	
	
%.o: %.asm
	nasm -felf -ggdb -o $@ $^
	

clean:
	rm -f *.o
	
clean_all: clean
	rm -f main *~
	

