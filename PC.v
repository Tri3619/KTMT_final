module PC (
    input clk,                 // Đầu vào: Tín hiệu xung nhịp
    input rst_n,               // Đầu vào: Tín hiệu reset (active-low)
    input [31:0] next_PC,      // Đầu vào 32 bit: Giá trị PC tiếp theo (từ module NextPCSel)
    output reg [31:0] PC_Out   // Đầu ra 32 bit: Giá trị Program Counter hiện tại
);
    // Khối always xử lý cập nhật PC tại cạnh lên của xung nhịp hoặc khi reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)            // Nếu rst_n = 0 (reset được kích hoạt)
            PC_Out <= 32'b0;   // Đặt PC về 0
        else                   // Nếu không reset, tại cạnh lên của xung nhịp
            PC_Out <= next_PC; // Cập nhật PC bằng giá trị next_PC
    end
endmodule