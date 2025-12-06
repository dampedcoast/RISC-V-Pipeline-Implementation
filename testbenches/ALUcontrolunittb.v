// ------------------------------------------------------------
// Testbench for ALU Control Unit
// ------------------------------------------------------------
`timescale 1ns / 1ps

module alu_control_tb;

reg  [1:0] ALUOp;
reg  [2:0] funct3;
reg  [6:0] funct7;
wire [3:0] alu_ctrl;

alu_control UUT (
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .alu_ctrl(alu_ctrl)
);

initial begin
    $dumpfile("alu_control_tb.vcd");
    $dumpvars(0, alu_control_tb);

    $display("=== ALU Control Unit Test ===");

    // 1. ADDW: ALUOp=00, f3=001, f7=0x10 (0010000)
    ALUOp = 2'b00; funct3 = 3'b001; funct7 = 7'b0010000; #10;
    $display("ADDW (f3=1, f7=0x10): alu_ctrl = %b (exp: 0000)", alu_ctrl);

    // 2. SUB: ALUOp=00, f3=001, f7=0x30 (0110000)
    ALUOp = 2'b00; funct3 = 3'b001; funct7 = 7'b0110000; #10;
    $display("SUB  (f3=1, f7=0x30): alu_ctrl = %b (exp: 0001)", alu_ctrl);

    // 3. AND: ALUOp=00, f3=0, f7=0x10
    ALUOp = 2'b00; funct3 = 3'b000; funct7 = 7'b0010000; #10;
    $display("AND  (f3=0, f7=0x10): alu_ctrl = %b (exp: 0010)", alu_ctrl);

    // 4. OR: ALUOp=00, f3=7, f7=0x10
    ALUOp = 2'b00; funct3 = 3'b111; funct7 = 7'b0010000; #10;
    $display("OR   (f3=7, f7=0x10): alu_ctrl = %b (exp: 0011)", alu_ctrl);

    // 5. XOR: ALUOp=00, f3=5, f7=0x10
    ALUOp = 2'b00; funct3 = 3'b101; funct7 = 7'b0010000; #10;
    $display("XOR  (f3=5, f7=0x10): alu_ctrl = %b (exp: 0100)", alu_ctrl);

    // 6. SLTU: ALUOp=00, f3=4, f7=0x01
    ALUOp = 2'b00; funct3 = 3'b100; funct7 = 7'b0000001; #10;
    $display("SLTU (f3=4, f7=0x01): alu_ctrl = %b (exp: 1001)", alu_ctrl);

    // 7. SRL: ALUOp=00, f3=6, f7=0x10
    ALUOp = 2'b00; funct3 = 3'b110; funct7 = 7'b0010000; #10;
    $display("SRL  (f3=6, f7=0x10): alu_ctrl = %b (exp: 0110)", alu_ctrl);

    // 8. SRA: ALUOp=00, f3=6, f7=0x30
    ALUOp = 2'b00; funct3 = 3'b110; funct7 = 7'b0110000; #10;
    $display("SRA  (f3=6, f7=0x30): alu_ctrl = %b (exp: 0111)", alu_ctrl);

    // 9. I-type: ADDIW (ALUOp=01, f3=0)
    ALUOp = 2'b01; funct3 = 3'b000; funct7 = 7'b0000000; #10; // funct7 ignored
    $display("ADDIW (I-type): alu_ctrl = %b (exp: 0000)", alu_ctrl);

    // 10. ORI (I-type)
    ALUOp = 2'b01; funct3 = 3'b110; #10;
    $display("ORI (I-type): alu_ctrl = %b (exp: 0011)", alu_ctrl);

    // 11. Load/Store (ALUOp=10) → ADD
    ALUOp = 2'b10; #10;
    $display("LW/SW (ALUOp=10): alu_ctrl = %b (exp: 0000)", alu_ctrl);

    // 12. Branch (ALUOp=11) → SUB
    ALUOp = 2'b11; #10;
    $display("BNE/BGE (ALUOp=11): alu_ctrl = %b (exp: 0001)", alu_ctrl);

    #20 $finish;
end

endmodule