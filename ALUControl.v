// ALU Control
module ALUControl(
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output [3:0] ALUControl
);
    reg [3:0] ALUControl_reg;
    
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl_reg = 4'b0010; // add (for loads/stores)
            2'b01: ALUControl_reg = 4'b0110; // subtract (for branches)
            2'b10: begin // R-type and I-type operations
                case (funct3)
                    3'b000: ALUControl_reg = (funct7[5] ? 4'b0110 : 4'b0010); // sub/add
                    3'b001: ALUControl_reg = 4'b0101; // sll
                    3'b010: ALUControl_reg = 4'b0111; // slt
                    3'b100: ALUControl_reg = 4'b0100; // xor
                    3'b101: ALUControl_reg = (funct7[5] ? 4'b1101 : 4'b0101); // sra/srl
                    3'b110: ALUControl_reg = 4'b0001; // or
                    3'b111: ALUControl_reg = 4'b0000; // and
                    default: ALUControl_reg = 4'bxxxx;
                endcase
            end
            default: ALUControl_reg = 4'bxxxx;
        endcase
    end
    
    assign ALUControl = ALUControl_reg;
endmodule