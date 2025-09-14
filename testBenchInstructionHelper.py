from testBenchInstructionHelperCoreFunctions import create_instruction, get_valid_input, complete_test
from testBenchInstructionHelperGUI import update_grid, create_grid_window, update_grid_values
import configparser

instruction_set = {
    'ADDI':         {'type': 'I', 'funct3': '000', 'opcode': '0010011',
                    'imm': 'Enter the first number to add (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second number to add (0 to 31): '},
    'SLTI':         {'type': 'I', 'funct3': '010', 'opcode': '0010011',
                    'imm': 'Enter the immediate value (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the value you want to compare to the immediate value (0 to 31): '},
    'SLTIU':        {'type': 'I', 'funct3': '011', 'opcode': '0010011',
                    'imm': 'Enter the immediate value (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the value you want to compare to the immediate value (0 to 31): '},
    'ANDI':         {'type': 'I', 'funct3': '111', 'opcode': '0010011',
                    'imm': 'Enter the first number to AND (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second number to AND (0 to 31): '},
    'ORI':          {'type': 'I', 'funct3': '110', 'opcode': '0010011',
                    'imm': 'Enter the first number to OR (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second number to OR (0 to 31): '},
    'XORI':         {'type': 'I', 'funct3': '100', 'opcode': '0010011',
                    'imm': 'Enter the first number to XOR (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second number to XOR (0 to 31): '},
    'SLLI':         {'type': 'I', 'funct3': '001', 'opcode': '0010011', 'special': True,
                    'imm': 'Enter amount to shift by (0 to 63): ',
                    'rs1': 'Enter register location of value to shift (0 to 31): '},
    'SRLI':         {'type': 'I', 'funct3': '101', 'opcode': '0010011', 'special': True,
                    'imm': 'Enter amount to shift by (0 to 63): ',
                    'rs1': 'Enter register location of value to shift (0 to 31): '},
    'SRAI':         {'type': 'I', 'funct3': '101', 'opcode': '0010011', 'special': True,
                    'imm': 'Enter amount to shift by (0 to 63): ',
                    'rs1': 'Enter register location of value to shift (0 to 31): '},

    'LUI':          {'type': 'U', 'opcode': '0110111',
                    'imm': 'Enter immediate value (0 to 1048575): '},

    'AUIPC':        {'type': 'U', 'opcode': '0010111',
                    'imm': 'Enter immediate value (0 to 1048575): '},

    'ADD':          {'type': 'R', 'funct7': '0000000', 'funct3': '000', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the first value to add (0 to 31): ',
                    'rs2': 'Enter the register location of the second value of add (0 to 31): '},
    'SLT':          {'type': 'R', 'funct7': '0000000', 'funct3': '010', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the value to compare to (0 to 31): ',
                    'rs2': 'Enter the register location of the value to compare (0 to 31): '},
    'SLTU':         {'type': 'R', 'funct7': '0000000', 'funct3': '011', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the value to compare to (0 to 31): ',
                    'rs2': 'Enter the register location of the value to compare (0 to 31): '},
    'AND':          {'type': 'R', 'funct7': '0000000', 'funct3': '111', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the first value to AND (0 to 31): ',
                    'rs2': 'Enter the register location of the second value to AND (0 to 31): '},
    'OR':           {'type': 'R', 'funct7': '0000000', 'funct3': '110', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the first value to OR (0 to 31): ',
                    'rs2': 'Enter the register location of the second value to OR (0 to 31): '},
    'XOR':          {'type': 'R', 'funct7': '0000000', 'funct3': '100', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the first value to XOR (0 to 31): ',
                    'rs2': 'Enter the register location of the second value to XOR (0 to 31): '},
    'SLL':          {'type': 'R', 'funct7': '0000000', 'funct3': '001', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the value to shift (0 to 31): ',
                    'rs2': 'Enter the register location of the amount to shift by (0 to 31): '},
    'SRL':          {'type': 'R', 'funct7': '0000000', 'funct3': '101', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the value to shift (0 to 31): ',
                    'rs2': 'Enter the register location of the amount to shift by (0 to 31): '},
    'SUB':          {'type': 'R', 'funct7': '0100000', 'funct3': '000', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the value to subtract by (0 to 31): ',
                    'rs2': 'Enter the register location of the value to subtract (0 to 31): '},
    'SRA':          {'type': 'R', 'funct7': '0100000', 'funct3': '101', 'opcode': '0110011',
                    'rs1': 'Enter the register location of the value to shift (0 to 31): ',
                    'rs2': 'Enter the register location of the value to shift by (0 to 31): '},

    'JAL':          {'type': 'J', 'opcode': '1101111',
                    'imm': 'Enter the value to calculate the jump address (0 to 1048575): '},
    'JALR':         {'type': 'I', 'funct3': '000', 'opcode': '1100111',
                    'imm': 'Enter the first value to calculate the jump address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the jump address (0 to 31): '},

    'BEQ':          {'type': 'B', 'funct3': '000', 'opcode': '1100011',
                    'imm': 'Enter the value to calculate the jump address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the value to compare (0 to 31): ',
                    'rs2': 'Enter the register location of the value to compare to (0 to 31): '},
    'BNE':          {'type': 'B', 'funct3': '001', 'opcode': '1100011',
                    'imm': 'Enter the value to calculate the jump address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the value to compare (0 to 31): ',
                    'rs2': 'Enter the register location of the value to compare to (0 to 31): '},
    'BLT':          {'type': 'B', 'funct3': '100', 'opcode': '1100011',
                    'imm': 'Enter the value to calculate the jump address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the value to compare (0 to 31): ',
                    'rs2': 'Enter the register location of the value to compare to (0 to 31): '},
    'BLTU':         {'type': 'B', 'funct3': '110', 'opcode': '1100011',
                    'imm': 'Enter the value to calculate the jump address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the value to compare (0 to 31): ',
                    'rs2': 'Enter the register location of the value to compare to (0 to 31): '},
    'BGE':          {'type': 'B', 'funct3': '101', 'opcode': '1100011',
                    'imm': 'Enter the value to calculate the jump address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the value to compare (0 to 31): ',
                    'rs2': 'Enter the register location of the value to compare to (0 to 31): '},
    'BGEU':         {'type': 'B', 'funct3': '111', 'opcode': '1100011',
                    'imm': 'Enter the value to calculate the jump address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the value to compare (0 to 31): ',
                    'rs2': 'Enter the register location of the value to compare to (0 to 31): '},

    'LD':           {'type': 'I', 'funct3': '011', 'opcode': '0000011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): '},
    'LW':           {'type': 'I', 'funct3': '010', 'opcode': '0000011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): '},
    'LWU':          {'type': 'I', 'funct3': '110', 'opcode': '0000011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): '},
    'LH':           {'type': 'I', 'funct3': '001', 'opcode': '0000011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): '},
    'LHU':          {'type': 'I', 'funct3': '101', 'opcode': '0000011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): '},
    'LB':           {'type': 'I', 'funct3': '000', 'opcode': '0000011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): '},
    'LBU':          {'type': 'I', 'funct3': '100', 'opcode': '0000011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): '},

    'SD':           {'type': 'S', 'funct3': '011', 'opcode': '0100011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): ',
                    'rs2': 'Enter the register location of the value to move to memory (0 to 31): '},
    'SW':           {'type': 'S', 'funct3': '010', 'opcode': '0100011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): ',
                    'rs2': 'Enter the register location of the value to move to memory (0 to 31): '},
    'SH':           {'type': 'S', 'funct3': '001', 'opcode': '0100011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): ',
                    'rs2': 'Enter the register location of the value to move to memory (0 to 31): '},
    'SB':           {'type': 'S', 'funct3': '000', 'opcode': '0100011',
                    'imm': 'Enter the first value to calculate the memory address (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second value to calculate the memory address (0 to 31): ',
                    'rs2': 'Enter the register location of the value to move to memory (0 to 31): '},

    'FENCE':        {'funct3': '000', 'opcode': '0001111',
                    'fm': '0000',
                    'pred': 'Which instruction must finish? (Memory Write/Read, Output/Input): ',
                    'succ': 'Which instruction must wait? (Memory Write/Read, Output/Input): ',
                    'rs1': '00000',
                    'rd': '00000'},
    'FENCE.TSO':    {'funct3': '000', 'opcode': '0001111',
                    'fm': '1000',
                    'pred': '0011',
                    'succ': '0011',
                    'rs1': '00000',
                    'rd': '00000'},
    'PAUSE':        {'funct3': '000', 'opcode': '0001111',
                    'fm': '0000',
                    'pred': '0001',
                    'succ': '0000',
                    'rs1': '00000',
                    'rd': '00000'},

    'ECALL':        {'type': 'I', 'funct3': '000', 'opcode': '1110011',
                    'imm': '000000000000',
                    'rs1': '00000',
                    'rd': '00000'},
    'EBREAK':       {'type': 'I', 'funct3': '000', 'opcode': '1110011',
                    'imm': '000000000001',
                    'rs1': '00000',
                    'rd': '00000'},

    'ADDIW':        {'type': 'I', 'funct3': '000', 'opcode': '0011011',
                    'imm': 'Enter the first number to add (-2048 to 2047): ',
                    'rs1': 'Enter the register location of the second number to add (0 to 31): '},
    'SLLIW':        {'type': 'I', 'funct3': '001', 'opcode': '0011011', 'special': True,
                    'imm': 'Enter amount to shift by (0 to 31): ',
                    'rs1': 'Enter register location of value to shift (0 to 31): '},
    'SRLIW':        {'type': 'I', 'funct3': '101', 'opcode': '0011011', 'special': True,
                    'imm': 'Enter amount to shift by (0 to 31): ',
                    'rs1': 'Enter register location of value to shift (0 to 31): '},
    'SRAIW':        {'type': 'I', 'funct3': '101', 'opcode': '0011011', 'special': True,
                    'imm': 'Enter amount to shift by (0 to 31): ',
                    'rs1': 'Enter register location of value to shift (0 to 31): '},

    'ADDW':         {'type': 'R', 'funct7': '0000000', 'funct3': '000', 'opcode': '0111011',
                    'rs1': 'Enter the register location of the first value to add (0 to 31): ',
                    'rs2': 'Enter the register location of the second value of add (0 to 31): '},
    'SLLW':         {'type': 'R', 'funct7': '0000000', 'funct3': '001', 'opcode': '0111011',
                    'rs1': 'Enter the register location of the value to shift (0 to 31): ',
                    'rs2': 'Enter the register location of the amount to shift by (0 to 31): '},
    'SRLW':         {'type': 'R', 'funct7': '0000000', 'funct3': '101', 'opcode': '0111011',
                    'rs1': 'Enter the register location of the value to shift (0 to 31): ',
                    'rs2': 'Enter the register location of the amount to shift by (0 to 31): '},
    'SUBW':         {'type': 'R', 'funct7': '0100000', 'funct3': '000', 'opcode': '0111011',
                    'rs1': 'Enter the register location of the value to subtract by (0 to 31): ',
                    'rs2': 'Enter the register location of the value to subtract (0 to 31): '},
    'SRAW':         {'type': 'R', 'funct7': '0100000', 'funct3': '101', 'opcode': '0111011',
                    'rs1': 'Enter the register location of the value to shift (0 to 31): ',
                    'rs2': 'Enter the register location of the value to shift by (0 to 31): '},

}

