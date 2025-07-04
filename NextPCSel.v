module NextPCSel (
    input [31:0] PC_plus4,
    input [31:0] PC_branch,
    input [31:0] JALR_target,
    input Branch, Jump,
    input branch_taken,
    input [6:0] op, // Thêm cổng đầu vào op
    output [31:0] next_PC
);
    assign next_PC = (Jump && (op == 7'b1100111)) ? JALR_target : // JALR
                     (Jump || (Branch && branch_taken)) ? PC_branch : // JAL or Branch
                     PC_plus4;
endmodule
