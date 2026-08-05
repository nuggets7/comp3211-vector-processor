// written by Nishant Dave (z5589837)

module control_unit(
    // 4 bit OPCODE signal (Lowest 4 bits of 6 bit OPCODE)
    input [3:0] OPCODE, 

    // Outputs
    output REG_WRITE,
    output ITYPE_RD,
    output ITYPE_RT,
    output USE_IMM,
    output ALU_SRC,
    output MEM_WRITE,
    output MEM_READ,
    output AND_SEL,
    output OR_SEL,
    output JUMP_SEL,
    output JUMP_REG,
    output ADD_SEL,
    output SUB_SEL,
    output MULT_SEL,
    output DIV_SEL,
    output BRANCH,
    output BRANCH_EQ,
    output BRANCH_LT,
    output IN_SEL,
    output OUT_SEL
    );

    // R-type instructions
    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam AND = 4'b0010;
    localparam OR = 4'b0011;
    localparam JR = 4'b0100;
    localparam MULT = 4'b0101;
    localparam DIV = 4'b0110;

    // I-type instructions
    localparam LOAD = 4'b0111;
    localparam STORE = 4'b1000;
    localparam ADDI = 4'b1001;
    localparam BEQ = 4'b1010;
    localparam BLT = 4'b1011;
    localparam IN = 4'b1100;
    localparam OUT = 4'b1101;

    // J-type instructions
    localparam JAL = 4'b1110;
    localparam J = 4'b1111;

    assign REG_WRITE = (OPCODE == ADD) || (OPCODE == SUB) || (OPCODE == AND) || (OPCODE == OR) || (OPCODE == MULT) || (OPCODE == DIV) || (OPCODE == LOAD) || (OPCODE == ADDI) || (OPCODE == IN) || (OPCODE == JAL);
    assign ITYPE_RD = (OPCODE == LOAD) || (OPCODE == ADDI) || (OPCODE == IN);
    assign ITYPE_RT = (OPCODE == STORE) || (OPCODE == BEQ) || (OPCODE == BLT);
    assign USE_IMM = (OPCODE == LOAD) || (OPCODE == STORE) || (OPCODE == ADDI) || (OPCODE == BEQ) || (OPCODE == BLT) || (OPCODE == IN) || (OPCODE == OUT);
    assign ALU_SRC = (OPCODE == LOAD) || (OPCODE == STORE) || (OPCODE == ADDI);
    assign MEM_WRITE = (OPCODE == STORE);
    assign MEM_READ = (OPCODE == LOAD);
    assign AND_SEL = (OPCODE == AND);
    assign OR_SEL = (OPCODE == OR);
    assign JUMP_SEL = (OPCODE == J) || (OPCODE == JAL) || (OPCODE == JR);
    assign JUMP_REG = (OPCODE == JR);
    assign ADD_SEL = (OPCODE == ADD);
    assign SUB_SEL = (OPCODE == SUB);
    assign MULT_SEL = (OPCODE == MULT);
    assign DIV_SEL = (OPCODE == DIV); 
    assign BRANCH = (OPCODE == BEQ) || (OPCODE == BLT);
    assign BRANCH_EQ = (OPCODE == BEQ);
    assign BRANCH_LT = (OPCODE == BLT);
    assign IN_SEL = (OPCODE == IN);
    assign OUT_SEL = (OPCODE == OUT);
endmodule