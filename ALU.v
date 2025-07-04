module ALU (
    input [31:0] a,
    input [31:0] b,
    input [2:0] alu_control,
    output reg [31:0] result,
    output zero
);
    wire [31:0] b_actual;
    wire [4:0] shamt = b[4:0];
    
    assign b_actual = (alu_control == 3'b111) ? b : a; // For LUI
    
    always @(*) begin
        case (alu_control)
            3'b000: result = a + b_actual;       // ADD
            3'b001: result = a << shamt;         // SLL/SLLI
            3'b010: result = ($signed(a) < $signed(b_actual)) ? 1 : 0; // SLT/SLTI
            3'b011: result = (a < b_actual) ? 1 : 0; // SLTU/SLTIU
            3'b100: result = a ^ b_actual;       // XOR/XORI
            3'b101: result = a >> shamt;         // SRL/SRLI
            3'b110: result = a | b_actual;       // OR/ORI
            3'b111: result = b_actual;           // AND/ANDI/LUI
            default: result = a + b_actual;
        endcase
    end
    
    assign zero = (result == 0);
endmodule