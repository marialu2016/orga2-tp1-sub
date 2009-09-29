OBJECTS = bordes.o 

bordes: $(OBJECTS)
	gcc  $(OBJECTS) -g -o bordes `pkg-config --cflags --libs opencv`

bordes.o: bordes.c
	gcc -g -c bordes.c -o bordes.o `pkg-config --cflags opencv`

clean:
	rm -f $(OBJECTS) bordes
