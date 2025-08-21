def create_instruction(instruction_set, instr, rs2=None, rs1=None, rd=None, imm=None):
    if instr not in instruction_set:
        raise ValueError(f"Instruction {instr} not supported")

    opcode = instruction_set[instr]['opcode']
    funct3 = instruction_set[instr].get('funct3', '')
    funct7 = instruction_set[instr].get('funct7', '')
    special = instruction_set[instr].get('special', False)

    if opcode == '0110011':                     # R-type
        rs2_bin = get_binary_string(rs2, 5)
        rs1_bin = get_binary_string(rs1, 5)
        rd_bin = get_binary_string(rd, 5)
        instruction = funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode

    elif opcode in ['0010011', '0000011']:                   # I-type
        if special:
            if instr == 'SRAI':
                imm_bin = '010000' + get_binary_string(imm, 6)
            else:
                imm_bin = '000000' + get_binary_string(imm, 6)
        else:
            imm_bin = get_binary_string(imm, 12)
        rs1_bin = get_binary_string(rs1, 5)
        rd_bin = get_binary_string(rd, 5)
        instruction = imm_bin + rs1_bin + funct3 + rd_bin + opcode

    elif opcode == '0100011':                   # S-type
        imm_bin = get_binary_string(imm, 12)
        rs2_bin = get_binary_string(rs2, 5)
        rs1_bin = get_binary_string(rs1, 5)
        instruction = imm_bin[0:7] + rs2_bin + rs1_bin + funct3 + imm_bin[7:12] + opcode

    elif opcode == '1100011':                   # B-type
        imm_bin = get_binary_string(imm, 12)
        rs2_bin = get_binary_string(rs2, 5)
        rs1_bin = get_binary_string(rs1, 5)
        instruction = imm_bin[0] + imm_bin[2:8] + rs2_bin + rs1_bin + funct3 + imm_bin[8:12] + imm_bin[1] + opcode

    elif opcode in ['0110111', '0010111']:       # U-type
        imm_bin = get_binary_string(imm, 20)
        rd_bin = get_binary_string(rd, 5)
        instruction = imm_bin + rd_bin + opcode

    elif opcode == '1100111':                   # JALR
        imm_bin = get_binary_string(imm, 12)
        rs1_bin = get_binary_string(rs1, 5)
        rd_bin = get_binary_string(rd, 5)
        instruction = imm_bin + rs1_bin + funct3 + rd_bin + opcode

    elif opcode == '1101111':                   # J-type
        imm_bin = get_binary_string(imm, 20)
        rd_bin = get_binary_string(rd, 5)
        instruction = imm_bin[0] + imm_bin[10:20] + imm_bin[9] + imm_bin[1:9] + rd_bin + opcode

    elif opcode == '0001111':                   # FENCE
        imm_bin = imm
        # rs1_bin = get_binary_string(rs1, 5)
        # rd_bin = get_binary_string(rd, 5)

        rs1_bin = rs1
        rd_bin = rd

        instruction = imm_bin + rs1_bin + funct3 + rd_bin + opcode

    elif opcode == '1110011':                   # ECB
        # imm_bin = get_binary_string(imm, 12)
        # rs1_bin = get_binary_string(rs1, 5)
        # rd_bin = get_binary_string(rd, 5)

        imm_bin = imm
        rs1_bin = rs1
        rd_bin = rd

        instruction = imm_bin + rs1_bin + funct3 + rd_bin + opcode

    elif opcode == '0011011':                   # I-type (64-bit)
        if special:
            if instr == 'SRAIW':
                imm_bin = '010000' + get_binary_string(imm, 5)
            else:
                imm_bin = '000000' + get_binary_string(imm, 5)
        else:
            imm_bin = get_binary_string(imm, 12)
        rs1_bin = get_binary_string(rs1, 5)
        rd_bin = get_binary_string(rd, 5)
        instruction = imm_bin + rs1_bin + funct3 + rd_bin + opcode

    elif opcode == '0111011':                     # R-type (64-bit)
        rs2_bin = get_binary_string(rs2, 5)
        rs1_bin = get_binary_string(rs1, 5)
        rd_bin = get_binary_string(rd, 5)
        instruction = funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode

    return instruction

def get_valid_input(prompt, min_value, max_value):
    while True:
        try:
            value = int(input(prompt))
            if min_value <= value <= max_value:
                return value
            else:
                print(f"Please enter a value between {min_value} and {max_value}.")

        except ValueError:
            print("Invalid input. Please enter an integer.")

def get_binary_string(value, bits):
    if value < 0:
        value = (1 << bits) + value

    value = value & (1 << bits) - 1

    return format(value, f'0{bits}b')

def complete_test(instruction_set, instructions, instructionname):
    total_regs = 32
    
    for idx, (name, details) in enumerate(instruction_set.items()):

        instructionname.append(name)

        rd = idx % total_regs
        rs1 = (idx + 1) % total_regs
        rs2 = (idx + 2) % total_regs
        imm = 1

        opcode = details['opcode']

        if opcode == '0001111':  # FENCE and PAUSE
            imm = details['fm'] + details['pred'] + details['succ']
            rs1 = details['rs1']
            rd  = details['rd']

        elif opcode == '1110011':  #ECALL/EBREAK/CSR
            imm = details['imm']
            rs1 = details['rs1']
            rd  = details['rd']

        binary_instruction = create_instruction(instruction_set, name, rs2, rs1, rd, imm)
        instructions.append(binary_instruction)

    return instructions, instructionname