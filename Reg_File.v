module Reg_File (A1, A2, A3, WD3, R63, RD1, RD2, R56, R57, CLK, WE3, WE63);
	input CLK;
	input [5:0] A1;
	input [5:0] A2;
	input [5:0] A3;
	input [31:0] WD3;
	input WE3;
	input WE63;
	input [31:0] R63;
	output [31:0] RD1;
	output [31:0] RD2;
	output [31:0] R56;
	output [31:0] R57;

	reg [31:0] regs[63:0];

	always @ (posedge CLK)
	begin
		if(WE63)
		begin
			regs[63] = R63;
		end
		if(WE3)
		begin
			regs[A3] = WD3;
		end
	end

	assign RD1 = regs[A1];
	assign RD2 = regs[A2];
	assign R57 = regs[57];
	assign R56 = regs[56];

endmodule