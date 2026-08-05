module instruction_memory(
    input reset, 
    input clk, 
    input[9:0] addr_in, 
    output[31:0] insn_out
    );
    
    reg[31:0] insn_array[0:31];
    
    assign insn_out = insn_array[addr_in];
    
    always @(posedge clk) begin
        if (reset) begin
            //      initial values of the instruction memory :
            //      insn_0 : load  $1, $0, 0   - load data 0($0) into $1
            //      insn_1 : load  $2, $0, 1   - load data 1($0) into $2
            //      insn_2 : noop
            //      insn_3 : noop
            //      insn_4 : out $1            - led = 5
            //      insn_5 : add $3, $1, $2    - add $1 and $2 into 3
            //      insn_6 : noop
            //      insn_7 : noop
            //      insn_8 : noop
            //      insn_9 : bne $1, $2, 12    - branch will be taken (5 != 8)
            //      insn_10: noop
            //      insn_11: noop
            //      insn_12: dis $3, $1, 2     - cop1 = $1 + 2 = 7, cop2 = 13, flag = 1
            //      insn_13: out $3            - led = 13
            //      insn_14: noop
            //      insn_15: noop
            
            insn_array[0] <= 32'h1010;
            insn_array[1] <= 32'h1021;
            insn_array[2] <= 32'h0000;
            insn_array[3] <= 32'h0000;
            insn_array[4] <= 32'hb100;
            insn_array[5] <= 32'h8123;
            insn_array[6] <= 32'h0000;
            insn_array[7] <= 32'h0000;
            insn_array[8] <= 32'h0000;
            insn_array[9] <= 32'hd12c;
            insn_array[10] <= 32'h0000;
            insn_array[11] <= 32'h0000;
            insn_array[12] <= 32'he312;
            insn_array[13] <= 32'hb300;
            insn_array[14] <= 32'h0000;
            insn_array[15] <= 32'h0000;
        end
    end
endmodule