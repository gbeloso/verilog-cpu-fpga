module PC (CLK, PC_I, PC_O, PC_E, PC_RESET);
	input [31:0] PC_I;
	input CLK;
	input PC_E;
	input PC_RESET;
	output [31:0] PC_O;
	reg [31:0] registrador;
	reg reset;
	always @ (posedge CLK)
	begin
		if(PC_E)
		begin
			registrador <= PC_I;
		end
		if(PC_RESET)
			registrador <= 31'b0;
	end
	
	assign PC_O = registrador;
	
endmodule