module instructionMemory #(
    parameter XLEN = 64,
    parameter INSTRUCTION_LENGTH = XLEN/2,
    parameter SIMULATION_MEMORY_SIZE = 6)
(
    input clk,
    input [SIMULATION_MEMORY_SIZE - 2:0] addr,
    output logic [INSTRUCTION_LENGTH - 1:0] instruction,
    output logic [INSTRUCTION_LENGTH - 1:0] next_instruction, // Instructions purely
    output logic [INSTRUCTION_LENGTH - 1:0] next_next_instruction, // for FENCE handling

    // Debug ports to write into instruction memory during testing
    input dbg_wr_en,
    input [SIMULATION_MEMORY_SIZE - 1:0] dbg_addr,
    input [INSTRUCTION_LENGTH - 1:0] dbg_instr
);

logic [INSTRUCTION_LENGTH - 1:0] instruction_memory [2**(SIMULATION_MEMORY_SIZE - 1) - 1:0];

always_comb begin : read

    instruction = instruction_memory[addr];
    next_instruction = instruction_memory[addr + 1];
    next_next_instruction = instruction_memory[addr + 2];

end : read

always_comb begin : dbg_write

    if (dbg_wr_en) begin

        instruction_memory[dbg_addr] = dbg_instr;

    end

end : dbg_write

endmodule
