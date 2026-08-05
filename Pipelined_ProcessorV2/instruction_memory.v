module instruction_memory(
    input reset, 
    input clk, 
    input[9:0] addr_in, 
    output reg [31:0] insn_out
    );

    always @(*) begin
        case (addr_in)
            10'd2: insn_out = 32'h1C010000; // LOAD R1, R0, 0
            10'd3: insn_out = 32'h1C020001; // LOAD R2, R0, 1
            10'd4: insn_out = 32'h40221800; // VADD R3, R1, R2
            10'd5: insn_out = 32'h241F000F; // ADDI R31, R0, 15
            10'd6: insn_out = 32'hC06027C0; // VCLIP R4, R3, R31
            10'd7: insn_out = 32'h34800000; // OUT R4 (Should turn 8 LEDs ON: 0F0F)

            10'd125: insn_out = 32'h279C0014; // ADDI    R28, R28, 20
            10'd126: insn_out = 32'h27BD0064; // ADDI    R29, R29, 100 (100 = 20 students * 5 values each)
            10'd127: insn_out = 32'h27DE0064; // ADDI    R30, R30, 100
            10'd128: insn_out = 32'h300A0000; // IN      R10
            10'd129: insn_out = 32'h202A0000; // STORE   R10, 0(R1)
            10'd130: insn_out = 32'h24210001; // ADDI    R1, R1, 1
            10'd131: insn_out = 32'h24420001; // ADDI    R2, R2, 1
            10'd132: insn_out = 32'h00000000; // NOOP
            10'd133: insn_out = 32'h00000000; // NOOP
            10'd134: insn_out = 32'h00000000; // NOOP
            10'd135: insn_out = 32'h2C5DFFF8; // BLT     R2, R29, Read_Loop
            10'd136: insn_out = 32'h00205800; // ADD     R11, R1, R0
            10'd137: insn_out = 32'h00000800; // ADD     R1, R0, R0
            10'd138: insn_out = 32'h00001000; // ADD     R2, R0, R0
            10'd139: insn_out = 32'h1C230000; // LOAD    R3, 0(R1)
            10'd140: insn_out = 32'h1C240001; // LOAD    R4, 1(R1)
            10'd141: insn_out = 32'h1C250002; // LOAD    R5, 2(R1)
            10'd142: insn_out = 32'h1C260003; // LOAD    R6, 3(R1)
            10'd143: insn_out = 32'h1C270004; // LOAD    R7, 4(R1)
            10'd144: insn_out = 32'h00854000; // ADD     R8, R4, R5
            10'd145: insn_out = 32'h01064000; // ADD     R8, R8, R6
            10'd146: insn_out = 32'h01074000; // ADD     R8, R8, R7
            10'd147: insn_out = 32'h00000000; // NOOP
            10'd148: insn_out = 32'h00000000; // NOOP
            10'd149: insn_out = 32'h00000000; // NOOP
            10'd150: insn_out = 32'h2D1E0001; // BLT     R8, R30, Cap_Ok
            10'd151: insn_out = 32'h03C04000; // ADD     R8, R30, R0
            10'd152: insn_out = 32'h016D7000; // ADD     R14, R11, R13
            10'd153: insn_out = 32'h21C80000; // STORE   R8, 0(R14)
            10'd154: insn_out = 32'h25AD0001; // ADDI    R13, R13, 1
            10'd155: insn_out = 32'h00250800; // ADD     R1, R1, 5
            10'd156: insn_out = 32'h00000000; // NOOP
            10'd157: insn_out = 32'h00000000; // NOOP
            10'd158: insn_out = 32'h00000000; // NOOP
            10'd159: insn_out = 32'h2DBCFFEB; // BLT     R13, R28, Proc_Loop
            10'd160: insn_out = 32'h00000800; // ADD     R1, R0, R0
            10'd161: insn_out = 32'h01617000; // ADD     R14, R11, R1
            10'd162: insn_out = 32'h1DCF0000; // LOAD    R15, 0(R14)
            10'd163: insn_out = 32'h020F8000; // ADD     R16, R16, R15
            10'd164: insn_out = 32'h26310001; // ADDI    R17, R17, 1
            10'd165: insn_out = 32'h00000000; // NOOP
            10'd166: insn_out = 32'h00000000; // NOOP
            10'd167: insn_out = 32'h00000000; // NOOP
            10'd168: insn_out = 32'h2E3CFFF8; // BLT     R17, R28, Avg_Totals
            10'd169: insn_out = 32'h1A1C9000; // DIV     R18, R16, R28
            10'd170: insn_out = 32'h36400000; // OUT     R18

            10'd229: insn_out = 32'h277B0005; // ADDI    R27, R27, 5
            10'd230: insn_out = 32'h279C0014; // ADDI    R28, R28, 20
            10'd231: insn_out = 32'h27BD0019; // ADDI    R29, R29, 25 (100 values / 4 values per 32 bits = 25)
            10'd232: insn_out = 32'h27DE0064; // ADDI    R30, R30, 100
            10'd233: insn_out = 32'h300A0000; // IN      R10
            10'd234: insn_out = 32'h202A0000; // STORE   R10, 0(R1)
            10'd235: insn_out = 32'h24210001; // ADDI    R1, R1, 1
            10'd236: insn_out = 32'h24420001; // ADDI    R2, R2, 1
            10'd237: insn_out = 32'h00000000; // NOOP
            10'd238: insn_out = 32'h00000000; // NOOP
            10'd239: insn_out = 32'h00000000; // NOOP
            10'd240: insn_out = 32'h2C5DFFF8; // BLT     R2, R29, Read_Loop
            10'd241: insn_out = 32'h00205800; // ADD     R11, R1, R0
            10'd242: insn_out = 32'h00000800; // ADD     R1, R0, R0
            10'd243: insn_out = 32'h00001000; // ADD     R2, R0, R0
            10'd244: insn_out = 32'h1C230005; // LOAD    R3, 5(R1)
            10'd245: insn_out = 32'h1C24000A; // LOAD    R4, 10(R1)
            10'd246: insn_out = 32'h1C25000F; // LOAD    R5, 15(R1)
            10'd247: insn_out = 32'h1C260014; // LOAD    R6, 20(R1)
            10'd248: insn_out = 32'h1C270019; // LOAD    R7, 25(R1)
            10'd249: insn_out = 32'h40644000; // VADD    R8, R3, R4
            10'd250: insn_out = 32'h41054000; // VADD    R8, R8, R5
            10'd251: insn_out = 32'h41064000; // VADD    R8, R8, R6
            10'd252: insn_out = 32'h41074000; // VADD    R8, R8, R7
            10'd253: insn_out = 32'hC1004780; // VCLIP   R8, 100
            10'd254: insn_out = 32'h01616000; // ADD     R12, R11, R1
            10'd255: insn_out = 32'h21880000; // STORE   R8, 0(R12)
            10'd256: insn_out = 32'h24210001; // ADDI    R1, R1, 1
            10'd257: insn_out = 32'h00000000; // NOOP
            10'd258: insn_out = 32'h00000000; // NOOP
            10'd259: insn_out = 32'h00000000; // NOOP
            10'd260: insn_out = 32'h2C3BFFEF; // BLT     R1, R27, Proc_Loop
            10'd261: insn_out = 32'h00000800; // ADD     R1, R0, R0
            10'd262: insn_out = 32'h000A4000; // ADD     R8, R0, R10
            10'd263: insn_out = 32'h01616000; // ADD     R12, R11, R1
            10'd264: insn_out = 32'h1D880000; // LOAD    R8, 0(R12)
            10'd265: insn_out = 32'h41284800; // VADD    R9, R9, R8
            10'd266: insn_out = 32'h24210001; // ADDI    R1, R1, 1
            10'd267: insn_out = 32'h00000000; // NOOP
            10'd268: insn_out = 32'h00000000; // NOOP
            10'd269: insn_out = 32'h00000000; // NOOP
            10'd270: insn_out = 32'h2C3BFFF8; // BLT     R1, R27, Avg_Totals
            10'd271: insn_out = 32'h241A0000; // ADDI    R26, R0, FF000000 (hex)
            10'd272: insn_out = 32'h24190000; // ADDI    R25, R0, 00FF0000 (hex)
            10'd273: insn_out = 32'h2418FF00; // ADDI    R24, R0, 0000FF00 (hex)
            10'd274: insn_out = 32'h241700FF; // ADDI    R23, R0, 000000FF (hex)
            10'd275: insn_out = 32'h0F49D000; // OR      R26, R26, R9
            10'd276: insn_out = 32'h0F29C800; // OR      R25, R25, R9
            10'd277: insn_out = 32'h0F09C000; // OR      R24, R24, R9
            10'd278: insn_out = 32'h0EE9B800; // OR      R23, R23, R9
            10'd279: insn_out = 32'h24150000; // ADDI    R21, 01000000 (hex)
            10'd280: insn_out = 32'h1B55D000; // DIV     R26, R26, R21
            10'd281: insn_out = 32'h0000A800; // ADD     R21, R0, R0
            10'd282: insn_out = 32'h24150000; // ADDI    R21, 00010000 (hex)
            10'd283: insn_out = 32'h1B35C800; // DIV     R25, R25, R21
            10'd284: insn_out = 32'h0000A800; // ADD     R21, R0, R0
            10'd285: insn_out = 32'h24150100; // ADDI    R21, 00000100 (hex)
            10'd286: insn_out = 32'h1B15C000; // DIV     R24, R24, R21
            10'd287: insn_out = 32'h02F8A000; // ADD     R20, R23, R24
            10'd288: insn_out = 32'h0299A000; // ADD     R20, R20, R25
            10'd289: insn_out = 32'h029AA000; // ADD     R20, R20, R26
            10'd290: insn_out = 32'h24160004; // ADDI    R22, R0, 4
            10'd291: insn_out = 32'h1A96A000; // DIV     R20, R20, R22
            10'd292: insn_out = 32'h36800000; // OUT     R20

            default: insn_out = 32'h00000000; // NOOP
        endcase
    end
endmodule