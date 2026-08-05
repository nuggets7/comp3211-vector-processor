module adder_32b(
    input [31:0] src_a,
    input [31:0] src_b,
    output [31:0] sum,
    output carry_out
    );
    assign {carry_out, sum} = src_a + src_b;
endmodule