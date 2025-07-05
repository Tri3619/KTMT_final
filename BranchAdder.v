module BranchAdder (
    input [31:0] PC_in,       // Đầu vào 32 bit, giá trị của Program Counter (PC) hiện tại
    input [31:0] imm_ext,     // Đầu vào 32 bit, giá trị tức thì (immediate) đã được mở rộng dấu
    output [31:0] PC_branch   // Đầu ra 32 bit, địa chỉ nhánh (branch address) được tính toán
);
    // Tính toán địa chỉ nhánh bằng cách cộng PC hiện tại với giá trị tức thì đã mở rộng
    assign PC_branch = PC_in + imm_ext;
endmodule