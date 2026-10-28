module ULA(SrcA, SrcB, aluResult, aluControl);
    input [31:0] SrcA;
    input [31:0] SrcB;
    input [2:0] aluControl;
    output [31:0] aluResult;
    reg [31:0] res;
    
    always @ (*)
    begin
        case(aluControl)
            3'd0: res = SrcA + SrcB;      // soma
            3'd1: res = SrcA - SrcB;      // subtrai
            3'd2: res = SrcA / SrcB;      // div
            3'd3: res = SrcA * SrcB;      // mult
            3'd4: res = SrcA ^ SrcB;      // XOR
            3'd5: res = ~SrcA;            // NOT
            3'd6: begin                    // cmp
                if (SrcA > SrcB)
                    res = 32'd0;          // maior
                else if (SrcA == SrcB)
                    res = 32'd1;          // igual
                else
                    res = 32'd2;          // menor (covers SrcA < SrcB)
            end
            default: res = SrcB;          // aluControl == 3'd7
        endcase
    end
    
    assign aluResult = res;
endmodule