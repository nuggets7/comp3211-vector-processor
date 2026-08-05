# Instruction Set Architecture (ISA) Opcodes & Formats

This document defines the final 32-bit instruction encoding formats and specific opcodes for the CPU and Coprocessor designed for the Data Preprocessing Assignment. 

It includes full support for conditionals and subroutines (functions) to keep the benchmark assembly code clean.

## 1. Instruction Formats (32-bit)

We use four instruction formats to accommodate all CPU and vector instructions within a 32-bit word constraint. Register fields (`Rs`, `Rt`, `Rd`) are 5 bits, allowing for 32 general-purpose registers. R31 is reserved as Ra, the return-address register used by JAL.

### R-Type (Register)
Used for arithmetic, logical operations between registers, and register jumps.
`[Opcode: 6 bits] [Rs: 5 bits] [Rt: 5 bits] [Rd: 5 bits] [Reserved: 11 bits]`

### I-Type (Immediate / Memory / Branch / IO)
Used for operations that require an immediate value, memory offsets, or branch offsets.
`[Opcode: 6 bits] [Rs: 5 bits] [Rd/Rt: 5 bits] [Immediate: 16 bits]`

### J-Type (Jump)
Used for unconditional jumps and function calls requiring a large address field.
`[Opcode: 6 bits] [Address: 26 bits]`

### V-Type (Vector / Coprocessor)
Custom format for coprocessor operations that require three register addresses (two source bases, one destination base). The vector size is fixed at a width or 4 elements of 8 bits each. Rk is a register that supplies the scalar for VSCALE and clip limit for VCLIP.
`[Opcode: 6 bits] [Rs: 5 bits] [Rt: 5 bits] [Rd: 5 bits] [Rk: 5 bits] [Reserved: 6 bits]`

*Note: The top two bits of the opcode select CPU vs coprocessor execution. Opcode[5:4] == 00 -> CPU, Opcode[5:4] != 00 -> CoProc*

---

## 2. Opcode Table (19 Final Instructions)

### R-Type Instructions

| Instruction | Opcode (Binary) | Description | Example Encoding (`[Op][Rs][Rt][Rd][Rsv]`) |
| :--- | :--- | :--- | :--- |
| **ADD** | `000000` | `Rd = Rs + Rt` | `000000 [Rs] [Rt] [Rd] 00000 000000` |
| **SUB** | `000001` | `Rd = Rs - Rt` | `000001 [Rs] [Rt] [Rd] 00000 000000` |
| **AND** | `000010` | `Rd = Rs & Rt` | `000010 [Rs] [Rt] [Rd] 00000 000000` |
| **OR** | `000011` | `Rd = Rs \| Rt` | `000011 [Rs] [Rt] [Rd] 00000 000000` |
| **JR**  | `000100` | Jump to address in `Rs` (Return) | `000100 [Rs] 00000 00000 00000 000000` |
| **MULT** | `000101` | `Rd = Rs * Rt` | `000101 [Rs] [Rt] [Rd] 00000 000000` |
| **DIV** | `000110` | `Rd = Rs / Rt` | `000110 [Rs] [Rt] [Rd] 00000 000000` | 

*Note: Division by 0 should set the destination register to all 1's, Multiplication overflow will truncate higher bits*

### I-Type Instructions

| Instruction | Opcode (Binary) | Description | Example Encoding (`[Op][Rs][Rd/Rt][Immediate]`) |
| :--- | :--- | :--- | :--- |
| **LOAD** | `000111` | `Rd = DMEM[Rs + imm]` | `000111 [Rs] [Rd] [16-bit offset]` |
| **STORE**| `001000` | `DMEM[Rs + imm] = Rt` | `001000 [Rs] [Rt] [16-bit offset]` |
| **ADDI** | `001001` | `Rd = Rs + imm` | `001001 [Rs] [Rd] [16-bit immediate]` |
| **BEQ**  | `001010` | Branch if `Rs == Rt` | `001010 [Rs] [Rt] [16-bit offset]` |
| **BLT**  | `001011` | Branch if `Rs < Rt` | `001011 [Rs] [Rt] [16-bit offset]` |
| **IN**   | `001100` | Read I/O `Rd` | `001100 00000 [Rd] [16-bit port id]` |
| **OUT**  | `001101` | Write `Rs` to I/O | `001101 [Rs] 00000 [16-bit port id]` |

### J-Type Instructions

*Note: `Ra` is a special register, reserved for the return address

| Instruction | Opcode (Binary) | Description | Example Encoding (`[Op][Address]`) |
| :--- | :--- | :--- | :--- |
| **JAL** | `001110` | Jump to address and store next instruction in `Ra` | `001110 [26-bit absolute address]` |
| **J** | `001111` | Jump to address, no link | `001111 [26-bit absolute address]` | 


### V-Type Instructions (Special Coprocessor Vectors)

| Instruction | Opcode (Binary) | Description | Example Encoding (`[Op][Rs][Rt][Rd][Rk][Rsv]`) |
| :--- | :--- | :--- | :--- |
| **VADD** | `010000` | `DMEM[Rd] = DMEM[Rs] + DMEM[Rt]` | `010000 [Rs] [Rt] [Rd] 00000 000000` |
| **VSCALE** | `100000` | `DMEM[Rd] = DMEM[Rs] * value[Rk]` | `100000 [Rs] 00000 [Rd] [Rk] 000000` |
| **VCLIP** | `110000` | `DMEM[Rd] = clip(DMEM[Rs], value[Rk])` | `110000 [Rs] 00000 [Rd] [Rk] 000000` |

---

## 3. Example Binary Breakdown

If we execute the instruction:
`ADD R3, R1, R2` (where `Rd`=R3, `Rs`=R1, `Rt`=R2)

- **Format:** R-Type
- **Opcode:** `000000` (6 bits)
- **Rs (R1):** `00001` (5 bits)
- **Rt (R2):** `00010` (5 bits)
- **Rd (R3):** `00011` (5 bits)
- **Reserved:** `00000 000000` (11 bits)

**Full 32-bit Binary:**
`000000_00001_00010_00011_00000_000000`

If we execute the instruciton: 
`VSCALE R5, R1, R2` (where `Rd` = R5, `Rs` = R1, `Rk` = R2)
- **Format:** V-Type
- **Opcode:** `010000` (6 bits)
- **Rs (R1):** `00001` (5 bits)
- **Rt :** `00000` (5 bits, unused)
- **Rd (R5):** `00101` (5 bits)
- **Rk (R2):** `00010` (5 bits)
- **Reserved:** `000000` (6 bits)

**Full 32-bit Binary:**
`010000_00001_00000_00101_00010_000000`

