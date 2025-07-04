module RISCV_Single_Cycle(
    input clk,
    input rst_n
);
    // Testbench interface
    output [31:0] PC_out_top;
    output [31:0] Instruction_out_top;
    
    // PC Logic
    reg [31:0] PC;
    wire [31:0] PC_next = PC + ((Branch & Zero) || Jump ? ImmExt : 4);
    
    always @(posedge clk or negedge rst_n)
        if (!rst_n) PC <= 0;
        else PC <= PC_next;
    
    // Memory
    IMEM IMEM_inst(.address(PC), .instruction(Instruction_out_top));
    DMEM DMEM_inst(
        .clk(clk),
        .mem_write(MemWrite),
        .address(ALUResult),
        .write_data(ReadData2),
        .read_data(ReadDataMem)
    );
    
    // Register File
    RegisterFile RF(
        .clk(clk),
        .rst_n(rst_n),
        .reg_write(RegWrite),
        .read_reg1(Instruction_out_top[19:15]),
        .read_reg2(Instruction_out_top[24:20]),
        .write_reg(Instruction_out_top[11:7]),
        .write_data(WriteBackData),
        .read_data1(ReadData1),
        .read_data2(ReadData2)
    );
    
    // ALU
    ALU alu(
        .a(ReadData1),
        .b(ALUSrc ? ImmExt : ReadData2),
        .alu_control(ALUControl),
        .result(ALUResult),
        .zero(Zero)
    );
    
    // Control Unit
    ControlUnit CU(
        .opcode(Instruction_out_top[6:0]),
        .funct3(Instruction_out_top[14:12]),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUControl(ALUControl)
    );
    
    // Immediate Generator
    ImmGenerator imm_gen(
        .inst(Instruction_out_top),
        .imm(ImmExt)
    );
    
    // Writeback Mux
    assign WriteBackData = 
        (ResultSrc == 0) ? ALUResult :
        (ResultSrc == 1) ? ReadDataMem : 
        (PC + 4);
    
    assign PC_out_top = PC;
endmodule