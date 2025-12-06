`timescale 1ns/1ps

module im_tb;

    reg  [31:0] pc;
    wire [31:0] instruction;

    InstructionMemory im (
        .pc(pc),
        .instruction(instruction)
    );

    initial begin
        $dumpfile("im_tb.vcd");
        $dumpvars(0, im_tb);

        $display("Testing InstructionMemory (Hardcoded ROM)...");
        $display("-------------------------------------------");

        pc = 0;
        #0 $display("PC = %0d | Instruction = 0x%08h", pc, instruction);

        pc = 4;
        #0 $display("PC = %0d | Instruction = 0x%08h", pc, instruction);

        pc = 8;
        #0 $display("PC = %0d | Instruction = 0x%08h", pc, instruction);

        pc = 12;
        #0 $display("PC = %0d | Instruction = 0x%08h", pc, instruction);

        pc = 16;
        #0 $display("PC = %0d | Instruction = 0x%08h", pc, instruction);

        $display("-------------------------------------------");
        $display("Expected:");
        $display("  PC=0  → 0x00100093 (ADDI x1, x0, 1)");
        $display("  PC=4  → 0x00200113 (ADDI x2, x0, 2)");
        $display("  PC=8  → 0x002081B3 (ADD  x3, x1, x2)");
        $display("  PC=12 → 0x00000013 (NOP)");
        $display("  PC=16 → 0x00000013 (NOP)");

        #10 $finish;
    end

endmodule