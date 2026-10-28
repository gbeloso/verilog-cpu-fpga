module extensor (EXT_I, EXT_O, EXT_SEL, SW_I);
	input [23:0] EXT_I;
	input [7:0] SW_I;
	output [31:0] EXT_O;
	input [2:0] EXT_SEL;
	reg [31:0] temp;
	
	always @ (EXT_I, EXT_SEL, SW_I)
	begin
		if(EXT_SEL == 3'b000)
		begin
			temp[7:0] = EXT_I[7:0];
			temp[31:8] = 24'b000000000000000000000000;
		end
		else if(EXT_SEL == 3'b001)
		begin
			temp[11:0] = EXT_I[11:0];
			temp[31:12] = 20'b00000000000000000000;
		end
		else if(EXT_SEL == 3'b010)
		begin
			temp[9:0] = EXT_I[9:0];
			temp[31:10] = 22'b0000000000000000000000;
		end
		else if(EXT_SEL == 3'b011)
		begin
			temp[7:0] = SW_I;
			temp[31:8] = 24'b000000000000000000000000;
		end
		else
		begin
			temp = 32'd0;
		end
	end
	
	assign EXT_O = temp;
	
endmodule