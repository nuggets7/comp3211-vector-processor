// Written by Hugh Donaldson (z5683554)

`timescale 1ns / 1ps

module debouncer (
    input clk,
    input button_in,
    output reg button_out
);

    reg [1:0] sync;
    
    always @(posedge clk) begin
        // synchronize and debounce
        sync[0] <= button_in;
        sync[1] <= sync[0];
        
        // if the signal is stable across consecutive clock cycles, update the output
        if (sync[1] == sync[0]) begin
            button_out <= sync[1];
        end
    end
endmodule
