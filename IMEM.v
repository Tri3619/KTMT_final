// Instruction Memory
module IMEM(
    input  [31:0] addr,
    output [31:0] instruction,
    output reg [31:0] memory [0:1023]  // Thêm output này
);
    initial begin
        $readmemh("./mem/imem.hex", memory);
    end

    assign instruction = memory[addr[31:2]];
endmodule
