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

    localparam DEPTH = 65536;

    // 2^16 words, each 32 bits wide
    reg [31:0] memory [0:DEPTH-1];

    integer i;

    // Initialise all memory locations to zero
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    // Synchronous write
    always @(posedge clk) begin
        if (write_enable) begin
            memory[addr_in] <= write_data;
        end
    end

    // Asynchronous read
    assign data_out =
        (reset || !read_enable)
        ? 32'b0
        : memory[addr_in];

endmodule