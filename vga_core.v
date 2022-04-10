
// Input frequency: 75 MHz
module vga_gen(h_sync, v_sync, avr, line_num, pixel_num, clk);

output h_sync, v_sync, avr; // AVR = Avtive Video Region
output [9:0] line_num, pixel_num;
input clk;

// Timing parameters (1024 x 768 @ 70Hz)
//
// HORIZONTAL:
// Visible area: 1024 pixels
localparam H_S_VIZ_COUNT = 1024;
// Back porch:   144
localparam H_S_B_PORCH = 144;                           // Count for single timing element
localparam H_A_B_PORCH = H_S_VIZ_COUNT - 1;             // Accumulated count value
// Sync pulse:   136
localparam H_S_SYNC = 136;
localparam H_A_SYNC = H_A_B_PORCH + H_S_B_PORCH;
// Front porch:  24
localparam H_S_F_PORCH = 24;                            
localparam H_A_F_PORCH = H_A_SYNC + H_S_SYNC;     
// Whole line:   1328
localparam H_A_ENDLINE = H_A_F_PORCH + H_S_F_PORCH;

// VERTICAL:
// Visible lines: 768 lines
localparam V_S_VIZ_COUNT = 768;
// Back porch:    29
localparam V_S_B_PORCH = 29;
localparam V_A_B_PORCH = V_S_VIZ_COUNT - 1;
// Sync pulse:    6
localparam V_S_SYNC = 6;
localparam V_A_SYNC = V_A_B_PORCH + V_S_B_PORCH;
// Front porch:   3
localparam V_S_F_PORCH = 3;
localparam V_A_F_PORCH = V_A_SYNC + V_S_SYNC;
// Whole frame:   806
localparam V_A_ENDFRAME = V_A_F_PORCH + V_S_F_PORCH;

// // Timing parameters (1368 x 768 @ 70Hz)
// //
// // HORIZONTAL:
// // Visible area: 1368 pixels
// localparam H_S_VIZ_COUNT = 1368; // 1024
// // Back porch:   216
// localparam H_S_B_PORCH = 216;                     // Count for single timing element
// localparam H_A_B_PORCH = H_S_VIZ_COUNT - 1;             // Accumulated count value
// // Sync pulse:   144
// localparam H_S_SYNC = 144;
// localparam H_A_SYNC = H_A_B_PORCH + H_S_B_PORCH;
// // Front porch:  72
// localparam H_S_F_PORCH = 72;                            
// localparam H_A_F_PORCH = H_A_SYNC + H_S_SYNC;     
// // Whole line:   1800
// localparam H_A_ENDLINE = H_A_F_PORCH + H_S_F_PORCH;

// // VERTICAL:
// // Visible lines: 768 lines
// localparam V_S_VIZ_COUNT = 768;
// // Back porch:    23
// localparam V_S_B_PORCH = 23;
// localparam V_A_B_PORCH = V_S_VIZ_COUNT - 1;
// // Sync pulse:    3
// localparam V_S_SYNC = 3;
// localparam V_A_SYNC = V_A_B_PORCH + V_S_B_PORCH;
// // Front porch:   1
// localparam V_S_F_PORCH = 1;
// localparam V_A_F_PORCH = V_A_SYNC + V_S_SYNC;
// // Whole frame:   795
// localparam V_A_ENDFRAME = V_A_F_PORCH + V_S_F_PORCH;



wire h_detect_fporch;           // Each of these signals goes high when the pxl count reaches the relevant localparam constant
wire h_detect_sync;
wire h_detect_bporch;
wire h_detect_end;

wire v_detect_fporch;           // Each of these signals goes high when the line count reaches the relevant localparam constant
wire v_detect_sync;
wire v_detect_bporch;
wire v_detect_end;

reg [10:0] pxl;                 // Number of pixels since beginning of line
reg [9:0] line;                 // The visible line number. (porches and sync are all at the end of count instead of beginning and end)

// Handle output ports for address generation
assign line_num = line;
assign pixel_num = pxl[9:0];

// Based on the count, set the state control lines for next state
assign h_detect_fporch = (pxl == H_A_F_PORCH);
assign h_detect_sync   = (pxl == H_A_SYNC);
assign h_detect_bporch = (pxl == H_A_B_PORCH);
assign h_detect_end    = (pxl == H_A_ENDLINE);

assign v_detect_fporch = (line == V_A_F_PORCH);
assign v_detect_sync   = (line == V_A_SYNC);
assign v_detect_bporch = (line == V_A_B_PORCH);
assign v_detect_end    = (line == V_A_ENDFRAME);

// ----------------- COUNTERS -----------------

always @(posedge clk)
begin
    pxl <= pxl + 1;
end

always @(posedge clk)
begin
    if (v_detect_end == 1'b1)
    begin
        line <= 10'b0;
    end
    else if (h_detect_end == 1'b1)
    begin
        line <= line + 1;
    end
end

// ----------------- STATE MACHINE -----------------

localparam SM_PXL_VIZ = 2'b00;
localparam SM_PXL_FP  = 2'b01;
localparam SM_PXL_SYN = 2'b10;
localparam SM_PXL_BP  = 2'b11;
localparam SM_LINE_VIZ = 2'b00;
localparam SM_LINE_FP  = 2'b01;
localparam SM_LINE_SYN = 2'b10;
localparam SM_LINE_BP  = 2'b11;

reg [1:0] state_p_pxl, state_p_line;

// pixel state machine
always @(posedge clk)
begin
    case (state_p_pxl)
    SM_PXL_SYN: begin
        if (h_detect_fporch == 1'b1)
        begin
            state_p_pxl <= SM_PXL_FP;
        end
    end
    SM_PXL_FP: begin
        if (h_detect_end == 1'b1)
        begin
            state_p_pxl <= SM_PXL_VIZ;
        end
    end
    SM_PXL_VIZ: begin
        if (h_detect_bporch == 1'b1)
        begin
            state_p_pxl <= SM_PXL_BP;
        end
    end
    SM_PXL_BP: begin
        if (h_detect_sync == 1'b1)
        begin
            state_p_pxl <= SM_PXL_SYN;
        end
    end
    endcase
end

// Line state machine
always @(posedge clk)
begin
    case (state_p_line)
    SM_LINE_SYN: begin
        if (v_detect_fporch == 1'b1)
        begin
            state_p_line <= SM_LINE_FP;
        end
    end
    SM_LINE_FP: begin
        if (v_detect_end == 1'b1)
        begin
            state_p_line <= SM_LINE_VIZ;
        end
    end
    SM_LINE_VIZ: begin
        if (v_detect_bporch == 1'b1)
        begin
            state_p_line <= SM_LINE_BP;
        end
    end
    SM_LINE_BP: begin
        if (v_detect_sync == 1'b1)
        begin
            state_p_line <= SM_LINE_SYN;
        end
    end
    endcase
end

// Handle Active Video Region output
assign avr = (state_p_pxl == SM_PXL_VIZ && state_p_line == SM_LINE_VIZ) ? 1'b1 : 1'b0;

// Handle sync signals
assign h_sync = (state_p_pxl == SM_PXL_SYN) ? 1'b1 : 1'b0;
assign v_sync = (state_p_line == SM_LINE_SYN) ? 1'b1 : 1'b0;

endmodule
