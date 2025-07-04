module ALU (
    input [31:0] a,
    input [31:0] b,
    input [2:0] alu_control,
    output reg [31:0] result,
    output zero
);
    wire signed [31:0] a_signed = a;
    wire signed [31:0] b_signed = b;
    
    always @(*) begin
        case (alu_control)
            3'b000: result = a + b;                     // ADD
            3'b001: result = a - b;                     // SUB/BEQ
            3'b010: result = a & b;                     // AND
            3'b011: result = a | b;                     // OR
            3'b100: result = a ^ b;                     // XOR
            3'b101: result = a << b[4:0];               // SLL
            3'b110: result = a >> b[4:0];               // SRL
            3'b111: result = a_signed >>> b[4:0];       // SRA
        endcase
    end
    
    // Zero flag for BEQ/BNE
    assign zero = (result == 0);
endmodule