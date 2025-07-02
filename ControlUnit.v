// Control Unit
module ControlUnit(
    input  [6:0] opcode,
    output reg       RegWrite,
    output reg       ALUSrc,
    output reg       MemWrite,
    output reg       MemtoReg,
    output reg       Branch,
    output reg       Jump,
    output reg [1:0] ALUOp
);
    always @(*) begin
        case (opcode)
            // R-type
            7'b0110011: {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp} = 
                         {1'b1,    1'b0,   1'b0,     1'b0,      1'b0,   1'b0, 2'b10};
            
            // I-type (ALU)
            7'b0010011: {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp} = 
                         {1'b1,    1'b1,   1'b0,     1'b0,      1'b0,   1'b0, 2'b10};
            
            // I-type (Load)
            7'b0000011: {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp} = 
                         {1'b1,    1'b1,   1'b0,     1'b1,      1'b0,   1'b0, 2'b00};
            
            // S-type (Store)
            7'b0100011: {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp} = 
                         {1'b0,    1'b1,   1'b1,     1'bx,      1'b0,   1'b0, 2'b00};
            
            // B-type (Branch)
            7'b1100011: {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp} = 
                         {1'b0,    1'b0,   1'b0,     1'bx,      1'b1,   1'b0, 2'b01};
            
            // J-type (JAL)
            7'b1101111: {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp} = 
                         {1'b1,    1'bx,   1'b0,     1'b0,      1'b0,   1'b1, 2'bxx};
            
            // J-type (JALR)
            7'b1100111: {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp} = 
                         {1'b1,    1'b1,   1'b0,     1'b0,      1'b0,   1'b1, 2'b00};
            
            // ECALL/EBREAK
            7'b1110011: {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp} = 
                         {1'b0,    1'b0,   1'b0,     1'bx,      1'b0,   1'b0, 2'bxx};
            
            default:    {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp} = 
                         {1'bx,    1'bx,   1'bx,     1'bx,      1'bx,   1'bx, 2'bxx};
        endcase
    end
endmodule
