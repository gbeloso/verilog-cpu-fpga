module freq_divider (divIn, divOut);

	input divIn;
	output divOut;
	reg [11:0] temp;
	//reg [18:0] temp;
	//reg [21:0] temp;
	//reg [24:0] temp;
	
	always @ (posedge divIn)
	begin
		temp = temp + 1'd1;
		//temp = temp + 12'd1;
	end
	
	assign divOut = temp[11];
	//assign divOut = temp[18];
	//assign divOut = temp[21];
	//assign divOut = temp[24];
	//assign divOut = divIn;
	
endmodule