module ControlUnit (
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
        {RegWrite, MemWrite, ALUSrc, ResultSrc, Branch, Jump} = 0;
        ALUControl = 3'b000;
        
        case (opcode)
            // Load
            7'b0000011: begin
                RegWrite = 1;
                ALUSrc = 1;
                ResultSrc = 2'b01;
                ALUControl = 3'b000;
            end
            
            // Store
            7'b0100011: begin
                MemWrite = 1;
                ALUSrc = 1;
                ALUControl = 3'b000;
            end
            
            // R-type
            7'b0110011: begin
                RegWrite = 1;
                case (funct3)
                    3'b000: ALUControl = 3'b000; // ADD/SUB
                    3'b001: ALUControl = 3'b001; // SLL
                    3'b010: ALUControl = 3'b010; // SLT
                    3'b011: ALUControl = 3'b011; // SLTU
                    3'b100: ALUControl = 3'b100; // XOR
                    3'b101: ALUControl = 3'b101; // SRL/SRA
                    3'b110: ALUControl = 3'b110; // OR
                    3'b111: ALUControl = 3'b111; // AND
                endcase
            end
            
            // I-type
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUControl = {1'b0, funct3}; // Map directly
            end
            
            // Branch
            7'b1100011: begin
                Branch = 1;
                ALUControl = {1'b0, funct3};
            end
            
            // JAL
            7'b1101111: begin
                RegWrite = 1;
                Jump = 1;
                ResultSrc = 2'b10;
            end
            
            // JALR
            7'b1100111: begin
                RegWrite = 1;
                Jump = 1;
                ALUSrc = 1;
                ResultSrc = 2'b10;
            end
            
            // LUI/AUIPC
            7'b0110111, 7'b0010111: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUControl = (opcode[5]) ? 3'b111 : 3'b000; // LUI: pass imm
            end
        endcase
    end
endmodule