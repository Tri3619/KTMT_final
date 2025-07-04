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
);
    reg [31:0] registers [0:31];

    integer i;
    // Reset logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0;
            end
        end
        else if (reg_write && (write_reg != 0)) begin
            registers[write_reg] <= write_data;
        end
    end

    assign read_data1 = (read_reg1 == 0) ? 32'h0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'h0 : registers[read_reg2];
endmodule