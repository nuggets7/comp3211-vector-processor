module instruction_memory(
    input reset, 
    input clk, 
    input[9:0] addr_in, 
    output[31:0] insn_out
    );
    
    reg[31:0] insn_array[0:1023];
    
    assign insn_out = insn_array[addr_in];
    
    integer i;
    
    initial begin
        // Initialize all 1024 instruction slots to 0 (NOOP)
        for (i = 0; i < 1024; i = i + 1) begin
            insn_array[i] = 32'h00000000;
        end
        
        // Load Vector 1 from Mem[0] into R1
        // Load Vector 2 from Mem[1] into R2
        // VADD vectors into R3
        // Load limit (15) into R31
        // VCLIP R3 by R31 into R4
        // OUT R4
        
        insn_array[0] = 32'h1C010000; // LOAD R1, R0, 0
        insn_array[1] = 32'h1C020001; // LOAD R2, R0, 1
        insn_array[2] = 32'h40221800; // VADD R3, R1, R2
        insn_array[3] = 32'h241F000F; // ADDI R31, R0, 15
        insn_array[4] = 32'hC06027C0; // VCLIP R4, R3, R31
        insn_array[5] = 32'h34800000; // OUT R4
    
    end
endmodule