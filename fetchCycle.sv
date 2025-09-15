module fetchCycle #(
    parameter XLEN = 64,
    parameter INSTRUCTION_LENGTH = XLEN/2)
(   
    input clk,
    input rst,
    input  [XLEN - 1:0] PC_in, // From Decode
    output logic [XLEN - 1:0] PC_out,
    output [INSTRUCTION_LENGTH - 1:0] instruction,
    output [INSTRUCTION_LENGTH - 1:0] next_instruction,
    // Debug ports to write into instruction memory during testing
    input dbg_wr_en,
    input [XLEN - 1:0] dbg_addr,
    input [INSTRUCTION_LENGTH - 1:0] dbg_instr
);

logic count_start; // Force PC to start incrementing after PC = 0 for only one clock cycle starting at the first rising edge after reset deasserted

always_ff @(posedge clk) begin

    if (rst) begin

        PC_out <= '0;
        count_start <= '0;

    end
    else begin

        count_start <= '1;
        PC_out <= count_start ? PC_in + 1 : PC_in;
        
    end
    
end


instructionMemory instruction_memory (
    .addr(PC_out),
    .instruction(instruction),
    .dbg_wr_en(dbg_wr_en),
    .dbg_addr(dbg_addr),
    .dbg_instr(dbg_instr)
    );

endmodule
