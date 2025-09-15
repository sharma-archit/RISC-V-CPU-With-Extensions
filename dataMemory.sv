module dataMemory #(
    parameter XLEN = 64,
    parameter BYTE_SIZE = 8,
    parameter MEM_STEPS = XLEN/BYTE_SIZE,
    parameter SIMULATION_MEMORY_SIZE = 6)
(
    input clk,
    input  read_enable,
    input  write_enable,
    input  [SIMULATION_MEMORY_SIZE - 1:0] read_addr,
    input  [XLEN - 1:0] write_addr,
    input  [XLEN - 1:0] write_data,
    output logic [XLEN - 1:0] read_data
);

logic [XLEN - 1:0] data_memory [2**(SIMULATION_MEMORY_SIZE - 1) - 1:0];

always_comb begin

    read_data <= '0;

    if (read_enable == 1) begin

            read_data <= data_memory[read_addr];

    end
    else if (write_enable == 1) begin

            data_memory[write_addr] <= write_data;

    end

end

endmodule