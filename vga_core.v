
// Input frequency: 75 MHz
module vga_gen(h_sync, v_sync, r, g, b, clk);

output h_sync, v_sync;
output [3:0] r, g, b;
input clk;

// Timing parameters (1024 x 768 @ 70Hz)
//
// HORIZONTAL:
// Visible area: 1024 pixels
localparam H_S_VIZ_COUNT = 1024;
// Front porch:  24
localparam H_S_F_PORCH = 24;                            // Count for single timing element
localparam H_A_F_PORCH = H_VIZ_COUNT;                   // Accumulated count value
// Sync pulse:   136
localparam H_S_SYNC = 136;
localparam H_A_SYNC = H_A_F_PORCH + H_S_F_PORCH;
// Back porch:   144
localparam H_S_B_PORCH = 144;
localparam H_A_B_PORCH = H_A_SYNC + H_S_SYNC;
// Whole line:   1328
localparam H_A_ENDLINE = H_A_B_PORCH + H_S_B_PORCH;

// VERTICAL:
// Visible lines: 768 lines
localparam V_S_VIZ_COUNT = 768;
// Front porch:   3
localparam V_S_F_PORCH = 3;
localparam V_A_F_PORCH = V_S_VIZ_COUNT;
// Sync pulse:    6
localparam V_S_SYNC = 6;
localparam V_A_SYNC = V_A_F_PORCH + V_S_F_PORCH;
// Back porch:    29
localparam V_S_B_PORCH = 29;
localparam V_A_B_PORCH = V_A_SYNC + V_S_SYNC;
// Whole frame:   806
localparam V_A_ENDFRAME = V_A_B_PORCH + V_S_B_PORCH;

wire h_detect_fporch;           // Each of these signals goes high when the 
wire h_detect_sync;
wire h_detect_bporch;
wire h_detect_end;

wire v_detect_fporch;
wire v_detect_sync;
wire v_detect_bporch;
wire v_detect_end;







reg [23:0] pxl_count;       // Number of clock pulses since the beginnng of the frame

reg [10:0] line;            // The visible line number. (porches and sync are all at the end of count instead of beginning and end)




endmodule
