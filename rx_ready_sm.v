module rx_ready_sm (
    input wire clk,                // Clock
    input wire [7:0] op,           // Entrada de 8 bits
    input wire rx_done,            // Sinal para indicar que algo foi recebido
    output reg done                // Saída de 1 bit
);

    // Definição de estados
    localparam IDLE = 2'b00;      
    localparam ACTIVATED = 2'b01;  

    // Registro para armazenar o estado atual e o próximo estado
    reg [1:0] current_state;  // Inicialização do estado atual
    reg [1:0] next_state;

    // Lógica sequencial: Atualiza o estado atual
    always @(posedge clk) begin
        current_state <= next_state; // Transição de estado
    end

    // Lógica combinacional: Define o próximo estado e a saída
    always @(*) begin
        // Estado padrão (fica no mesmo estado e saída padrão)
        next_state = current_state;
        done = 1'b0;

        case (current_state)
            IDLE: begin
                if (op == 8'b00010101 && rx_done) begin
                    next_state = ACTIVATED; // Vai para o estado ativado
                end
            end
            ACTIVATED: begin
                done = 1'b1; // Saída alta no estado ativado
                if (op != 8'b00010101) begin
                    next_state = IDLE; // Retorna ao estado inicial
                end
            end
            default: begin
                next_state = IDLE; // Estado padrão de segurança
            end
        endcase
    end

endmodule
