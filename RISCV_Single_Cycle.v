module RISCV_Single_Cycle(
    input clk,
    input rst_n
);
    // Tín hiệu output cho testbench
    output [31:0] PC_out_top;
    output [31:0] Instruction_out_top;
    
    // Các tín hiệu nội bộ
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
    wire Zero;
    
    // Gán tín hiệu output
    assign PC_out_top = PC;
    assign Instruction_out_top = Instruction;
    
    // PC logic
    assign PC = PC_reg;
    assign PC_next = (Branch & Zero) ? (PC + ImmExt) : 
                   Jump ? (PC + ImmExt) : 
                   (PC + 4);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) PC_reg <= 32'h0;
        else PC_reg <= PC_next;
    end
    
    // IMEM
    IMEM IMEM_inst (
        .address(PC),
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
    
    // Immediate Generator
    ImmGenerator imm_gen (
        .inst(Instruction),
        .imm(ImmExt)
    );
    
    // Writeback Mux
    wire [31:0] WriteBackData;
    assign WriteBackData = (ResultSrc == 2'b00) ? ALUResult :
                          (ResultSrc == 2'b01) ? ReadDataMem : 
                          (ResultSrc == 2'b10) ? (PC + 4) : 
                          32'b0;
    
endmodule