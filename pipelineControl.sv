module pipelineControl #(
    parameter XLEN = 64,
    parameter REGISTER_SIZE = 5,
    parameter SHIFT_DEPTH = 3,  // Current and previous two instructions
    parameter INSTRUCTION_LENGTH = XLEN/2,
    parameter PREDECESSOR = 4,
    parameter SUCCESSOR = 4,
    parameter OPCODE = 7,
    parameter ADDRESS_LENGTH = )
(
    input clk,
    input rst,
    input [INSTRUCTION_LENGTH - 1:0] instruction,
    input [INSTRUCTION_LENGTH - 1:0] instruction_direct,
    input [INSTRUCTION_LENGTH - 1:0] next_instruction,
    input [REGISTER_SIZE - 1:0] destination_reg,
    input [REGISTER_SIZE - 1:0] source_reg1,
    input [REGISTER_SIZE - 1:0] source_reg2,
    input dm_read_enable,
    input dm_write_enable,
    input [XLEN - 1:0] dm_read_data,

    // Signals coming from the instruction decoder
    input logic [XLEN - 1:0] dec_alu_data_in_a,
    input logic [XLEN - 1:0] dec_alu_data_in_b,
    input logic [XLEN - 1:0] alu_data_out,
    input logic [XLEN - 1:0] dec_jbl_data_in1,
    input logic [XLEN - 1:0] dec_jbl_data_in2,
    input logic [XLEN - 1:0] dec_jbl_address_in,
    input logic [XLEN - 1:0] dec_dm_write_data,
    input logic [XLEN - 1:0] dm_data_bypass,
    input logic [PREDECESSOR - 1:0] fence_pred, // Predecessor is instructions after decode cycle
    input logic [SUCCESSOR - 1:0] fence_succ, // Successor is instructions before decode cycle

    // Signals to go to the pipeline register
    output logic [XLEN - 1:0] alu_data_in_a,
    output logic [XLEN - 1:0] alu_data_in_b,
    output logic [XLEN - 1:0] jbl_data_in1,
    output logic [XLEN - 1:0] jbl_data_in2,
    output logic [XLEN - 1:0] jbl_address_in,
    output logic [XLEN - 1:0] dm_write_data,

    // Pipeline flop stall signals
    output logic f_to_d_enable_ff, // Fetch to decode ff enable
    output logic d_to_e_enable_ff // Decode to execute ff enable
);

logic [1:0] [1:0] pipeline_forward_sel; // Data fwd source mux select

const logic A = 0;
const logic B = 1;

typedef struct packed {
    logic [REGISTER_SIZE - 1:0] destination;
    logic [REGISTER_SIZE - 1:0] source1;
    logic [REGISTER_SIZE - 1:0] source2;
} instr_registers_t;

// Internally storing dest/source registers for current and previous two instructions
// NOTE: instr_reg_info[0] = current instruction (in decode cycle)
//       instr_reg_info[1] = previous instruction (in execute cycle)
//       instr_reg_info[2] = previous previous instruction (in memory writeback cycle)
instr_registers_t [SHIFT_DEPTH - 1:0] instr_reg_info;

logic [SHIFT_DEPTH - 1:0] dm_read_enable_d;

logic stall_trigger;
int stall_counter;

logic [SHIFT_DEPTH - 1:0] before_current_instruction;
logic [SHIFT_DEPTH - 1:0] after_current_instruction;

logic [SHIFT_DEPTH - 1:0] [INSTRUCTION_LENGTH - 1:0] predecessor_instructions;
logic [SHIFT_DEPTH - 1:0] [INSTRUCTION_LENGTH - 1:0] successor_instructions;

logic [SHIFT_DEPTH - 1:0] [XLEN - 1:0] previous_alu_data_out; // Impossible to get alu_data_out when instruction is in decode phase, only 1 cycle and 2 cycle old data available

enum logic [1:0] {DECODE_RF_OPERAND, MEM_ACCESS_DM_OPERAND, EXECUTE_ALU_OPERAND, MEM_ACCESS_ALU_OPERAND} DATA_FWD_SOURCE;

