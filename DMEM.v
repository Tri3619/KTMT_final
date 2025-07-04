module DMEM(
    input clk,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:255]; // Exactly 256 words for sc2
    
    initial 
        for (integer i=0; i<256; i++) 
            memory[i] = 0;

    always @(posedge clk)
        if (mem_write && address[31:2] < 256)
            memory[address[31:2]] <= write_data;

    always @(*)
        read_data = (address[31:2] < 256) ? memory[address[31:2]] : 0;
endmodule