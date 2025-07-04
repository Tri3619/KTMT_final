<<<<<<< HEAD
module IMEM (
    input [31:0] address,
    output reg [31:0] instruction
);
    // 1024 words memory
    reg [31:0] memory [0:1023];
    
    // Initialize all memory to 'x'
=======
module IMEM(
    input  [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] memory [0:1023];  // Khai báo bộ nhớ

>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
    initial begin
        for (int i = 0; i < 1024; i++) begin
            memory[i] = 32'hxxxxxxxx;
        end
    end

<<<<<<< HEAD
    always @(*) begin
        // Convert byte address to word address
        instruction = memory[address[31:2]];
    end
endmodule
=======
    assign instruction = memory[addr[31:2]];
endmodule
>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
