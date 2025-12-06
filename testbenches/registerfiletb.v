`timescale 1ns/1ps

module regfile_tb;

    reg clk;
    reg we;
    reg [4:0] ra1, ra2, wa;
    reg [31:0] wd;
    wire [31:0] rd1, rd2;

    regfile UUT (
        .clk(clk),
        .we(we),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    initial begin
        $dumpfile("regfile_tb.vcd");
        $dumpvars(0, regfile_tb);
    end

   
    always #5 clk = ~clk;

    initial begin
        clk = 0; we = 0;

        $display("Register File Test...");

        
        we = 1; wa = 5; wd = 99; #10;

        
        we = 1; wa = 10; wd = 12345; #10;

        
        we = 0;

        
        ra1 = 5; ra2 = 10; #10;
        $display("rd1=%d rd2=%d", rd1, rd2);

        
        ra1 = 0; #10;
        $display("x0 = %d (should be 0)", rd1);

        #20 $finish;
    end

endmodule
