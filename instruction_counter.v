module instruction_counter (
	input wire clk,                                    // Clock do sistema
	input wire rst,                                  // Reset ativo baixo
	input wire start,                                  // Sinal para iniciar contagem
	input wire [31:0] target_count,       // Número alvo de instruções
	input wire [31:0] instruction,    // Instrução atual
	input wire [7:0] opcode,    // opcode da instrução atual
	output reg overflow_flag,                          // Flag indicando que atingiu o alvo
	output reg [31:0] overflow_instruction//, // Instrução que causou overflow
	//output wire [31:0] saida_prev,
	//output wire [31:0] saida_curr,
	//output wire [31:0] saida_count
	);

	// Estados do contador
	localparam IDLE = 2'b00;
	localparam COUNTING = 2'b01;
	localparam OVERFLOW = 2'b10;

	reg [1:0] current_state;
	reg [31:0] counter, target;
	reg [31:0] prev_inst;
	reg [31:0]curr_inst;
	// ========================================
	// BLOCO 1: Registrador de estado (sequencial)
	// ========================================
	always @(posedge clk) begin
		if(rst) begin
			prev_inst <= instruction;
			curr_inst <= instruction;
			current_state <= 2'd0;
			counter <= 32'd0;
			overflow_flag <= 0;
			overflow_instruction <= 32'd0;
		end
		else begin
			prev_inst <= curr_inst;
			curr_inst <= instruction;
			if(current_state == IDLE) begin
				current_state <= IDLE;
				if(start) begin
					current_state <= COUNTING;
					counter <= 32'd1;
					overflow_instruction <= 32'd0;
				end
			end
			
			else if(current_state == COUNTING) begin
				if (prev_inst != curr_inst && opcode != 8'b00010101) begin
					counter <= counter + 1;
				end
				if(counter + 1 >= target && opcode != 8'b00010101)begin
					overflow_flag <= 1;
					current_state <= OVERFLOW;
				end
			end
			
			else if(current_state == OVERFLOW) begin
				overflow_flag <= 0;
				current_state <= IDLE;
				overflow_instruction <= instruction;
			end
			
			else begin
				current_state <= IDLE;
			end
		end
	end
	
	always @(negedge clk) begin
		if(start) begin
			target <= target_count;
		end
	end
	
	//assign saida_prev = prev_inst;
	//assign saida_curr = curr_inst;
	//assign saida_count = counter;
	
endmodule