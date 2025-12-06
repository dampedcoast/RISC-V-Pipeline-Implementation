`timescale 1ns/1ps

module pc_tb;

    reg         clock;
    reg         reset;
    reg         pc_en;
    reg  [31:0] next_pc;
    wire [31:0] pc;
    programcounter UUT (
        .clock(clock),
        .reset(reset),
        .next_pc(next_pc),
        .pc_en(pc_en),
        .pc(pc)
    );

  
    always #5 clock = ~clock;

    initial begin
        
        $dumpfile("pc_tb.vcd");
        $dumpvars(0, pc_tb);

       
        clock   = 0;
        reset   = 1;
        pc_en   = 0;
        next_pc = 32'h00000000;

       
        #20;
        reset = 0;

        
        #10;
        pc_en = 1;
        next_pc = 32'h00000004;   

        #10;
        next_pc = 32'h00000008;

        #10;
        next_pc = 32'h0000000C;

        
        #10;
        pc_en = 0;
        next_pc = 32'hDEADBEEF;  

        #20;

        
        reset = 1;
        #10;
        reset = 0;

        #20;

        $finish;
    end

endmodule
