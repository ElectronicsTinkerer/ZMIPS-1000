
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module ZMIPS_1000(

	//////////// CLOCK //////////
	input 		          		CLOCK_50,
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	inout 		          		CLOCK4_50,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,
	input 		          		RESET_N,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// microSD Card //////////
	output		          		SD_CLK,
	inout 		          		SD_CMD,
	inout 		     [3:0]		SD_DATA,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
);




//=======================================================
//  REG/WIRE declarations
//=======================================================


// Signals for VGA generation
wire pxl_clk, pxl_mem_clk;
wire [9:0] line_num, pixel_num;
wire avr;
wire [14:0] vmem_vga_addr;
wire [3:0] vga_pre_r, vga_pre_g, vga_pre_b; // Color signals from the LUT, before being ANDed with the AVR

// Signals for CPU interface
wire [31:0] cpu_i_data, cpu_i_addr, cpu_d_i_data, cpu_d_o_data, cpu_d_addr;
wire cpu_clk;
wire cpu_rst;
wire cpu_wren, cpu_rden;
wire [3:0] vga_vindex;
wire [31:0] cpu_vga_i_data, cpu_romdata;

// CPU-Video state machine interface
wire [31:0] vcore_state; // Passed to CPU
reg [1:0] vcore_v_sync_state;
reg [5:0] vcore_frame_num, vcore_frame_num_cdc_0, vcore_frame_num_cdc_1, vcore_frame_num_cdc_2, vcore_frame_num_prev;
reg [6:0] line_num_cdc_0, line_num_cdc_1, line_num_cdc_2;
reg vcore_new_frame;

// User interface
// Neeed to do CDC on the buttons so they aren't changing when the CPU reads their state
wire [31:0] user_input_state; // Sent to CPU
reg [2:0] keys_cdc_1, keys_cdc_2;

//=======================================================
//  Structural coding
//=======================================================

// Generate 65 MHZ pixel clock
pll65 PLL_65(
		.refclk(CLOCK2_50),   //  refclk.clk
		.rst(!RESET_N),      //   reset.reset
		.outclk_0(pxl_clk), // outclk0.clk
		.outclk_1(pxl_mem_clk) // outclk1.clk
		//.locked()    //  locked.export
	);
	
vga_gen VGAG(.h_sync(VGA_HS), .v_sync(VGA_VS), .avr(avr), .line_num(line_num), .pixel_num(pixel_num), .clk(pxl_clk));

// Resolution: 256 x 256 (via pixel doubling)
assign vmem_vga_addr = {line_num[8:2], pixel_num[9:2]}; // Pixel quadrupling in v- and h-direction

