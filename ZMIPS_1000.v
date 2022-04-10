
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

wire pxl_clk;
wire [9:0] line_num, pixel_num;
wire avr;

//=======================================================
//  Structural coding
//=======================================================

// Generate 85.86 MHZ pixel clock
pll25175 PLL_85(
		.refclk(CLOCK_50),   //  refclk.clk
		.rst(!RESET_N),      //   reset.reset
		.outclk_0(pxl_clk) // outclk0.clk
		//.locked    //  locked.export
	);
	
vga_gen VGAG(.h_sync(VGA_HS), .v_sync(VGA_VS), .avr(avr), .line_num(line_num), .pixel_num(pixel_num), .clk(pxl_clk));

assign VGA_R = line_num[3:0] & {4{avr}};
assign VGA_G = 4'b0000; //line_num[7:4];
assign VGA_B = 4'b0000; //{line_num[9:8], pixel_num[1:0]};
assign LEDR[3:0] = {VGA_HS, VGA_VS, !VGA_HS, !VGA_VS};


endmodule
