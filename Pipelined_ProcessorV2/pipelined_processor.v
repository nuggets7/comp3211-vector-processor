`timescale 1ns / 1ps

module pipelined_processor(
    input clk,
    input reset,
    input [15:0] SW,
    output wire [16:0] LED,
    output wire [9:0] pc_out

);

    // ==========================================
    // IF Stage
    // ==========================================

    wire [9:0] sig_curr_pc;
    wire [9:0] sig_next_pc;
    wire [9:0] sig_pc_in;
    wire [31:0] sig_insn;

    wire ex_branch_taken;
    wire id_JUMP_SEL;
    wire id_JUMP_REG;
    wire [9:0] id_jump_target;
    wire [9:0] ex_branch_target;
    wire [31:0] id_ra_data;


    // program_counter.v
    program_counter PC(
        .clk(clk),
        .reset(reset),
        .addr_in(sig_pc_in),
        .addr_out(sig_curr_pc)
    );

    wire hazard_stall;
    wire stall_pipeline;
    wire overall_stall = stall_pipeline | hazard_stall;

    // adder_10b.v
    adder_10b next_PC(
        .src_a(sig_curr_pc),
        .src_b(10'b0000000001),
        .sum(sig_next_pc),
        .carry_out()
    );

    assign sig_pc_in = overall_stall ? sig_curr_pc :
                       ex_branch_taken ? ex_branch_target : 
                       (link_jump_taken && !hazard_stall) ? link_jump_target :
                       (jump_taken && !hazard_stall) ? jump_target[9:0] : sig_next_pc;

    // instruction_memory.v
    instruction_memory ins_mem(
        .clk(clk),
        .reset(reset),
        .addr_in(sig_curr_pc),
        .insn_out(sig_insn)
    );

    // ==========================================
    // IF/ID Pipeline Register
    // ==========================================
    reg [31:0] ifid_insn;
    reg [9:0] ifid_pc_plus_1;

    wire jump_flush;
    wire link_flush;

    always @(posedge clk) begin
        // Flush on branch or jump
        if (reset || ex_branch_taken || ((jump_flush || link_flush) && !overall_stall)) begin
            ifid_insn <= 32'b0;
            ifid_pc_plus_1 <= 10'b0;
        end else if (!overall_stall) begin
            ifid_insn <= sig_insn;
            ifid_pc_plus_1 <= sig_next_pc;
        end
    end

    // ==========================================
    // ID Stage
    // ==========================================
    wire [1:0] id_cop_op = ifid_insn[31:30];
    wire [3:0] id_opcode = ifid_insn[29:26];
    wire [4:0] id_rs = ifid_insn[25:21];
    wire [4:0] id_rt = ifid_insn[20:16];
    wire [4:0] id_rd = ifid_insn[15:11];
    wire [15:0] id_imm = ifid_insn[15:0];
    assign id_jump_target = ifid_insn[9:0];

    // Control signals
    wire id_REG_WRITE, id_ITYPE_RD, id_ITYPE_RT, id_USE_IMM, id_ALU_SRC;
    wire id_MEM_WRITE, id_MEM_READ;
    wire id_AND_SEL, id_OR_SEL;
    wire id_ADD_SEL, id_SUB_SEL, id_MULT_SEL, id_DIV_SEL;
    wire id_BRANCH, id_BRANCH_EQ, id_BRANCH_LT;
    wire id_IN_SEL, id_OUT_SEL;

    // control_unit.v
    control_unit ctrl_unit(
        .OPCODE(id_opcode),
        .REG_WRITE(id_REG_WRITE),
        .ITYPE_RD(id_ITYPE_RD),
        .ITYPE_RT(id_ITYPE_RT),
        .USE_IMM(id_USE_IMM),
        .ALU_SRC(id_ALU_SRC),
        .MEM_WRITE(id_MEM_WRITE),
        .MEM_READ(id_MEM_READ),
        .AND_SEL(id_AND_SEL),
        .OR_SEL(id_OR_SEL),
        .JUMP_SEL(),
        .JUMP_REG(),
        .ADD_SEL(id_ADD_SEL),
        .SUB_SEL(id_SUB_SEL),
        .MULT_SEL(id_MULT_SEL),
        .DIV_SEL(id_DIV_SEL),
        .BRANCH(id_BRANCH),
        .BRANCH_EQ(id_BRANCH_EQ),
        .BRANCH_LT(id_BRANCH_LT),
        .IN_SEL(id_IN_SEL),
        .OUT_SEL(id_OUT_SEL)
    );

    wire [31:0] id_rb_data, id_k_data;
    wire wb_reg_write;
    wire [4:0] wb_write_reg;
    wire [31:0] wb_write_data;
    
    wire io_reg_write_enable;
    wire [4:0] io_reg_write_register;
    wire [31:0] io_reg_write_data;
    wire io_out_valid;
    wire [15:0] io_out_port;
    wire [31:0] io_out_data;
    
    reg id_valid;
    always @(posedge clk) begin
        if (reset || ex_branch_taken || ((jump_flush || link_flush) && !overall_stall)) begin
            id_valid <= 1'b0;
        end else if (stall_pipeline) begin
            // IO control stall (IN instruction): clear to prevent re-execution
            id_valid <= 1'b0;
        end else if (!hazard_stall) begin
            // No stall: new instruction entering IF/ID next cycle
            id_valid <= 1'b1;
        end
        // During hazard_stall: id_valid RETAINS its value so the stalled
        // instruction (e.g. OUT) gets executed when the hazard clears
    end

    // Hazard Detection Unit
    // Combined "will write" signals that include coprocessor instructions
    wire idex_will_write  = idex_REG_WRITE  | idex_is_cop;
    wire exmem_will_write = exmem_REG_WRITE | exmem_is_cop;
    wire memwb_will_write = memwb_REG_WRITE | memwb_is_cop;

    wire id_rs_required_in_id = (id_opcode == 4'b0100) /* JR */ | (id_opcode == 4'b1101) /* OUT */;
    
    wire hazard_in_ex = idex_will_write && (idex_write_reg != 5'd0) && (idex_write_reg == id_rs);
    wire hazard_in_mem = exmem_will_write && (exmem_write_reg != 5'd0) && (exmem_write_reg == id_rs);
    wire hazard_in_wb = memwb_will_write && (memwb_write_reg != 5'd0) && (memwb_write_reg == id_rs);
    
    wire id_stage_hazard = id_rs_required_in_id && (hazard_in_ex | hazard_in_mem | hazard_in_wb);
    
    wire load_use_hazard = idex_MEM_READ && ((idex_write_reg == id_rs) || (idex_write_reg == id_rt) || (id_is_cop && idex_write_reg == 5'd31));
    
    assign hazard_stall = load_use_hazard | id_stage_hazard;

    // io_control.v
    io_control io_ctrl(
        .clk(clk),
        .reset(reset),
        .cancel(ex_branch_taken),
        .execute_valid(id_valid && !hazard_stall),
        .instruction(ifid_insn),
        .rs_value(id_ra_data),
        .io_input_data({16'b0, SW}),
        .stall_pipeline(stall_pipeline),
        .in_request(),
        .in_port(),
        .reg_write_enable(io_reg_write_enable),
        .reg_write_register(io_reg_write_register),
        .reg_write_data(io_reg_write_data),
        .out_valid(io_out_valid),
        .out_port(io_out_port),
        .out_data(io_out_data)
    );

    wire wb_reg_write_final = wb_reg_write | io_reg_write_enable | ra_write_enable;
    wire [4:0] wb_write_reg_final = io_reg_write_enable ? io_reg_write_register :
                                    ra_write_enable ? ra_write_register : wb_write_reg;
    wire [31:0] wb_write_data_final = io_reg_write_enable ? io_reg_write_data :
                                      ra_write_enable ? ra_write_data : wb_write_data;

    wire [31:0] debug_r4;
    wire [31:0] debug_r5;

    // register_file.v
    register_file register_file_inst(
        .clk(clk),
        .reset(reset),
        .write_enable(wb_reg_write_final),
        .RA(id_rs),
        .RB(id_rt),
        .RD(wb_write_reg_final),
        .RD_Data(wb_write_data_final),
        .RA_Out(id_ra_data),
        .RB_Out(id_rb_data),
        .K_Out(id_k_data)
    );

    wire [31:0] id_imm_ext;

    // sign_extend_16to32.v
    sign_extend_16to32 sign_ext(
        .data_in(id_imm),
        .data_out(id_imm_ext)
    );

    wire id_is_cop = (id_cop_op != 2'b00);
    wire [4:0] id_write_reg;
    
    // Determine write destination register
    assign id_write_reg = id_is_cop ? id_rd :
                          id_ITYPE_RD ? id_rt : id_rd;
                          
    // Jump and Link Controls
    wire jump_taken;
    wire [31:0] jump_target;
    
    // jump_control.v
    jump_control jump_ctrl(
        .instruction(ifid_insn),
        .jump_taken(jump_taken),
        .jump_target(jump_target),
        .flush_pipeline(jump_flush)
    );
    
    wire link_jump_taken;
    wire [9:0] link_jump_target;
    wire ra_write_enable;
    wire [4:0] ra_write_register;
    wire [31:0] ra_write_data;
    
    // link_control.v
    link_control link_ctrl(
        .instruction(ifid_insn),
        .current_pc(ifid_pc_plus_1 - 10'd1),
        .rs_value(id_ra_data),
        .link_jump_taken(link_jump_taken),
        .link_jump_target(link_jump_target),
        .ra_write_enable(ra_write_enable),
        .ra_write_register(ra_write_register),
        .ra_write_data(ra_write_data),
        .flush_pipeline(link_flush)
    );

    // ==========================================
    // ID/EX Pipeline Register
    // ==========================================
    reg [31:0] idex_ra_data, idex_rb_data, idex_k_data, idex_imm_ext;
    reg [4:0] idex_write_reg, idex_rs, idex_rt;
    reg [9:0] idex_pc_plus_1;
    reg idex_REG_WRITE, idex_ALU_SRC, idex_MEM_WRITE, idex_MEM_READ;
    reg idex_AND_SEL, idex_OR_SEL, idex_ADD_SEL, idex_SUB_SEL, idex_MULT_SEL, idex_DIV_SEL;
    reg idex_BRANCH, idex_BRANCH_EQ, idex_BRANCH_LT;
    reg idex_IN_SEL, idex_OUT_SEL, idex_JUMP_SEL;
    reg idex_is_cop;
    reg [1:0] idex_cop_op;

    always @(posedge clk) begin
        if (reset || ex_branch_taken || overall_stall) begin
            idex_REG_WRITE <= 0;
            idex_MEM_WRITE <= 0;
            idex_MEM_READ <= 0;
            idex_BRANCH <= 0;
            idex_is_cop <= 0;
            idex_OUT_SEL <= 0;
            idex_IN_SEL <= 0;
            idex_JUMP_SEL <= 0;
            idex_ALU_SRC <= 0;
            idex_AND_SEL <= 0; idex_OR_SEL <= 0;
            idex_ADD_SEL <= 0; idex_SUB_SEL <= 0;
            idex_MULT_SEL <= 0; idex_DIV_SEL <= 0;
            idex_BRANCH_EQ <= 0; idex_BRANCH_LT <= 0;
            idex_write_reg <= 5'b0;
            idex_rs <= 5'b0;
            idex_rt <= 5'b0;
            idex_cop_op <= 2'b0;
            idex_ra_data <= 32'b0; idex_rb_data <= 32'b0;
            idex_k_data <= 32'b0; idex_imm_ext <= 32'b0;
            idex_pc_plus_1 <= 10'b0;
        end else begin
            idex_ra_data <= id_ra_data;
            idex_rb_data <= id_rb_data;
            idex_k_data <= id_k_data;
            idex_imm_ext <= id_imm_ext;
            idex_write_reg <= id_write_reg;
            idex_rs <= id_rs;
            idex_rt <= id_rt;
            idex_pc_plus_1 <= ifid_pc_plus_1;
            // Prevent IN or JAL from writing again in WB since they write in ID
            idex_REG_WRITE <= id_REG_WRITE && !id_IN_SEL && !ra_write_enable;
            idex_ALU_SRC <= id_ALU_SRC;
            idex_MEM_WRITE <= id_MEM_WRITE;
            idex_MEM_READ <= id_MEM_READ;
            idex_AND_SEL <= id_AND_SEL;
            idex_OR_SEL <= id_OR_SEL;
            idex_ADD_SEL <= id_ADD_SEL;
            idex_SUB_SEL <= id_SUB_SEL;
            idex_MULT_SEL <= id_MULT_SEL;
            idex_DIV_SEL <= id_DIV_SEL;
            idex_BRANCH <= id_BRANCH;
            idex_BRANCH_EQ <= id_BRANCH_EQ;
            idex_BRANCH_LT <= id_BRANCH_LT;
            idex_IN_SEL <= id_IN_SEL;
            idex_OUT_SEL <= id_OUT_SEL;
            idex_JUMP_SEL <= id_JUMP_SEL;
            idex_is_cop <= id_is_cop;
            idex_cop_op <= id_cop_op;
        end
    end

    // ==========================================
    // EX Stage & Forwarding Unit
    // ==========================================
    
    wire [1:0] forward_a = (exmem_will_write && (exmem_write_reg != 5'd0) && (exmem_write_reg == idex_rs)) ? 2'b10 :
                           (memwb_will_write && (memwb_write_reg != 5'd0) && (memwb_write_reg == idex_rs)) ? 2'b01 : 2'b00;

    wire [1:0] forward_b = (exmem_will_write && (exmem_write_reg != 5'd0) && (exmem_write_reg == idex_rt)) ? 2'b10 :
                           (memwb_will_write && (memwb_write_reg != 5'd0) && (memwb_write_reg == idex_rt)) ? 2'b01 : 2'b00;

    wire [1:0] forward_k = (exmem_will_write && (exmem_write_reg != 5'd0) && (exmem_write_reg == 5'd31)) ? 2'b10 :
                           (memwb_will_write && (memwb_write_reg != 5'd0) && (memwb_write_reg == 5'd31)) ? 2'b01 : 2'b00;

    wire [31:0] exmem_forward_data = exmem_MEM_READ ? mem_data_out :
                                     exmem_is_cop ? exmem_cop_result : exmem_alu_result;

    wire [31:0] forward_a_val = (forward_a == 2'b10) ? exmem_forward_data :
                                (forward_a == 2'b01) ? wb_write_data :
                                idex_ra_data;

    wire [31:0] forward_b_val = (forward_b == 2'b10) ? exmem_forward_data :
                                (forward_b == 2'b01) ? wb_write_data :
                                idex_rb_data;

    wire [31:0] forward_k_val = (forward_k == 2'b10) ? exmem_forward_data :
                                (forward_k == 2'b01) ? wb_write_data :
                                idex_k_data;

    wire [31:0] ex_alu_b = idex_ALU_SRC ? idex_imm_ext : forward_b_val;
    wire [31:0] ex_alu_result;
    
    // alu.v
    alu ALU(
        .A(forward_a_val),
        .B(ex_alu_b),
        .ADD_SEL(idex_ADD_SEL),
        .SUB_SEL(idex_SUB_SEL),
        .MULT_SEL(idex_MULT_SEL),
        .DIV_SEL(idex_DIV_SEL),
        .AND_SEL(idex_AND_SEL),
        .OR_SEL(idex_OR_SEL),
        .RESULT(ex_alu_result)
    );

    wire [31:0] ex_cop_result;


    // co_processor.v
    co_processor COP(
        .OPCODE(idex_cop_op),
        .RA(forward_a_val),
        .RB(forward_b_val),
        .K(forward_k_val),
        .RD(ex_cop_result)
    );

    // Branch resolution
    wire ex_eq = (forward_a_val == forward_b_val);
    wire ex_lt = ($signed(forward_a_val) < $signed(forward_b_val));
    assign ex_branch_taken = idex_BRANCH & ((idex_BRANCH_EQ & ex_eq) | (idex_BRANCH_LT & ex_lt));
    assign ex_branch_target = idex_pc_plus_1 + idex_imm_ext[9:0];

    // ==========================================
    // EX/MEM Pipeline Register
    // ==========================================
    reg [31:0] exmem_alu_result, exmem_cop_result, exmem_rb_data, exmem_ra_data;
    reg [4:0] exmem_write_reg;
    reg [9:0] exmem_pc_plus_1;
    reg exmem_REG_WRITE, exmem_MEM_WRITE, exmem_MEM_READ;
    reg exmem_IN_SEL, exmem_OUT_SEL, exmem_JUMP_SEL, exmem_is_cop;

    always @(posedge clk) begin
        if (reset) begin
            exmem_REG_WRITE <= 0;
            exmem_MEM_WRITE <= 0;
            exmem_MEM_READ <= 0;
            exmem_OUT_SEL <= 0;
            exmem_IN_SEL <= 0;
            exmem_JUMP_SEL <= 0;
            exmem_is_cop <= 0;
            exmem_write_reg <= 5'b0;
            exmem_alu_result <= 32'b0; exmem_cop_result <= 32'b0;
            exmem_rb_data <= 32'b0; exmem_ra_data <= 32'b0;
            exmem_pc_plus_1 <= 10'b0;
        end else begin
            exmem_alu_result <= ex_alu_result;
            exmem_cop_result <= ex_cop_result;
            exmem_rb_data <= forward_b_val; // Store the forwarded B value for memory write
            exmem_ra_data <= forward_a_val;
            exmem_write_reg <= idex_write_reg;
            exmem_pc_plus_1 <= idex_pc_plus_1;
            exmem_REG_WRITE <= idex_REG_WRITE;
            exmem_MEM_WRITE <= idex_MEM_WRITE;
            exmem_MEM_READ <= idex_MEM_READ;
            exmem_IN_SEL <= idex_IN_SEL;
            exmem_OUT_SEL <= idex_OUT_SEL;
            exmem_JUMP_SEL <= idex_JUMP_SEL;
            exmem_is_cop <= idex_is_cop;
        end
    end

    // ==========================================
    // MEM Stage
    // ==========================================
    wire [31:0] mem_data_out;

    // data_memory.v
    data_memory data_mem(
        .reset(reset),
        .clk(clk),
        .read_enable(exmem_MEM_READ),
        .write_enable(exmem_MEM_WRITE),
        .addr_in(exmem_alu_result[9:0]),
        .write_data(exmem_rb_data),
        .data_out(mem_data_out)
    );

    // ==========================================
    // MEM/WB Pipeline Register
    // ==========================================
    reg [31:0] memwb_alu_result, memwb_cop_result, memwb_mem_data, memwb_ra_data;
    reg [4:0] memwb_write_reg;
    reg [9:0] memwb_pc_plus_1;
    reg memwb_REG_WRITE, memwb_IN_SEL, memwb_OUT_SEL, memwb_JUMP_SEL, memwb_is_cop, memwb_MEM_READ;

    always @(posedge clk) begin
        if (reset) begin
            memwb_REG_WRITE <= 0;
            memwb_OUT_SEL <= 0;
            memwb_IN_SEL <= 0;
            memwb_JUMP_SEL <= 0;
            memwb_is_cop <= 0;
            memwb_MEM_READ <= 0;
            memwb_write_reg <= 5'b0;
            memwb_alu_result <= 32'b0; memwb_cop_result <= 32'b0;
            memwb_mem_data <= 32'b0; memwb_ra_data <= 32'b0;
            memwb_pc_plus_1 <= 10'b0;
        end else begin
            memwb_alu_result <= exmem_alu_result;
            memwb_cop_result <= exmem_cop_result;
            memwb_mem_data <= mem_data_out;
            memwb_ra_data <= exmem_ra_data;
            memwb_write_reg <= exmem_write_reg;
            memwb_pc_plus_1 <= exmem_pc_plus_1;
            memwb_REG_WRITE <= exmem_REG_WRITE;
            memwb_IN_SEL <= exmem_IN_SEL;
            memwb_OUT_SEL <= exmem_OUT_SEL;
            memwb_JUMP_SEL <= exmem_JUMP_SEL;
            memwb_is_cop <= exmem_is_cop;
            memwb_MEM_READ <= exmem_MEM_READ;
        end
    end

    // ==========================================
    // WB Stage
    // ==========================================
    assign wb_write_data = memwb_is_cop ? memwb_cop_result :
                           memwb_MEM_READ ? memwb_mem_data :
                           memwb_alu_result;

    assign wb_reg_write = memwb_REG_WRITE | memwb_is_cop;
    assign wb_write_reg = memwb_write_reg;

    reg [16:0] led_reg;
    always @(posedge clk) begin
        if (reset) begin
            led_reg <= 17'b0;
        end else if (io_out_valid) begin
            led_reg <= {1'b0, io_out_data[15:0]};
        end
    end
    
    // Output LED
    assign LED = led_reg;

    // Expose current PC for 7-segment display
    assign pc_out = sig_curr_pc;

endmodule