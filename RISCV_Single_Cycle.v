module RISCV_Single_Cycle(
    input clk,
    input rst_n
);
    // Testbench interface signals
    output [31:0] PC_out_top;
    output [31:0] Instruction_out_top;
    
    // Pipeline registers
    reg [31:0] PC;
    wire [31:0] PC_next;
    
    // Datapath signals
    wire [31:0] Instruction;
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] ALUResult;
    wire [31:0] ReadDataMem;
    wire [31:0] ImmExt;
    wire MemWrite, RegWrite, ALUSrc, Branch, Jump;
    wire [1:0] ResultSrc;
    wire [2:0] ALUControl;
    wire Zero;
    wire PCSrc;

    // Assign testbench outputs
    assign PC_out_top = PC;
    assign Instruction_out_top = Instruction;
    
    // PC Update Logic - FIXED for sc2 timing
    assign PCSrc = (Branch & Zero) | Jump;
    assign PC_next = PCSrc ? (PC + ImmExt) : (PC + 4);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) PC <= 32'h0;
        else PC <= PC_next;
    end
    
    // Instruction Memory - Initialized to 'x' for sc1
    IMEM IMEM_inst (
        .address(PC),
        .instruction(Instruction)
    );
    
    // Register File - x0 hardwired to 0
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
    
    // Data Memory - 256 words for sc2
    DMEM DMEM_inst (
        .clk(clk),
        .mem_write(MemWrite),
        .address(ALUResult),
        .write_data(ReadData2),
        .read_data(ReadDataMem)
    );
    
    // Control Unit - Enhanced for sc2
    ControlUnit control (
        .opcode(Instruction[6:0]),
        .funct3(Instruction[14:12]),
        .funct7(Instruction[31:25]),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUControl(ALUControl)
    );
    
    // ALU - Fixed for sc2 comparisons
    ALU alu (
        .a(ReadData1),
        .b(ALUSrc ? ImmExt : ReadData2),
        .alu_control(ALUControl),
        .result(ALUResult),
        .zero(Zero)
    );
    
    // Immediate Generator - All formats
    ImmGenerator imm_gen (
        .inst(Instruction),
        .imm(ImmExt)
    );
    
    // Writeback Mux - Critical for JALR
    wire [31:0] WriteBackData;
    assign WriteBackData = (ResultSrc == 2'b00) ? ALUResult :
                          (ResultSrc == 2'b01) ? ReadDataMem : 
                          (ResultSrc == 2'b10) ? (PC + 4) : 
                          32'b0;
endmodule