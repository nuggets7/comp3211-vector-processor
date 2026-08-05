module register_32b(
    input reset, clk, write_enable,
    input [31:0] data_in,
    output reg [31:0] data_out
    );
    always @(posedge clk) begin
        if (reset) data_out <= 32'b0;
        else if (write_enable) data_out <= data_in;
    end
endmodule
