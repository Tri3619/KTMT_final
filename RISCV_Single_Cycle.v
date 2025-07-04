module RISCV_Single_Cycle(
    input clk,
    input rst_n
);
    // Tín hiệu mới cần thêm cho testbench
    output [31:0] PC_out_top;
    output [31:0] Instruction_out_top;
    
    // Các tín hiện nội bộ
    reg [31:0] PC_reg;
    wire [31:0] PC;
    wire [31:0] PC_next;
    wire [31:0] Instruction;
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] ALUResult;
    wire [31:0] ReadDataMem;
    wire [31:0] ImmExt;
    wire MemWrite, RegWrite, ALUSrc, Branch, Jump;
    wire [1:0] ResultSrc;
    wire [2:0] ALUControl;
    
<<<<<<< HEAD
    // Gán tín hiệu output cho testbench
    assign PC_out_top = PC;
    assign Instruction_out_top = Instruction;
    
    // PC logic
    assign PC = PC_reg;
    assign PC_next = (Branch & Zero) ? (PC + ImmExt) : 
                   Jump ? (PC + ImmExt) : 
                   (PC + 4);
=======
    // Control signals
    wire        PCSrc;
    wire        RegWrite;
    wire        ALUSrc;
    wire        MemWrite;
    wire        MemtoReg;
    wire        Branch;
    wire        Jump;
    wire [1:0]  ALUOp;
    wire [3:0]  ALUControl;
    wire        Zero;
    wire [31:0] imem_memory [0:1023];
    wire [31:0] dmem_memory [0:1023];
    // Testbench signals
    reg  [31:0] Instruction_out_top;
>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) PC_reg <= 32'h0;
        else PC_reg <= PC_next;
    end
    
<<<<<<< HEAD
    // IMEM
    IMEM IMEM_inst (
        .address(PC),
=======
    assign PCPlus4 = PC + 4;
    assign PCSrc = Branch & Zero;
    assign PCNext = Jump ? (PC + ImmExt) : 
                   PCSrc ? PCBranch : 
                   PCPlus4;
    assign PCBranch = PC + ImmExt;
    
    // Instruction Memory
    // IMEM imem(
    //     .addr(PC),
    //     .instruction(Instruction),
    //     .memory(imem_memory)
    // );
    IMEM IMEM_inst (  // Đổi tên thành IMEM_inst
        .addr(PC),
>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
        .instruction(Instruction)
    );
    
    // Register File
    RegisterFile Reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write(RegWrite),
        .read_reg1(Instruction[19:15]),
        .read_reg2(Instruction[24:20]),
        .write_reg(Instruction[11:7]),
        .write_data(WriteBackData),
        .read_data1(ReadData1),
        .read_data2(ReadData2)
    );
    
    // DMEM
    DMEM DMEM_inst (
        .clk(clk),
        .mem_write(MemWrite),
        .address(ALUResult),
        .write_data(ReadData2),
        .read_data(ReadDataMem)
    );
    
    // Control Unit
    ControlUnit control (
        .opcode(Instruction[6:0]),
        .funct3(Instruction[14:12]),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUControl(ALUControl)
    );
    
    // ALU
    ALU alu (
        .a(ReadData1),
        .b(ALUSrc ? ImmExt : ReadData2),
        .alu_control(ALUControl),
        .result(ALUResult),
        .zero(Zero)
    );
    
<<<<<<< HEAD
    // Immediate Extender (sử dụng module của bạn)
    ImmExtend imm_ext (
        .inst(Instruction),
        .imm(ImmExt)
=======
    // Data Memory
    // DMEM dmem(
    //     .clk(clk),
    //     .we(MemWrite),
    //     .addr(ALUResult),
    //     .wd(ReadData2),
    //     .rd(ReadData),
    //     .memory(dmem_memory)
    // );
        DMEM DMEM_inst (  // Đổi tên thành DMEM_inst
        .clk(clk),
        .we(MemWrite),
        .addr(ALUResult),
        .wd(ReadData2),
        .rd(ReadData)
>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
    );
    
    // Writeback Mux
    wire [31:0] WriteBackData;
    assign WriteBackData = (ResultSrc == 2'b00) ? ALUResult :
                          (ResultSrc == 2'b01) ? ReadDataMem : 
                          (ResultSrc == 2'b10) ? (PC + 4) : 
                          32'b0;
    
<<<<<<< HEAD
endmodule
=======
    // Program termination detection
    always @(posedge clk) begin
        if (Instruction === 32'h00000000 || 
            Instruction === 32'h00000073 || // ECALL
            Instruction === 32'h00100073)   // EBREAK
        begin
            Instruction_out_top <= 32'hxxxxxxxx;
        end
        else begin
            Instruction_out_top <= Instruction;
        end
    end
endmodule
>>>>>>> 3c902f98d32c2b187d33f5dbcd2306833dc21240
