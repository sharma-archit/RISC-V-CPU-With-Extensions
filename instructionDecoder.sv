module instructionDecoder #(
    parameter XLEN = 64,
    parameter UIMMEDIATE = 20, // Bit location if there is uimmediate in the opcode
    parameter REGISTER_SIZE = 5, // Bit size of register address in opcode = clog2(32)
    parameter DESTINATION_REGISTER_LOC = 12, // Bit location of destination register address in opcode
    parameter ALU_SEL_SIZE = 4, // Bit size of alu selection
    parameter JALR_OFFSET_SIZE = 12, // Bit size of jalr offset in opcode
    parameter JAL_OFFSET_SIZE = 20,
    parameter SOURCE_REGISTER1_LOC = 20, // Bit location of source register 1 address in opcode
    parameter SOURCE_REGISTER2_LOC = 25, // Bit location of source register 2 address in opcode
    parameter LOAD_OFFSET = 12, // Bit size of load offset in opcode
    parameter BYTE = 8,
    parameter HALFWORD = 16,
    parameter WORD = 32,
    parameter IRII_IMMEDIATE = 12, // Bit location of immediate value in irii opcode
    parameter SHIFT_SIZE = 6, // Bit size of shift amount in opcode
    parameter FUNCT3 = 15, // Bit location of funct3 in opcode
    parameter FUNCT3_SIZE = 3, // Bit size of funct3 value in opcode
    parameter FUNCT12 = 12, // Bit size of funct12 value in opcode
    parameter INSTRUCTION_LENGTH = XLEN/2,
    parameter FENCE_FM = 4,
    parameter PREDECESSOR = 4,
    parameter SUCCESSOR = 4)
(
    input logic [INSTRUCTION_LENGTH - 1:0] instruction,
    input logic [XLEN - 1:0] PC_in,

    // Destination and source registers of the current instruction
    output logic [REGISTER_SIZE - 1:0] destination_reg,
    output logic [REGISTER_SIZE - 1:0] source_reg1,
    output logic [REGISTER_SIZE - 1:0] source_reg2,

    output logic alu_enable,
    output logic [ALU_SEL_SIZE - 1:0] alu_sel,
    output logic [SHIFT_SIZE - 1: 0] alu_shift_amt,
    output logic [XLEN - 1:0] alu_data_in_a,
    output logic [XLEN - 1:0] alu_data_in_b,
    
    output logic [FUNCT3_SIZE - 1:0] jbl_operation,
    output logic [JALR_OFFSET_SIZE - 1:0] jbl_offset,
    output logic [JAL_OFFSET_SIZE - 1:0] jbl_jal_offset,
    output logic [XLEN - 1:0] jbl_data_in1,
    output logic [XLEN - 1:0] jbl_data_in2,
    output logic [XLEN - 1:0] jbl_address_in,

    output logic rf_read_enable1,
    output logic rf_read_enable2,
    output logic [REGISTER_SIZE - 1:0] rf_read_addr1,
    output logic [REGISTER_SIZE - 1:0] rf_read_addr2,
    input logic [XLEN - 1:0] rf_read_data1,
    input logic [XLEN - 1:0] rf_read_data2,

    output logic rf_write_enable,
    output logic [1:0] rf_write_data_sel,
    output logic [REGISTER_SIZE - 1:0] rf_write_addr,
    
    output logic dm_read_enable,
    output logic dm_write_enable,
    output logic [XLEN - 1:0] dm_write_data,
    output logic [2:0] dm_load_type,

    // Pipeline control signals
    output logic f_to_d_enable_ff,
    output logic d_to_e_enable_ff,
    output logic [PREDECESSOR - 1:0] fence_pred,
    output logic [SUCCESSOR - 1:0] fence_succ
);