always_ff @(posedge(clk)) begin : reg_info_shift_reg

    // Push current instruction into shift reg
    instr_reg_info[0].destination <= destination_reg;
    instr_reg_info[0].source1 <= source_reg1;
    instr_reg_info[0].source2 <= source_reg2;

    if (rst) begin

        for (int i = 0; i < SHIFT_DEPTH - 2; i = i + 1) begin
            
            instr_reg_info[i] <= '0;
            
        end

    end

    else begin

        // Cycle instructions 
        for (int i = 0; i < SHIFT_DEPTH - 2; i = i + 1) begin
            
            instr_reg_info[i + 1].destination <= instr_reg_info[i].destination;
            instr_reg_info[i + 1].source1 <= instr_reg_info[i].source1;
            instr_reg_info[i + 1].source2 <= instr_reg_info[i].source2;
            
        end

    end

end : reg_info_shift_reg

always_ff @(posedge(clk)) begin : load_enable_shift_reg

    dm_read_enable_d[0] <= dm_read_enable;

    if (rst) begin

        for (int i = 0; i < SHIFT_DEPTH - 1; i = i + 1) begin
            
            dm_read_enable_d[i + 1] <= '0;
            
        end

    end
    else begin

        for (int i = 0; i < SHIFT_DEPTH - 1; i = i + 1) begin
            
            dm_read_enable_d[i + 1] <= dm_read_enable_d[i];
            
        end
    
    end

end : load_enable_shift_reg

