module instructionMemory #(
    parameter XLEN = 64,
    parameter INSTRUCTION_LENGTH = XLEN/2)
(
    input [XLEN - 1:0] addr,
    output logic [3:0][7:0] instruction, // Hack to make this work in vivado
    output logic [3:0][7:0] next_instruction, // Instructions purely for FENCE

    // debug ports to write into instruction memory during testing
    input dbg_wr_en,
    input [XLEN - 1:0] dbg_addr,
    input [3:0][7:0] dbg_instr
);

logic [2^(XLEN - 1)-1:0][7:0] instruction_memory = '0; // instruction memory is half the address-space

always_comb begin : read

    for (int i=0; i < (INSTRUCTION_LENGTH/8); i++) begin //Transfer 8 bit data sets in 4 steps, totalling 32 bits

        // Risk of jumps/branches going into the middle of an instruction since instructions are stored as 4 blocks of 8 bits in here
        // might need to implement same fix as data memory, then can increment pc by just 1 instead of 4

        instruction[i] = instruction_memory[addr + i]; //Hack to make this work in vivado
        next_instruction[i] = instruction_memory[addr + 4 + i];

    end

end : read

always_comb begin : dbg_write

    if (dbg_wr_en) begin

        for (int i=0; i < (INSTRUCTION_LENGTH/8); i++) begin // write 8 bit data sets in 4 steps, totalling 32 bits

        instruction_memory[dbg_addr + i] = dbg_instr[i];

        end

    end

end : dbg_write

endmodule
