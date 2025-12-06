"""
assembler.py
-------------
This file contains the full RISC-V assembler implementation.
It provides:
    • Instruction dictionary
    • Operand parsing
    • Immediate/register encoding helpers
    • Instruction binary encoding
    • assemble(line) → returns machine code (8-hex digits)
    
The MAIN PROGRAM IS IN main.py — NOT HERE.
This file should be imported by main.py.
"""

import re

# ----------------------------------------------------------------------
#  Instruction Set Table
# ----------------------------------------------------------------------
# Each instruction entry contains:
#   type  = R, I, S, SB, U, UJ
#   opcode = last 7 bits
#   funct3/funct7 (if applicable)
#   has_shamt_funct7 = for shift-immediate instructions like SLLI/SRLI/SRAI
#
INSTRUCTIONS = {
    # R-type
    "add":   {"type": "R", "opcode": "0110011", "funct3": "000", "funct7": "0000000"},
    "sub":   {"type": "R", "opcode": "0110011", "funct3": "000", "funct7": "0100000"},
    "addw":  {"type": "R", "opcode": "0111011", "funct3": "000", "funct7": "0000000"},
    "and":   {"type": "R", "opcode": "0110011", "funct3": "111", "funct7": "0000000"},
    "xor":   {"type": "R", "opcode": "0110011", "funct3": "100", "funct7": "0000000"},
    "sltu":  {"type": "R", "opcode": "0110011", "funct3": "011", "funct7": "0000000"},

    # I-type
    "addiw": {"type": "I", "opcode": "0011011", "funct3": "000", "has_shamt_funct7": True},
    "andi":  {"type": "I", "opcode": "0010011", "funct3": "111"},
    "ori":   {"type": "I", "opcode": "0010011", "funct3": "110"},
    "slli":  {"type": "I", "opcode": "0010011", "funct3": "001", "funct7": "0000000", "has_shamt_funct7": True},
    "srli":  {"type": "I", "opcode": "0010011", "funct3": "101", "funct7": "0000000", "has_shamt_funct7": True},
    "srai":  {"type": "I", "opcode": "0010011", "funct3": "101", "funct7": "0100000", "has_shamt_funct7": True},
    "jalr":  {"type": "I", "opcode": "1100111", "funct3": "000"},
    "lh":    {"type": "I", "opcode": "0000011", "funct3": "001"},
    "lw":    {"type": "I", "opcode": "0000011", "funct3": "010"},

    # S-type
    "sb":    {"type": "S", "opcode": "0100011", "funct3": "000"},
    "sw":    {"type": "S", "opcode": "0100011", "funct3": "010"},

    # SB-type (branches)
    "bge":   {"type": "SB", "opcode": "1100011", "funct3": "101"},
    "bne":   {"type": "SB", "opcode": "1100011", "funct3": "001"},

    # U-type
    "lui":   {"type": "U", "opcode": "0110111"},

    # UJ-type
    "jal":   {"type": "UJ", "opcode": "1101111"},
}

# ----------------------------------------------------------------------
# Utility Functions
# ----------------------------------------------------------------------

def to_int(x):
    """Convert hex/decimal/binary strings into integer."""
    if isinstance(x, str):
        return int(x, 0)
    return int(x)

def reg_to_bin(reg):
    """Convert register name (x5) to 5-bit binary."""
    if reg.startswith('x'):
        num = int(reg[1:])
    else:
        num = int(reg)
    if not (0 <= num <= 31):
        raise ValueError(f"Register out of range: {reg}")
    return f"{num:05b}"

def imm_to_bin(val, bits):
    """Convert signed immediate to two's complement bitstring."""
    val = to_int(val)
    val &= (1 << bits) - 1
    return f"{val:0{bits}b}"

# ----------------------------------------------------------------------
# Encoding Logic
# ----------------------------------------------------------------------

