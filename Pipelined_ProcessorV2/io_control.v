`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2026 23:37:07
// Design Name: 
// Module Name: io_control
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


module io_control (
    input  wire        clk,
    input  wire        reset,

    // Cancels a pending operation, for example after a flush.
    input  wire        cancel,

    // Must pulse high for one cycle when a new instruction starts.
    input  wire        execute_valid,

    input  wire [31:0] instruction,

    // Value read from Rs. Used by OUT.
    input  wire [31:0] rs_value,

    // Data supplied by the external input device.
    input  wire [31:0] io_input_data,

    // The processor should stop advancing while IN is waiting.
    output wire        stall_pipeline,

    // External input request.
    output wire        in_request,
    output wire [15:0] in_port,

    // Register-file writeback produced by IN.
    output reg         reg_write_enable,
    output reg  [4:0]  reg_write_register,
    output reg  [31:0] reg_write_data,

    // External output produced by OUT.
    output reg         out_valid,
    output reg  [15:0] out_port,
    output reg  [31:0] out_data
);

    localparam [5:0] OPCODE_IN  = 6'b001100;
    localparam [5:0] OPCODE_OUT = 6'b001101;

    // State-machine values.
    localparam [1:0] STATE_IDLE   = 2'b00;
    localparam [1:0] STATE_WAIT_1 = 2'b01;
    localparam [1:0] STATE_WAIT_2 = 2'b10;

    reg [1:0] state;

    // Information saved while an IN instruction is waiting.
    reg [4:0]  pending_rd;
    reg [15:0] pending_port;

    wire [5:0] opcode;
    wire       is_in;
    wire       is_out;

    assign opcode = instruction[31:26];

    assign is_in  = (opcode == OPCODE_IN);
    assign is_out = (opcode == OPCODE_OUT);

    /*
     * Stall immediately when an IN instruction starts and remain stalled
     * while the state machine is waiting.
     */
    assign stall_pipeline =
        (state != STATE_IDLE) ||
        (execute_valid && is_in);

    // Keep the input request active during the two waiting cycles.
    assign in_request = (state != STATE_IDLE);
    assign in_port    = pending_port;

    always @(posedge clk) begin
        if (reset || cancel) begin
            state              <= STATE_IDLE;
            pending_rd         <= 5'b0;
            pending_port       <= 16'b0;

            reg_write_enable   <= 1'b0;
            reg_write_register <= 5'b0;
            reg_write_data     <= 32'b0;

            out_valid          <= 1'b0;
            out_port           <= 16'b0;
            out_data           <= 32'b0;
        end else begin
            /*
             * These are pulse signals. They return to zero automatically
             * unless the current cycle explicitly activates them.
             */
            reg_write_enable <= 1'b0;
            out_valid        <= 1'b0;

            case (state)
                STATE_IDLE: begin
                    if (execute_valid && is_in) begin
                        // Save Rd and the port while waiting.
                        pending_rd   <= instruction[20:16];
                        pending_port <= instruction[15:0];

                        state <= STATE_WAIT_1;
                    end else if (execute_valid && is_out) begin
                        /*
                         * OUT completes immediately and produces a
                         * one-cycle valid pulse.
                         */
                        out_port  <= instruction[15:0];
                        out_data  <= rs_value;
                        out_valid <= 1'b1;
                    end
                end

                STATE_WAIT_1: begin
                    // First waiting cycle.
                    state <= STATE_WAIT_2;
                end

                STATE_WAIT_2: begin
                    /*
                     * Second waiting cycle is complete.
                     * Write the external input value into Rd.
                     */
                    reg_write_enable   <= 1'b1;
                    reg_write_register <= pending_rd;
                    reg_write_data     <= io_input_data;

                    state <= STATE_IDLE;
                end

                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule