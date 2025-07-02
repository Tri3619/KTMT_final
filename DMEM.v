module DMEM(
    input         clk,
    input         we,
    input  [31:0] addr,
    input  [31:0] wd,
    output [31:0] rd,
    output reg [31:0] memory [0:1023]  // Thêm output này
);
    initial begin
        $readmemh("./mem/dmem_init.hex", memory);
    end

    assign rd = memory[addr[31:2]];

    always @(posedge clk) begin
        if (we) begin
            memory[addr[31:2]] <= wd;
        end
    end
endmodule
