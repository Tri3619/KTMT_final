module RegisterFile(
    input         clk,
    input         we,
    input  [4:0]  a1,
    input  [4:0]  a2,
    input  [4:0]  a3,
    input  [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
);
    reg [31:0] registers [0:31];
    
    // Khởi tạo tất cả thanh ghi = 0
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    assign rd1 = (a1 != 0) ? registers[a1] : 0;
    assign rd2 = (a2 != 0) ? registers[a2] : 0;

    always @(posedge clk) begin
        if (we && a3 != 0) begin
            registers[a3] <= wd;
        end
    end
endmodule
