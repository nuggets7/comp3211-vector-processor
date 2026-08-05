module adder_10b(
    input [9:0] src_a,
    input [9:0] src_b,
    output [9:0] sum,
    output carry_out
    );
    assign {carry_out, sum} = src_a + src_b;
endmodule