`timescale 1ns/1ps

module RISCV_Single_Cycle(
    input  clk,
    input  rst_n
);
    // Internal signals
    reg  [31:0] PC;
    wire [31:0] PCNext;
    wire [31:0] PCPlus4;
    wire [31:0] PCBranch;
    wire [31:0] Instruction;
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] WriteData;
    wire [31:0] ALUResult;
    wire [31:0] ReadData;
    wire [31:0] ImmExt;
    
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
    
    // Testbench signals
    reg  [31:0] Instruction_out_top;
    
    // Program Counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) PC <= 32'h0;
        else        PC <= PCNext;
    end
    
    assign PCPlus4 = PC + 4;
    assign PCSrc = Branch & Zero;
    assign PCNext = Jump ? (PC + ImmExt) : 
                   PCSrc ? PCBranch : 
                   PCPlus4;
    assign PCBranch = PC + ImmExt;
    
    // Instruction Memory
    IMEM imem(
        .addr(PC),
        .instruction(Instruction)
    );
    
    // Register File
    RegisterFile reg_file(
        .clk(clk),
        .we(RegWrite),
        .a1(Instruction[19:15]),
        .a2(Instruction[24:20]),
        .a3(Instruction[11:7]),
        .wd(WriteData),
        .rd1(ReadData1),
        .rd2(ReadData2)
    );
    
    // Control Unit
    ControlUnit ctrl_unit(
        .opcode(Instruction[6:0]),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );
    
    // Immediate Generator
    ImmGenerator imm_gen(
        .inst(Instruction),
        .imm(ImmExt)
    );
    
    // ALU Control
    ALUControl alu_ctrl(
        .ALUOp(ALUOp),
        .funct3(Instruction[14:12]),
        .funct7(Instruction[31:25]),
        .ALUControl(ALUControl)
    );
    
    // ALU
    wire [31:0] SrcB = ALUSrc ? ImmExt : ReadData2;
    ALU alu(
        .a(ReadData1),
        .b(SrcB),
        .ALUControl(ALUControl),
        .result(ALUResult),
        .zero(Zero)
    );
    
    // Data Memory
    DMEM dmem(
        .clk(clk),
        .we(MemWrite),
        .addr(ALUResult),
        .wd(ReadData2),
        .rd(ReadData)
    );
    
    // Write-back MUX
    assign WriteData = MemtoReg ? ReadData : ALUResult;
    
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