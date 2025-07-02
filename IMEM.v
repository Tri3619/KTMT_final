// Instruction Memory
module IMEM(
    input  [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] memory [0:1023]; // 1KB memory

    initial begin
        $readmemh("./mem/imem.hex", memory);
    end

    assign instruction = memory[addr[31:2]]; // Word-aligned access
endmodule
