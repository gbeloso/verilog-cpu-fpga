module Mem_Instr
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=12)
(
	input [(ADDR_WIDTH-1):0] addr,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q
);
	// Declare the ROM variable
	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file single_port_rom_init.txt.  Without this file,
	// this design will not compile.

	// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
	// format of this file, or see the "Using $readmemb and $readmemh"
	// template later in this section.

	initial
	begin
		$readmemb("codigos/so_bin.txt", rom, 12'd000, 12'd299);  // Posição 0x000
		$readmemb("codigos/area_bin.txt", rom, 12'd300, 12'd599);  // Posição 0x300
		$readmemb("codigos/div_bin.txt", rom, 12'd600, 12'd899);  // Posição 0x600
		$readmemb("codigos/fat_bin.txt", rom, 12'd900, 12'd1199);  // Posição 0x900
		$readmemb("codigos/fib_bin.txt", rom, 12'd1200, 12'd1499);  // Posição 0x1200
		$readmemb("codigos/gcd_bin.txt", rom, 12'd1500, 12'd1799);  // Posição 0x1500
		//$readmemb("codigos/mult_bin.txt", rom, 12'd1800);  // Posição 0x1800
		//$readmemb("codigos/pot_bin.txt", rom, 12'd2100);  // Posição 0x2100
		//$readmemb("codigos/soma_bin.txt", rom, 12'd2400);  // Posição 0x2400
		//$readmemb("codigos/soma_esc_bin.txt", rom, 12'd2700);  // Posição 0x2700
		//$readmemb("codigos/sub_bin.txt", rom, 12'd3000);  // Posição 0x3000
	end

	always @ (posedge clk)
	begin
		q <= rom[addr];
	end
	
endmodule
