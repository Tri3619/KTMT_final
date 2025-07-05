module IMEM (
    input [29:0] addr,        // Đầu vào 30 bit: Địa chỉ word-addressable (tương ứng với 32-bit instruction)
    output [31:0] instruction // Đầu ra 32 bit: Lệnh được đọc từ bộ nhớ
);
    // Bộ nhớ lệnh được tổ chức dưới dạng mảng 32 bit, với 1024 từ (4KB)
    reg [31:0] memory [0:1023];

    // Khởi tạo bộ nhớ bằng cách đọc dữ liệu từ file "memory.dat"
    initial begin
        $readmemh("memory.dat", memory); // Tải chương trình từ file memory.dat vào bộ nhớ
    end

    // Gán lệnh từ bộ nhớ tại địa chỉ addr vào đầu ra instruction
    assign instruction = memory[addr];
endmodule