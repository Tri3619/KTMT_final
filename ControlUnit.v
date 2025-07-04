module ControlUnit(
    input [6:0] opcode,
    input [2:0] funct3,
    output reg RegWrite,
    output reg MemWrite,
    output reg ALUSrc,
    output reg [1:0] ResultSrc,
    output reg Branch,
    output reg Jump,
    output reg [2:0] ALUControl
);
    always @(*) begin
        // Defaults
        {RegWrite, MemWrite, ALUSrc, Branch, Jump} = 0;
        ResultSrc = 0;
        ALUControl = 0;
        
        case (opcode)
            // Load
            7'b0000011: begin
                RegWrite = 1;
                ALUSrc = 1;
                ResultSrc = 1;
                ALUControl = 0;
            end
            
            // Store
            7'b0100011: begin
                MemWrite = 1;
                ALUSrc = 1;
                ALUControl = 0;
            end
            
            // R-type
            7'b0110011: begin
                RegWrite = 1;
                ALUControl = {1'b0, funct3};
            end
            
            // I-type
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUControl = {1'b0, funct3};
            end
            
            // Branch
            7'b1100011: begin
                Branch = 1;
                ALUControl = 3'b001; // Always SUB for branches
            end
            
            // JAL
            7'b1101111: begin
                RegWrite = 1;
                Jump = 1;
                ResultSrc = 2;
            end
            
            // JALR
            7'b1100111: begin
                RegWrite = 1;
                Jump = 1;
                ALUSrc = 1;
                ResultSrc = 2;
                ALUControl = 0;
            end
        endcase
    end
endmodule