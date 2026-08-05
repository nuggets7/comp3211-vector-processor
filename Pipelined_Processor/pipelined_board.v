`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 11:38:19
// Design Name: 
// Module Name: pipelined_board
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


module pipelined_board(
    input [15:0] SW,
    input reset, sys_clk,
    output [15:0] LED,
    output [6:0] seg,
    output [3:0] an
    );
    
    // Disable 7-segment display by default
    assign seg = 7'b1111111;
    assign an = 4'b1111;
    
    reg [31:0] timer = 32'd0;
    reg proc_clk = 1'b0; 
    
    // Create 1Hz automatic clock (toggles every 50,000,000 cycles at 100MHz)
    always@ (posedge sys_clk) begin 
         timer <= timer + 1'b1;
         
         if (timer >= 32'd50000000) begin
            proc_clk <= ~proc_clk;
            timer <= 32'd0;
        end
    end
    
    wire reset_debounced;
    
    debouncer db1(sys_clk, reset, reset_debounced);
    
    wire[16:0] proc_led;
    
    pipelined_processor pp(proc_clk, reset_debounced, SW, proc_led);
    
    assign LED[14:0] = proc_led[14:0];
    assign LED[15] = proc_led[15] | proc_led[16];
    
endmodule
