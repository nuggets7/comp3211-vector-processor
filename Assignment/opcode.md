# Instruction Set Architecture (ISA) Opcodes & Formats

This document defines the final 32-bit instruction encoding formats and specific opcodes for the CPU and Coprocessor designed for the Data Preprocessing Assignment. 

It includes full support for conditionals and subroutines (functions) to keep the benchmark assembly code clean. We have also mapped Coprocessor polling to the standard `IN` instruction to save an opcode.

## 1. Instruction Formats (32-bit)

We use four instruction formats to accommodate all CPU and vector instructions within a 32-bit word constraint. Register fields (`Rs`, `Rt`, `Rd`) are 5 bits, allowing for 32 general-purpose registers.

### R-Type (Register)
Used for arithmetic, logical operations between registers, and register jumps.
`[Opcode: 6 bits] [Rs: 5 bits] [Rt: 5 bits] [Rd: 5 bits] [Reserved: 5 bits] [Funct: 6 bits]`

### I-Type (Immediate / Memory / Branch / IO)
Used for operations that require an immediate value, memory offsets, or branch offsets.
`[Opcode: 6 bits] [Rs: 5 bits] [Rd/Rt: 5 bits] [Immediate: 16 bits]`

### J-Type (Jump)
Used for unconditional jumps and function calls requiring a large address field.
`[Opcode: 6 bits] [Address: 26 bits]`

### V-Type (Vector / Coprocessor)
Custom format for coprocessor operations that require three register addresses (two source bases, one destination base) and an immediate (vector size or scalar).
`[Opcode: 6 bits] [Rs: 5 bits] [Rt: 5 bits] [Rd: 5 bits] [Immediate: 11 bits]`

---

## 2. Opcode Table (19 Final Instructions)

### R-Type Instructions (Opcode = `000000`)
The operation is determined by the `Funct` field.

| Instruction | Funct (Binary) | Description | Example Encoding (`[Op][Rs][Rt][Rd][Rsv][Funct]`) |
| :--- | :--- | :--- | :--- |
| **ADD** | `100000` | `Rd = Rs + Rt` | `000000 [Rs] [Rt] [Rd] 00000 100000` |
| **SUB** | `100010` | `Rd = Rs - Rt` | `000000 [Rs] [Rt] [Rd] 00000 100010` |
| **AND** | `100100` | `Rd = Rs & Rt` | `000000 [Rs] [Rt] [Rd] 00000 100100` |
| **OR** | `100101` | `Rd = Rs \| Rt` | `000000 [Rs] [Rt] [Rd] 00000 100101` |
| **CMP** | `101010` | Compare `Rs`, `Rt` | `000000 [Rs] [Rt] 00000 00000 101010` |
| **JR**  | `001000` | Jump to address in `Rs` (Return) | `000000 [Rs] 00000 00000 00000 001000` |

### I-Type Instructions

| Instruction | Opcode (Binary) | Description | Example Encoding (`[Op][Rs][Rd/Rt][Immediate]`) |
| :--- | :--- | :--- | :--- |
| **LOAD** | `001111` | `Rd = DMEM[Rs + imm]` | `001111 [Rs] [Rd] [16-bit offset]` |
| **STORE**| `010000` | `DMEM[Rs + imm] = Rt` | `010000 [Rs] [Rt] [16-bit offset]` |
| **ADDI** | `001000` | `Rd = Rs + imm` | `001000 [Rs] [Rd] [16-bit immediate]` |
| **BEQ**  | `000100` | Branch if `Rs == Rt` | `000100 [Rs] [Rt] [16-bit offset]` |
| **BNE**  | `000101` | Branch if `Rs != Rt` | `000101 [Rs] [Rt] [16-bit offset]` |
| **BLT**  | `000110` | Branch if `Rs < Rt` | `000110 [Rs] [Rt] [16-bit offset]` |
| **IN**   | `001100` | Read I/O or Coproc Status to `Rd` | `001100 00000 [Rd] [16-bit port id]` |
| **OUT**  | `001101` | Write `Rs` to I/O | `001101 [Rs] 00000 [16-bit port id]` |

### J-Type Instructions

| Instruction | Opcode (Binary) | Description | Example Encoding (`[Op][Address]`) |
| :--- | :--- | :--- | :--- |
| **JMP** | `000010` | Unconditional jump | `000010 [26-bit absolute address]` |
| **JAL** | `000011` | Jump & Link (Call func, save Return) | `000011 [26-bit absolute address]` |

### V-Type Instructions (Special Coprocessor Vectors)
*Note: `Rs` and `Rt` represent base addresses in memory for source vectors, `Rd` is the destination base address, and `Immediate` represents the vector size or a scalar value.*

| Instruction | Opcode (Binary) | Description | Example Encoding (`[Op][Rs][Rt][Rd][Immediate]`) |
| :--- | :--- | :--- | :--- |
| **VADD** | `011000` | `DMEM[Rd..] = DMEM[Rs..] + DMEM[Rt..]` | `011000 [Rs] [Rt] [Rd] [11-bit size]` |
| **VSCALE** | `011001` | `DMEM[Rd..] = DMEM[Rs..] * scalar` | `011001 [Rs] [00000] [Rd] [11-bit scalar/size]` |
| **VCLIP** | `011010` | `DMEM[Rd..] = clip(DMEM[Rs..], MAX)` | `011010 [Rs] [00000] [Rd] [11-bit MAX/size]` |

---

## 3. Example Binary Breakdown

If we execute the instruction:
`ADD R3, R1, R2` (where `Rd`=R3, `Rs`=R1, `Rt`=R2)

- **Format:** R-Type
- **Opcode:** `000000` (6 bits)
- **Rs (R1):** `00001` (5 bits)
- **Rt (R2):** `00010` (5 bits)
- **Rd (R3):** `00011` (5 bits)
- **Reserved:** `00000` (5 bits)
- **Funct (ADD):** `100000` (6 bits)

**Full 32-bit Binary:**
`000000_00001_00010_00011_00000_100000`
