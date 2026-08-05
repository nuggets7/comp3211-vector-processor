`timescale 1ns / 1ps

module data_memory (
    input  wire        clk,
    input  wire        reset,

    input  wire        read_enable,
    input  wire        write_enable,

    input  wire [9:0]  addr_in,
    input  wire [31:0] write_data,
    output reg  [31:0] data_out
);

    always @(*) begin
        if (reset || !read_enable) begin
            data_out = 32'b0;
        end else begin
            case (addr_in)
                10'd0: data_out = 32'h00000205; // Vector A: [0, 0, 2, 5]
                10'd1: data_out = 32'h00000304; // Vector B: [0, 0, 3, 4]
                default: data_out = 32'b0;
            endcase
        end
    end
endmodule