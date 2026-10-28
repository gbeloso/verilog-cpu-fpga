module display_controller (
    input wire clk,              // Clock do sistema
    input wire reset_n,          // Reset ativo baixo
    input wire [13:0] number,    // Número de entrada (14 bits)
    output reg [7:0] segments,   // Segmentos (a-g)
    output reg [3:0] digit_sel   // Seleção do display (ativo baixo)
);

    // Parâmetros para divisão de clock (ajuste conforme seu clock)
    parameter REFRESH_RATE = 16'd50000; // Para ~1kHz com clock de 50MHz
    
    // Registradores internos
    reg [15:0] refresh_counter;
    reg [1:0] display_select;    // Seleciona qual display está ativo
    reg [3:0] current_digit;     // Valor atual a ser mostrado
    
    // Registradores para armazenar cada dígito
    reg [3:0] digit3;  // Milhares
    reg [3:0] digit2;  // Centenas
    reg [3:0] digit1;  // Dezenas
    reg [3:0] digit0;  // Unidades
	 
	 wire [13:0] div1000_res = number / 14'd1000;
	wire [13:0] div100_res  = (number % 14'd1000) / 14'd100;
	wire [13:0] div10_res   = (number % 14'd100) / 14'd10;
	wire [13:0] mod10_res   = number % 14'd10;

    
    // Divisão do número em dígitos
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            digit3 <= 4'd0;
            digit2 <= 4'd0;
            digit1 <= 4'd0;
            digit0 <= 4'd0;
        end else begin
            // Divisão por 1000, 100, 10 para separar os dígitos
            digit3 <= div1000_res[3:0];
				digit2 <= div100_res[3:0];
				digit1 <= div10_res[3:0];
				digit0 <= mod10_res[3:0];
        end
    end
    
    // Contador para refresh
    always @(posedge clk or posedge reset_n) begin
        if (reset_n)
            refresh_counter <= 16'd0;
        else if (refresh_counter >= REFRESH_RATE)
            refresh_counter <= 16'd0;
        else
            refresh_counter <= refresh_counter + 16'd1;
    end
    
    // Seleção do display
    always @(posedge clk or posedge reset_n) begin
        if (reset_n)
            display_select <= 2'd0;
        else if (refresh_counter == 16'd0)
            display_select <= display_select + 2'd1;
    end
    
    // Seleção do dígito a ser mostrado
    always @(*) begin
        case (display_select)
            2'b00: begin
                digit_sel = 4'b1110;  // Display 0 (direita)
                current_digit = digit0;
            end
            2'b01: begin
                digit_sel = 4'b1101;  // Display 1
                current_digit = digit1;
            end
            2'b10: begin
                digit_sel = 4'b1011;  // Display 2
                current_digit = digit2;
            end
            2'b11: begin
                digit_sel = 4'b0111;  // Display 3 (esquerda)
                current_digit = digit3;
            end
        endcase
    end
    
    // Decodificador BCD para 7 segmentos
    // segments: {g,f,e,d,c,b,a}
    always @(*) begin
        case (current_digit)
            4'h0: segments = 8'b11000000; // 0
            4'h1: segments = 8'b11111001; // 1
            4'h2: segments = 8'b10100100; // 2
            4'h3: segments = 8'b10110000; // 3
            4'h4: segments = 8'b10011001; // 4
            4'h5: segments = 8'b10010010; // 5
            4'h6: segments = 8'b10000010; // 6
            4'h7: segments = 8'b11111000; // 7
            4'h8: segments = 8'b10000000; // 8
            4'h9: segments = 8'b10010000; // 9
            default: segments = 8'b11111111; // Todos desligados
        endcase
    end

endmodule