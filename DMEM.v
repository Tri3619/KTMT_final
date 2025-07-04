module DMEM (
    input clk, MemWrite,
    input [31:0] address, write_data,
    output [31:0] read_data
);
    reg [31:0] memory [0:1023];
    always @(posedge clk) begin
        if (MemWrite)
            memory[address >> 2] <= write_data;
    end
    assign read_data = memory[address >> 2];
endmodule