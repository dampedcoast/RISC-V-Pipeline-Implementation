module data_memory(
    input  wire         clk,
    input  wire         mem_write,   
    input  wire         mem_read,     
    input  wire [2:0]   funct3,       
    input  wire [31:0]  addr,         
    input  wire [31:0]  write_data,
    output reg  [31:0]  read_data
);

    reg [7:0] mem [0:8191];

    // Temporary variables must be declared OUTSIDE always blocks
    reg [7:0]  byte_data;
    reg [15:0] half_data;

    integer i;
    initial begin
        for (i = 0; i < 8192; i = i + 1)
            mem[i] = 8'b0;
    end

    // WRITE
    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
                3'b000: begin // SB
                    mem[addr] <= write_data[7:0];
                end

                3'b001: begin // SH
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                end

                3'b010: begin // SW
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                    mem[addr+2] <= write_data[23:16];
                    mem[addr+3] <= write_data[31:24];
                end
            endcase
        end
    end

    // READ
    always @(*) begin
        if (!mem_read) begin
            read_data = 32'b0;
        end else begin
            case (funct3)
                3'b000: begin // LB
                    byte_data = mem[addr];
                    read_data = {{24{byte_data[7]}}, byte_data};
                end

                3'b001: begin // LH
                    half_data = {mem[addr+1], mem[addr]};
                    read_data = {{16{half_data[15]}}, half_data};
                end

                3'b010: begin // LW
                    read_data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                end

                3'b100: begin // LBU
                    byte_data = mem[addr];
                    read_data = {24'b0, byte_data};
                end

                3'b101: begin // LHU
                    half_data = {mem[addr+1], mem[addr]};
                    read_data = {16'b0, half_data};
                end

                default: read_data = 32'b0;
            endcase
        end
    end

endmodule
