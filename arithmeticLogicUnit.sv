module arithmeticLogicUnit #(
    parameter SEL_SIZE = 4,
    parameter SHIFT_SIZE = 6,
    parameter XLEN = 64,
    parameter UIMMEDIATE = 20,
    parameter UIMMEDIATE_FILLED = 32)
(
    input  enable,
    input  [SEL_SIZE - 1:0]  sel,
    input  [SHIFT_SIZE - 1:0]  shift_amt,
    input  signed [XLEN - 1:0] data_in_a,
    input  signed [XLEN - 1:0] data_in_b,
    output logic signed [XLEN - 1:0] data_out
    );

enum {ADD, SUB, SLT, SLTU, ANDI, ORI, XORI, SLL, SRL, SRA, LUI, AUIPC, ADDW, SUBW, SLLW, SRLW, SRAW} ALU_OP_E; //ANDI, ORI, and XORI are used to avoid using SystemVerilog keywords

logic signed [XLEN/2 - 1:0] intermediate_result;

always_comb begin

if (enable) begin

    case (sel)

        ADD: begin

            data_out = data_in_a + data_in_b;

        end

        SUB: begin

            data_out = data_in_a - data_in_b;

        end
        
        SLT: begin

            if (data_in_a < data_in_b) begin

                data_out = 1;

            end
            else begin 

                data_out = 0;

            end

        end

        SLTU: begin

             if (unsigned'(data_in_a) < unsigned'(data_in_b)) begin

                data_out = 1;

            end
            else begin 

                data_out = 0;
                
            end
        end
        
        ANDI: begin

            data_out = data_in_a & data_in_b;

        end

        ORI: begin
            
            data_out = data_in_a | data_in_b;

        end

        XORI: begin
            
            data_out = data_in_a ^ data_in_b;

        end

        SLL: begin
            
            data_out = data_in_a << shift_amt;

        end
        
        SRL: begin
            
            data_out = data_in_a >> shift_amt;

        end

        SRA: begin

            data_out = data_in_a >>> shift_amt;
            
        end

        LUI: begin

            data_out = {{(XLEN - UIMMEDIATE_FILLED){data_in_a[UIMMEDIATE - 1]}}, data_in_a[UIMMEDIATE - 1:0], 12'd0}; // data_in_a = 20 bit U-immediate
            
        end

        AUIPC: begin

            data_out = {{(XLEN - UIMMEDIATE_FILLED){data_in_a[UIMMEDIATE - 1]}}, data_in_a[UIMMEDIATE - 1:0], 12'd0} + data_in_b; // data_in_a = 20 bit u-immediate, data_in_b = 32-bit addr of AUIPC instruction

        end

        ADDW: begin

            intermediate_result = data_in_a[XLEN/2 - 1:0] + data_in_b[XLEN/2 - 1:0];
            data_out = {{(XLEN - XLEN/2){intermediate_result[XLEN/2 - 1]}}, intermediate_result};

        end

        SUBW: begin

            intermediate_result = data_in_a[XLEN/2 - 1:0] - data_in_b[XLEN/2 - 1:0];
            data_out = {{(XLEN - XLEN/2){intermediate_result[XLEN/2 - 1]}}, intermediate_result};

        end

        SLLW: begin

            intermediate_result = data_in_a[XLEN/2 - 1:0] << shift_amt;
            data_out = {{(XLEN - XLEN/2){intermediate_result[XLEN/2 - 1]}}, intermediate_result};

        end

        SRLW: begin

            intermediate_result = data_in_a[XLEN/2 - 1:0] >> shift_amt;
            data_out = {{(XLEN - XLEN/2){intermediate_result[XLEN/2 - 1]}}, intermediate_result};

        end

        SRAW: begin
            
            intermediate_result = data_in_a[XLEN/2 - 1:0] >>> shift_amt;
            data_out = {{(XLEN - XLEN/2){intermediate_result[XLEN/2 - 1]}}, intermediate_result};

        end

    default:
        data_out = 0;

    endcase

end

else begin
    
    data_out = '0;

end

end

endmodule