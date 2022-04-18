
module tb_vga_core();

reg clk;
wire v_sync, h_sync, avr;
wire [9:0] line_num, pixel_num;

vga_gen VGAG0(h_sync, v_sync, avr, line_num, pixel_num, clk);

initial
begin
    clk = 1'b0;
    forever #1 clk = !clk;
end

endmodule
