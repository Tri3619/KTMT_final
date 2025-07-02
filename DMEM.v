// Data Memory
module DMEM(
    input         clk,
    input         we,
    input  [31:0] addr,
    input  [31:0] wd,
    output [31:0] rd
);
    reg [31:0] memory [0:1023]; // 1KB memory

    initial begin
        $readmemh("./mem/dmem_init.hex", memory);
    end

    assign rd = memory[addr[31:2]]; // Word-aligned access

    always @(posedge clk) begin
        if (we) begin
            memory[addr[31:2]] <= wd;
        end
    end
endmodule