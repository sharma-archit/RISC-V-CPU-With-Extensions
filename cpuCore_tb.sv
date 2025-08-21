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
    dbg_instr = 32'b00000000000100001000000000010011;       //ADDI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 4;
    dbg_instr = 32'b00000000000100010010000010010011;       //SLTI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 8;
    dbg_instr = 32'b00000000000100011011000100010011;       //SLTIU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 12;
    dbg_instr = 32'b00000000000100100111000110010011;       //ANDI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 16;
    dbg_instr = 32'b00000000000100101110001000010011;       //ORI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 20;
    dbg_instr = 32'b00000000000100110100001010010011;       //XORI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 24;
    dbg_instr = 32'b00000000000100111001001100010011;       //SLLI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 28;
    dbg_instr = 32'b00000000000101000101001110010011;       //SRLI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 32;
    dbg_instr = 32'b01000000000101001101010000010011;       //SRAI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 36;
    dbg_instr = 32'b00000000000000000001010010110111;       //LUI
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 40;
    dbg_instr = 32'b00000000000000000001010100010111;       //AUIPC
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 44;
    dbg_instr = 32'b00000000110101100000010110110011;       //ADD
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 48;
    dbg_instr = 32'b00000000111001101010011000110011;       //SLT
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 52;
    dbg_instr = 32'b00000000111101110011011010110011;       //SLTU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 56;
    dbg_instr = 32'b00000001000001111111011100110011;       //AND
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 60;
    dbg_instr = 32'b00000001000110000110011110110011;       //OR
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 64;
    dbg_instr = 32'b00000001001010001100100000110011;       //XOR
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 68;
    dbg_instr = 32'b00000001001110010001100010110011;       //SLL
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 72;
    dbg_instr = 32'b00000001010010011101100100110011;       //SRL
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 76;
    dbg_instr = 32'b01000001010110100000100110110011;       //SUB
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 80;
    dbg_instr = 32'b01000001011010101101101000110011;       //SRA
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 84;
    dbg_instr = 32'b00000000001000000000101011101111;       //JAL
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 88;
    dbg_instr = 32'b00000000000110111000101101100111;       //JALR
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 92;
    dbg_instr = 32'b00000001100111000000000101100011;       //BEQ
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 96;
    dbg_instr = 32'b00000001101011001001000101100011;       //BNE
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 100;
    dbg_instr = 32'b00000001101111010100000101100011;       //BLT
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 104;
    dbg_instr = 32'b00000001110011011110000101100011;       //BLTU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 108;
    dbg_instr = 32'b00000001110111100101000101100011;       //BGE
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 112;
    dbg_instr = 32'b00000001111011101111000101100011;       //BGEU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 116;
    dbg_instr = 32'b00000000000111110011111010000011;       //LD
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 120;
    dbg_instr = 32'b00000000000111111010111100000011;       //LW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 124;
    dbg_instr = 32'b00000000000100000110111110000011;       //LWU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 128;
    dbg_instr = 32'b00000000000100001001000000000011;       //LH
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 132;
    dbg_instr = 32'b00000000000100010101000010000011;       //LHU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 136;
    dbg_instr = 32'b00000000000100011000000100000011;       //LB
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 140;
    dbg_instr = 32'b00000000000100100100000110000011;       //LBU
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 144;
    dbg_instr = 32'b00000000011000101011000010100011;       //SD
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 148;
    dbg_instr = 32'b00000000011100110010000010100011;       //SW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 152;
    dbg_instr = 32'b00000000100000111001000010100011;       //SH
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 156;
    dbg_instr = 32'b00000000100101000000000010100011;       //SB
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
    dbg_instr = 32'b00000000000101110000011010011011;       //ADDIW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 184;
    dbg_instr = 32'b0000000000101111001011100011011;       //SLLIW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 188;
    dbg_instr = 32'b0000000000110000101011110011011;       //SRLIW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 192;
    dbg_instr = 32'b0100000000110001101100000011011;       //SRAIW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 196;
    dbg_instr = 32'b00000001001110010000100010111011;       //ADDW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 200;
    dbg_instr = 32'b00000001010010011001100100111011;       //SLLW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 204;
    dbg_instr = 32'b00000001010110100101100110111011;       //SRLW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 208;
    dbg_instr = 32'b01000001011010101000101000111011;       //SUBW
    #(2*CLK_PERIOD)
    dbg_wr_en = 1;
    #CLK_PERIOD
    dbg_wr_en = 0;
    #CLK_PERIOD
    dbg_addr = 212;
    dbg_instr = 32'b01000001011110110101101010111011;       //SRAW
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