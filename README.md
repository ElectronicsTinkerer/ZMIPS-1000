# ZMIPS-1000 Game Console

## Hardware

The ZMIPS-1000 games console runs on the [ZMIPS](https://github.com/ElectronicsTinkerer/zmips-cpu) CPU, which is a MIPS-based, pipelined 32-bit architecture. This uses a separate instruction and data memory, so two different sets of buses are used in the ZMIPS-1000 top level module for interfacing it with the rest of the system. Currently, the ROM block for the instruction memory is 2048 words and is initialized from the `mifdata/game_source.mif` file.

The data memory is more interesting, however. This uses a mux to perform address decoding between different memory sources:
1. Video memory (16k words, CPU; 128k nibbles, VGA)
2. Graphics ROM (16k words, initialized from `mifdata/game_data.mif`)
3. User inputs (1 word, mirrored over 16k addresses)
4. VGA state information (1 word, mirrored over 16k addresses)

With this configuration, accessing the screen buffer, reading background/sprite data, handling user inputs, and reading the current line or frame is as simple as an access to memory. Since all the memory blocks are setup using the FPGA's internal memory structures, the memory is able to run at the same speed as the CPU.

### User Inputs

The user input register (memory location) is mapped as follows:

```
+----------------------------+-+-+-+-+
|0000000000000000000000000000|P|F|U|D|
+----------------------------+-+-+-+-+
|                                    |
|31                                 0|
```

Where the fields are:

* `D` - The state of the "Down" button. 1 = pressed, 0 = not pressed.
* `U` - The state of the "Up" button. 1 = pressed, 0 = not pressed.
* `F` - The state of the "Fire" button. 1 = pressed, 0 = not pressed.
* `P` - 1 on the first CPU read of the register in which the fire button is pressed. All subsequent reads while the fire button is pressed will read as 0.

### VGA State Register

When the CPU reads the VGA state register, it receives the following data:

```
+-+------------------+------+-------+
|N|000000000000000000|ffffff|lllllll|
+-+------------------+------+-------+
|  \                 |      |       |
|    \               |      |       |
|31 30|29          13|12   7|6     0|
```

Where the fields are:

* `N` - Will be high if this is the first time that the CPU has read the state register since the last frame change.
* `ffffff` - The current frame counter (rolls over)
* `lllllll` - The current line number

Note that the data in this register will be several clock cycles behind the updates in the VGA core since there is a series of synchronization flip flops between the VGA and CPU clock domains.

### Memory

The video memory is a dual-port memory block. On the CPU side, it is organized as 16k words (where a word is 32 bits). The first 4k words of this are dedicated to the video memory. The next 4k words are "reserved" for the event that double buffering support gets implemented in hardware. The remaining 8k words are available for use by the CPU to store game variables and stack data.

On the VGA side, the dual-port memory is seen as a 4-bit wide interface. This allows for reading a single pixel at a time, which can be directly input to the color lookup table to generate the appropriate RGB signals to output. The difference in data port widths creates an interesting "feature" where the words that are stored by the CPU are displayed horizontally backwards. As a result, the ordering of the quartets in words  written to the screen must be reversed. This is achieved by simply storing the sprite and background image data in the reversed order. (The image converter utility handles this reversal).

### VGA Core

The "VGA Core" implements the state machine needed to generate the sync pulses and address generation to produce a VGA output. The current output resolution is 1024 x 768 @ 60Hz, but the front porch and back porch periods have been extended to center a 256 x 128 pixel frame. The ZMIPS_1000 module preforms pixel-quadrupling in both the X and Y directions, meaning that a display which is connected will still see a "standard" VGA resolution.

The core has been parameterized, allowing for easy modification to fit different resolutions/framerates. All that it needs is an input clock and it will generate the V-sync, H-sync, row, column, and active video region (AVR) signals.

## Synthesis, Assembling, and Running

When the system was designed, I was targeting a Cyclone V FPGA (on Terasic's DE0-CV board), using Quartus 21.1. This is used for synthesis and creating the chain description file (CDF). Once synthesized, the makefile can be used to quickly reassemble updates to the MIF files and reupload the bitstream to the FPGA. 

**Makefile targets:**

* `all` - Build both program and data images.
* `upload` - Build both program and data images then attempt to upload to a board. Requires a connected programmer and valid CDF.
* `clean` - Remove all MIF and DAT files.

**Environment Variables for Make:**

Before running `make`, be sure to set `QUARTUS_INSTALL_DIR` environment variable to the root install directory of the Quartus install.

**Other Notes:**

All assembling is performed using the `zmips_assembler.py` file which needs to be placed into the `tools` directory. The assembler can be found in the ZMIPS CPU repository. This also requires python3 to be installed.

To run the makefile, I used a WSL2 instance on Windows 11. This has the benefit of being able to run the linux commands and bash script needed to order the data from the images while also being able to run the windows Quartus executable.

The ZMIPS CPU repository is also needed to synthesize the games console. Clone the CPU into a folder called `ZMIPS` into the same folder that the games console was cloned. This will allow Quartus to locate the files needed for synthesis. Your directory structure should look like:

```
.
├── ZMIPS
│   *
│   └── ***
└── ZMIPS-1000
    *
    └── ***
```

