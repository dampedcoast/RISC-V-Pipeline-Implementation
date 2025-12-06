// ---------------------------------------------------------------------------
// RISC-V Control Unit (RV64I subset)
// Supports: R-type, I-type (ADDI), Load (LW), Store (SW), Branch (BNE), JAL, JALR, LUI
// ---------------------------------------------------------------------------

module control_unit (
    input  [6:0] Opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,

    output reg   RegWrite,
    output reg   MemRead,
    output reg   MemWrite,
    output reg   MemtoReg,
    output reg   ALUSrc,
    output reg   Branch,
    output reg   Jump,
    output reg   PCSource,
    output reg [1:0] ALUOp
);

    always @(*) begin
        // Default control signals (safe initialization)
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = 1'b0;
        ALUSrc   = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        PCSource = 1'b0;
        ALUOp    = 2'b01;
        
        case (Opcode)
            7'b0110011: begin // R-type (e.g., ADD, SUB)
                RegWrite = 1'b1; 
                ALUSrc   = 1'b0;
                ALUOp    = 2'b00;
            end

            7'b0010011: begin // I-type ALU (e.g., ADDI)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b01;
            end
            
            7'b0000011: begin // Load (LW)
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b10;
            end

            7'b0100011: begin // Store (SW)
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b10;
            end

            7'b1100011: begin // Branch (e.g., BNE)
                Branch   = 1'b1;
                PCSource = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b11;
            end
            
            7'b1101111: begin // JAL
                RegWrite = 1'b1;
                Jump     = 1'b1;
                PCSource = 1'b1;
                ALUOp    = 2'b10;
            end
            
            7'b1100111: begin // JALR
                RegWrite = 1'b1;
                Jump     = 1'b1;
                PCSource = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b10;
            end
            
            7'b0110111: begin // LUI
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b01;
            end
            
            default: begin
               
            end
        endcase
    end

endmodule




