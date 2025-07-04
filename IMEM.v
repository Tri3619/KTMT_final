module IMEM (
    input [31:0] address,
    output reg [31:0] instruction
);
    // 1024 words memory
    reg [31:0] memory [0:1023];
    
    // Initialize all memory to 'x'
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'hxxxxxxxx;
        end
    end

    always @(*) begin
        instruction = memory[address[11:2]];
    end
endmodule