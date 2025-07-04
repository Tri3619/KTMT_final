module BranchAdder (
    input [31:0] PC_in,
    input [31:0] imm_ext,
    output [31:0] PC_branch
);
    assign PC_branch = PC_in + imm_ext;
endmodule