// Video memory
vmem VMEM0(
	.address_a(cpu_d_addr[14:0]),
	.address_b({3'b0, vmem_vga_addr}),
	.clock_a(cpu_clk),
	.clock_b(pxl_mem_clk), // Latch address on falling clock edge since data is read on rising
	.data_a(cpu_d_o_data),
	.data_b(4'b0000),
	.wren_a(cpu_wren & (~|cpu_d_addr[31:15])), // Lowest portion of memory is video
	.wren_b(1'b0), // Video circuit does not need to write to mem
	.q_a(cpu_vga_i_data),
	.q_b(vga_vindex)
	);

// Color LUT
vga_clut VGA_LUT(.index(vga_vindex), .r(vga_pre_r), .g(vga_pre_g), .b(vga_pre_b));

assign VGA_R = vga_pre_r & {4{avr}};
assign VGA_G = vga_pre_g & {4{avr}};
assign VGA_B = vga_pre_b & {4{avr}};

// CPU connections
pll_cpu_40 PLL_CPU(
		.refclk(CLOCK_50),   //  refclk.clk
		.rst(!RESET_N),      //   reset.reset
		.outclk_0(cpu_clk) // outclk0.clk
		// .outclk_1(cpu_mem_clk) // outclk1.clk
		//.locked()    //  locked.export
	);
	
// assign cpu_clk = KEY[0];
// assign HEX0 = cpu_i_data[31:26];

assign cpu_rst = !KEY[3];

zmips CPU0(
	.i_data(cpu_i_data),
	.i_addr(cpu_i_addr), 
	.d_data_o(cpu_d_o_data),
	.d_data_i(cpu_d_i_data),
	.d_addr(cpu_d_addr),
	.clk(cpu_clk),
	.d_wr(cpu_wren),
	.d_rd(cpu_rden),
	.rst(cpu_rst)
	);

// CPU ROM
cpurom ROM0(
	.address(cpu_i_addr[12:2]),
	.clock(cpu_clk),
	.q(cpu_i_data)
);

// Game data rom
gdrom ROM1(
	.address(cpu_d_addr[13:0]),
	.clock(cpu_clk),
	.q(cpu_romdata)
);


// Keep a frame counter
always @(negedge pxl_mem_clk) // internal line counters of the VGA_CORE are updated on posedge
begin
	case ({vcore_v_sync_state, VGA_VS})
	3'b000:	vcore_v_sync_state <= 2'b01; // Input is high, go to next state
	3'b001: vcore_v_sync_state <= 2'b00; // Stay in initial state
	3'b011: vcore_v_sync_state <= 2'b00; // Input went low early, shut off output
	3'b010: vcore_v_sync_state <= 2'b11; // Input is still high, go to stable state for input high
	3'b110: vcore_v_sync_state <= 2'b11; // Stay in high steady state
	3'b111: vcore_v_sync_state <= 2'b01; // Currently in steady state with high input, start transition to low steady state
	// 3'b101: 
	// 3'b100:
	endcase

	if ({vcore_v_sync_state, VGA_VS} == 3'b010)
	begin
		vcore_frame_num <= vcore_frame_num + 6'b1;
	end
end

// Synchronize count with CPU
always @(posedge pxl_mem_clk)
begin
	vcore_frame_num_cdc_0 <= vcore_frame_num;
	line_num_cdc_0 <= line_num[8:2];
end
always @(posedge cpu_clk)
begin
	vcore_frame_num_cdc_1 <= vcore_frame_num_cdc_0;
	vcore_frame_num_cdc_2 <= vcore_frame_num_cdc_1;
	line_num_cdc_1 <= line_num_cdc_0;
	line_num_cdc_2 <= line_num_cdc_1;
end

// Handle "new frame" flag
always @(posedge cpu_clk)
begin
	// If the video core data reg is accessed and the CPU is reading
	if (cpu_d_addr[15:14] == 2'b11 && cpu_rden == 1'b1)
	begin
		// Then set the flag indicating if this is not the same as the one previously read
		vcore_new_frame <= (vcore_frame_num_cdc_2 != vcore_frame_num_prev) ? 1'b0 : 1'b1;
		// And update the previously accessed frame reg
		vcore_frame_num_prev <= vcore_frame_num_cdc_2;
	end
end

assign vcore_state = {vcore_new_frame, 18'b0, vcore_frame_num_cdc_2, line_num_cdc_2};

// User interface CDC
always @(posedge cpu_clk)
begin
	keys_cdc_1 <= KEY[2:0];
	keys_cdc_2 <= keys_cdc_1;
end

assign user_input_state = {29'b0, keys_cdc_2};

// Memory map:
// 0x00000000 - 0x00001fff => Video memory (Buffer 0)
// 0x00002000 - 0x00003fff => Video memory (Buffer 1)
// 0x00004000 - 0x00005fff => ROM data (not code)
// 0x00006000 - 0x00007fff => ROM data (not code) - Mirrored
// 0x00008000 - 0x0000bfff => USER input
// 0x0000c000 - 0x0000ffff => Video core state machine state
// Select which data to send to CPU
zmips_mux432 MUX_MEMSEL(
	.a(cpu_vga_i_data),
	.b(cpu_romdata),
	.c(user_input_state),	// Allow CPU to read input keys and screen state
	.d(vcore_state),
	.sel(cpu_d_addr[15:14]),
	.y(cpu_d_i_data)
);

assign LEDR = cpu_i_addr[11:2];

endmodule
