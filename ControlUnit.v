module ControlUnit (
    input [6:0] opcode,        // 7-bit opcode from instruction
    input [2:0] funct3,        // 3-bit funct3 from instruction
    input [6:0] funct7,        // 7-bit funct7 for R-type instructions
    output reg RegWrite,       // Enable write to register file
    output reg ALUSrc,         // Select ALU operand (0: rs2, 1: immediate)
    output reg [3:0] ALUOp,    // ALU operation code
    output reg MemRead,        // Enable data memory read
    output reg MemWrite,       // Enable data memory write
    output reg MemtoReg,       // Select data to write to register (0: ALU, 1: Memory)
    output reg Branch,         // Enable branch
    output reg Jump,           // Enable jump (jal/jalr)
    output reg [1:0] PCSrc,    // PC source (0: PC+4, 1: Branch, 2: jal, 3: jalr)
    output reg [1:0] ImmSel    // Immediate type selector (0: I-type, 1: S-type, 2: B-type, 3: U-type/J-type)
);

    always @(*) begin
        // Default values to avoid latches
        RegWrite = 0;
        ALUSrc = 0;
        ALUOp = 4'b0000;
        MemRead = 0;
        MemWrite = 0;
        MemtoReg = 0;
        Branch = 0;
        Jump = 0;
        PCSrc = 2'b00; // Default: PC = PC + 4
        ImmSel = 2'b00; // Default: I-type immediate

        case (opcode)
            // R-type instructions (opcode: 0110011)
            7'b0110011: begin
                RegWrite = 1;
                ALUSrc = 0;
                MemtoReg = 0;
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            ALUOp = 4'b0000; // add
                        else if (funct7 == 7'b0100000)
                            ALUOp = 4'b0001; // sub
                        else if (funct7 == 7'b0000001)
                            ALUOp = 4'b0010; // mul (part of M extension)
                    end
                    3'b111: ALUOp = 4'b0011; // and
                    3'b110: ALUOp = 4'b0100; // or
                    3'b100: ALUOp = 4'b0101; // xor
                    3'b001: ALUOp = 4'b0110; // sll
                    3'b101: begin
                        if (funct7 == 7'b0000000)
                            ALUOp = 4'b0111; // srl
                        else if (funct7 == 7'b0100000)
                            ALUOp = 4'b1000; // sra
                    end
                    3'b010: ALUOp = 4'b1001; // slt
                    3'b011: ALUOp = 4'b1010; // sltu
                    default: ALUOp = 4'b0000; // Default to add for safety
                endcase
            end

            // I-type instructions (opcode: 0010011 for arithmetic/logical, 0000011 for loads, 1100111 for jalr)
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc = 1;
                MemtoReg = 0;
                ImmSel = 2'b00; // I-type immediate
                case (funct3)
                    3'b000: ALUOp = 4'b0000; // addi
                    3'b111: ALUOp = 4'b0011; // andi
                    3'b110: ALUOp = 4'b0100; // ori
                    3'b100: ALUOp = 4'b0101; // xori
                    3'b001: ALUOp = 4'b0110; // slli
                    3'b101: begin
                        if (funct7 == 7'b0000000)
                            ALUOp = 4'b0111; // srli
                        else if (funct7 == 7'b0100000)
                            ALUOp = 4'b1000; // srai
                    end
                    3'b010: ALUOp = 4'b1001; // slti
                    3'b011: ALUOp = 4'b1010; // sltiu
                    default: ALUOp = 4'b0000; // Default to add for safety
                endcase
            end

            // Load instructions (opcode: 0000011)
            7'b0000011: begin
                RegWrite = 1;
                ALUSrc = 1;
                MemRead = 1;
                MemtoReg = 1;
                ImmSel = 2'b00; // I-type immediate
                case (funct3)
                    3'b000: ALUOp = 4'b0000; // lb (load byte, sign-extended)
                    3'b100: ALUOp = 4'b0000; // lbu (load byte, zero-extended)
                    3'b001: ALUOp = 4'b0000; // lh (load halfword, sign-extended)
                    3'b101: ALUOp = 4'b0000; // lhu (load halfword, zero-extended)
                    3'b010: ALUOp = 4'b0000; // lw (load word)
                    default: ALUOp = 4'b0000; // Default to add for safety
                endcase
            end

            // Store instructions (opcode: 0100011)
            7'b0100011: begin
                ALUSrc = 1;
                MemWrite = 1;
                ImmSel = 2'b01; // S-type immediate
                case (funct3)
                    3'b000: ALUOp = 4'b0000; // sb
                    3'b001: ALUOp = 4'b0000; // sh
                    3'b010: ALUOp = 4'b0000; // sw
                    default: ALUOp = 4'b0000; // Default to add for safety
                endcase
            end

            // Branch instructions (opcode: 1100011)
            7'b1100011: begin
                Branch = 1;
                ALUSrc = 0;
                ImmSel = 2'b10; // B-type immediate
                case (funct3)
                    3'b000: ALUOp = 4'b1011; // beq
                    3'b001: ALUOp = 4'b1100; // bne
                    3'b100: ALUOp = 4'b1101; // blt
                    3'b101: ALUOp = 4'b1110; // bge
                    3'b110: ALUOp = 4'b1111; // bltu
                    3'b111: ALUOp = 4'b0000; // bgeu
                    default: ALUOp = 4'b0000; // Default to add for safety
                endcase
                PCSrc = 2'b01; // Branch
            end

            // Jump instructions (jal: 1101111, jalr: 1100111)
            7'b1101111: begin // jal
                RegWrite = 1;
                Jump = 1;
                ImmSel = 2'b11; // J-type immediate
                PCSrc = 2'b10; // jal
                ALUOp = 4'b0000; // No ALU operation needed
            end
            7'b1100111: begin // jalr
                RegWrite = 1;
                ALUSrc = 1;
                Jump = 1;
                ImmSel = 2'b00; // I-type immediate
                PCSrc = 2'b11; // jalr
                ALUOp = 4'b0000; // No ALU operation needed
            end

            // U-type instructions (auipc: 0010111, lui: 0110111)
            7'b0010111: begin // auipc
                RegWrite = 1;
                ImmSel = 2'b11; // U-type immediate
                ALUOp = 4'b0000; // Add PC + imm
                MemtoReg = 0;
            end
            7'b0110111: begin // lui
                RegWrite = 1;
                ImmSel = 2'b11; // U-type immediate
                ALUOp = 4'b0000; // Pass imm directly
                MemtoReg = 0;
            end

            // System instructions (ebreak, ecall: 1110011)
            7'b1110011: begin
                case (funct3)
                    3'b000: begin
                        // ebreak and ecall: No register write, no ALU operation
                        RegWrite = 0;
                        ALUOp = 4'b0000;
                    end
                    default: ALUOp = 4'b0000; // Default to add for safety
                endcase
            end

            default: begin
                // Default case for unrecognized opcodes
                RegWrite = 0;
                ALUSrc = 0;
                ALUOp = 4'b0000;
                MemRead = 0;
                MemWrite = 0;
                MemtoReg = 0;
                Branch = 0;
                Jump = 0;
                PCSrc = 2'b00;
                ImmSel = 2'b00;
            end
        endcase
    end
endmodule