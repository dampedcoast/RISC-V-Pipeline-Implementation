module control_unit_tb;

    reg  [6:0] Opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Branch, Jump, PCSource;
    wire [1:0] ALUOp;
    control_unit uut (
        .Opcode(Opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .Jump(Jump),
        .PCSource(PCSource),
        .ALUOp(ALUOp)
    );

    initial begin
        $dumpfile("control_unit.vcd");
        $dumpvars(0, control_unit_tb);

       
        #1 Opcode = 7'b0110011; funct3 = 3'b001; funct7 = 7'b0000000; 
        #1 Opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000; 
        #1 Opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000; 
        #1 Opcode = 7'b1100011; funct3 = 3'b001; funct7 = 7'b0000000; 
        #1 Opcode = 7'b1101111; funct3 = 3'b000; funct7 = 7'b0000000; 
        #1 Opcode = 7'b0010011; funct3 = 3'b001; funct7 = 7'b0000000; 
        #1 Opcode = 7'b1100111; funct3 = 3'b000; funct7 = 7'b0000000; 
        #1 Opcode = 7'b0110111; funct3 = 3'b000; funct7 = 7'b0000000; 

        #5 $finish;
    end

endmodule