// 7-bit opcodes //
// Stand-alone instructions
const logic [6:0] LUI     = 7'b0110111;
const logic [6:0] AUIPC   = 7'b0010111;
const logic [6:0] JAL     = 7'b1101111;
const logic [6:0] JALR    = 7'b1100111;
// Instruction groups
const logic [6:0] BRANCH  = 7'b1100011;
const logic [6:0] LOAD    =  7'b0000011;
const logic [6:0] STORE   = 7'b0100011;
const logic [6:0] IRII    = 7'b0010011;
const logic [6:0] IRRO    = 7'b0110011;
const logic [6:0] FENCE   = 7'b0001111;
const logic [6:0] ECB     = 7'b1110011;
const logic [6:0] IRIIW   = 7'b0011011;
const logic [6:0] IRROW   = 7'b0111011;
const logic [6:0] LOADW   = 7'b0000011;
const logic [6:0] STOREW  = 7'b0100011;

enum {ADD, SUB, SLT, SLTU, ANDI, ORI, XORI, SLL, SRL, SRA, ALU_LUI, ALU_AUIPC, ADDW, SUBW, SLLW, SRLW, SRAW} ALU_OP_E; // ANDI, ORI, and XORI are used to avoid using SystemVerilog keywords
enum {JBL_JAL, JBL_JALR, BEQ, BNE, BLT, BGE, BLTU, BGEU} JBL_OP_E;
enum {LOAD_B, LOAD_H, LOAD_W, LOAD_D, LOAD_BU, LOAD_HU, LOAD_WU} LOAD_OP_E; // To size load data in the mem_access cycle
enum {ALU, DATA_MEM} WRITEBACK_DATA_SEL_E; // To select the source of write data in the writeback cycle

