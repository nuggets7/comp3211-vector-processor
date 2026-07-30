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
    input BTNL, BTNC, CLK,
    output [15:0] LED
    );
    
    reg [31:0] timer = 32'd0;
    reg sys_clk = 1'b0; 
    
    always@ (posedge CLK) begin 
         timer <= timer + 1'b1;
         
         if (timer >= 32'd1000000) begin
            sys_clk <= ~sys_clk;
            timer <= 32'd0;
        end
    end
    
    wire RESET;
    wire BTN_CLK;
    
    debouncer db1(sys_clk, BTNL, RESET);
    debouncer db2(sys_clk, BTNC, BTN_CLK);
    
    reg btn_clk_prev = 1'b0;
    
    wire btn_clk_press;
    
    assign btn_clk_press = BTN_CLK & ~btn_clk_prev;
    
    always @(posedge sys_clk) begin
        btn_clk_prev <= BTN_CLK;
    end
    
    wire[16:0] proc_led;
    
    pipelined_processor pp(btn_clk_press, RESET, SW, proc_led);
    
    assign LED[14:0] = proc_led[14:0];
    assign LED[15] = proc_led[15] | proc_led[16];
    
endmodule
