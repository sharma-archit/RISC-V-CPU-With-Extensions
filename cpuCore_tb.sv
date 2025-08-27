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
    dbg_instr = 32'b00000000000100000000000100010011;       //ADDI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 4;
    dbg_instr = 32'b00000000000100001010000110010011;       //SLTI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 8;
    dbg_instr = 32'b00000000000100010011001000010011;       //SLTIU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 12;
    dbg_instr = 32'b00000000000100011111001010010011;       //ANDI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 16;
    dbg_instr = 32'b00000000000100100110001100010011;       //ORI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 20;
    dbg_instr = 32'b00000000000100101100001110010011;       //XORI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 24;
    dbg_instr = 32'b00000000000100110001010000010011;       //SLLI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 28;
    dbg_instr = 32'b00000000000100111101010010010011;       //SRLI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 32;
    dbg_instr = 32'b01000000000101000101010100010011;       //SRAI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 36;
    dbg_instr = 32'b00000000000000000001010110110111;       //LUI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 40;
    dbg_instr = 32'b00000000000000000001011000010111;       //AUIPC
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 44;
    dbg_instr = 32'b00000000110001011000011010110011;       //ADD
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 48;
    dbg_instr = 32'b00000000110101100010011100110011;       //SLT
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 52;
    dbg_instr = 32'b00000000111001101011011110110011;       //SLTU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 56;
    dbg_instr = 32'b00000000111101110111100000110011;       //AND
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 60;
    dbg_instr = 32'b00000001000001111110100010110011;       //OR
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 64;
    dbg_instr = 32'b00000001000110000100100100110011;       //XOR
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 68;
    dbg_instr = 32'b00000001001010001001100110110011;       //SLL
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 72;
    dbg_instr = 32'b00000001001110010101101000110011;       //SRL
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 76;
    dbg_instr = 32'b01000001010010011000101010110011;       //SUB
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 80;
    dbg_instr = 32'b01000001010110100101101100110011;       //SRA
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 84;
    dbg_instr = 32'b00000000001000000000101111101111;       //JAL
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 88;
    dbg_instr = 32'b00000000000110110000110001100111;       //JALR
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 92;
    dbg_instr = 32'b00000001100010111000000101100011;       //BEQ
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 96;
    dbg_instr = 32'b00000001100111000001000101100011;       //BNE
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 100;
    dbg_instr = 32'b00000001101011001100000101100011;       //BLT
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 104;
    dbg_instr = 32'b00000001101111010110000101100011;       //BLTU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 108;
    dbg_instr = 32'b00000001110011011101000101100011;       //BGE
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 112;
    dbg_instr = 32'b00000001110111100111000101100011;       //BGEU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 116;
    dbg_instr = 32'b00000000000111101011111110000011;       //LD
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 120;
    dbg_instr = 32'b00000000000111110010000010000011;       //LW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 124;
    dbg_instr = 32'b00000000000111111110000010000011;       //LWU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 128;
    dbg_instr = 32'b00000000000100000001000100000011;       //LH
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 132;
    dbg_instr = 32'b00000000000100001101000110000011;       //LHU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 136;
    dbg_instr = 32'b00000000000100010000001000000011;       //LB
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 140;
    dbg_instr = 32'b00000000000100011100001010000011;       //LBU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 144;
    dbg_instr = 32'b00000000010100100011000010100011;       //SD
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 148;
    dbg_instr = 32'b00000000011000101010000010100011;       //SW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 152;
    dbg_instr = 32'b00000000011100110001000010100011;       //SH
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 156;
    dbg_instr = 32'b00000000100000111000000010100011;       //SB
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 160;
    dbg_instr = 32'b00000000000000000000000000001111;       //FENCE
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 164;
    dbg_instr = 32'b10000011001100000000000000001111;       //FENCE.TSO
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 168;
    dbg_instr = 32'b00000001000000000000000000001111;       //PAUSE
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 172;
    dbg_instr = 32'b00000000000000000000000001110011;       //ECALL
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 176;
    dbg_instr = 32'b00000000000100000000000001110011;       //EBREAK
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 180;
    dbg_instr = 32'b00000000000101101000011110011011;       //ADDIW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 184;
    dbg_instr = 32'b0000000000101110001100000011011;       //SLLIW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 188;
    dbg_instr = 32'b0000000000101111101100010011011;       //SRLIW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 192;
    dbg_instr = 32'b0100000000110000101100100011011;       //SRAIW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 196;
    dbg_instr = 32'b00000001001010001000100110111011;       //ADDW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 200;
    dbg_instr = 32'b00000001001110010001101000111011;       //SLLW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 204;
    dbg_instr = 32'b00000001010010011101101010111011;       //SRLW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 208;
    dbg_instr = 32'b01000001010110100000101100111011;       //SUBW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 212;
    dbg_instr = 32'b01000001011010101101101110111011;       //SRAW
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