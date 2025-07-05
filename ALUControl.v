module ALUControl (
    input [1:0] ALUOp,         // Đầu vào 2 bit xác định loại phép toán ALU (cộng, trừ, hoặc dựa trên funct3/funct7)
    input [2:0] funct3,        // Đầu vào 3 bit, trường funct3 từ lệnh RISC-V, xác định phép toán cụ thể
    input [6:0] funct7,        // Đầu vào 7 bit, trường funct7 từ lệnh RISC-V, bổ sung thông tin cho một số phép toán
    input [6:0] op,            // Đầu vào 7 bit, mã opcode từ lệnh RISC-V, xác định loại lệnh
    output reg [3:0] ALUControl // Đầu ra 4 bit, tín hiệu điều khiển ALU để chọn phép toán
);

    // Xác định phép trừ cho lệnh R-type (opcode = 0110011, funct3 = 000, funct7[5] = 1)
    wire RtypeSub = (op == 7'b0110011 && funct3 == 3'b000 && funct7[5]) ? 1'b1 : 1'b0;
    
    // Xác định phép nhân cho lệnh R-type (opcode = 0110011, funct3 = 000, funct7 = 0000001)
    wire RtypeMul = (op == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0000001) ? 1'b1 : 1'b0;

    // Khối always thực hiện logic điều khiển dựa trên ALUOp, funct3, funct7 và op
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // ALUOp = 00: Thực hiện phép cộng (ADD)
            2'b01: ALUControl = 4'b0001; // ALUOp = 01: Thực hiện phép trừ (SUB)
            2'b10: begin                 // ALUOp = 10: Chọn phép toán dựa trên funct3 và funct7
                case (funct3)
                    3'b000: ALUControl = RtypeSub ? 4'b0001 : (RtypeMul ? 4'b1010 : 4'b0000); 
                        // funct3 = 000: Nếu RtypeSub = 1 thì trừ (SUB), nếu RtypeMul = 1 thì nhân (MUL), ngược lại cộng (ADD)
                    3'b001: ALUControl = 4'b0101; // funct3 = 001: Dịch trái logic (SLL)
                    3'b010: ALUControl = 4'b1000; // funct3 = 010: So sánh có dấu (SLT)
                    3'b011: ALUControl = 4'b1001; // funct3 = 011: So sánh không dấu (SLTU)
                    3'b100: ALUControl = 4'b0100; // funct3 = 100: Phép XOR
                    3'b101: ALUControl = funct7[5] ? 4'b0111 : 4'b0110; 
                        // funct3 = 101: Nếu funct7[5] = 1 thì dịch phải số học (SRA), ngược lại dịch phải logic (SRL)
                    3'b110: ALUControl = 4'b0011; // funct3 = 110: Phép OR
                    3'b111: ALUControl = 4'b0010; // funct3 = 111: Phép AND
                    default: ALUControl = 4'b0000; // Trường hợp mặc định: Cộng (ADD)
                endcase
            end
            default: ALUControl = 4'b0000; // Trường hợp ALUOp không hợp lệ: Cộng (ADD)
        endcase
    end
endmodule