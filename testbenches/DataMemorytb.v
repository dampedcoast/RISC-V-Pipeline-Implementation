`timescale 1ns/1ps

module data_memory_tb;

    reg clk;
    reg mem_write, mem_read;
    reg [2:0] funct3;
    reg [31:0] addr;
    reg [31:0] write_data;
    wire [31:0] read_data;

    data_memory UUT(
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .funct3(funct3),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial begin
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);
    end

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        mem_write = 0;
        mem_read = 0;

        $display("Testing Data Memory...");

        // Store word: mem[100..103] = 0x11223344
        addr = 100;
        write_data = 32'h11223344;
        mem_write = 1;
        funct3 = 3'b010;      // SW
        #10 mem_write = 0;

        // Load word
        mem_read = 1;
        funct3 = 3'b010;      // LW
        #5 $display("LW = %h (Expected 11223344)", read_data);

        mem_read = 0;

        // Store byte (0xAA) at mem[200]
        addr = 200;
        write_data = 32'h000000AA;
        mem_write = 1;
        funct3 = 3'b000;      // SB
        #10 mem_write = 0;

        // LB
        mem_read = 1;
        funct3 = 3'b000;      // LB
        #5 $display("LB = %h", read_data);

        // LBU
        funct3 = 3'b100;
        #5 $display("LBU = %h", read_data);

        #20 $finish;
    end

endmodule
