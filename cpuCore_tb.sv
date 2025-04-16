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
    dbg_instr = 32'b00000000000100000000000010010011;       //ADDI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 4;
    dbg_instr = 32'b00000000001000001010000100010011;       //SLTI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 8;
    dbg_instr = 32'b00000000001000001011000110010011;       //SLTIU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 12;
    dbg_instr = 32'b00010101100100001111001000010011;       //ANDI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 16;
    dbg_instr = 32'b00010101100100001110001000010011;       //ORI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 20;
    dbg_instr = 32'b00010101100100001100001010010011;       //XORI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 24;
    dbg_instr = 32'b00000000001000001001001100010011;       //SLLI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 28;
    dbg_instr = 32'b00000000001000001101001110010011;       //SRLI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 32;
    dbg_instr = 32'b01000000001000001101010000010011;       //SRAI
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