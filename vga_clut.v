
// VGA color LUT

module vga_clut(index, r, g, b);

input [3:0] index;
output [3:0] r, g, b;

reg [12:0] rgb;

assign r = rgb[11:8];
assign g = rgb[7:4];
assign b = rgb[3:0];

always @(*)
begin
    case(index)
    4'b0000: rgb = 12'h000; // black (black)
    4'b0001: rgb = 12'h00a; // dark dark blue
    4'b0010: rgb = 12'h0a0; // dark green
    4'b0011: rgb = 12'h0aa; // dark cyan
    4'b0100: rgb = 12'ha00; // dark red
    4'b0101: rgb = 12'ha0a; // dark magenta
    4'b0110: rgb = 12'ha50; // dark yellow (brown)
    4'b0111: rgb = 12'haaa; // dark white (light grey)
    4'b1000: rgb = 12'h555; // bright black (dark grey)
    4'b1001: rgb = 12'h55f; // bright blue
    4'b1010: rgb = 12'h5f5; // bright green
    4'b1011: rgb = 12'h5ff; // bright cyan
    4'b1100: rgb = 12'hf55; // bright red
    4'b1101: rgb = 12'hf5f; // bright magenta
    4'b1110: rgb = 12'hff5; // bright yellow
    4'b1111: rgb = 12'hfff; // bright white
    endcase
end


endmodule