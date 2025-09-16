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
    dbg_instr = 32'b00000000001100010011000010100011;       //SD
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 1;
    dbg_instr = 32'b00000001001000000000000000001111;       //FENCE
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 2;
    dbg_instr = 32'b00000000010100100000001100110011;       //ADD
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 3;
    dbg_instr = 32'b00000000011101000011010010000011;       //LD
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    rst = 0;

    end

    // clock generator
    always #(CLK_PERIOD/2) clk = !clk;

endmodule