config = configparser.ConfigParser()
config.read('config.ini')
testbench_file = config['Paths']['testbench_file']

# Initializations
grid = [0] * 32
memory = {}

memory_grid_column = -1

PC = 0

instructions = []
instructionname = []

written_registers = set()

# Create the grid window
window, grid_labels = create_grid_window(grid)

# Get user input for instruction(s)
while True:
    instr = input("Enter the RISC-V instruction (or 'done' to finish): ").upper()
    if instr == 'DONE':
        window.destroy()
        break

    if instr == 'ALL INSTRUCTIONS':
        window.destroy()
        instructions, instructionname = complete_test(instruction_set, instructions, instructionname)
        break

    if instr not in instruction_set:
        print("Invalid instruction. Please enter a valid RISC-V instruction.")
        continue

    instructionname.append(instr)
    rs2 = rs1 = rd = imm = fm = pred = succ = None

    if instruction_set[instr]['opcode'] in ['0010011', '0100011', '1100011', '0011011', '1100111', '0000011']:
        if instruction_set[instr].get('special', False):
            imm = get_valid_input(instruction_set[instr]['imm'], 0, 63) # 6-bit immeidate value (cannot be signed)
        else:
            imm = get_valid_input(instruction_set[instr]['imm'], -2048, 2047)  # 12-bit signed immediate
    elif instruction_set[instr]['opcode'] in ['0010111', '1101111', '0110111']:
        imm = get_valid_input(instruction_set[instr]['imm'], 0, 1048575)  # 20-bit unsigned immediate

    if instruction_set[instr]['opcode'] in ['0110011', '0010011', '0100011', '1100011', '0011011', '0111011', '1100111', '0000011']:
        rs1 = get_valid_input(instruction_set[instr]['rs1'], 0, 31)

    if instruction_set[instr]['opcode'] in ['0110011', '0100011', '1100011', '0111011']:
        rs2 = get_valid_input(instruction_set[instr]['rs2'], 0, 31)

    if instruction_set[instr]['opcode'] in ['0110011', '0010011', '0010111', '1101111', '0011011', '0111011', '0110111', '1100111', '0000011']:
        rd = get_valid_input("Enter the register location to store the output (0 to 31): ", 0, 31)

    if instruction_set[instr]['opcode'] == '0001111':
        if instr == 'FENCE':
            fm = instruction_set[instr]['fm']
            pred = input(instruction_set[instr]['pred']).upper()
            succ = input(instruction_set[instr]['succ']).upper()
            rs1 = instruction_set[instr]['rs1']
            rd = instruction_set[instr]['rd']
        elif instr == 'FENCE.TSO': # FENCE.TSO
            fm = instruction_set[instr]['fm']
            pred = instruction_set[instr]['pred']
            succ = instruction_set[instr]['succ']
            rs1 = instruction_set[instr]['rs1']
            rd = instruction_set[instr]['rd']

    if instruction_set[instr]['opcode'] == '1110011': # ECALL/EBREAK
        imm = instruction_set[instr]['imm']
        rs1 = instruction_set[instr]['rs1']
        rd = instruction_set[instr]['rd']

    binary_instruction = create_instruction(instruction_set, instr, rs2, rs1, rd, imm, fm, pred, succ)
    instructions.append(binary_instruction)

    update_grid_values(instr, rs1, rs2, rd, imm, grid, grid_labels, memory, PC)

    PC += 4

    memory_grid_column, grid_labels = update_grid(grid, grid_labels, memory, memory_grid_column, window)

