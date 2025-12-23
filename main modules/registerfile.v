module regfile(
    input  wire         clk,
    input  wire         we,    // write enable   
    input  wire [4:0]   ra1,      
    input  wire [4:0]   ra2,      
    input  wire [4:0]   wa,       
    input  wire [31:0]  wd,       
    output wire [31:0]  rd1,
    output wire [31:0]  rd2
);

    reg [31:0] rf [0:31];
    integer i;
    initial begin
        for (i=0;i<32;i=i+1) rf[i] = 32'b0;
    end

    
    always @(posedge clk) begin
        if (we && (wa != 5'd0)) begin
            rf[wa] <= wd;
        end
    end

    
    assign rd1 = (ra1 == 5'd0) ? 32'b0 : rf[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'b0 : rf[ra2];

endmodule
