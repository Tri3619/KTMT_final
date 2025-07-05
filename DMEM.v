module DMEM (
    input clk,                    // Đầu vào: Tín hiệu xung nhịp
    input MemWrite,               // Đầu vào: Tín hiệu điều khiển cho phép ghi vào bộ nhớ
    input MemRead,                // Đầu vào: Tín hiệu điều khiển cho phép đọc từ bộ nhớ
    input [31:0] address,         // Đầu vào 32 bit: Địa chỉ bộ nhớ (byte-addressable)
    input [31:0] write_data,      // Đầu vào 32 bit: Dữ liệu cần ghi vào bộ nhớ
    input [2:0] funct3,           // Đầu vào 3 bit: Trường funct3, xác định kích thước dữ liệu (byte, halfword, word)
    output reg [31:0] read_data   // Đầu ra 32 bit: Dữ liệu đọc từ bộ nhớ
);
    // Bộ nhớ được tổ chức dưới dạng mảng 32 bit, với 1024 từ (4KB)
    reg [31:0] memory [0:1023];   // Bộ nhớ word-addressable, mỗi phần tử là 32 bit

    // Chuyển đổi địa chỉ byte sang địa chỉ word bằng cách bỏ 2 bit thấp
    wire [31:0] word_address = address[31:2]; // Địa chỉ word = địa chỉ byte chia 4

    // Xử lý thao tác đọc (Read operation)
    always @(*) begin
        if (MemRead) begin        // Chỉ thực hiện đọc khi MemRead = 1
            case (funct3)
                3'b000:           // lb (load byte, mở rộng dấu)
                    read_data = {{24{memory[word_address][7]}}, memory[word_address][7:0]};
                3'b100:           // lbu (load byte unsigned, không mở rộng dấu)
                    read_data = {24'b0, memory[word_address][7:0]};
                3'b001:           // lh (load halfword, mở rộng dấu)
                    read_data = {{16{memory[word_address][15]}}, memory[word_address][15:0]};
                3'b101:           // lhu (load halfword unsigned, không mở rộng dấu)
                    read_data = {16'b0, memory[word_address][15:0]};
                3'b010:           // lw (load word)
                    read_data = memory[word_address];
                default:          // Trường hợp không hợp lệ: trả về 0
                    read_data = 32'b0;
            endcase
        end else begin            // Nếu MemRead = 0: trả về 0
            read_data = 32'b0;
        end
    end

    // Xử lý thao tác ghi (Write operation)
    always @(posedge clk) begin   // Thực hiện ghi tại cạnh lên của xung nhịp
        if (MemWrite) begin       // Chỉ thực hiện ghi khi MemWrite = 1
            case (funct3)
                3'b000:           // sb (store byte)
                    memory[word_address][7:0] <= write_data[7:0];
                3'b001:           // sh (store halfword)
                    memory[word_address][15:0] <= write_data[15:0];
                3'b010:           // sw (store word)
                    memory[word_address] <= write_data;
                default: ;        // Trường hợp không hợp lệ: không làm gì
            endcase
        end
    end
endmodule