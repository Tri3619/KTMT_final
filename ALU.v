// ALU
module ALU(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  ALUControl,
    output [31:0] result,
    output        zero
);
    reg [31:0] result_reg;
    
    always @(*) begin
        case (ALUControl)
            4'b0000: result_reg = a & b;      // AND
            4'b0001: result_reg = a | b;      // OR
            4'b0010: result_reg = a + b;      // ADD
            4'b0100: result_reg = a ^ b;      // XOR
            4'b0101: result_reg = a << b[4:0]; // SLL
            4'b0110: result_reg = a - b;      // SUB
            4'b0111: result_reg = ($signed(a) < $signed(b)) ? 1 : 0; // SLT
            4'b1101: result_reg = $signed(a) >>> b[4:0]; // SRA
            default: result_reg = 32'hxxxxxxxx;
        endcase
    end
    
    assign result = result_reg;
    assign zero = (result_reg == 0);
endmodule