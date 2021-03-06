#!/bin/bash

TOOLS_DIR=$1
ASSETS_DIR=$2
IMG_TARGET=$3

# If this order is changed, remember to update the offsets in game_source.asm
ASSETS_SRC=(\
		title_screen.png \
		gameplay_background.png \
		number1.png \
		number2.png \
		number3.png \
		number4.png \
		number5.png \
		number6.png \
		number7.png \
		number8.png \
		number9.png \
		number10.png \
		enemy1.png \
		enemy2.png \
		missile.png \
		player_right1.png \
		player_right2.png \
		player_thrust1.png \
		player_thrust2.png \
		player_thrust3.png \
		player_thrust4.png \
		dead1.png \
		dead2.png \
		dead3.png \
		dead4.png \
		dead5.png \
		explosion1.png \
		explosion2.png \
		explosion3.png \
		explosion4.png
)

ASSETS_FLGS=(\
		--nomask \
		--nomask \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
		-- \
)

rm -f "$IMG_TARGET"

for i in "${!ASSETS_SRC[@]}"; do
    echo "Reading '${ASSETS_SRC[$i]}'";
    python3 "$TOOLS_DIR/img2dat.py" "$ASSETS_DIR/${ASSETS_SRC[$i]}" "${ASSETS_FLGS[$i]}" >> "$IMG_TARGET";
    echo -ne "\n\n" >> "$IMG_TARGET";
done

