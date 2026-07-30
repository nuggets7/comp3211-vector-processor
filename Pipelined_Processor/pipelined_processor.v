`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 09:31:43
// Design Name: 
// Module Name: pipelined_processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pipelined_processor(input clk, input reset, input [15:0] SW, output [16:0] LED);
    //------------------- IF wires ----------------------
    wire[3:0] sig_next_pc;
    wire[3:0] sig_curr_pc;
    wire[3:0] sig_pc_in;
    wire sig_pc_carry_out;
    wire[15:0] sig_insn;
    //------------------- IF/ID pipeline ----------------------
    reg[15:0] ifid_insn;
    reg[3:0] ifid_next_pc;
    //------------------- ID wires ----------------------
    wire id_reg_dst;
    wire id_reg_write;
    wire id_alu_src;
    wire id_mem_write;
    wire id_mem_to_reg;
    wire id_in_sel;
    wire id_out_sel;
    wire id_saddu_sel;
    wire id_dis_sel;
    wire[15:0] id_read_data_a;
    wire[15:0] id_read_data_b;
    wire[15:0] id_sign_extended;
    wire[3:0] id_write_register;
    //------------------- ID/EX pipeline ----------------------
    reg idex_reg_write;
    reg idex_alu_src;
    reg idex_mem_write;
    reg idex_mem_to_reg;
    reg idex_in_sel;
    reg idex_out_sel;
    reg idex_saddu_sel;
    reg idex_dis_sel;
    reg[15:0] idex_read_data_a;
    reg[15:0] idex_read_data_b;
    reg[15:0] idex_sign_extended;
    reg[3:0] idex_write_register;
    reg[3:0] idex_opcode;
    reg[3:0] idex_branch_target;
    //------------------- EX wires ----------------------
    wire ex_bne_taken;
    wire[15:0] ex_alu_src_b;
    wire[15:0] ex_alu_result;
    wire ex_alu_carry_out;
    wire[15:0] ex_saturated_sum;
    //------------------- EX/MEM pipeline ----------------------
    reg exmem_reg_write;
    reg exmem_mem_write;
    reg exmem_mem_to_reg;
    reg exmem_in_sel;
    reg exmem_out_sel;
    reg exmem_saddu_sel;
    reg exmem_dis_sel;
    reg[15:0] exmem_alu_result;
    reg exmem_alu_carry_out;
    reg[15:0] exmem_saturated_sum;
    reg[15:0] exmem_read_data_a;
    reg[15:0] exmem_read_data_b;
    reg[3:0] exmem_write_register;
    //------------------- MEM wires ----------------------
    wire[15:0] mem_data_out;
    //------------------- MEM/WB pipeline ----------------------
    reg memwb_reg_write;
    reg memwb_mem_to_reg;
    reg memwb_in_sel;
    reg memwb_out_sel;
    reg memwb_saddu_sel;
    reg memwb_dis_sel;
    reg[15:0] memwb_alu_result;
    reg[15:0] memwb_mem_data_out;
    reg[15:0] memwb_saturated_sum;
    reg[15:0] memwb_read_data_a;
    reg[3:0] memwb_write_register;
    //------------------- WB wires ----------------------
    wire[15:0] wb_mem_to_reg_out;
    wire[15:0] wb_in_sel_out;
    wire[15:0] wb_write_data;
    wire[15:0] sig_led_out;
    wire[15:0] sig_cop1_out;
    wire[15:0] sig_cop2_out;
    wire sig_flag;
    
    //------------------- IF stage ----------------------
    
    program_counter PC(
        .clk(clk),
        .reset(reset),
        .addr_in(sig_pc_in),
        .addr_out(sig_curr_pc)
    );
    
    adder_4b next_PC(
        .src_a(sig_curr_pc),
        .src_b(4'b0001),
        .sum(sig_next_pc),
        .carry_out(sig_pc_carry_out)
    );
    
    mux_2to1_4b mux_bne(
        .mux_select(ex_bne_taken),
        .data_a(sig_next_pc),
        .data_b(idex_branch_target),
        .data_out(sig_pc_in)
    );
    
    instruction_memory ins_mem(
        .clk(clk),
        .reset(reset),
        .addr_in(sig_curr_pc),
        .insn_out(sig_insn)
    );
    
    //------------------- ID stage ----------------------
    
    control_unit ctrl_unit(
        .opcode(ifid_insn[15:12]),
        .reg_dst(id_reg_dst),
        .reg_write(id_reg_write),
        .alu_src(id_alu_src),
        .mem_write(id_mem_write),
        .mem_to_reg(id_mem_to_reg),
        .in_sel(id_in_sel),
        .out_sel(id_out_sel),
        .saddu_sel(id_saddu_sel),
        .dis_sel(id_dis_sel)
    );
    
    mux_2to1_4b mux_reg_dst(
        .mux_select(id_reg_dst),
        .data_a(ifid_insn[7:4]),
        .data_b(ifid_insn[3:0]),
        .data_out(id_write_register)
    );
    
    register_file register_file_inst(
        .reset(reset),
        .clk(clk),
        .read_register_a(ifid_insn[11:8]),
        .read_register_b(ifid_insn[7:4]),
        .write_enable(memwb_reg_write),
        .write_register(memwb_write_register),
        .write_data(wb_write_data),
        .read_data_a(id_read_data_a),
        .read_data_b(id_read_data_b)
    );
    
    sign_extend_4to16 sign_extend(
        .data_in(ifid_insn[3:0]),
        .data_out(id_sign_extended)
    );
    
    //------------------- EX stage ----------------------
    
    assign ex_bne_taken = (idex_opcode == 4'b1101) && (idex_read_data_a != idex_read_data_b); 
    
    mux_2to1_16b mux_alu_src(
        .mux_select(idex_alu_src),
        .data_a(idex_read_data_b),
        .data_b(idex_sign_extended),
        .data_out(ex_alu_src_b)
    );
    
    adder_16b ALU(
        .src_a(idex_read_data_a),
        .src_b(ex_alu_src_b),
        .sum(ex_alu_result),
        .carry_out(ex_alu_carry_out)
    );
    
    saturate_16b sat(
        .sum_in(ex_alu_result),
        .carry_in(ex_alu_carry_out),
        .sum_out(ex_saturated_sum)
    );
    
    //------------------- MEM stage ----------------------
    
    data_memory data_mem(
        .reset(reset),
        .clk(clk),
        .write_enable(exmem_mem_write),
        .write_data(exmem_read_data_b),
        .addr_in(exmem_alu_result[3:0]),
        .data_out(mem_data_out)
    );
    
    //------------------- WB stage ----------------------
    
    mux_2to1_16b mux_mem_to_reg(
        .mux_select(memwb_mem_to_reg),
        .data_a(memwb_alu_result),
        .data_b(memwb_mem_data_out),
        .data_out(wb_mem_to_reg_out)
    );
    
    mux_2to1_16b mux_in_sel(
        .mux_select(memwb_in_sel),
        .data_a(wb_mem_to_reg_out),
        .data_b(SW),
        .data_out(wb_in_sel_out)
    );
    
    mux_2to1_16b mux_saddu_sel(
        .mux_select(memwb_saddu_sel),
        .data_a(wb_in_sel_out),
        .data_b(memwb_saturated_sum),
        .data_out(wb_write_data)
    );
    
    register_16b led_reg(
        .reset(reset),
        .clk(clk),
        .write_enable(memwb_out_sel),
        .data_in(memwb_read_data_a),
        .data_out(sig_led_out)
    );
    
    register_16b cop1_reg(
        .reset(reset),
        .clk(clk),
        .write_enable(memwb_dis_sel),
        .data_in(memwb_alu_result),
        .data_out(sig_cop1_out)
    );
    
    register_16b cop2_reg(
        .reset(reset),
        .clk(clk),
        .write_enable(memwb_dis_sel),
        .data_in(memwb_read_data_a),
        .data_out(sig_cop2_out)
    );
    
    register_1b flag_reg(
        .reset(reset),
        .clk(clk),
        .write_enable(memwb_dis_sel),
        .data_out(sig_flag)
    );
    
    assign LED[15:0] = sig_led_out;
    assign LED[16] = sig_flag;
    
    //------------------- IF/ID pipeline ----------------------
    always @(posedge clk) begin
        if (reset || ex_bne_taken) begin
            ifid_insn    <= 16'b0;
            ifid_next_pc <= 4'b0;
        end else begin
            ifid_insn <= sig_insn;
            ifid_next_pc <= sig_next_pc;
        end
    end

    //------------------- ID/EX pipeline ----------------------
    always @(posedge clk) begin
        if (reset || ex_bne_taken) begin
            idex_reg_write      <= 1'b0;
            idex_alu_src        <= 1'b0;
            idex_mem_write      <= 1'b0;
            idex_mem_to_reg     <= 1'b0;
            idex_in_sel         <= 1'b0;
            idex_out_sel        <= 1'b0;
            idex_saddu_sel      <= 1'b0;
            idex_dis_sel        <= 1'b0;
            idex_read_data_a    <= 16'b0;
            idex_read_data_b    <= 16'b0;
            idex_sign_extended  <= 16'b0;
            idex_write_register <= 4'b0;
            idex_opcode         <= 4'b0;
            idex_branch_target  <= 4'b0;
        end else begin
            idex_reg_write      <= id_reg_write;
            idex_alu_src        <= id_alu_src;
            idex_mem_write      <= id_mem_write;
            idex_mem_to_reg     <= id_mem_to_reg;
            idex_in_sel         <= id_in_sel;
            idex_out_sel        <= id_out_sel;
            idex_saddu_sel      <= id_saddu_sel;
            idex_dis_sel        <= id_dis_sel;
            idex_read_data_a    <= id_read_data_a;
            idex_read_data_b    <= id_read_data_b;
            idex_sign_extended  <= id_sign_extended;
            idex_write_register <= id_write_register;
            idex_opcode         <= ifid_insn[15:12];
            idex_branch_target  <= ifid_insn[3:0];
        end
    end
    
    //------------------- EX/MEM pipeline ----------------------
    
    always @(posedge clk) begin
        if (reset) begin
            exmem_reg_write      <= 1'b0;
            exmem_mem_write      <= 1'b0;
            exmem_mem_to_reg     <= 1'b0;
            exmem_in_sel         <= 1'b0;
            exmem_out_sel        <= 1'b0;
            exmem_saddu_sel      <= 1'b0;
            exmem_dis_sel        <= 1'b0;
            exmem_alu_result     <= 16'b0;
            exmem_alu_carry_out  <= 1'b0;
            exmem_saturated_sum  <= 16'b0;
            exmem_read_data_a    <= 16'b0;
            exmem_read_data_b    <= 16'b0;
            exmem_write_register <= 4'b0;
        end else begin
            exmem_reg_write      <= idex_reg_write;
            exmem_mem_write      <= idex_mem_write;
            exmem_mem_to_reg     <= idex_mem_to_reg;
            exmem_in_sel         <= idex_in_sel;
            exmem_out_sel        <= idex_out_sel;
            exmem_saddu_sel      <= idex_saddu_sel;
            exmem_dis_sel        <= idex_dis_sel;
            exmem_alu_result     <= ex_alu_result;
            exmem_alu_carry_out  <= ex_alu_carry_out;
            exmem_saturated_sum  <= ex_saturated_sum;
            exmem_read_data_a    <= idex_read_data_a;
            exmem_read_data_b    <= idex_read_data_b;
            exmem_write_register <= idex_write_register;
        end
    end
    
    //------------------- MEM/WB pipeline ----------------------
    
    always @(posedge clk) begin
        if (reset) begin
            memwb_reg_write      <= 1'b0;
            memwb_mem_to_reg     <= 1'b0;
            memwb_in_sel         <= 1'b0;
            memwb_out_sel        <= 1'b0;
            memwb_saddu_sel      <= 1'b0;
            memwb_dis_sel        <= 1'b0;
            memwb_alu_result     <= 16'b0;
            memwb_mem_data_out   <= 16'b0;
            memwb_saturated_sum  <= 16'b0;
            memwb_read_data_a    <= 16'b0;
            memwb_write_register <= 4'b0;
        end else begin
            memwb_reg_write      <= exmem_reg_write;
            memwb_mem_to_reg     <= exmem_mem_to_reg;
            memwb_in_sel         <= exmem_in_sel;
            memwb_out_sel        <= exmem_out_sel;
            memwb_saddu_sel      <= exmem_saddu_sel;
            memwb_dis_sel        <= exmem_dis_sel;
            memwb_alu_result     <= exmem_alu_result;
            memwb_mem_data_out   <= mem_data_out;
            memwb_saturated_sum  <= exmem_saturated_sum;
            memwb_read_data_a    <= exmem_read_data_a;
            memwb_write_register <= exmem_write_register;
        end
    end

endmodule
