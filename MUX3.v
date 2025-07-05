module MUX3 (
    input [31:0] input0,      // Đầu vào 32 bit: Dữ liệu đầu tiên (lựa chọn khi select = 00)
    input [31:0] input1,      // Đầu vào 32 bit: Dữ liệu thứ hai (lựa chọn khi select = 01)
    input [31:0] input2,      // Đầu vào 32 bit: Dữ liệu thứ ba (lựa chọn khi select = 10)
    input [1:0] select,       // Đầu vào 2 bit: Tín hiệu điều khiển chọn đầu vào
    output [31:0] out         // Đầu ra 32 bit: Kết quả được chọn từ input0, input1 hoặc input2
);
    // Gán đầu ra dựa trên tín hiệu select
    // select = 00: out = input0
    // select = 01: out = input1
    // select = 10: out = input2
    // select = 11: out = 0 (mặc định)
    assign out = (select == 2'b00) ? input0 :
                 (select == 2'b01) ? input1 :
                 (select == 2'b10) ? input2 : 32'b0;
endmodule