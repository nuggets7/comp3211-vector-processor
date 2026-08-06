module instruction_memory_case1(
    input reset,
    input clk,
    input [9:0] addr_in,
    output reg [31:0] insn_out
    );
 
    always @(*) begin
        case (addr_in)
            10'd0: insn_out = 32'h241E0000; // ADDI R30, R0, 0
            10'd1: insn_out = 32'h241D02BC; // ADDI R29, R0, 700
            10'd2: insn_out = 32'h241C0064; // ADDI R28, R0, 100
            10'd3: insn_out = 32'h241B0006; // ADDI R27, R0, 6
            10'd4: insn_out = 32'h241A00FF; // ADDI R26, R0, 255
            10'd5: insn_out = 32'h24190064; // ADDI R25, R0, 100
            10'd6: insn_out = 32'h2418FFFF; // ADDI R24, R0, 65535
            10'd7: insn_out = 32'h03C00800; // ADD R1, R30, R0
            10'd8: insn_out = 32'h00001000; // ADD R2, R0, R0
            10'd9: insn_out = 32'h179B1800; // MULT R3, R28, R27
            10'd10: insn_out = 32'h30170000; // IN R23, 0            [READ_LOOP]
            10'd11: insn_out = 32'h20370000; // STORE R23, 0(R1)
            10'd12: insn_out = 32'h24210001; // ADDI R1, R1, 1
            10'd13: insn_out = 32'h24420001; // ADDI R2, R2, 1
            10'd14: insn_out = 32'h2C43FFFB; // BLT R2, R3, READ_LOOP
            10'd15: insn_out = 32'h03C00800; // ADD R1, R30, R0
            10'd16: insn_out = 32'h00001000; // ADD R2, R0, R0
            10'd17: insn_out = 32'h03005800; // ADD R11, R24, R0
            10'd18: insn_out = 32'h00006000; // ADD R12, R0, R0
            10'd19: insn_out = 32'h03A09800; // ADD R19, R29, R0
            10'd20: insn_out = 32'h0000A000; // ADD R20, R0, R0
            10'd21: insn_out = 32'h0000A800; // ADD R21, R0, R0
            10'd22: insn_out = 32'h1C240000; // LOAD R4, 0(R1)       [PROC_LOOP]
            10'd23: insn_out = 32'h1C250001; // LOAD R5, 1(R1)
            10'd24: insn_out = 32'h1C260002; // LOAD R6, 2(R1)
            10'd25: insn_out = 32'h1C270003; // LOAD R7, 3(R1)
            10'd26: insn_out = 32'h1C280004; // LOAD R8, 4(R1)
            10'd27: insn_out = 32'h1C290005; // LOAD R9, 5(R1)
            10'd28: insn_out = 32'h28BA0001; // BEQ R5, R26, M1_EMPTY
            10'd29: insn_out = 32'h3C00001F; // J M1_OK
            10'd30: insn_out = 32'h00002800; // ADD R5, R0, R0       [M1_EMPTY]
            10'd31: insn_out = 32'h28DA0001; // BEQ R6, R26, M2_EMPTY [M1_OK]
            10'd32: insn_out = 32'h3C000022; // J M2_OK
            10'd33: insn_out = 32'h00003000; // ADD R6, R0, R0       [M2_EMPTY]
            10'd34: insn_out = 32'h28FA0001; // BEQ R7, R26, M3_EMPTY [M2_OK]
            10'd35: insn_out = 32'h3C000025; // J M3_OK
            10'd36: insn_out = 32'h00003800; // ADD R7, R0, R0       [M3_EMPTY]
            10'd37: insn_out = 32'h291A0001; // BEQ R8, R26, M4_EMPTY [M3_OK]
            10'd38: insn_out = 32'h3C000028; // J M4_OK
            10'd39: insn_out = 32'h00004000; // ADD R8, R0, R0       [M4_EMPTY]
            10'd40: insn_out = 32'h293A0001; // BEQ R9, R26, M5_EMPTY [M4_OK]
            10'd41: insn_out = 32'h3C00002B; // J M5_OK
            10'd42: insn_out = 32'h00004800; // ADD R9, R0, R0       [M5_EMPTY]
            10'd43: insn_out = 32'h00A65000; // ADD R10, R5, R6      [M5_OK]
            10'd44: insn_out = 32'h01475000; // ADD R10, R10, R7
            10'd45: insn_out = 32'h01485000; // ADD R10, R10, R8
            10'd46: insn_out = 32'h01495000; // ADD R10, R10, R9
            10'd47: insn_out = 32'h2D590001; // BLT R10, R25, CAP_OK
            10'd48: insn_out = 32'h03205000; // ADD R10, R25, R0
            10'd49: insn_out = 32'h288B0014; // BEQ R4, R11, SAME_GROUP [CAP_OK]
            10'd50: insn_out = 32'h2978000A; // BEQ R11, R24, SKIP_FLUSH
            10'd51: insn_out = 32'h226D0000; // STORE R13, 0(R19)
            10'd52: insn_out = 32'h226E0001; // STORE R14, 1(R19)
            10'd53: insn_out = 32'h226F0002; // STORE R15, 2(R19)
            10'd54: insn_out = 32'h22700003; // STORE R16, 3(R19)
            10'd55: insn_out = 32'h22710004; // STORE R17, 4(R19)
            10'd56: insn_out = 32'h22720005; // STORE R18, 5(R19)
            10'd57: insn_out = 32'h226C0006; // STORE R12, 6(R19)
            10'd58: insn_out = 32'h26730007; // ADDI R19, R19, 7
            10'd59: insn_out = 32'h028CA000; // ADD R20, R20, R12
            10'd60: insn_out = 32'h26B50001; // ADDI R21, R21, 1
            10'd61: insn_out = 32'h00805800; // ADD R11, R4, R0      [SKIP_FLUSH]
            10'd62: insn_out = 32'h01406000; // ADD R12, R10, R0
            10'd63: insn_out = 32'h00806800; // ADD R13, R4, R0
            10'd64: insn_out = 32'h00A07000; // ADD R14, R5, R0
            10'd65: insn_out = 32'h00C07800; // ADD R15, R6, R0
            10'd66: insn_out = 32'h00E08000; // ADD R16, R7, R0
            10'd67: insn_out = 32'h01008800; // ADD R17, R8, R0
            10'd68: insn_out = 32'h01209000; // ADD R18, R9, R0
            10'd69: insn_out = 32'h3C00004F; // J GROUP_DONE
            10'd70: insn_out = 32'h2D8A0001; // BLT R12, R10, NEW_BEST [SAME_GROUP]
            10'd71: insn_out = 32'h3C00004F; // J GROUP_DONE
            10'd72: insn_out = 32'h01406000; // ADD R12, R10, R0     [NEW_BEST]
            10'd73: insn_out = 32'h00806800; // ADD R13, R4, R0
            10'd74: insn_out = 32'h00A07000; // ADD R14, R5, R0
            10'd75: insn_out = 32'h00C07800; // ADD R15, R6, R0
            10'd76: insn_out = 32'h00E08000; // ADD R16, R7, R0
            10'd77: insn_out = 32'h01008800; // ADD R17, R8, R0
            10'd78: insn_out = 32'h01209000; // ADD R18, R9, R0
            10'd79: insn_out = 32'h24210006; // ADDI R1, R1, 6       [GROUP_DONE]
            10'd80: insn_out = 32'h24420001; // ADDI R2, R2, 1
            10'd81: insn_out = 32'h2C5CFFC4; // BLT R2, R28, PROC_LOOP
            10'd82: insn_out = 32'h226D0000; // STORE R13, 0(R19)
            10'd83: insn_out = 32'h226E0001; // STORE R14, 1(R19)
            10'd84: insn_out = 32'h226F0002; // STORE R15, 2(R19)
            10'd85: insn_out = 32'h22700003; // STORE R16, 3(R19)
            10'd86: insn_out = 32'h22710004; // STORE R17, 4(R19)
            10'd87: insn_out = 32'h22720005; // STORE R18, 5(R19)
            10'd88: insn_out = 32'h226C0006; // STORE R12, 6(R19)
            10'd89: insn_out = 32'h26730007; // ADDI R19, R19, 7
            10'd90: insn_out = 32'h028CA000; // ADD R20, R20, R12
            10'd91: insn_out = 32'h26B50001; // ADDI R21, R21, 1
            10'd92: insn_out = 32'h1A95B000; // DIV R22, R20, R21
            10'd93: insn_out = 32'h36C00001; // OUT R22, 1
            10'd94: insn_out = 32'h3C00005E; // J HALT               [HALT]
 
            default: insn_out = 32'h00000000; // NOOP
        endcase
    end
endmodule
