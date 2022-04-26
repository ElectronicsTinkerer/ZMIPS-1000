
# If a command fails, stop
.SHELLFLAGS += -e

PROJECT_NAME	= ZMIPS_1000

GAME_SOURCE	= ./asm/game_source.asm
GAME_DATA	= ./asm/game_data.asm
GS_TARGET	= ./mifdata/game_source
GD_TARGET	= ./mifdata/game_data
SYNTH_DIR	= ./synthesis

IMG_TARGET	= ./asm/dummy.bak
ASSETS_DIR	= ./assets

all: mifupdate
	cd $(SYNTH_DIR) && $(QUARTUS_INSTALL_DIR)/21.1/quartus/bin64/quartus_asm.exe $(PROJECT_NAME) -c $(PROJECT_NAME) --read_settings_files=on --write_settings_files=off

mifupdate: assemble
	cd $(SYNTH_DIR) && $(QUARTUS_INSTALL_DIR)/21.1/quartus/bin64/quartus_cdb.exe $(PROJECT_NAME) -c $(PROJECT_NAME) --update_mif

assemble:
	python3 ./zmips_assembler.py $(GAME_DATA) $(GD_TARGET)
	python3 ./zmips_assembler.py $(GAME_SOURCE) $(GS_TARGET)

img:
	python3 ./img2dat.py $(ASSETS_DIR)/$(IMAGE) > $(IMG_TARGET)

clean:
	rm ./mifdata/*

