
GAME_SOURCE	= ./asm/game_source.asm
GAME_DATA	= ./asm/game_data.asm
GS_TARGET	= ./mifdata/game_source
GD_TARGET	= ./mifdata/game_data

all: assemble

assemble:
	python3 ./zmips_assembler.py $(GAME_DATA) $(GD_TARGET)
	python3 ./zmips_assembler.py $(GAME_SOURCE) $(GS_TARGET)

clean:
	rm ./mifdata/*
