module DMEM (
    input clk,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);
    // 256 words memory
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
            memory[address[9:2]] <= write_data;
        end
    end

    always @(*) begin
        read_data = memory[address[9:2]];
    end
endmodule