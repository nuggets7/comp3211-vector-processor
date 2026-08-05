`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2026 23:17:05
// Design Name: 
// Module Name: Link_control
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



module link_control (
    // Instruction currently being decoded
    input  wire [31:0] instruction,

    // Address of this instruction
    input  wire [9:0]  current_pc,

    // Value read from the Rs register
    // Used as the target for JR
    input  wire [31:0] rs_value,

    // Becomes 1 for either JAL or JR
    output wire        link_jump_taken,

    // Address that should be loaded into the PC
    output wire [9:0]  link_jump_target,

    // JAL writes the return address into R31
    output wire        ra_write_enable,
    output wire [4:0]  ra_write_register,
    output wire [31:0] ra_write_data,

    // Wrong-path instruction must be removed
    output wire        flush_pipeline
);

    // Opcodes from opcode.md
    localparam [5:0] OPCODE_JAL = 6'b001110;
    localparam [5:0] OPCODE_JR  = 6'b000100;

    wire [5:0] opcode;
    wire       is_jal;
    wire       is_jr;

    // The complete opcode is stored in bits 31 down to 26
    assign opcode = instruction[31:26];

    // Identify the two link-related instructions
    assign is_jal = (opcode == OPCODE_JAL);
    assign is_jr  = (opcode == OPCODE_JR);

    // Both instructions change the normal flow of execution
    assign link_jump_taken = is_jal || is_jr;

    // JAL uses the instruction's absolute address.
    // JR uses the address stored in Rs.
    assign link_jump_target =
        is_jr ? rs_value[9:0] : instruction[9:0];

    // Only JAL saves a return address
    assign ra_write_enable = is_jal;

    // R31 is the reserved return-address register
    assign ra_write_register = 5'd31;

    // PC is instruction-addressed, so the next instruction is PC + 1
    assign ra_write_data = {22'b0, current_pc + 10'd1};

    // Both JAL and JR require wrong-path instructions to be flushed
    assign flush_pipeline = link_jump_taken;

endmodule
