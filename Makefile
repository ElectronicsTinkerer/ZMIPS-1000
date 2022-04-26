
# If a command fails, stop
.SHELLFLAGS += -e

PROJECT_NAME	= ZMIPS_1000

GAME_SOURCE	= ./asm/game_source.asm
GAME_DATA	= ./asm/game_data.asm
GS_TARGET	= ./mifdata/game_source
GD_TARGET	= ./mifdata/game_data
GD_RULE		= $(wildcard ./assets/*.png)
SYNTH_DIR	= ./synthesis
CDF_FILE	= $(PROJECT_NAME).cdf
SOF_FILE	= $(PROJECT_NAME).sof
MIF_LOG		= db/$(PROJECT_NAME).mif_update.qmsg

TOOLS_DIR	= ./tools

IMG_TARGET	= ./asm/game_data.asm
ASSETS_DIR	= ./assets

all: $(SYNTH_DIR)/$(SOF_FILE)

# Reassemble SOF
$(SYNTH_DIR)/$(SOF_FILE): $(SYNTH_DIR)/$(MIF_LOG)
	cd $(SYNTH_DIR) && $(QUARTUS_INSTALL_DIR)/21.1/quartus/bin64/quartus_asm.exe $(PROJECT_NAME) -c $(PROJECT_NAME) --read_settings_files=on --write_settings_files=off

# Update MIFs
$(SYNTH_DIR)/$(MIF_LOG): $(GD_TARGET) $(GS_TARGET)
	cd $(SYNTH_DIR) && $(QUARTUS_INSTALL_DIR)/21.1/quartus/bin64/quartus_cdb.exe $(PROJECT_NAME) -c $(PROJECT_NAME) --update_mif

$(GS_TARGET): $(GAME_SOURCE)
	python3 $(TOOLS_DIR)/zmips_assembler.py $< $@
	touch $@

img: $(GD_TARGET)
$(GD_TARGET): $(GAME_DATA)
	python3 $(TOOLS_DIR)/zmips_assembler.py $< $@
	touch $@

$(GAME_DATA): $(GD_RULE)
# $(foreach var,$(ASSETS_SRC),python3 $(TOOLS_DIR)/img2dat.py $(ASSETS_DIR)/"$(var)" >> $(IMG_TARGET);)
	$(TOOLS_DIR)/img_convert.bash $(TOOLS_DIR) $(ASSETS_DIR) $(IMG_TARGET)

upload: $(SYNTH_DIR)/$(SOF_FILE)
	cd $(SYNTH_DIR) && $(QUARTUS_INSTALL_DIR)/21.1/quartus/bin64/quartus_pgm.exe -m jtag $(CDF_FILE)

clean:
	rm ./mifdata/*


