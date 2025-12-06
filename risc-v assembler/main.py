from assembler import assemble


tests1 = [
    "addw x1, x2, x3",
    "addiw x1, x2, 10",
    "and x5, x6, x7",
    "andi x5, x6, 12",
    "bge x1, x2, 8",
    "bne x1, x2, 16",
    "jal x1, 40",
    "jalr x1, x2, 20",
    "lw x1, 8(x2)",
    "lh x3, 4(x5)",
    "sw x1, 12(x2)",
    "sb x3, 5(x7)",
    "ori x1, x2, 7",
    "xor x1, x2, x3",
    "sltu x1, x2, x3",
    "slli x1, x2, 1",
    "srli x3, x4, 2",
    "srai x5, x6, 3",
    "sub x1, x2, x3",
    "lui x1, 0x10000",
]
tests2 = [
    # R-type group
    "and x1, x2, x3",
    "addw x1, x2, x3",
    "sub x1, x2, x3",
    "sltu x1, x2, x3",
    "xor x1, x2, x3",
    "srl x1, x2, x3",
    "sra x1, x2, x3",
    "or x1, x2, x3",

    # I-type group
    "slli x1, x2, 2",
    "ori x1, x2, 7",
    "lw x1, 3(x2)",
    "lh x1, 4(x2)",
    "addiw x1, x2, 1",
    "andi x1, x2, 0",
    "jalr x1, x2, 1",

    # U-type
    "lui x1, 0x38",

    # SB-type
    "bge x1, x2, 6",
    "bne x1, x2, 2",

    # UJ-type
    "jal x1, 70",

    # S-type
    "sb x1, 1(x2)",
    "sw x1, 3(x2)",
]

# ---------------------------------------------------------
# MERGE TESTS (your original + your added tests)
# ---------------------------------------------------------
all_tests = tests1 + tests2

# ---------------------------------------------------------
# EXECUTE TESTS
# ---------------------------------------------------------
print("\n==================== ASSEMBLER TEST RESULTS ====================\n")

for t in all_tests:
    try:
        hex_value = assemble(t)
        print(f"{t:<30} → {hex_value}")
    except Exception as e:
        print(f"{t:<30} → ERROR: {e}")

print("\n============================ DONE ==============================\n")