if instructions:
    with open(testbench_file, 'r') as file:
        lines = file.readlines()

    # Find "initial begin" and "end" lines and write between
    dbg_addr = 0
    inside_initial_block = False
    new_lines = []
    for line in lines:
        if 'dbg_addr = 0;' in line:     # Checks for beginning of area to edit
            inside_initial_block = True
            new_lines.append(line)
            new_lines.append(f'    dbg_instr = 32\'b{instructions[0]};       //{instructionname[0]}\n')
            new_lines.append('    #(2*CLK_PERIOD)\n    dbg_wr_en = 1;\n    #CLK_PERIOD\n    dbg_wr_en = 0;\n    #CLK_PERIOD\n')
        elif 'end' in line and inside_initial_block: # Finds end statement in initial block and writes instructions before the end statement
            for instruction, name in zip(instructions[1:], instructionname[1:]):
                dbg_addr += 4
                new_lines.append(f'    dbg_addr = {dbg_addr};\n')
                new_lines.append(f'    dbg_instr = 32\'b{instruction};       //{name}\n')
                new_lines.append('    #(2*CLK_PERIOD)\n    dbg_wr_en = 1;\n    #CLK_PERIOD\n    dbg_wr_en = 0;\n    #CLK_PERIOD\n')
            new_lines.append('    rst = 0;\n\n')
            new_lines.append(line)
            inside_initial_block = False
        elif inside_initial_block:
            continue
        else:
            new_lines.append(line)

    # Write back to testbench
    with open(testbench_file, 'w') as file:
        file.writelines(new_lines)

    print("Instructions written to the testbench file.")
else:
    print("No instructions to write to the testbench file.")

window.mainloop()