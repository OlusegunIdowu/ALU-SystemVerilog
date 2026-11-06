# Parameterisable ALU in SystemVerilog


A parameterisable N-bit ALU implemented in SystemVerilog, with a self-checking testbench. Built as part of a self-learning computer hardware engineering curriculum.

## Overview

This ALU supports 8 operations on N-bit operands (N defaults to 8) and produces 4 status flags. It is fully combinational (no clock) and synthesisable.

## Files

| File | Purpose |
|---|---|
| `alu.sv` | The ALU module |
| `alu_tb.sv` | Self-checking testbench (20 directed test vectors) |
| `Makefile` | `make test` runs the simulation|

## Operations

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

## Status Flags

| flag     | description                                   |
|----------|-----------------------------------------------|
| zero     | result is all zeros                           |
| negative | MSB of result is 1 (signed negative)          |
| carry    | unsigned carry-out (ADD) / borrow-out (SUB)   |
| overflow | signed overflow (ADD and SUB only)            |

## Diagram

```
A [N-1:0] -|
B [N-1:0] -| -> ALU -> result [N-1:0]
op [2:0]  -|        -> zero
                    -> negative
                    -> carry
                    -> overflow
```

## Design Decisions

- **Parameterisation:** Bit width is a module parameter, so the ALU can be reused at any width without changing the code. The testbench uses the same parameter.
- **Carry capture:** `full_result` is N+1 bits wide so any carry-out from addition, or borrow-out from subtraction, lands in the MSB. That bit drives the carry flag, so the carry is never dropped.
- **Carry on subtraction:** carry is set when a borrow occurs (for example 5 - 10). This is the opposite of the Arm C flag after a subtraction, where C = 1 means no borrow.
- **Overflow detection:** carry flags unsigned overflow and overflow flags signed overflow, and they are computed independently. For ADD, overflow is set when both operands have the same sign and the result has a different sign. For SUB, it is set when the operands have different signs and the result's sign differs from A. Example on 8 bits: 200 + 100 sets carry but not overflow, and 127 + 1 sets overflow but not carry.
- **SRA and SRL:** arithmetic right shift fills vacated bits with the sign bit, which implements signed division by powers of two. The `$signed()` cast tells the synthesiser to treat A as signed for the `>>>` operator.
- **Shift amount:** only the low 3 bits of B (`B[2:0]`) are used, so shifts are 0 to 7 positions regardless of N.

## Verification

The testbench runs 20 directed test vectors covering:

- Basic arithmetic correctness
- Carry-out detection
- Signed overflow detection (ADD and SUB)
- Zero flag
- Negative flag
- SRA sign extension vs SRL zero-fill
- Edge cases: max positive, min negative, self subtraction

All 20 tests pass. The GitHub Actions workflow runs them on every push.

## How to Simulate

Requirements: Icarus Verilog and make.

```
make test
```

or manually:

```
iverilog -g2012 -o alu_sim alu.sv alu_tb.sv
vvp alu_sim
```

## Future Work

- Exhaustive verification for N=8 against a reference model
- Registered (pipelined) version of the ALU