always_comb begin : pipeline_data_hazard_detection

    pipeline_forward_sel[A] = DECODE_RF_OPERAND;
    pipeline_forward_sel[B] = DECODE_RF_OPERAND;

    // Need to check if the current instruction has a data hazard with the previous two instructions in the pipeline
    for (int i = 1; i < 3 ; i = i + 1) begin
    
        // If a past instruction's destination reg is source1 reg for the current instruction
        if (instr_reg_info[i].destination == instr_reg_info[0].source1 && instr_reg_info[i].destination !== 0 && instr_reg_info[0].source1 !== 0) begin
            
            // For previous load instructions
            if (dm_read_enable_d[i]) begin : load_instr_A

                if (i == 1) begin // Conflicting load instruction is currently in execute cycle

                    // Order a stall since the previous load instruction must be in the memory access cycle to produce the operand that will be forwarded to the decode stage
                    stall_trigger = 1;
                    stall_counter = 2;

                end
                else if (i == 2) begin // Conflicting load instruction is currently in memory access cycle

                    pipeline_forward_sel[A] = MEM_ACCESS_DM_OPERAND;

                end
            end : load_instr_A
            
            // For non-load previous instructions
            else begin : non_load_instr_A

                if (i == 1) begin
                    // Forward alu_data_out from execute cycle to decode cycle
                    pipeline_forward_sel[A] = EXECUTE_ALU_OPERAND;
                end
                else begin
                // Forward alu_data_out from memory access cycle to decode cycle
                pipeline_forward_sel[A] = MEM_ACCESS_ALU_OPERAND;

                end

            end : non_load_instr_A

        end

        // If a past instruction's destination reg is source2 reg for the current instruction
        if (instr_reg_info[i].destination == instr_reg_info[0].source2 && instr_reg_info[i].destination !== 0 && instr_reg_info[0].source2 !== 0) begin
            
            // For previous load instructions
            if (dm_read_enable_d[i]) begin : load_instr_B

                if (i == 1) begin // Conflicting load instruction is currently in execute cycle

                    // Order a stall since the previous load instruction must be in the memory access cycle to produce the operand that will be forwarded to the decode stage
                    stall_trigger = 1;
                    stall_counter = 2;

                end
                else if (i == 2) begin // Conflicting load instruction is currently in memory access cycle

                    pipeline_forward_sel[B] = MEM_ACCESS_DM_OPERAND;

                end
            end : load_instr_B
            
            // For non-load previous instructions
            else begin : non_load_instr_B

                if (i == 1) begin
                    // Forward alu_data_out from execute cycle to decode cycle
                    pipeline_forward_sel[B] = EXECUTE_ALU_OPERAND;
                end
                else if (i == 2) begin
                // Forward alu_data_out from memory access cycle to decode cycle
                pipeline_forward_sel[B] = MEM_ACCESS_ALU_OPERAND;

                end

            end : non_load_instr_B

        end

    end

    // Operand forwarding for alu_in_a
    case (pipeline_forward_sel[A])

        MEM_ACCESS_DM_OPERAND: begin

            alu_data_in_a = dm_read_data;

            if (instruction[6:0] == 7'b1100011) begin
            
                jbl_data_in1 = dm_read_data;
                jbl_address_in = dec_jbl_address_in;

            end
            else begin
                
                jbl_data_in1 = dec_jbl_data_in1;
                jbl_address_in = dm_read_data;

            end

        end

        EXECUTE_ALU_OPERAND: begin
            
            alu_data_in_a = alu_data_out;
            
            if (instruction[6:0] == 7'b1100011) begin
            
                jbl_data_in1 = alu_data_out;
                jbl_address_in = dec_jbl_address_in;

            end
            else begin
                
                jbl_data_in1 = dec_jbl_data_in1;
                jbl_address_in = alu_data_out;
            end
        end
        
        MEM_ACCESS_ALU_OPERAND: begin

            alu_data_in_a = dm_data_bypass;

            if (instruction[6:0] == 7'b1100011) begin

                jbl_data_in1 = dm_data_bypass;
                jbl_address_in = dec_jbl_address_in;

            end
            else begin
                
                jbl_data_in1 = dec_jbl_data_in1;
                jbl_address_in = dm_data_bypass;
            end
        end

        default: begin

            alu_data_in_a = dec_alu_data_in_a;
            jbl_data_in1 = dec_jbl_data_in1;
            jbl_address_in = dec_jbl_address_in;

        end
        
    endcase

    // Operand forwarding for alu_in_b/store data source
    case (pipeline_forward_sel[B])

        MEM_ACCESS_DM_OPERAND: begin // Forward operand from mem access cycle into ALU input a

            alu_data_in_b = dm_read_data;
            dm_write_data = dm_read_data;

            jbl_data_in2 = dm_read_data;
            
        end
        
        EXECUTE_ALU_OPERAND: begin // Forward operand from execute cycle

            jbl_data_in2 = alu_data_out;
            
            if (dm_write_enable) begin // If instruction is store
                
                alu_data_in_b = dec_alu_data_in_b;
                dm_write_data = alu_data_out;
                
            end
            else begin
                
                alu_data_in_b = alu_data_out;
                dm_write_data = dec_dm_write_data;

            end
            
        end
        
        MEM_ACCESS_ALU_OPERAND: begin // Forward operand from mem access cycle
            
            jbl_data_in2 = dm_data_bypass;

            if (dm_write_enable) begin // If instruction is store
                
                alu_data_in_b = dec_alu_data_in_b;
                dm_write_data = dm_data_bypass;
                
            end
            else begin
                
                alu_data_in_b = dm_data_bypass;
                dm_write_data = dec_dm_write_data;

            end

        end
        
        default: begin

            alu_data_in_b = dec_alu_data_in_b;
            dm_write_data = dec_dm_write_data;
            jbl_data_in2 = dec_jbl_data_in2;
            
        end

    endcase

end : pipeline_data_hazard_detection

always_ff @(posedge(clk)) begin : pipeline_stalling

    if (rst) begin

        f_to_d_enable_ff <= 1'b1;
        d_to_e_enable_ff <= 1'b1;
        stall_trigger = '0;
        stall_counter = '0;

    end
    else if (stall_trigger && (stall_counter == 1)) begin

            f_to_d_enable_ff <= '0;
            stall_counter = stall_counter - 1;

        stall_trigger = '0;

    end
    else if (stall_trigger && (stall_counter == 2)) begin

            f_to_d_enable_ff <= '0;
            d_to_e_enable_ff <= '0;
            stall_counter = stall_counter - 1;

    end
    else if (stall_counter < 1) begin

        stall_trigger = '0;
        
    end

end : pipeline_stalling

always_ff @(posedge(clk)) begin : address_opcodes_shift_reg

    if (rst) begin

        for (int i = 0; i < SHIFT_DEPTH - 2; i++) begin

            predecessor_instructions[i + 1] <= '0;
            successor_instructions[i + 1] <= '0;

        end

    end
    else begin

        predecessor_instructions[0] <= instruction;
        successor_instructions[0] <= instruction;
        successor_instructions[1] <= instruction_direct;
        successor_instructions[2] <= next_instruction;

        for (int i = 0; i < SHIFT_DEPTH - 2; i++) begin

            predecessor_instructions[i + 1] <= predecessor_instructions[i];

        end

    end

end : address_opcodes_shift_reg

always_ff @(posedge(clk)) begin : alu_data_out_shift_reg

    if (rst) begin

        for (int i = 0; i < SHIFT_DEPTH - 2; i++) begin

            previous_alu_data_out[i] <= '0;


        end

    end
    else begin

        previous_alu_data_out[1] <= alu_data_out;
        previous_alu_data_out[2] <= previous_alu_data_out[1];

    end

end

always_comb begin : fence_handling

    case (fence_succ) // How far before FENCE is the key instruction? (Input, Output, Read, or Write)

        (fence_succ[0] || fence_succ[2]): begin // Memory writes or outputs

            for (logic [SHIFT_DEPTH - 1:0] i = 1; i < SHIFT_DEPTH; i++) begin
                                                                            // Change alu_data_out range when address space is not only used by memory
                if ((successor_instructions[i][OPCODE - 1:0] == 7'b0100011) && (0 <= alu_data_out[i] <= (2^(XLEN - 1) - 1))) begin

                    before_current_instruction = i;

                end
                else begin
                    // For when output addresses exist and address space is not only used by memory
                end

            end

        end

        (fence_succ[1] || fence_succ[3]): begin // Memory reads or inputs

            for (logic [SHIFT_DEPTH - 1:0] i = '0; i < SHIFT_DEPTH; i++) begin
                                                                            // Change alu_data_out range when address space is not only used by memory
                if ((successor_instructions[i][OPCODE - 1:0] == 7'b0000011) && (0 <= alu_data_out[i] <= (2^(XLEN - 1) - 1))) begin

                    before_current_instruction = i;

                end
                else begin
                    // For when output addresses exist and address space is not only used by memory
                end

            end

        end

        default: begin
            
        end

    endcase

    case (fence_pred) // How far after FENCE is the key instruction? (Input, Output, Read, or Write)

        (fence_pred[0] || fence_pred[2]): begin // Check for memory writes or outputs

            for (logic [SHIFT_DEPTH - 1:0] i = '0; i < SHIFT_DEPTH; i++) begin
                                                                            // Change alu_data_out range when address space is not only used by memory
                if ((predecessor_instructions[i][OPCODE - 1:0] == 7'b0100011) && (0 <= alu_data_out[i] <= (2^(XLEN - 1) - 1))) begin

                    after_current_instruction = i;

                end
                else begin
                    // For when output addresses exist and address space is not only used by memory
                end

            end

        end

        (fence_pred[1] || fence_pred[3]): begin // Check for memory reads or inputs

            for (logic [SHIFT_DEPTH - 1:0] i = '0; i < SHIFT_DEPTH; i++) begin
                                                                            // Change alu_data_out range when address space is not only used by memory
                if ((predecessor_instructions[i][OPCODE - 1:0] == 7'b0000011) && (0 <= alu_data_out[i] <= (2^(XLEN - 1) - 1))) begin

                    after_current_instruction = i;

                end
                else begin
                    // For when output addresses exist and address space is not only used by memory
                end

            end

        end

        default: begin

        end

    endcase

    if (before_current_instruction + after_current_instruction == 2) begin // Successor instruction will not exit pipeline before predecessor enters decode

        stall_trigger = 1;
        stall_counter = 2;

    end else if (before_current_instruction + after_current_instruction < 2) begin
        // Impossible; if the value is less than one then current instruction is not FENCE
    end

end

endmodule
