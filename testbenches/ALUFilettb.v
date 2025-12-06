`timescale 1ns/1ps

module alu_tb;

    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire zero;

    alu UUT (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        $display("Starting ALU Test...");

        a = 10; b = 5;

        alu_ctrl = 4'b0000; #5 $display("ADD  : %d", result);
        alu_ctrl = 4'b0001; #5 $display("SUB  : %d", result);
        alu_ctrl = 4'b0010; #5 $display("AND  : %d", result);
        alu_ctrl = 4'b0011; #5 $display("OR   : %d", result);
        alu_ctrl = 4'b0100; #5 $display("XOR  : %d", result);

        alu_ctrl = 4'b0101; #5 $display("SLL  : %d", result);
        alu_ctrl = 4'b0110; #5 $display("SRL  : %d", result);

        a = -32; b = 2;
        alu_ctrl = 4'b0111; #5 $display("SRA  : %d", result);

        a = 3; b = 20;
        alu_ctrl = 4'b1000; #5 $display("SLT  : %d", result);

        a = 32'hFFFFFFFF; b = 0;
        alu_ctrl = 4'b1001; #5 $display("SLTU : %d", result);

        #20 $finish;
    end

endmodule
