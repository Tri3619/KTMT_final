module RegisterFile (
    input clk,
    input rst_n,
    input [4:0] addA, addB, addD,
    input [31:0] WB_out,
    input RegWrite,
    output [31:0] dataA, dataB,
    output reg [31:0] registers [0:31] // Khai báo registers là cổng đầu ra kiểu reg
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end
        else if (RegWrite && addD != 0) begin
            registers[addD] <= WB_out;
        end
    end

    assign dataA = registers[addA];
    assign dataB = registers[addB];
endmodule
