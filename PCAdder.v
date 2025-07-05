module PCAdder (
    input [31:0] PC_in,       // Đầu vào 32 bit: Giá trị Program Counter hiện tại
    output [31:0] PC_plus4    // Đầu ra 32 bit: Giá trị PC cộng thêm 4
);
    // Tính PC tiếp theo bằng cách cộng 4 vào PC hiện tại
    assign PC_plus4 = PC_in + 32'd4;
endmodule