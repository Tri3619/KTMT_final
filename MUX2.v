module MUX2 (
    input [31:0] input0,      // Đầu vào 32 bit: Dữ liệu đầu tiên (lựa chọn khi select = 0)
    input [31:0] input1,      // Đầu vào 32 bit: Dữ liệu thứ hai (lựa chọn khi select = 1)
    input select,             // Đầu vào 1 bit: Tín hiệu điều khiển chọn đầu vào
    output [31:0] out         // Đầu ra 32 bit: Kết quả được chọn từ input0 hoặc input1
);
    // Gán đầu ra dựa trên tín hiệu select
    // Nếu select = 1, out = input1; nếu select = 0, out = input0
    assign out = select ? input1 : input0;
endmodule