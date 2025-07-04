<<<<<<< HEAD
module ALU (
    input [31:0] a,
    input [31:0] b,
    input [2:0] alu_control,
    output reg [31:0] result
);
    always @(*) begin
        case (alu_control)
            3'b000: result = a + b;   // ADD
            3'b001: result = a - b;   // SUB
            3'b010: result = a & b;   // AND
            3'b011: result = a | b;   // OR
            default: result = a + b;  // Default ADD
=======
module ALU(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  ALUControl,
    output reg [31:0] result,  // Khai báo output là reg
    output reg        zero      // Khai báo output là reg
);
    always @(*) begin
        case (ALUControl)
            4'b0000: result = a & b;      // AND
            4'b0001: result = a | b;      // OR
            4'b0010: result = a + b;      // ADD
            4'b0100: result = a ^ b;      // XOR
            4'b0101: result = a << b[4:0]; // SLL
            4'b0110: result = a - b;      // SUB
            4'b0111: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT
            4'b1101: result = $signed(a) >>> b[4:0]; // SRA
            default: result = 32'hxxxxxxxx;
>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
        endcase
        
        zero = (result == 0);
    end
<<<<<<< HEAD
endmodule
=======
endmodule
>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
