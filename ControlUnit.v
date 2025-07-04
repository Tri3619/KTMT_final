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
        // Default values
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        ALUSrc = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        ALUControl = 3'b000;
        
        case (opcode)
            // Load (I-type)
            7'b0000011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                ResultSrc = 2'b01;
                ALUControl = 3'b000; // ADD
            end
            
            // Store (S-type)
            7'b0100011: begin
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUControl = 3'b000; // ADD
            end
            
            // R-type
            7'b0110011: begin
                RegWrite = 1'b1;
                case (funct3)
                    3'b000: ALUControl = 3'b000; // ADD
                    3'b001: ALUControl = 3'b000; // SLLI (not implemented)
                    3'b010: ALUControl = 3'b000; // SLT (not implemented)
                    3'b100: ALUControl = 3'b010; // XOR (not implemented)
                    3'b110: ALUControl = 3'b011; // OR
                    3'b111: ALUControl = 3'b010; // AND
                    default: ALUControl = 3'b000;
                endcase
            end
            
            // I-type ALU
            7'b0010011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUControl = 3'b000; // ADDI
            end
            
            // Branch (B-type)
            7'b1100011: begin
                Branch = 1'b1;
                ALUControl = 3'b001; // SUB
            end
            
            // JAL (J-type)
            7'b1101111: begin
                RegWrite = 1'b1;
                Jump = 1'b1;
                ResultSrc = 2'b10; // PC+4
                ALUControl = 3'b000;
            end
            
            // JALR (I-type)
            7'b1100111: begin
                RegWrite = 1'b1;
                Jump = 1'b1;
                ALUSrc = 1'b1;
                ResultSrc = 2'b10; // PC+4
                ALUControl = 3'b000;
            end
            
            // LUI (U-type)
            7'b0110111: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                ResultSrc = 2'b00; // ALUResult
                ALUControl = 3'b100; // Pass Imm
            end
            
            // AUIPC (U-type)
            7'b0010111: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUControl = 3'b000; // ADD (PC + Imm)
            end
            
            // ECALL/EBREAK
            7'b1110011: begin
                // System instructions - no operation
            end
            
            default: begin
                // Handle unknown instructions
            end
        endcase
    end
endmodule