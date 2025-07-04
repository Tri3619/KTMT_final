<<<<<<< HEAD
module RegisterFile (
    input clk,
    input rst_n,
    input reg_write,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
=======
module RegisterFile(
    input         clk,
    input         we,
    input  [4:0]  a1,
    input  [4:0]  a2,
    input  [4:0]  a3,
    input  [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
);
    reg [31:0] registers [0:31];
    
    // Khởi tạo tất cả thanh ghi = 0
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

<<<<<<< HEAD
    // Reset logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'h0;
            end
        end
        else if (reg_write && write_reg != 0) begin
            registers[write_reg] <= write_data;
        end
    end

    assign read_data1 = (read_reg1 != 0) ? registers[read_reg1] : 0;
    assign read_data2 = (read_reg2 != 0) ? registers[read_reg2] : 0;
endmodule
=======
    assign rd1 = (a1 != 0) ? registers[a1] : 0;
    assign rd2 = (a2 != 0) ? registers[a2] : 0;

    always @(posedge clk) begin
        if (we && a3 != 0) begin
            registers[a3] <= wd;
        end
    end
endmodule
>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
