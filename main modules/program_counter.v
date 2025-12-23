module programcounter (
    input              clock,
    input              reset,   
    input      [31:0]  next_pc,
    input              pc_en, //pc enable
    output reg [31:0]  pc
);

    always @(posedge clock) begin
        if (reset) begin
            pc <= 32'b0;
        end else if (pc_en) begin
            pc <= next_pc;
        end
        
    end

endmodule
