module Unidade_controle(
    input clk,             // Clock do sistema
    input rst,             // Reset
    input [7:0] Opcode, 
    input enter, 
    input [1:0] flags,
    input o_ready,
    input clk_overflow,
    output reg [1:0] REG_SRC,
    output reg [1:0] PC_SRC,
    output reg REG_WE,
    output reg MEM_WE,
    output reg [1:0] MEM_REG,
    output reg ALU_SRC,
    output reg [2:0] ALU_CNTRL,
    output reg [2:0] IMM_CNTRL,
    output reg PC_E,
    output reg E_REGO,
    output reg REG_WE15,
    output reg ULAOUTSEL,
    output reg START_COUNT,
    output reg REG_DST      // Seleciona o registrador de destino A3
);

    reg state_2cycles; // Registrador de estado para STRR (28) e LDRR (29)

    // Máquina de estados sequencial para instruções multiciclo
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_2cycles <= 1'b0;
        end else begin
            if (Opcode == 8'b00011100 || Opcode == 8'b00011101) begin
                state_2cycles <= ~state_2cycles; // Alterna 0 -> 1 -> 0
            end else begin
                state_2cycles <= 1'b0;
            end
        end
    end

    // Lógica Combinacional de Controle
    always @ (*) begin
        // Valores Padrão (Default)
        REG_SRC     = 2'b01;
        PC_SRC      = 2'b01;
        REG_WE      = 1'b0;
        MEM_WE      = 1'b0;
        MEM_REG     = 2'b01;
        ALU_SRC     = 1'b0;
        ALU_CNTRL   = 3'b111;
        IMM_CNTRL   = 3'b011;
        PC_E        = 1'b1;
        E_REGO      = 1'b0;
        REG_WE15    = 1'b0;
        ULAOUTSEL   = 1'b0;
        START_COUNT = 1'b0;
        REG_DST     = 1'b0;

        if (clk_overflow == 1'b1) begin
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b10;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b011;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00000000) begin
            // add RD, RN, RM
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b000;
            IMM_CNTRL   = 3'b000;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00000001) begin
            // addi RD, RN, IMM[8bits]
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b000;
            IMM_CNTRL = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00000010) begin
            // sub RD, RN, RM
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b001;
            IMM_CNTRL   = 3'b000;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00000011) begin
            // subi RD, RN, IMM[8bits]
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b001;
            IMM_CNTRL = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00000100) begin
            // cmp RD, RN, RM
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b110;
            IMM_CNTRL   = 3'b000;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00000101) begin
            // cmpi RD, RN, IMM
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b110;
            IMM_CNTRL = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00000110) begin
            // mov RD, RM
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00000111) begin
            // mult RD, RN, RM
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b011;
            IMM_CNTRL   = 3'b000;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00001000) begin
            // multi RD, RN, IMM
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b011;
            IMM_CNTRL = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00001001) begin
            // div RD, RN, RM
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b010;
            IMM_CNTRL   = 3'b000;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00001010) begin
            // divi RD, RN, IMM
            REG_SRC     = 2'b00;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b010;
            IMM_CNTRL = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00001011) begin
            // str RD, RN, IMM
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b1;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b000;
            IMM_CNTRL   = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b1;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end 
        else if (Opcode == 8'b00001100) begin
            // ldr RD, RN, IMM
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b00;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b000;
            IMM_CNTRL   = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b1;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00001101) begin
            // ldrb RD, imm
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00001110) begin
            // beq RN IMM
            REG_SRC     = 2'b00;
            PC_SRC      = (flags == 2'b01) ? 2'b00 : 2'b01;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b010;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b1;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00001111) begin
            // bnq RN IMM
            REG_SRC     = 2'b00;
            PC_SRC      = (flags == 2'b01) ? 2'b01 : 2'b00;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b010;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b1;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00010000) begin
            // bgt RN IMM
            REG_SRC     = 2'b00;
            PC_SRC      = (flags == 2'b00) ? 2'b00 : 2'b01;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b010;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b1;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00010001) begin
            // blt RN IMM
            REG_SRC     = 2'b00;
            PC_SRC      = (flags == 2'b10) ? 2'b00 : 2'b01;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b010;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b1;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00010010) begin
            // JMP IMM
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b00;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b010;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b1;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00010011) begin
            // JAL IMM
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b00;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b010;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b1;
            ULAOUTSEL   = 1'b1;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00010100) begin
            // JMPR RD
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b00;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b010;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00010101) begin
            // in RD
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b011;
            PC_E        = (enter == 1'b1) ? 1'b1 : 1'b0;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00010110) begin
            // out RD
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b011;
            PC_E        = (o_ready == 1'b1) ? 1'b1 : 1'b0;
            E_REGO      = 1'b1;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00010111) begin
            // POSIN
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b011;
            PC_E        = (enter == 1'b0) ? 1'b1 : 1'b0;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00011000) begin
            // NOP
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b0;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b011;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00011001) begin
            // HALT
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b10;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b010;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00011010) begin
            // CLK IMM
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b0;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b01;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b111;
            IMM_CNTRL   = 3'b010;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b0;
            START_COUNT = 1'b1;
            REG_DST     = 1'b0;
        end
        else if (Opcode == 8'b00011011) begin
            // ldrclk RD
            REG_SRC     = 2'b01;
            PC_SRC      = 2'b01;
            REG_WE      = 1'b1;
            MEM_WE      = 1'b0;
            MEM_REG     = 2'b10;
            ALU_SRC     = 1'b1;
            ALU_CNTRL   = 3'b000;
            IMM_CNTRL   = 3'b001;
            PC_E        = 1'b1;
            E_REGO      = 1'b0;
            REG_WE15    = 1'b0;
            ULAOUTSEL   = 1'b1;
            START_COUNT = 1'b0;
            REG_DST     = 1'b0;
        end

        // --- INSTRUÇÃO STRR (Opcode 28) ---
        else if (Opcode == 8'b00011100) begin
            if (state_2cycles == 1'b0) begin
                // CICLO 1: Captura R1
                REG_SRC     = 2'b01;
                PC_SRC      = 2'b01;
                REG_WE      = 1'b0;
                MEM_WE      = 1'b0;
                MEM_REG     = 2'b01;
                ALU_SRC     = 1'b0;
                ALU_CNTRL   = 3'b111;
                IMM_CNTRL   = 3'b001;
                PC_E        = 1'b0;     // Trava o PC
                E_REGO      = 1'b0;
                REG_WE15    = 1'b0;
                ULAOUTSEL   = 1'b0;
                START_COUNT = 1'b0;
                REG_DST     = 1'b0;
            end else begin
                // CICLO 2: Grava na Memória
                REG_SRC     = 2'b11;
                PC_SRC      = 2'b01;
                REG_WE      = 1'b0;
                MEM_WE      = 1'b1;
                MEM_REG     = 2'b01;
                ALU_SRC     = 1'b1;
                ALU_CNTRL   = 3'b000;
                IMM_CNTRL   = 3'b001;
                PC_E        = 1'b1;     // Destrava o PC
                E_REGO      = 1'b0;
                REG_WE15    = 1'b0;
                ULAOUTSEL   = 1'b1;
                START_COUNT = 1'b0;
                REG_DST     = 1'b0;
            end
        end

        // --- INSTRUÇÃO LDRR (Opcode 29) ---
        else if (Opcode == 8'b00011101) begin
            if (state_2cycles == 1'b0) begin
                // CICLO 1: Captura RD (índice alvo) em reg_temp
                REG_SRC     = 2'b01;
                PC_SRC      = 2'b01;
                REG_WE      = 1'b0;
                MEM_WE      = 1'b0;
                MEM_REG     = 2'b00;
                ALU_SRC     = 1'b0;
                ALU_CNTRL   = 3'b111;
                IMM_CNTRL   = 3'b001;
                PC_E        = 1'b0;     // Trava o PC
                E_REGO      = 1'b0;
                REG_WE15    = 1'b0;
                ULAOUTSEL   = 1'b0;
                START_COUNT = 1'b0;
                REG_DST     = 1'b0;
            end else begin
                // CICLO 2: Lê da Memória e grava em R[reg_temp]
                REG_SRC     = 2'b01;
                PC_SRC      = 2'b01;
                REG_WE      = 1'b1;     // Habilita escrita no banco
                MEM_WE      = 1'b0;
                MEM_REG     = 2'b00;     // Dado vem da memória de dados
                ALU_SRC     = 1'b1;     // ULA recebe Imediato
                ALU_CNTRL   = 3'b000;   // Soma (RN + IMM)
                IMM_CNTRL   = 3'b001;
                PC_E        = 1'b1;     // Destrava o PC
                E_REGO      = 1'b0;
                REG_WE15    = 1'b0;
                ULAOUTSEL   = 1'b1;
                START_COUNT = 1'b0;
                REG_DST     = 1'b1;     // Destino = reg_temp
            end
        end
    end

endmodule