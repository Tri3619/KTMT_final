module DMEM (
    input clk,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:255]; // 256 words for sc2
    
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'h0; // Initialize to 0
        end
    end

    always @(posedge clk) begin
        if (mem_write && address[31:2] < 256) begin
            memory[address[31:2]] <= write_data;
        end
    end

    always @(*) begin
        read_data = (address[31:2] < 256) ? memory[address[31:2]] : 32'h0;
    end
endmodule