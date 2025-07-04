module DMEM (
    input clk,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);
    // 256 words memory (1KB)
    reg [31:0] memory [0:255];
    
    // Initialize all memory to 0
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'h0;
        end
    end

    always @(posedge clk) begin
        if (mem_write) begin
            // Chỉ ghi khi địa chỉ trong phạm vi
            if (address[31:2] < 256) begin
                memory[address[31:2]] <= write_data;
            end
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