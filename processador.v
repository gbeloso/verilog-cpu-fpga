module processador(
    // Entradas e Saídas
    input clock, 
    input reset_btn,
    input i_rx,
    output o_tx_done,
    output o_tx,
    output [3:0] o_sel_disp,
    output [7:0] o_disp
);

    wire clk_reduced;
    wire [31:0] pc_out_bus;
	 
    wire [31:0] pc_in_bus;
    wire [31:0] mux_data_memory_out_bus;
    wire [31:0] alu_srcB_bus;
    wire [31:0] alu_out_displaced_bus;
    wire [5:0] mux_rd1_bus;
    wire [5:0] mux_rd2_bus;

    // --- NOVOS BARRAMENTOS / MUX DE DESTINO ---
    reg [5:0] reg_temp;
    wire reg_dst_bus;
    wire [5:0] mux_a3_bus;
    // -------------------------------------------

    wire [1:0] mux_pc_bus;
    wire [31:0] mem_instr_out_bus;
    wire [31:0] mem_data_out_bus;
    wire [31:0] rd1_out_bus;
    wire [31:0] rd2_out_bus;
    wire [31:0] r57_out_bus;
    wire [31:0] r56_out_bus;
    wire [31:0] imm_out_bus;
    wire [31:0] overflow_inst_bus;
    wire done_sm_rx_bus;
    wire done_sm_tx_bus;
    wire inst_count_overflow_bus;
    wire [1:0] reg_src_bus;
    wire [31:0] pc_plus_one_bus;
    assign pc_plus_one_bus = pc_out_bus + 32'd1;
    wire [31:0] alu_out_sum_bus;
    assign alu_out_sum_bus = r57_out_bus + alu_out_bus;
    wire [31:0] alu_out_bus;
    wire pc_enable_bus;
    wire reg_enable_bus;
    wire mem_data_enable_bus;
    wire [1:0] mux_mem_data_bus;
    wire alu_src_bus;
    wire [2:0] alu_cntrl_bus;
    wire [2:0] imm_cntrl_bus;
    wire out_cntrl_reg_bus;
    wire reg_jal_we_bus;
    wire alu_out_sel_bus;
    wire start_count_bus;
    wire rx_done_bus;
    wire [7:0] rx_bus;
    wire tx_actiuve_bus;
    wire [7:0] usm_data_bus;
    wire uart_send_bus;

    // --- Instanciação dos Módulos ---

    freq_divider divider (
		.divIn(clock), 
		.divOut(clk_reduced)
	);

    PC program_counter (
        .CLK(clk_reduced), .PC_I(pc_in_bus), .PC_O(pc_out_bus),
        .PC_E(pc_enable_bus), .PC_RESET(~reset_btn)
    );

    Mem_Instr #(.DATA_WIDTH(32), .ADDR_WIDTH(11)) instruction_mem (
        .addr(pc_out_bus), .clk(clock), .q(mem_instr_out_bus)
    );

    Unidade_controle u_controle (
        .clk(clk_reduced),
        .rst(~reset_btn),
        .Opcode(mem_instr_out_bus[31:24]), .enter(done_sm_rx_bus),
        .flags(rd1_out_bus[1:0]), .o_ready(done_sm_tx_bus),
        .clk_overflow(inst_count_overflow_bus), .REG_SRC(reg_src_bus),
        .PC_SRC(mux_pc_bus), .REG_WE(reg_enable_bus),
        .MEM_WE(mem_data_enable_bus), .MEM_REG(mux_mem_data_bus),
        .ALU_SRC(alu_src_bus), .ALU_CNTRL(alu_cntrl_bus),
        .IMM_CNTRL(imm_cntrl_bus), .PC_E(pc_enable_bus),
        .E_REGO(out_cntrl_reg_bus), .REG_WE15(reg_jal_we_bus),
        .ULAOUTSEL(alu_out_sel_bus), .START_COUNT(start_count_bus),
        .REG_DST(reg_dst_bus) // <--- CONECTADO
    );

    rx_ready_sm sm_rx (.clk(clock), .op(mem_instr_out_bus[31:24]), .rx_done(rx_done_bus), .done(done_sm_rx_bus));
    uart_rx #(.CLKS_PER_BIT(5208)) rx_module (.i_Clock(clock), .i_Rx_Serial(i_rx), .o_Rx_DV(rx_done_bus), .o_Rx_Byte(rx_bus));

    Reg_File r_file (
        .CLK(clk_reduced), .A1(mux_rd1_bus), .A2(mux_rd2_bus),
        .A3(mux_a3_bus), // <--- CONECTADO AO MUX A3 (Permite gravar em R[reg_temp])
        .WD3(mux_data_memory_out_bus),
        .WE3(reg_enable_bus), .WE63(reg_jal_we_bus),
        .R63(pc_plus_one_bus), .RD1(rd1_out_bus),
        .RD2(rd2_out_bus), .R57(r57_out_bus), .R56(r56_out_bus)
    );

    extensor ext (.EXT_I(mem_instr_out_bus[23:0]), .SW_I(rx_bus), .EXT_SEL(imm_cntrl_bus), .EXT_O(imm_out_bus));
    display_controller dp (.clk(clock), .reset_n(~reset_btn), .number(pc_out_bus[13:0]), .segments(o_disp), .digit_sel(o_sel_disp));
    ULA ALU (.SrcA(rd1_out_bus), .SrcB(alu_srcB_bus), .aluControl(alu_cntrl_bus), .aluResult(alu_out_bus));

    Mem_Data #(.DATA_WIDTH(32), .ADDR_WIDTH(11)) data_memory (
        .data(rd2_out_bus),
        .addr(alu_out_displaced_bus),
        .we(mem_data_enable_bus), .clk(clk_reduced), .q(mem_data_out_bus)
    );
	 
	instruction_counter inst_c(
		.clk(clk_reduced), .rst(~reset_btn), .start(start_count_bus),
		.target_count(imm_out_bus), .instruction(pc_out_bus),
		.opcode(mem_instr_out_bus[31:24]), .overflow_flag(inst_count_overflow_bus),
		.overflow_instruction(overflow_inst_bus)
	);

	uart_state_machine usm (
		.clk(clock), .reset(~reset_btn), .data_in(alu_out_bus),
		.start(out_cntrl_reg_bus), .uart_ready(~tx_actiuve_bus),
		.uart_data(usm_data_bus), .uart_send(uart_send_bus), .done(done_sm_tx_bus)
	);
	
	uart_tx #(.CLKS_PER_BIT(5208)) tx (
		.i_Clock(clock), .i_Tx_DV(uart_send_bus), .i_Tx_Byte(usm_data_bus), 
		.o_Tx_Active(tx_actiuve_bus), .o_Tx_Serial(o_tx), .o_Tx_Done(o_tx_done)
	);

    // --- CAPTURA DO REGISTRADOR TEMPORÁRIO (Atende STRR [28] e LDRR [29]) ---
    always @(posedge clk_reduced or posedge ~reset_btn) begin
        if (~reset_btn) begin
            reg_temp <= 6'd0;
        end else if (mem_instr_out_bus[31:24] == 8'b00011100 || mem_instr_out_bus[31:24] == 8'b00011101) begin
            reg_temp <= rd2_out_bus[5:0]; // Salva o índice contido em RD (Ciclo 1)
        end
    end

    // --- Assigns / Multiplexadores ---

    // Mux PC
    assign pc_in_bus = (mux_pc_bus == 2'b00) ? mux_data_memory_out_bus :
                       (mux_pc_bus == 2'b01) ? pc_plus_one_bus :
                       r56_out_bus;

    // Mux Endereço de Escrita A3 (Novo)
    assign mux_a3_bus = (reg_dst_bus == 1'b1) ? reg_temp : mem_instr_out_bus[17:12];

    // Mux Registrador 1
    assign mux_rd1_bus = (reg_src_bus == 2'b11) ? mem_instr_out_bus[23:18] :
                         (reg_src_bus[1] == 1'd0) ? mem_instr_out_bus[23:18] :
                         (reg_src_bus[1] == 1'd1) ? 6'b111111 :
                         6'd0;

    // Mux Registrador 2
    assign mux_rd2_bus = (reg_src_bus == 2'b11) ? reg_temp :
                         (reg_src_bus[0] == 1'd0) ? mem_instr_out_bus[5:0] :
                         (reg_src_bus[0] == 1'd1) ? mem_instr_out_bus[17:12] :
                         6'd0;

    // Mux ALU
    assign alu_srcB_bus = (alu_src_bus == 1'd0) ? rd2_out_bus :
                          (alu_src_bus == 1'd1) ? imm_out_bus :
                          32'd0;

    // Mux ALU Deslocada
    assign alu_out_displaced_bus = (alu_out_sel_bus == 1'd0) ? alu_out_bus :
                                   (alu_out_sel_bus == 1'd1) ? alu_out_sum_bus :
                                   alu_out_bus;

    // Mux MEM DATA
    assign mux_data_memory_out_bus = (mux_mem_data_bus == 2'd0) ? mem_data_out_bus :
                                     (mux_mem_data_bus == 2'd1) ? alu_out_displaced_bus :
                                     (mux_mem_data_bus == 2'd2) ? overflow_inst_bus :
                                     32'd0;

endmodule