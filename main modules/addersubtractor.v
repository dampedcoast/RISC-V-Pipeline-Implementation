module add_sub (
    input        clk,
    input  [3:0] num1,
    input  [3:0] num2,
    input        op,         
    output reg [4:0] res
);

always @(posedge clk) begin
    if (op) begin
        res <= num1 + num2;   
    end else begin
        res <= num1 - num2; 
    end
end

endmodule


module tb_add_sub;

  
    reg        clk;
    reg  [3:0] num1;
    reg  [3:0] num2;
    reg        op;
    wire [4:0] res;

  
    add_sub uut (
        .clk(clk),
        .num1(num1),
        .num2(num2),
        .op(op),
        .res(res)
    );

      parameter CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $monitor("Time %0t op:%b num1:%d num2:%d res:%d", $time, op, num1, num2, res);
        clk = 1; 
        num1 = 0;
        num2 = 0;
        op = 0;
        #1;
        num1 = 5;
        num2 = 3;
        #10;
        num1 = 11;
        num2 = 4;
        op = 1;
        #10;
        $display("@Simulation finished");
        $finish;
    end

endmodule