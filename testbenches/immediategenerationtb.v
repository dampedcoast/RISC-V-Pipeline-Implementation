`timescale 1ns/1ps

module imm_gen_tb;

    reg  [31:0] instr;
    wire [31:0] imm_i, imm_s, imm_sb, imm_u, imm_uj;

    imm_gen UUT(
        .instr(instr),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_sb(imm_sb),
        .imm_u(imm_u),
        .imm_uj(imm_uj)
    );

    initial begin
        $dumpfile("imm_gen_tb.vcd");
        $dumpvars(0, imm_gen_tb);

        $display("Testing Immediate Generator...\n");

      
        instr = 32'b000000000011_00010_000_00001_0010011;
        #5 $display("I-Type imm = %d", imm_i);

       
        instr = 32'b0000001_00001_00010_010_10000_0100011;
        #5 $display("S-Type imm = %d", imm_s);

       
        instr = 32'b0000000_00010_00001_001_10000_1100011;
        #5 $display("SB-Type imm = %d", imm_sb);

       
        instr = 32'b00010010001101000101_00001_0110111;
        #5 $display("U-Type imm = %h", imm_u);

        instr = 32'b00000010000_00000000_00001_1101111;
        #5 $display("UJ-Type imm = %d", imm_uj);

        #10 $finish;
    end

endmodule
