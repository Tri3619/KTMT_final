module ControlUnit (
    input [6:0] op,
    output RegWrite, ALUSrc, ALUSrc_pc, MemWrite, MemRead, Branch, Jump,
    output [1:0] ALUOp,
    output [1:0] ResultSrc,
    output reg [2:0] imm_sel
);
    assign RegWrite = (op == 7'b0000011 || op == 7'b0110011 || op == 7'b0010011 || 
                       op == 7'b0110111 || op == 7'b0010111 || op == 7'b1101111 || 
                       op == 7'b1100111) ? 1'b1 : 1'b0;
    assign ALUSrc = (op == 7'b0000011 || op == 7'b0100011 || op == 7'b0010011 || 
                     op == 7'b1100111 || op == 7'b1101111 || op == 7'b1100011) ? 1'b1 : 1'b0;
    assign ALUSrc_pc = (op == 7'b1100011 || op == 7'b1101111 || op == 7'b0010111) ? 1'b1 : 1'b0; // Thêm AUIPC
    assign MemWrite = (op == 7'b0100011) ? 1'b1 : 1'b0;
    assign MemRead = (op == 7'b0000011) ? 1'b1 : 1'b0;
    assign ResultSrc = (op == 7'b0000011) ? 2'b01 : // Load
                       (op == 7'b1101111 || op == 7'b1100111) ? 2'b10 : // JAL, JALR
                       2'b00; // ALU
    assign Branch = (op == 7'b1100011) ? 1'b1 : 1'b0;
    assign Jump = (op == 7'b1101111 || op == 7'b1100111) ? 1'b1 : 1'b0;
    assign ALUOp = (op == 7'b0110011 || op == 7'b0010011) ? 2'b10 : 
                   (op == 7'b1100011) ? 2'b01 : 
                   2'b00; // JAL, JALR, AUIPC dùng ADD

    always @(*) begin
        case (op)
            7'b0010011, 7'b0000011, 7'b1100111: imm_sel = 3'b001; // I-type, LOAD, JALR
            7'b0100011: imm_sel = 3'b010; // S-type
            7'b1100011: imm_sel = 3'b011; // B-type
            7'b0110111, 7'b0010111: imm_sel = 3'b100; // U-type (LUI, AUIPC)
            7'b1101111: imm_sel = 3'b101; // J-type
            default: imm_sel = 3'b000;
        endcase
    end
endmodule