def encode_instruction(inst_name, operands):
    """Return the 32-bit binary encoding of an instruction."""
    info = INSTRUCTIONS[inst_name]
    typ = info["type"]

    # ============================
    # R-TYPE
    # ============================
    if typ == "R":
        rd, rs1, rs2 = operands
        return info["funct7"] + reg_to_bin(rs2) + reg_to_bin(rs1) + info["funct3"] + reg_to_bin(rd) + info["opcode"]

    # ============================
    # I-TYPE
    # ============================
    elif typ == "I":
        rd, rs1, imm = operands

        # Shift-immediate instructions use funct7 | shamt[4:0]
        if info.get("has_shamt_funct7", False):
            shamt = imm_to_bin(imm, 5)
            imm_bin = info["funct7"] + shamt
        else:
            imm_bin = imm_to_bin(imm, 12)

        return imm_bin + reg_to_bin(rs1) + info["funct3"] + reg_to_bin(rd) + info["opcode"]

    # ============================
    # S-TYPE
    # ============================
    elif typ == "S":
        rs2, rs1, imm = operands
        imm_val = to_int(imm) & 0xfff
        imm_hi = (imm_val >> 5) & 0x7f
        imm_lo = imm_val & 0x1f
        return f"{imm_hi:07b}" + reg_to_bin(rs2) + reg_to_bin(rs1) + info["funct3"] + f"{imm_lo:05b}" + info["opcode"]

    # ============================
    # SB-TYPE (branches)
    # ============================
    elif typ == "SB":
        rs1, rs2, imm = operands
        imm_val = to_int(imm) & 0x1fff
        imm_12 = (imm_val >> 12) & 1
        imm_10_5 = (imm_val >> 5) & 0x3F
        imm_4_1 = (imm_val >> 1) & 0xF
        imm_11 = (imm_val >> 11) & 1

        return (
            f"{imm_12:b}{imm_10_5:06b}" +
            reg_to_bin(rs2) + reg_to_bin(rs1) +
            info["funct3"] +
            f"{imm_4_1:04b}{imm_11:b}" +
            info["opcode"]
        )

    # ============================
    # U-TYPE
    # ============================
    elif typ == "U":
        rd, imm = operands
        imm_hi = (to_int(imm) >> 12) & 0xFFFFF
        return f"{imm_hi:020b}" + reg_to_bin(rd) + info["opcode"]

    # ============================
    # UJ-TYPE (JAL)
    # ============================
    elif typ == "UJ":
        rd, imm = operands
        imm_val = to_int(imm) & 0x1FFFFF
        imm_20 = (imm_val >> 20) & 1
        imm_10_1 = (imm_val >> 1) & 0x3FF
        imm_11 = (imm_val >> 11) & 1
        imm_19_12 = (imm_val >> 12) & 0xFF

        return (
            f"{imm_20:b}{imm_10_1:010b}{imm_11:b}{imm_19_12:08b}" +
            reg_to_bin(rd) +
            info["opcode"]
        )

    else:
        raise ValueError(f"Unknown type: {typ}")

# ----------------------------------------------------------------------
# Operand Parsing
# ----------------------------------------------------------------------
def parse_operands(line, inst_type):
    """Parse registers/immediates from assembly syntax."""
    tokens = re.split(r"[,\s()]+", line.strip())
    tokens = [t for t in tokens if t]

    if inst_type == "R":
        return tokens[1], tokens[2], tokens[3]

    elif inst_type == "I":
        if '(' in line or tokens[0] == 'jalr':
            return tokens[1], tokens[3], tokens[2]  # rd, rs1, imm
        return tokens[1], tokens[2], tokens[3]

    elif inst_type == "S":
        return tokens[1], tokens[3], tokens[2]  # rs2, rs1, imm

    elif inst_type == "SB":
        return tokens[1], tokens[2], tokens[3]

    elif inst_type in ("U", "UJ"):
        return tokens[1], tokens[2]

    raise ValueError("Unknown instruction type")



def assemble(line):
    """Main assembly call: converts a line of assembly into hex machine code."""
    line = line.strip()
    if not line or line.startswith('#'):
        return None
    
    inst = line.split()[0].lower()
    if inst not in INSTRUCTIONS:
        raise ValueError(f"Unknown instruction: {inst}")

    operands = parse_operands(line, INSTRUCTIONS[inst]["type"])
    bin32 = encode_instruction(inst, operands)

    return f"{int(bin32, 2):08x}"
