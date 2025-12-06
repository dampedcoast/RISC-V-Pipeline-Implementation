`timescale 1ns/1ps

module cpu_pipeline (
    input wire clock,
    input wire reset
);

    // IF Stage Wires
    wire [31:0] pc_f, pc_plus_4_f;
    wire [31:0] instruction_f;
    wire [31:0] next_pc;
    wire pc_en_f = 1'b1;

    // IF/ID Register Wires
    reg  [31:0] pc_plus_4_id;
    reg  [31:0] instruction_id;

    // ID Stage Wires
    wire [4:0]  rs1_id, rs2_id, rd_id;
    wire [6:0]  opcode_id, funct7_id;
    wire [2:0]  funct3_id;
    wire [31:0] read_data1_id, read_data2_id;
    wire [31:0] imm_i_id, imm_s_id, imm_sb_id, imm_u_id, imm_uj_id;
    wire [31:0] imm_select_id;
    wire        RegWrite_id, MemRead_id, MemWrite_id, MemtoReg_id, ALUSrc_id;
    wire        Branch_id, Jump_id;
    wire [1:0]  ALUOp_id;

    // ID/EXE Register Wires
    reg  [31:0] pc_plus_4_exe;
    reg  [31:0] read_data1_exe, read_data2_exe;
    reg  [31:0] imm_exe;
    reg  [4:0]  wa_exe;
    reg  [6:0]  funct7_exe;
    reg  [2:0]  funct3_exe;
    reg         RegWrite_exe, MemRead_exe, MemWrite_exe, MemtoReg_exe, ALUSrc_exe;
    reg         Branch_exe, Jump_exe;
    reg  [1:0]  ALUOp_exe;

    // EXE Stage Wires
    wire [31:0] alu_operand2_exe;
    wire [3:0]  alu_ctrl_exe;
    wire [31:0] alu_result_exe;
    wire        alu_zero_exe;
    wire        branch_taken_exe;
    wire [31:0] branch_target_exe;

    // EXE/MEM Register Wires
    reg  [31:0] alu_result_mem;
    reg  [31:0] write_data_mem;
    reg  [4:0]  wa_mem;
    reg         RegWrite_mem, MemRead_mem, MemWrite_mem, MemtoReg_mem;
    reg  [2:0]  funct3_mem;

    // MEM Stage Wires
    wire [31:0] mem_read_data_mem;

    // MEM/WB Register Wires
    reg  [31:0] mem_read_data_wb;
    reg  [31:0] alu_result_wb;
    reg  [4:0]  wa_wb;
    reg         RegWrite_wb, MemtoReg_wb;

    // WB Stage Wires
    wire [31:0] write_data_wb;

    // =================================================================
    // 1. INSTRUCTION FETCH (IF) STAGE
    // =================================================================

    assign pc_plus_4_f = pc_f + 32'd4;
    assign branch_target_exe = pc_plus_4_exe + imm_exe;
    assign branch_taken_exe = Branch_exe & alu_zero_exe;

    assign next_pc = (Jump_exe || branch_taken_exe) ? branch_target_exe : pc_plus_4_f;

    programcounter PC_UUT (
        .clock(clock),
        .reset(reset),
        .next_pc(next_pc),
        .pc_en(pc_en_f),
        .pc(pc_f)
    );

    InstructionMemory IM_UUT (
        .pc(pc_f),
        .instruction(instruction_f)
    );

    always @(posedge clock) begin
        if (reset) begin
            pc_plus_4_id <= 32'b0;
            instruction_id <= 32'b0;
        end else begin
            pc_plus_4_id <= pc_plus_4_f;
            instruction_id <= instruction_f;
        end
    end

    // =================================================================
    // 2. INSTRUCTION DECODE (ID) STAGE
    // =================================================================

    assign opcode_id = instruction_id[6:0];
    assign rs1_id    = instruction_id[19:15];
    assign rs2_id    = instruction_id[24:20];
    assign rd_id     = instruction_id[11:7];
    assign funct3_id = instruction_id[14:12];
    assign funct7_id = instruction_id[31:25];

    control_unit CU_UUT (
        .Opcode(opcode_id),
        .funct3(funct3_id),
        .funct7(funct7_id),
        .RegWrite(RegWrite_id),
        .MemRead(MemRead_id),
        .MemWrite(MemWrite_id),
        .MemtoReg(MemtoReg_id),
        .ALUSrc(ALUSrc_id),
        .Branch(Branch_id),
        .Jump(Jump_id),
        .ALUOp(ALUOp_id)
    );

    imm_gen IMM_UUT (
        .instr(instruction_id),
        .imm_i(imm_i_id),
        .imm_s(imm_s_id),
        .imm_sb(imm_sb_id),
        .imm_u(imm_u_id),
        .imm_uj(imm_uj_id)
    );

    assign imm_select_id = (opcode_id == 7'b0010011 || opcode_id == 7'b0000011 || opcode_id == 7'b1100111) ? imm_i_id :
                           (opcode_id == 7'b0100011) ? imm_s_id :
                           (opcode_id == 7'b1100011) ? imm_sb_id :
                           (opcode_id == 7'b0110111) ? imm_u_id :
                           (opcode_id == 7'b1101111) ? imm_uj_id : 32'b0;

    regfile RF_UUT (
        .clk(clock),
        .we(RegWrite_wb),
        .ra1(rs1_id),
        .ra2(rs2_id),
        .wa(wa_wb),
        .wd(write_data_wb),
        .rd1(read_data1_id),
        .rd2(read_data2_id)
    );

    always @(posedge clock) begin
        if (reset) begin
            RegWrite_exe <= 1'b0; MemRead_exe <= 1'b0; MemWrite_exe <= 1'b0; MemtoReg_exe <= 1'b0; ALUSrc_exe <= 1'b0;
            Branch_exe <= 1'b0; Jump_exe <= 1'b0; ALUOp_exe <= 2'b00;
            pc_plus_4_exe <= 32'b0; read_data1_exe <= 32'b0; read_data2_exe <= 32'b0;
            imm_exe <= 32'b0; wa_exe <= 5'b0;
            funct7_exe <= 7'b0; funct3_exe <= 3'b0;
        end else begin
            RegWrite_exe <= RegWrite_id;
            MemRead_exe <= MemRead_id;
            MemWrite_exe <= MemWrite_id;
            MemtoReg_exe <= MemtoReg_id;
            ALUSrc_exe <= ALUSrc_id;
            Branch_exe <= Branch_id;
            Jump_exe <= Jump_id;
            ALUOp_exe <= ALUOp_id;
            pc_plus_4_exe <= pc_plus_4_id;
            read_data1_exe <= read_data1_id;
            read_data2_exe <= read_data2_id;
            imm_exe <= imm_select_id;
            wa_exe <= rd_id;
            funct7_exe <= funct7_id;
            funct3_exe <= funct3_id;
        end
    end

    // =================================================================
    // 3. EXECUTE (EXE) STAGE
    // =================================================================

    alu_control ALU_CTRL_UUT (
        .ALUOp(ALUOp_exe),
        .funct3(funct3_exe),
        .funct7(funct7_exe),
        .alu_ctrl(alu_ctrl_exe)
    );

    assign alu_operand2_exe = ALUSrc_exe ? imm_exe : read_data2_exe;

    alu ALU_UUT (
        .a(read_data1_exe),
        .b(alu_operand2_exe),
        .alu_ctrl(alu_ctrl_exe),
        .result(alu_result_exe),
        .zero(alu_zero_exe)
    );

    always @(posedge clock) begin
        if (reset) begin
            RegWrite_mem <= 1'b0; MemRead_mem <= 1'b0; MemWrite_mem <= 1'b0; MemtoReg_mem <= 1'b0;
            alu_result_mem <= 32'b0; write_data_mem <= 32'b0; wa_mem <= 5'b0; funct3_mem <= 3'b0;
        end else begin
            RegWrite_mem <= RegWrite_exe;
            MemRead_mem <= MemRead_exe;
            MemWrite_mem <= MemWrite_exe;
            MemtoReg_mem <= MemtoReg_exe;
            alu_result_mem <= alu_result_exe;
            write_data_mem <= read_data2_exe;
            wa_mem <= wa_exe;
            funct3_mem <= funct3_exe;
        end
    end

    // =================================================================
    // 4. MEMORY ACCESS (MEM) STAGE
    // =================================================================

    data_memory DM_UUT (
        .clk(clock),
        .mem_write(MemWrite_mem),
        .mem_read(MemRead_mem),
        .funct3(funct3_mem),
        .addr(alu_result_mem),
        .write_data(write_data_mem),
        .read_data(mem_read_data_mem)
    );

    always @(posedge clock) begin
        if (reset) begin
            RegWrite_wb <= 1'b0; MemtoReg_wb <= 1'b0;
            mem_read_data_wb <= 32'b0; alu_result_wb <= 32'b0; wa_wb <= 5'b0;
        end else begin
            RegWrite_wb <= RegWrite_mem;
            MemtoReg_wb <= MemtoReg_mem;
            mem_read_data_wb <= mem_read_data_mem;
            alu_result_wb <= alu_result_mem;
            wa_wb <= wa_mem;
        end
    end

    // =================================================================
    // 5. WRITE BACK (WB) STAGE
    // =================================================================

    assign write_data_wb = MemtoReg_wb ? mem_read_data_wb : alu_result_wb;

endmodule
`timescale 1ns/1ps

