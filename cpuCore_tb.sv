module cpuCore_tb #(
    parameter XLEN = 64,
    parameter INSTRUCTION_LENGTH = XLEN/2)
();

logic clk = 0;
logic rst;
logic dbg_wr_en;
logic [XLEN - 1:0] dbg_addr;
logic [INSTRUCTION_LENGTH - 1:0] dbg_instr;

const time CLK_PERIOD = 8;

cpuCore cpu_core(.*);

    initial begin

    rst = 1;
    dbg_wr_en = 0;
    dbg_addr = 0;

    end

    // clock generator
    always #(CLK_PERIOD/2) clk = !clk;

endmodule