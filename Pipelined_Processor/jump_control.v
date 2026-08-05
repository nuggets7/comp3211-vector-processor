`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2026 01:02:41
// Design Name: 
// Module Name: jump_control
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


module jump_control (
    input  wire [31:0] instruction,

    output wire        jump_taken,
    output wire [31:0] jump_target,
    output wire        flush_pipeline
);

    // Full six-bit opcode for the plain J instruction.
    localparam [5:0] OPCODE_J = 6'b001111;

    // Extract the opcode from bits 31 down to 26.
    wire [5:0] opcode;
    assign opcode = instruction[31:26];

    // This module handles only the plain J instruction.
    assign jump_taken = (opcode == OPCODE_J);

    // Assumption: the PC is instruction-addressed.
    // The 26-bit absolute destination is zero-extended to 32 bits.
    assign jump_target = {6'b000000, instruction[25:0]};

    // When a jump is detected, the wrong-path instruction must be flushed.
    assign flush_pipeline = jump_taken;

endmodule