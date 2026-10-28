module uart_state_machine (
    input wire clk,
    input wire reset,
    input wire [31:0] data_in,
    input wire start,
    input wire uart_ready,
    output reg [7:0] uart_data,
    output reg uart_send,
    output reg done
);

    // Definição dos estados
    reg [2:0] IDLE  = 3'b000;
    reg [2:0] BYTE0 = 3'b001;
    reg [2:0] BYTE1 = 3'b010;
    reg [2:0] BYTE2 = 3'b011;
    reg [2:0] BYTE3 = 3'b100;
    reg [2:0] PREDONE = 3'b101;
    reg [2:0] DONE  = 3'b110;

    reg[2:0] current_state, next_state;

    // Contador de bytes
    reg [1:0] byte_counter;

    // Máquina de estados: Transição de estados
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Lógica da máquina de estados
    always @(*) begin
        // Sinais padrão
        uart_send = 0;
        done = 0;
        next_state = current_state;
			uart_data = data_in[7:0];
        case (current_state)
            IDLE: begin
                if (start && uart_ready)
                    next_state = BYTE0;
            end

            BYTE0: begin
                if (uart_ready) begin
                    next_state = BYTE1;
                    uart_send = 1;
						  uart_data = data_in[7:0];
                end
            end

            BYTE1: begin
                if (uart_ready) begin
                    uart_send = 1;
                    next_state = BYTE2;
						  uart_data = data_in[15:8];
                end
            end

            BYTE2: begin
                if (uart_ready) begin
                    uart_send = 1;
                    next_state = BYTE3;
						  uart_data = data_in[23:16];
                end
            end

            BYTE3: begin
                if (uart_ready) begin
                    uart_send = 1;
                    next_state = PREDONE;
						  uart_data = data_in[31:24];
                end
            end
				
				PREDONE: begin
                if (uart_ready) begin
                    next_state = DONE;
                end
            end

            DONE: begin
					done = 1;
					if (!start)
					begin
						next_state = IDLE;
					end
					else
					begin
                    next_state = DONE;
					end
            end
				
				default:
				begin
					next_state = IDLE;
				end
        endcase
    end

    // Seleção de dados a serem enviados
    /*always @(posedge clk or posedge reset) begin
        if (reset) begin
            uart_data <= 8'd0;
            byte_counter <= 2'd0;
        end else if (uart_send && uart_ready) begin
            case (byte_counter)
                2'd0: uart_data <= data_in[7:0];
                2'd1: uart_data <= data_in[15:8];
                2'd2: uart_data <= data_in[23:16];
                2'd3: uart_data <= data_in[31:24];
            endcase
            byte_counter <= byte_counter + 1;
        end else if (current_state == IDLE) begin
            byte_counter <= 2'd0;
        end
    end*/

endmodule
