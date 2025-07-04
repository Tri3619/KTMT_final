module ALU(
    input [31:0] a,
    input [31:0] b,
    input [2:0] alu_control,
    output reg [31:0] result,
    output zero
);
    always @(*) begin
        case (alu_control)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = a << b[4:0];
            3'b110: result = a >> b[4:0];
            3'b111: result = $signed(a) >>> b[4:0];
        endcase
    end
    
    assign zero = (result == 0);
endmodule