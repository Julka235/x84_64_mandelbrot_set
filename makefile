program = mandelbrot

OBJECTS = main.o mandelbrot.o

CC = gcc

CFLAGS = -c -g -Wall -Wextra -I $(SDL_PATH)

LDFLAGS = -g -L $(LIB_PATH) -lSDL2main -lSDL2

SDL_PATH = /include/SDL2
LIB_PATH = /include/lib

all: $(program)

$(program): $(OBJECTS)
	$(CC) -g -o $(program) $(OBJECTS) $(LDFLAGS)

main.o: main.c mandelbrot.h
	$(CC) $(CFLAGS) main.c

mandelbrot.o: mandelbrot.s mandelbrot.h
	nasm -g -F DWARF -f elf64 -w+all mandelbrot.s -o mandelbrot.o

clean:
	rm -f *.o $(program)