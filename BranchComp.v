module BranchComp (
    input [6:0] op,               // Đầu vào 7 bit, mã opcode từ lệnh RISC-V, xác định loại lệnh
    input [2:0] funct3,           // Đầu vào 3 bit, trường funct3 từ lệnh RISC-V, xác định loại nhánh cụ thể
    input [31:0] rs1_data,        // Đầu vào 32 bit, dữ liệu từ thanh ghi nguồn rs1
    input [31:0] rs2_data,        // Đầu vào 32 bit, dữ liệu từ thanh ghi nguồn rs2
    output reg branch_taken       // Đầu ra 1 bit, tín hiệu quyết định nhánh có được thực hiện hay không
);
    // Khối always thực hiện so sánh và quyết định nhánh
    always @(*) begin
        branch_taken = 1'b0;      // Mặc định: không thực hiện nhánh
        if (op == 7'b1100011) begin // Kiểm tra opcode, chỉ xử lý khi là lệnh nhánh (opcode = 1100011)
            case (funct3)
                3'b000: branch_taken = (rs1_data == rs2_data); // BEQ: Nhánh nếu rs1 bằng rs2
                3'b001: branch_taken = (rs1_data != rs2_data); // BNE: Nhánh nếu rs1 khác rs2
                3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data)); // BLT: Nhánh nếu rs1 < rs2 (có dấu)
                3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data)); // BGE: Nhánh nếu rs1 >= rs2 (có dấu)
                3'b110: branch_taken = (rs1_data < rs2_data); // BLTU: Nhánh nếu rs1 < rs2 (không dấu)
                3'b111: branch_taken = (rs1_data >= rs2_data); // BGEU: Nhánh nếu rs1 >= rs2 (không dấu)
                default: branch_taken = 1'b0; // Trường hợp funct3 không hợp lệ: không nhánh
            endcase
        end
    end
endmodule