always_comb begin : decoder

    // Default all control signals to 0
    alu_enable = 0;
    alu_sel = 0;
    alu_shift_amt = '0;
    alu_data_in_a = '0;
    alu_data_in_b = '0;
    
    jbl_operation = '0;
    jbl_offset = '0;
    jbl_jal_offset = '0;
    jbl_data_in1 = '0;
    jbl_data_in1 = '0;
    jbl_address_in = '0;

    rf_read_enable1 = '0;
    rf_read_enable2 = '0;
    rf_read_addr1 = '0;
    rf_read_addr2 = '0;
    
    rf_write_enable = 0;
    rf_write_addr = '0;
    rf_write_data_sel = '0;
    
    dm_read_enable = '0;
    dm_write_enable = '0;
    dm_write_data = '0;
    dm_load_type = '0;

    destination_reg = 0;
    source_reg1 = 0;
    source_reg2 = 0;

    // Decode each instruction opcode
    case (instruction[6:0])
    
        LUI: begin

            alu_enable = 1;
            alu_sel = ALU_LUI;
            alu_data_in_a = {{(XLEN - UIMMEDIATE){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - UIMMEDIATE]};
            
            rf_write_enable = 1;
            rf_write_addr = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE]; // Which CPU reg to write to
            rf_write_data_sel = ALU; // RF write data to be computed in the execute cycle
            
            destination_reg = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            source_reg1 = 'x;
            source_reg2 = 'x;
            
        end

        AUIPC: begin
            
            alu_enable = 1;
            alu_sel = ALU_AUIPC;
            alu_data_in_a = {{(XLEN - UIMMEDIATE){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - UIMMEDIATE]};
            alu_data_in_b = PC_in; // Make sure PC value is the value to the AUIPC instruction

            rf_write_enable = 1;
            rf_write_addr = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE]; // Which CPU reg to write to
            rf_write_data_sel = ALU; // RF write data to be computed in the execute cycle

            destination_reg = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            source_reg1 = 'x;
            source_reg2 = 'x;

        end

        JAL: begin
            
            alu_enable = 1; // Use ALU to compute current PC + 8
            alu_sel = ADD;
            alu_data_in_a = PC_in;
            alu_data_in_b = 4;

            jbl_operation = JBL_JAL;
            jbl_jal_offset = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]}; // Reordering jal offset from instruction
            jbl_address_in = PC_in; // Make sure the PC value is the value of the JAL instruction

            rf_write_enable = 1;
            rf_write_addr = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            rf_write_data_sel = ALU; // Current PC + 4;

            destination_reg = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            source_reg1 = 'x;
            source_reg2 = 'x;

        end

        JALR: begin
            
            alu_enable = 1;
            alu_sel = ADD;
            alu_data_in_a = PC_in;
            alu_data_in_b = 4;
            
            jbl_operation = JBL_JALR;
            jbl_offset = instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - JALR_OFFSET_SIZE];
            jbl_address_in = rf_read_data1;

            // Read register rs1, write PC+8 to register rd
            rf_read_enable1 = 1;
            rf_read_addr1 = instruction[SOURCE_REGISTER1_LOC - 1:SOURCE_REGISTER1_LOC - REGISTER_SIZE];
            rf_write_enable = 1;
            rf_write_addr = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            rf_write_data_sel = ALU; // Current PC + 4

            destination_reg = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            source_reg1 = instruction[SOURCE_REGISTER1_LOC - 1: SOURCE_REGISTER1_LOC - REGISTER_SIZE];
            source_reg2 = 'x;

        end

        BRANCH: begin

            jbl_offset = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]}; // Reordered immediate value
            jbl_data_in1 = rf_read_data1;
            jbl_data_in1 = rf_read_data2;
            jbl_address_in = PC_in; // PC value of the branch instruction being decoded

            rf_read_enable1 = 1;
            rf_read_enable2 = 1;
            rf_read_addr1 = instruction[SOURCE_REGISTER1_LOC - 1:SOURCE_REGISTER1_LOC - REGISTER_SIZE];
            rf_read_addr2 = instruction[SOURCE_REGISTER2_LOC - 1:SOURCE_REGISTER2_LOC - REGISTER_SIZE];

            destination_reg = 'x;
            source_reg1 = instruction[SOURCE_REGISTER1_LOC - 1: SOURCE_REGISTER1_LOC - REGISTER_SIZE];
            source_reg2 = instruction[SOURCE_REGISTER2_LOC - 1: SOURCE_REGISTER2_LOC - REGISTER_SIZE];

            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b000) begin // BEQ_
            
                jbl_operation = BEQ;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b001) begin // BNE

                jbl_operation = BNE;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b100) begin // BLT

                jbl_operation = BLT;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101) begin // BGE_

                jbl_operation = BGE;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b110) begin // BLTU_

                jbl_operation = BLTU;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b111) begin // BGEU_

                jbl_operation = BGEU;

            end
        end
        
        LOAD: begin

                alu_enable = 1;
                alu_sel = ADD;
                alu_data_in_a = {{(XLEN - LOAD_OFFSET){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - LOAD_OFFSET]}; // Target address offset
                alu_data_in_b = rf_read_data1; // Target base address
                
                rf_read_enable1 = 1;
                rf_read_addr1 = instruction[SOURCE_REGISTER1_LOC:SOURCE_REGISTER1_LOC - REGISTER_SIZE]; // Address of cpu register holding base address
                
                rf_write_enable = 1;
                rf_write_addr = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE]; // Address of destination cpu register to load data into

                dm_read_enable = 1;
                
                rf_write_data_sel = DATA_MEM;

                destination_reg = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
                source_reg1 = instruction[SOURCE_REGISTER1_LOC - 1: SOURCE_REGISTER1_LOC - REGISTER_SIZE];
                source_reg2 = 'x;

                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b000) begin // LB
                    dm_load_type = LOAD_B;
                end
                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b001) begin // LH
                    dm_load_type = LOAD_H;
                end
                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b010) begin // LW
                    dm_load_type = LOAD_W;
                end
                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b011) begin // LD
                    dm_load_type = LOAD_D;
                end
                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b100) begin // LBU
                    dm_load_type = LOAD_BU;
                end
                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101) begin // LHU
                    dm_load_type = LOAD_HU;
                end
                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b110) begin // LWU
                    dm_load_type = LOAD_WU;
                end
        end

        STORE: begin
    
                alu_enable = 1;
                alu_sel = ADD;

                alu_data_in_a = {{(XLEN - 12){instruction[INSTRUCTION_LENGTH-1]}}, instruction[INSTRUCTION_LENGTH - 1:25], instruction[11:7]}; // Target address offset 
                alu_data_in_b = rf_read_data1; // target base address

                rf_read_enable1 = 1;
                rf_read_enable2 = 1;
                rf_read_addr1 = instruction[SOURCE_REGISTER1_LOC - 1:SOURCE_REGISTER1_LOC - REGISTER_SIZE]; // Cpu register where target base addr is stored
                rf_read_addr2 = instruction[SOURCE_REGISTER2_LOC - 1:SOURCE_REGISTER2_LOC - REGISTER_SIZE]; // Data value to store into data memory

                dm_write_enable = 1;

                destination_reg = 'x;
                source_reg1 = instruction[SOURCE_REGISTER1_LOC - 1: SOURCE_REGISTER1_LOC - REGISTER_SIZE];
                source_reg2 = instruction[SOURCE_REGISTER2_LOC - 1: SOURCE_REGISTER2_LOC - REGISTER_SIZE];

                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b000) begin // SB
                    dm_write_data = {{(XLEN - BYTE){rf_read_data2[BYTE - 1]}}, rf_read_data2[BYTE - 1:0]}; // Data byte sign extended to 64 bits
                end

                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b001) begin // SH
                    dm_write_data = {{(XLEN - HALFWORD){rf_read_data2[HALFWORD - 1]}}, rf_read_data2[HALFWORD - 1:0]};
                end

                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b010) begin // SW
                    dm_write_data = {{(XLEN - WORD){rf_read_data2[WORD - 1]}}, rf_read_data2[WORD - 1:0]};
                end
                if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b011) begin // SD
                    dm_write_data = rf_read_data2;
                end
        end

        IRII: begin 

                alu_enable = 1;

                rf_read_enable1 = 1;
                rf_read_addr1 = instruction[SOURCE_REGISTER1_LOC - 1:SOURCE_REGISTER1_LOC - REGISTER_SIZE];

                rf_write_enable = 1;
                rf_write_addr = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
                rf_write_data_sel = ALU;

                destination_reg = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
                source_reg1 = instruction[SOURCE_REGISTER1_LOC - 1: SOURCE_REGISTER1_LOC - REGISTER_SIZE];
                source_reg2 = 'x;

            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b000) begin // ADDI

                alu_sel = ADD;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = {{(XLEN - IRII_IMMEDIATE){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE]}; // Sign extended immediate value

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b010) begin // SLTI

                alu_sel = SLT;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = {{(XLEN - IRII_IMMEDIATE){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE]}; // Sign extended immediate value

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b011) begin // SLTIU

                alu_sel = SLTU;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = {{(XLEN - IRII_IMMEDIATE){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE]}; // Sign extended immediate value

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b100) begin // XORI

                alu_sel = XORI;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = {{(XLEN - IRII_IMMEDIATE){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE]}; // Sign extended immediate value

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b110) begin // ORI

                alu_sel = ORI;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = {{(XLEN - IRII_IMMEDIATE){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE]}; // Sign extended immediate value

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b111) begin // ANDI

                alu_sel = ANDI;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = {{(XLEN - IRII_IMMEDIATE){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE]}; // Sign extended immediate value

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b001 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b000000) begin // SLLI

                alu_sel = SLL;
                alu_shift_amt = instruction[INSTRUCTION_LENGTH - IRII_IMMEDIATE + SHIFT_SIZE - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE]; // Shift amount is lower 6 bits of immediate value
                alu_data_in_a = rf_read_data1;
            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b000000) begin // SRLI

                alu_sel = SRL;
                alu_shift_amt = instruction[INSTRUCTION_LENGTH - IRII_IMMEDIATE + SHIFT_SIZE - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE];
                alu_data_in_a = rf_read_data1;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b010000) begin // SRAI

                alu_sel = SRA;
                alu_shift_amt = instruction[INSTRUCTION_LENGTH - IRII_IMMEDIATE + SHIFT_SIZE - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE];
                alu_data_in_a = rf_read_data1;

            end
        end

        IRRO: begin

            alu_enable = 1;

            rf_read_enable1 = 1;
            rf_read_enable2 = 1;
            rf_read_addr1 = instruction[SOURCE_REGISTER1_LOC - 1:SOURCE_REGISTER1_LOC - REGISTER_SIZE];
            rf_read_addr2 = instruction[SOURCE_REGISTER2_LOC - 1:SOURCE_REGISTER2_LOC - REGISTER_SIZE];

            rf_write_enable = 1;
            rf_write_addr = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            rf_write_data_sel = ALU;

            destination_reg = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            source_reg1 = instruction[SOURCE_REGISTER1_LOC - 1: SOURCE_REGISTER1_LOC - REGISTER_SIZE];
            source_reg2 = instruction[SOURCE_REGISTER2_LOC - 1: SOURCE_REGISTER2_LOC - REGISTER_SIZE];
            
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b000 && instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 7] == 7'b0000000) begin // ADD

                alu_sel = ADD;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = rf_read_data2;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b000 && instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 7] == 7'b0100000) begin // SUB

                alu_sel = SUB;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = rf_read_data2;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b001 && instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 7] == 7'b0000000) begin // SLL

                alu_sel = SLL;
                alu_shift_amt = rf_read_data2[SHIFT_SIZE - 1:0]; // Shift amount is lower 6 bits of register value
                alu_data_in_a = rf_read_data1;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b010) begin // SLT

                alu_sel = SLT;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = rf_read_data2;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b011) begin // SLTU

                alu_sel = SLTU;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = rf_read_data2;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b100) begin // XOR

                alu_sel = XORI;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = rf_read_data2;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101 && instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 7] == 7'b0000000) begin // SRL

                alu_sel = SRL;
                alu_shift_amt = rf_read_data2[SHIFT_SIZE - 1:0];
                alu_data_in_a = rf_read_data1;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101 && instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 7] == 7'b0100000) begin // SRA

                alu_sel = SRA;
                alu_shift_amt = rf_read_data2[SHIFT_SIZE - 1:0];
                alu_data_in_a = rf_read_data1;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b110) begin // OR

                alu_sel = ORI;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = rf_read_data2;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b111) begin // AND

                alu_sel = ANDI;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = rf_read_data2;

            end

        end
        
        FENCE: begin

            // NOP since instruction is not implemented
            alu_enable = 1;

            rf_read_enable1 = 1;
            rf_read_addr1 = 0;

            rf_write_enable = 1;
            rf_write_addr = 0;
            rf_write_data_sel = ALU;

            destination_reg = 0;
            source_reg1 = 0;
            source_reg2 = 'x;

            alu_sel = ADD;
            alu_data_in_a = rf_read_data1;
            alu_data_in_b = 0;

            if (instruction[INSTRUCTION_LENGTH - 1 : INSTRUCTION_LENGTH - FENCE_FM] == 4'b1000) begin // TSO Fence

            end
            else begin // Normal Fence

                fence_pred = instruction[INSTRUCTION_LENGTH - FENCE_FM - 1: INSTRUCTION_LENGTH - FENCE_FM - PREDECESSOR];
                fence_succ = instruction[INSTRUCTION_LENGTH - FENCE_FM - PREDECESSOR - 1: INSTRUCTION_LENGTH - FENCE_FM - PREDECESSOR - SUCCESSOR];

            end
        end
        
        ECB: begin // Cannot be implemented in current unprivileged design

            if(instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - FUNCT12] == 12'b000000000000) begin // ECALL: System call

                // NOP since instruction is not implemented
                alu_enable = 1;

                rf_read_enable1 = 1;
                rf_read_addr1 = 0;

                rf_write_enable = 1;
                rf_write_addr = 0;
                rf_write_data_sel = ALU;

                destination_reg = 0;
                source_reg1 = 0;
                source_reg2 = 'x;

                alu_sel = ADD;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = 0;

            end

            if(instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - FUNCT12] == 12'b000000000001) begin // EBREAK: Debugging breakpoint

                // NOP since instruction is not implemented
                alu_enable = 1;

                rf_read_enable1 = 1;
                rf_read_addr1 = 0;

                rf_write_enable = 1;
                rf_write_addr = 0;
                rf_write_data_sel = ALU;

                destination_reg = 0;
                source_reg1 = 0;
                source_reg2 = 'x;

                alu_sel = ADD;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = 0;

            end

        end

        IRIIW: begin

            alu_enable = 1;

            rf_read_enable1 = 1;
            rf_read_addr1 = instruction[SOURCE_REGISTER1_LOC - 1:SOURCE_REGISTER1_LOC - REGISTER_SIZE];

            rf_write_enable = 1;
            rf_write_addr = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            rf_write_data_sel = ALU;

            destination_reg = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            source_reg1 = instruction[SOURCE_REGISTER1_LOC - 1: SOURCE_REGISTER1_LOC - REGISTER_SIZE];
            source_reg2 = 'x;

            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b000) begin // ADDIW

                alu_sel = ADDW;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = {{(XLEN - IRII_IMMEDIATE){instruction[INSTRUCTION_LENGTH - 1]}}, instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE]}; // Sign extended immediate value

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b001 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b000000 & instruction[INSTRUCTION_LENGTH - 7] == 1'b0) begin // SLLIW

                alu_sel = SLLW;
                alu_shift_amt = instruction[INSTRUCTION_LENGTH - IRII_IMMEDIATE + SHIFT_SIZE - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE]; // Shift amount is lower 5 bits of immediate value
                alu_data_in_a = rf_read_data1;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b000000 & instruction[INSTRUCTION_LENGTH - 7] == 1'b0) begin // SRLIW

                alu_sel = SRLW;
                alu_shift_amt = instruction[INSTRUCTION_LENGTH - IRII_IMMEDIATE + SHIFT_SIZE - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE];
                alu_data_in_a = rf_read_data1;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b010000 & instruction[INSTRUCTION_LENGTH - 7] == 1'b0) begin // SRAIW

                alu_sel = SRAW;
                alu_shift_amt = instruction[INSTRUCTION_LENGTH - IRII_IMMEDIATE + SHIFT_SIZE - 1:INSTRUCTION_LENGTH - IRII_IMMEDIATE];
                alu_data_in_a = rf_read_data1;

            end

        end

        IRROW: begin
            
            alu_enable = 1;

            rf_read_enable1 = 1;
            rf_read_enable2 = 1;
            rf_read_addr1 = instruction[SOURCE_REGISTER1_LOC - 1:SOURCE_REGISTER1_LOC - REGISTER_SIZE];
            rf_read_addr2 = instruction[SOURCE_REGISTER2_LOC - 1:SOURCE_REGISTER2_LOC - REGISTER_SIZE];

            rf_write_enable = 1;
            rf_write_addr = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            rf_write_data_sel = ALU;

            destination_reg = instruction[DESTINATION_REGISTER_LOC - 1:DESTINATION_REGISTER_LOC - REGISTER_SIZE];
            source_reg1 = instruction[SOURCE_REGISTER1_LOC - 1: SOURCE_REGISTER1_LOC - REGISTER_SIZE];
            source_reg2 = instruction[SOURCE_REGISTER2_LOC - 1: SOURCE_REGISTER2_LOC - REGISTER_SIZE];

            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b000 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b000000) begin // ADDW

                alu_sel = ADDW;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = rf_read_data2;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b001 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b000000) begin // SLLW

                alu_sel = SLLW;
                alu_shift_amt = {1'b0, rf_read_data2[SHIFT_SIZE - 2: 0]}; // Shift amount is lower 5 bits of immediate value
                alu_data_in_a = rf_read_data1;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b000000) begin // SRLW

                alu_sel = SRLW;
                alu_shift_amt = {1'b0, rf_read_data2[SHIFT_SIZE - 2: 0]};
                alu_data_in_a = rf_read_data1;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b000 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b010000) begin // SUBW

                alu_sel = SUBW;
                alu_data_in_a = rf_read_data1;
                alu_data_in_b = rf_read_data2;

            end
            if (instruction[FUNCT3 - 1:FUNCT3 - FUNCT3_SIZE] == 3'b101 & instruction[INSTRUCTION_LENGTH - 1:INSTRUCTION_LENGTH - 6] == 7'b010000) begin // SRAW

                alu_sel = SRAW;
                alu_shift_amt = {1'b0, rf_read_data2[SHIFT_SIZE - 2: 0]};
                alu_data_in_a = rf_read_data1;

            end
        end

        default: begin
            // Since all signals are set to zero in the beginning of the decode cycle nothing will happen if it's an invalid instruction
        end

    endcase

end : decoder

endmodule
