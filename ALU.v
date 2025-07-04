module ALU (
    input [31:0] operand1,   // First operand (rs1)
    input [31:0] operand2,   // Second operand (rs2 or immediate)
    input [3:0] ALUOp,       // ALU operation code
    output reg [31:0] result, // ALU result
    output reg zero,         // Zero flag for branch instructions
    output reg less_than     // Less than flag for slt, sltu, blt, bge, etc.
);

    always @(*) begin
        zero = 0;
        less_than = 0;
        result = 0;

        case (ALUOp)
            4'b0000: begin // add, addi, load, store, auipc, lui
                result = operand1 + operand2;
            end
            4'b0001: begin // sub
                result = operand1 - operand2;
            end
            4'b0010: begin // mul
                result = operand1 * operand2;
            end
            4'b0011: begin // and, andi
                result = operand1 & operand2;
            end
            4'b0100: begin // or, ori
                result = operand1 | operand2;
            end
            4'b0101: begin // xor, xori
                result = operand1 ^ operand2;
            end
            4'b0110: begin // sll, slli
                result = operand1 << operand2[4:0]; // Shift by lower 5 bits
            end
            4'b0111: begin // srl, srli
                result = operand1 >> operand2[4:0]; // Logical shift right
            end
            4'b1000: begin // sra, srai
                result = $signed(operand1) >>> operand2[4:0]; // Arithmetic shift right
            end
            4'b1001: begin // slt, slti
                less_than = ($signed(operand1) < $signed(operand2)) ? 1 : 0;
                result = {31'b0, less_than};
            end
            4'b1010: begin // sltu, sltiu
                less_than = (operand1 < operand2) ? 1 : 0;
                result = {31'b0, less_than};
            end
            4'b1011: begin // beq
                zero = (operand1 == operand2) ? 1 : 0;
            end
            4'b1100: begin // bne
                zero = (operand1 != operand2) ? 1 : 0;
            end
            4'b1101: begin // blt
                less_than = ($signed(operand1) < $signed(operand2)) ? 1 : 0;
                zero = less_than;
            end
            4'b1110: begin // bge
                less_than = ($signed(operand1) >= $signed(operand2)) ? 1 : 0;
                zero = less_than;
            end
            4'b1111: begin // bgeu
                less_than = (operand1 >= operand2) ? 1 : 0;
                zero = less_than;
            end
            default: begin
                result = 0;
                zero = 0;
                less_than = 0;
            end
        endcase
    end
endmodule