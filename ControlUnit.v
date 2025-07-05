module ControlUnit (
    input [6:0] op,            // Đầu vào 7 bit, mã opcode từ lệnh RISC-V, xác định loại lệnh
    input [2:0] funct3,        // Đầu vào 3 bit, trường funct3 từ lệnh RISC-V, xác định chức năng cụ thể
    input [11:0] imm,          // Đầu vào 12 bit, trường immediate của lệnh, dùng cho lệnh dừng (Halt)
    output RegWrite,           // Tín hiệu điều khiển (1 bit): Cho phép ghi vào thanh ghi đích
    output ALUSrc,             // Tín hiệu điều khiển (1 bit): Chọn toán hạng thứ hai của ALU (thanh ghi hoặc immediate)
    output ALUSrc_pc,          // Tín hiệu điều khiển (1 bit): Chọn toán hạng thứ nhất của ALU là PC thay vì thanh ghi
    output MemWrite,           // Tín hiệu điều khiển (1 bit): Cho phép ghi dữ liệu vào bộ nhớ
    output MemRead,            // Tín hiệu điều khiển (1 bit): Cho phép đọc dữ liệu từ bộ nhớ
    output Branch,             // Tín hiệu điều khiển (1 bit): Kích hoạt lệnh nhánh có điều kiện
    output Jump,               // Tín hiệu điều khiển (1 bit): Kích hoạt lệnh nhảy (JAL, JALR)
    output Halt,               // Tín hiệu điều khiển (1 bit): Dừng thực thi chương trình
    output [1:0] ALUOp,        // Tín hiệu điều khiển (2 bit): Xác định loại phép toán ALU
    output [1:0] ResultSrc,    // Tín hiệu điều khiển (2 bit): Chọn nguồn kết quả ghi vào thanh ghi
    output reg [2:0] imm_sel   // Tín hiệu điều khiển (3 bit): Chọn loại immediate mở rộng
);

    // RegWrite: Cho phép ghi vào thanh ghi đích
    // Kích hoạt cho các lệnh LOAD, R-type, I-type, LUI, AUIPC, JAL, JALR
    assign RegWrite = (op == 7'b0000011 || op == 7'b0110011 || op == 7'b0010011 || 
                      op == 7'b0110111 || op == 7'b0010111 || op == 7'b1101111 || 
                      op == 7'b1100111) ? 1'b1 : 1'b0;

    // ALUSrc: Chọn toán hạng thứ hai của ALU
    // = 1: Chọn immediate (cho LOAD, STORE, I-type, JALR, JAL, BRANCH)
    // = 0: Chọn thanh ghi rs2 (cho R-type)
    assign ALUSrc = (op == 7'b0000011 || op == 7'b0100011 || op == 7'b0010011 || 
                    op == 7'b1100111 || op == 7'b1101111 || op == 7'b1100011) ? 1'b1 : 1'b0;

    // ALUSrc_pc: Chọn toán hạng thứ nhất của ALU là PC
    // Kích hoạt cho BRANCH, JAL, AUIPC
    assign ALUSrc_pc = (op == 7'b1100011 || op == 7'b1101111 || op == 7'b0010111) ? 1'b1 : 1'b0;

    // MemWrite: Cho phép ghi vào bộ nhớ
    // Kích hoạt cho lệnh STORE
    assign MemWrite = (op == 7'b0100011) ? 1'b1 : 1'b0;

    // MemRead: Cho phép đọc từ bộ nhớ
    // Kích hoạt cho lệnh LOAD
    assign MemRead = (op == 7'b0000011) ? 1'b1 : 1'b0;

    // ResultSrc: Chọn nguồn dữ liệu ghi vào thanh ghi đích
    // 01: Dữ liệu từ bộ nhớ (LOAD)
    // 10: PC + 4 (JAL, JALR)
    // 00: Kết quả từ ALU (mặc định)
    assign ResultSrc = (op == 7'b0000011) ? 2'b01 : 
                      (op == 7'b1101111 || op == 7'b1100111) ? 2'b10 : 
                      2'b00;

    // Branch: Kích hoạt lệnh nhánh có điều kiện
    // Kích hoạt cho lệnh BRANCH
    assign Branch = (op == 7'b1100011) ? 1'b1 : 1'b0;

    // Jump: Kích hoạt lệnh nhảy
    // Kích hoạt cho lệnh JAL, JALR
    assign Jump = (op == 7'b1101111 || op == 7'b1100111) ? 1'b1 : 1'b0;

    // ALUOp: Xác định loại phép toán ALU
    // 10: R-type hoặc I-type (phép toán phụ thuộc vào funct3, funct7)
    // 01: BRANCH (phép trừ)
    // 00: LOAD, STORE (phép cộng)
    assign ALUOp = (op == 7'b0110011 || op == 7'b0010011) ? 2'b10 : 
                  (op == 7'b1100011) ? 2'b01 : 
                  2'b00;

    // Halt: Dừng thực thi chương trình
    // Kích hoạt khi opcode = 1110011 (SYSTEM), funct3 = 000, và imm = 000 hoặc 001
    assign Halt = (op == 7'b1110011 && funct3 == 3'b000 && (imm[11:0] == 12'h000 || imm[11:0] == 12'h001)) ? 1'b1 : 1'b0;

    // Khối always để chọn loại immediate mở rộng (imm_sel)
    always @(*) begin
        case (op)
            7'b0010011, 7'b0000011, 7'b1100111: imm_sel = 3'b001; // I-type: LOAD, I-type, JALR
            7'b0100011: imm_sel = 3'b010;                         // S-type: STORE
            7'b1100011: imm_sel = 3'b011;                         // B-type: BRANCH
            7'b0110111, 7'b0010111: imm_sel = 3'b100;             // U-type: LUI, AUIPC
            7'b1101111: imm_sel = 3'b101;                         // J-type: JAL
            default: imm_sel = 3'b000;                            // Mặc định: Không chọn immediate
        endcase
    end
endmodule