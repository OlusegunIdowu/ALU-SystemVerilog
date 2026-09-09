# Parameterisable ALU in SystemVerilog

A parameterisable N-bit ALU implemented using SystemVerilog, with a self-checking testbench. Built as part of a self-learning computer hardware engineering curriculum.

# Overview:
    This ALU supports 8 operations on N-bit operands (default for N has been declared as 8), with 4 status flags. it is fully synthesisable and written using synchronous design best practices.

# Operations:
    | op code | operation | description                            |
    |---------|-----------|----------------------------------------|
    | 3'b000  | ADD       | signed/unsigned addition               |
    | 3'b001  | SUB       | signed/unsigned subtraction            |
    | 3'b010  | AND       | bitwise AND                            |
    | 3'b011  | OR        | bitwise OR                             |
    | 3'b100  | XOR       | bitwise XOR                            |
    | 3'b101  | SLL       | shift left logical                     |
    | 3'b110  | SRL       | shift right logical (zero fill)        |
    | 3'b111  | SRA       | shift right arithmetic (sign extended) |

# Status Flags:
    | flag     | description                                  |
    |----------|----------------------------------------------|
    | zero     | result is all zeros                          |
    | negative | MSB of result is 1 (which is signed negative)|
    | carry    | unsigned overflow / borrow out               |
    | overflow | signed overflow                              |

# Diagram:
    A [N-1:0] -|
    B [N-1:0] -| -> ALU -> result [N-1:0]
    op [2:0]  -|        -> zero
                        -> negative
                        -> carry
                        -> overflow

# Design Desicions:
    - Parameterisation:
        Bit width is a module parameter which will allow the ALU to be reusable at any width without changing the enitre code. the testbench has the same paremeter.
    - Carry Capture:
        The signal full_result is a total of N+1 bits wide which will capture any carry out caused by addition or borrow out by subtraction in the MSB. The MSB is assigned to the carry flag. This extra bit stops the carry from being dropped.
    - Overflow Detection:
        Carry detects unsigned overflow which doesn't fit in N unsigned bits. Overflow detects signed overflow wich doest fit into N signed bits
        eg. 200 + 100 on an 8-bit ALU sets carry but not overflow. 127 + 1 sets overflow but the carry behaviour depends on interpretation. Both flags are computed independatnly
    - SRA and SRL:
        Arithmetic right shift fills the vacated bits with the sign bit instead of zero. This correctly implements signed division by powers of two. The $signed() cast is required to tell the synthesiser to treat A as a signed value for the >>> operator.

# Verification
    The testbench uses 20 directed test cases covering:
    - Basic arithmetic correctness
    - Carry out detection
    - Signed overflow detection (ADD and SUB)
    - Zero flag
    - Negative flag
    - SRA sign extension vs SRL zero-fill
    - Edge cases: max positive, min negative, self subtraction

All 20 tests passed.

# How to Simulate

    Requirements: Icarus Verilog

    - Terminal:
        iverilog -g2012 -o alu_sim alu.sv alu_tb.sv
        vvp alu_sim

