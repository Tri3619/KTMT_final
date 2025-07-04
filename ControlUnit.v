module ControlUnit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
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
            // Load (I-type)
            7'b0000011: begin
                RegWrite = 1;
                ALUSrc = 1;
                ResultSrc = 2'b01;
                ALUControl = 3'b000; // ADD
            end
            
            // Store (S-type)
            7'b0100011: begin
                MemWrite = 1;
                ALUSrc = 1;
                ALUControl = 3'b000; // ADD
            end
            
            // R-type
            7'b0110011: begin
                RegWrite = 1;
                case ({funct7[5], funct3})
                    4'b0_000: ALUControl = 3'b000; // ADD
                    4'b1_000: ALUControl = 3'b001; // SUB
                    4'b0_111: ALUControl = 3'b010; // AND
                    4'b0_110: ALUControl = 3'b011; // OR
                    4'b0_100: ALUControl = 3'b100; // XOR
                    4'b0_001: ALUControl = 3'b101; // SLL
                    4'b0_101: ALUControl = 3'b110; // SRL
                    4'b1_101: ALUControl = 3'b111; // SRA
                    default: ALUControl = 3'b000;
                endcase
            end
            
            // I-type ALU ops
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc = 1;
                case (funct3)
                    3'b000: ALUControl = 3'b000; // ADDI
                    3'b010: ALUControl = 3'b001; // SLTI
                    3'b011: ALUControl = 3'b010; // SLTIU
                    3'b100: ALUControl = 3'b100; // XORI
                    3'b110: ALUControl = 3'b011; // ORI
                    3'b111: ALUControl = 3'b010; // ANDI
                    3'b001: ALUControl = 3'b101; // SLLI
                    3'b101: ALUControl = funct7[5] ? 3'b111 : 3'b110; // SRAI/SRLI
                endcase
            end
            
            // Branch (B-type)
            7'b1100011: begin
                Branch = 1;
                case (funct3)
                    3'b000: ALUControl = 3'b001; // BEQ (SUB)
                    3'b001: ALUControl = 3'b001; // BNE (SUB)
                    3'b100: ALUControl = 3'b001; // BLT (SUB)
                    3'b101: ALUControl = 3'b001; // BGE (SUB)
                    3'b110: ALUControl = 3'b001; // BLTU (SUB)
                    3'b111: ALUControl = 3'b001; // BGEU (SUB)
                endcase
            end
            
            // JAL (J-type)
            7'b1101111: begin
                RegWrite = 1;
                Jump = 1;
                ResultSrc = 2'b10; // PC+4
            end
            
            // JALR (I-type)
            7'b1100111: begin
                RegWrite = 1;
                Jump = 1;
                ALUSrc = 1;
                ResultSrc = 2'b10; // PC+4
                ALUControl = 3'b000; // ADD
            end
            
            // LUI (U-type)
            7'b0110111: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUControl = 3'b000; // Pass immediate
            end
            
            // AUIPC (U-type)
            7'b0010111: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUControl = 3'b000; // ADD
            end
        endcase
    end
endmodule