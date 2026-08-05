`timescale 1ns / 1ps

module data_memory (
    input  wire        clk,
    input  wire        reset,

    input  wire        read_enable,
    input  wire        write_enable,

    input  wire [15:0] addr_in,
    input  wire [31:0] write_data,
    output wire [31:0] data_out
);

    localparam DEPTH = 1024;

    // 2^16 words, each 32 bits wide
    reg [31:0] memory [0:DEPTH-1];

    integer i;

    // Initialise all memory locations to zero (handled by FPGA default)
    initial begin
        // vectors for test script
        memory[0] = 32'h050A0F14; // Vector 1: [5, 10, 15, 20]
        memory[1] = 32'h01020304; // Vector 2: [1, 2, 3, 4]
    end

    // Synchronous write
    always @(posedge clk) begin
        if (write_enable) begin
            memory[addr_in[9:0]] <= write_data;
        end
    end

    // Asynchronous read
    assign data_out =
        (reset || !read_enable)
        ? 32'b0
        : memory[addr_in[9:0]];

endmodule