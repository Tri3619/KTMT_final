module RISCV_Single_Cycle (
    input clk,                        // Đầu vào: Xung nhịp
    input rst_n,                      // Đầu vào: Tín hiệu reset (active-low)
    output [31:0] Instruction_out_top,// Đầu ra: Lệnh hiện tại (32 bit), trả về xxxxxxxx khi Halt
    output [31:0] PC_out_top,         // Đầu ra: Giá trị Program Counter hiện tại
    output [31:0] registers [0:31]    // Đầu ra: Mảng 32 thanh ghi, mỗi thanh ghi 32 bit
);
    // Khai báo các dây (wire) kết nối giữa các module
    wire [31:0] instruction;          // Lệnh đọc từ bộ nhớ lệnh (IMEM)
    wire [6:0] op;                    // Opcode (7 bit) từ lệnh
    wire [2:0] funct3;                // Trường funct3 (3 bit) từ lệnh
    wire [6:0] funct7;                // Trường funct7 (7 bit) từ lệnh
    wire [11:0] imm;                  // Trường immediate (12 bit) cho lệnh ECALL/EBREAK
    wire [4:0] rs1, rs2, rd;          // Địa chỉ thanh ghi nguồn (rs1, rs2) và đích (rd)
    wire [31:0] imm_ext;              // Giá trị immediate đã mở rộng (32 bit)
    wire [31:0] PC_plus4, PC_branch, next_PC, PC_Out; // Các giá trị PC: PC+4, PC nhánh, PC tiếp theo, PC hiện tại
    wire [31:0] dataA, dataB;         // Dữ liệu đọc từ thanh ghi rs1 và rs2
    wire [31:0] A, B;                 // Toán hạng đầu vào cho ALU
    wire [3:0] ALUControl;            // Tín hiệu điều khiển ALU (4 bit)
    wire [31:0] alu_out;              // Kết quả từ ALU
    wire [31:0] read_data;            // Dữ liệu đọc từ bộ nhớ dữ liệu (DMEM)
    wire [31:0] WB_out;               // Dữ liệu ghi vào thanh ghi đích (write-back)
    wire ALUSrc, ALUSrc_pc, MemWrite, MemRead, RegWrite, Branch, branch_taken, Jump, Halt; // Tín hiệu điều khiển
    wire [1:0] ResultSrc;             // Tín hiệu chọn nguồn dữ liệu write-back
    wire [1:0] ALUOp;                 // Tín hiệu điều khiển loại phép toán ALU
    wire [2:0] imm_sel;               // Tín hiệu chọn loại immediate

    // Trích xuất các trường từ lệnh (instruction)
    assign rs1 = instruction[19:15];  // Địa chỉ thanh ghi nguồn rs1
    assign rs2 = instruction[24:20];  // Địa chỉ thanh ghi nguồn rs2
    assign rd  = instruction[11:7];   // Địa chỉ thanh ghi đích rd
    assign funct3 = instruction[14:12]; // Trường funct3
    assign funct7 = instruction[31:25]; // Trường funct7
    assign op = instruction[6:0];     // Opcode
    assign imm = instruction[31:20];  // Trường immediate cho ECALL/EBREAK

    // Đầu ra Instruction_out_top: trả về xxxxxxxx khi Halt, ngược lại trả về lệnh hiện tại
    assign Instruction_out_top = Halt ? 32'hxxxxxxxx : instruction;

    // Đầu ra PC_out_top: giá trị PC hiện tại
    assign PC_out_top = PC_Out;

    // Logic chọn PC tiếp theo (thay thế instance NextPCSel để xử lý Halt)
    assign next_PC = (Halt) ? PC_Out :                     // Nếu Halt = 1, giữ PC hiện tại
                     (Jump && (op == 7'b1100111)) ? alu_out : // JALR: Chọn alu_out
                     (Jump || (Branch && branch_taken)) ? PC_branch : // JAL hoặc nhánh thỏa mãn: Chọn PC_branch
                     PC_plus4;                       // Mặc định: Chọn PC + 4

    // Module PC: Quản lý Program Counter
    PC PC_inst (
        .clk(clk),
        .rst_n(rst_n),
        .next_PC(next_PC),
        .PC_Out(PC_Out)
    );

    // Module PCAdder: Tính PC + 4
    PCAdder PCAdder_inst (
        .PC_in(PC_Out),
        .PC_plus4(PC_plus4)
    );

    // Module BranchAdder: Tính địa chỉ nhánh (PC + imm_ext)
    BranchAdder BranchAdder_inst (
        .PC_in(PC_Out),
        .imm_ext(imm_ext),
        .PC_branch(PC_branch)
    );

    // Module IMEM: Bộ nhớ lệnh, đọc lệnh từ PC_Out
    IMEM IMEM_inst (
        .addr(PC_Out[31:2]), // Chuyển byte-address thành word-address
        .instruction(instruction)
    );

    // Module ControlUnit: Tạo các tín hiệu điều khiển dựa trên opcode, funct3, imm
    ControlUnit ControlUnit_inst (
        .op(op),
        .funct3(funct3),
        .imm(imm),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ALUSrc_pc(ALUSrc_pc),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .Halt(Halt),
        .ALUOp(ALUOp),
        .imm_sel(imm_sel)
    );

    // Module RegisterFile: Ngân hàng thanh ghi, đọc/ghi dữ liệu
    RegisterFile Reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .addA(rs1),
        .addB(rs2),
        .addD(rd),
        .WB_out(WB_out),
        .RegWrite(RegWrite),
        .dataA(dataA),
        .dataB(dataB),
        .registers(registers)
    );

    // Module ImmGen: Tạo immediate mở rộng
    ImmGen ImmGen_inst (
        .instruction(instruction),
        .imm_sel(imm_sel),
        .imm_ext(imm_ext)
    );

    // Module ALUControl: Tạo tín hiệu điều khiển cho ALU
    ALUControl ALU_Control_inst (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .op(op),
        .ALUControl(ALUControl)
    );

    // Module ALU: Thực hiện phép toán số học/logic
    ALU ALU_inst (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .alu_out(alu_out)
    );

    // Module BranchComp: Kiểm tra điều kiện nhánh
    BranchComp BranchComp_inst (
        .op(op),
        .funct3(funct3),
        .rs1_data(dataA),
        .rs2_data(dataB),
        .branch_taken(branch_taken)
    );

    // Module DMEM: Bộ nhớ dữ liệu, đọc/ghi dữ liệu
    DMEM DMEM_inst (
        .clk(clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(alu_out),
 .write_data(dataB),
        .funct3(funct3),
        .read_data(read_data)
    );

    // Module MUX2 (muxALU1): Chọn toán hạng A cho ALU (dataA hoặc PC_Out)
    MUX2 muxALU1 (
        .input0(dataA),
        .input1(PC_Out),
        .select(ALUSrc_pc),
        .out(A)
    );

    // Module MUX2 (muxALU2): Chọn toán hạng B cho ALU (dataB hoặc imm_ext)
    MUX2 muxALU2 (
        .input0(dataB),
        .input1(imm_ext),
        .select(ALUSrc),
        .out(B)
    );

    // Module MUX3 (muxWB): Chọn dữ liệu ghi vào thanh ghi (alu_out, read_data, hoặc PC_plus4)
    MUX3 muxWB (
        .input0(alu_out),
        .input1(read_data),
        .input2(PC_plus4),
        .select(ResultSrc),
        .out(WB_out)
    );
endmodule