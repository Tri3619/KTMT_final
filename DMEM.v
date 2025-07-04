module DMEM (
    input clk, MemWrite, MemRead,
    input [31:0] address, write_data,
    input [2:0] funct3, // Added funct3 to determine operation
    output reg [31:0] read_data
);
    reg [7:0] memory [0:4095]; // Byte-addressable memory (4KB = 1024 words * 4 bytes)

    // Write operation
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: memory[address] <= write_data[7:0]; // sb: store byte
                3'b001: begin // sh: store half-word
                    memory[address]   <= write_data[7:0];
                    memory[address+1] <= write_data[15:8];
                end
                3'b010: begin // sw: store word
                    memory[address]   <= write_data[7:0];
                    memory[address+1] <= write_data[15:8];
                    memory[address+2] <= write_data[23:16];
                    memory[address+3] <= write_data[31:24];
                end
                default: ; // Do nothing for unsupported funct3
            endcase
        end
    end

    // Read operation
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b000: read_data = {{24{memory[address][7]}}, memory[address]}; // lb: sign-extend byte
                3'b100: read_data = {24'b0, memory[address]}; // lbu: zero-extend byte
                3'b001: read_data = {{16{memory[address+1][7]}}, memory[address+1], memory[address]}; // lh: sign-extend half-word
                3'b101: read_data = {16'b0, memory[address+1], memory[address]}; // lhu: zero-extend half-word
                3'b010: read_data = {memory[address+3], memory[address+2], memory[address+1], memory[address]}; // lw: load word
                default: read_data = 32'b0; // Default case
            endcase
        end else begin
            read_data = 32'b0;
        end
    end
endmodule