module DMEM (
    input clk, MemWrite, MemRead,
    input [31:0] address, write_data,
    input [2:0] funct3,
    output reg [31:0] read_data
);
    reg [7:0] memory [0:4095]; // Byte-addressable memory (4KB)
    wire [31:0] byte_address = address << 2; // Chuyển word-address thành byte-address

    // Write operation
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: memory[byte_address] <= write_data[7:0]; // sb
                3'b001: begin // sh
                    memory[byte_address]   <= write_data[7:0];
                    memory[byte_address+1] <= write_data[15:8];
                end
                3'b010: begin // sw
                    memory[byte_address]   <= write_data[7:0];
                    memory[byte_address+1] <= write_data[15:8];
                    memory[byte_address+2] <= write_data[23:16];
                    memory[byte_address+3] <= write_data[31:24];
                end
                default: ; // Do nothing
            endcase
        end
    end

    // Read operation
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b000: read_data = {{24{memory[byte_address][7]}}, memory[byte_address]}; // lb
                3'b100: read_data = {24'b0, memory[byte_address]}; // lbu
                3'b001: read_data = {{16{memory[byte_address+1][7]}}, memory[byte_address+1], memory[byte_address]}; // lh
                3'b101: read_data = {16'b0, memory[byte_address+1], memory[byte_address]}; // lhu
                3'b010: read_data = {memory[byte_address+3], memory[byte_address+2], memory[byte_address+1], memory[byte_address]}; // lw
                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end
endmodule