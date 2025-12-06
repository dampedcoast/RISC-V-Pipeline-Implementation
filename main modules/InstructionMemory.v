

module InstructionMemory (
    input      [31:0] pc,      
    output reg [31:0] instruction 
);

    always @(*) begin
        case (pc[31:2])  // word address = pc / 4
            0:  instruction = 32'h00100093; // ADDI x1, x0, 1
            1:  instruction = 32'h00200113; // ADDI x2, x0, 2
            2:  instruction = 32'h002081B3; // ADD x3, x1, x2
            3:  instruction = 32'h00000013; // NOP
            4:  instruction = 32'h00000013; // NOP
            default: instruction = 32'h00000013; // NOP for all other addresses
        endcase
    end

endmodule
