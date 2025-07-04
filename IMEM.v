module IMEM (
    input [31:0] address,
    output reg [31:0] instruction
);
    // 1024 words memory
    reg [31:0] memory [0:1023];
    
    // Initialize all memory to 'x'
    initial begin
        for (int i = 0; i < 1024; i++) begin
            memory[i] = 32'hxxxxxxxx;
        end
    end

    always @(*) begin
        // Convert byte address to word address
        instruction = memory[address[31:2]];
    end
endmodule