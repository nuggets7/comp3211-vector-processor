module mux_2to1_5b(input mux_select, input[4:0] data_a, input[4:0] data_b, output[4:0] data_out);
    genvar i;
    generate
        for (i=0; i<5; i=i+1) begin
            mux_2to1_1b bit_mux(
                .mux_select(mux_select),
                .data_a(data_a[i]),
                .data_b(data_b[i]),
                .data_out(data_out[i])
            );
        end
    endgenerate
endmodule