module cpu_pipeline_tb;

    reg clock;
    reg reset;

    // Instantiate the CPU Pipeline
    cpu_pipeline UUT (
        .clock(clock),
        .reset(reset)
    );

    // Clock generator
    always #5 clock = ~clock;

    initial begin
        $dumpfile("cpu_pipeline_tb.vcd");
        $dumpvars(0, cpu_pipeline_tb);

        clock = 0;
        reset = 1;

        $display("----------------------------------------");
        $display("Starting RISC-V Pipeline Simulation (Extended)");
        $display("----------------------------------------");
        $display("Expected Results for initial block (x3=30, x4=30).");
        $display("Additional tests require updating imem.hex for: Logical/XOR, Branch, Jump.");
        $display("----------------------------------------");


        // 1. Assert Reset
        #10 reset = 0; 
        
        // --- Test Block 1: Arithmetic and Load/Store (5 Instructions) ---
        // Run for 10 clock cycles (50ns) to ensure the first 5 instructions complete the WB stage.
        #50; 
        
        // --- Test Block 2: Logical Operations (e.g., AND, OR, XOR) ---
        // Requires 5 additional instructions in imem.hex (e.g., ADDI, ADDI, AND, OR, XOR)
        #50; 
        
        // --- Test Block 3: Control Flow (e.g., Branch and Jump) ---
        // Requires 5 additional instructions (e.g., Branch, JAL, etc.)
        // This stage is critical for Phase 2, but we test the control signals here.
        #50;

        // 3. Continue running until all instructions have passed WB
        // Total simulation time increased to 150ns + 50ns final settling time = 200ns
        #50; 

        $display("Simulation Finished.");
        $finish;
    end

endmodule