<<<<<<< HEAD
module DMEM (
    input clk,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data,
    output reg [31:0] memory [0:255]  // Sửa kích thước thành 256 words
);
    // Khởi tạo bộ nhớ
=======
module DMEM(
    input         clk,
    input         we,
    input  [31:0] addr,
    input  [31:0] wd,
    output [31:0] rd
);
    reg [31:0] memory [0:1023];  // Khai báo bộ nhớ

>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
    initial begin
        for (int i = 0; i < 256; i++) begin
            memory[i] = 32'h0;
        end
    end

<<<<<<< HEAD
=======
    assign rd = memory[addr[31:2]];

>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
    always @(posedge clk) begin
        if (mem_write && (address[31:2] < 256)) begin
            memory[address[31:2]] <= write_data;
        end
    end

    always @(*) begin
        if (address[31:2] < 256) begin
            read_data = memory[address[31:2]];
        end else begin
            read_data = 32'h0;
        end
    end
endmodule
