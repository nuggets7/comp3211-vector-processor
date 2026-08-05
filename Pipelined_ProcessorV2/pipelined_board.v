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
    
    // Route generated clock through global clock buffer to avoid skew
    wire proc_clk_buffered;
    BUFG clk_buf_inst (.I(proc_clk), .O(proc_clk_buffered));
    
    wire[16:0] proc_led;
    wire[9:0] proc_pc;
    
    pipelined_processor pp(
        .clk(proc_clk_buffered),
        .reset(reset_debounced),
        .SW(SW),
        .LED(proc_led),
        .pc_out(proc_pc)
    );
    
    assign LED = proc_led[15:0];
    
    // ==========================================
    // 7-Segment Display: Show PC value in hex
    // ==========================================
    // The PC is 10 bits (0-1023). Display as 3 hex digits + blank.
    // Digit 0 (rightmost): PC[3:0]
    // Digit 1: PC[7:4]
    // Digit 2: PC[9:8] (only 2 bits, so 0-3)
    // Digit 3 (leftmost): blank
    
    // Refresh counter: cycle through 4 digits at ~1kHz
    // 100MHz / 100000 = 1kHz refresh rate
    reg [16:0] refresh_counter = 17'd0;
    wire [1:0] digit_select;
    
    always @(posedge sys_clk) begin
        refresh_counter <= refresh_counter + 1'b1;
    end
    
    assign digit_select = refresh_counter[16:15];
    
    // Select which digit's data to show and which anode to enable
    reg [3:0] hex_digit;
    reg [3:0] an_reg;
    
    always @(*) begin
        case (digit_select)
            2'b00: begin
                an_reg = 4'b1110;  // Enable digit 0 (rightmost)
                hex_digit = proc_pc[3:0];
            end
            2'b01: begin
                an_reg = 4'b1101;  // Enable digit 1
                hex_digit = proc_pc[7:4];
            end
            2'b10: begin
                an_reg = 4'b1011;  // Enable digit 2
                hex_digit = {2'b00, proc_pc[9:8]};
            end
            2'b11: begin
                an_reg = 4'b0111;  // Enable digit 3 (blank)
                hex_digit = 4'h0;
            end
        endcase
    end
    
    assign an = an_reg;
    
    // 7-segment decoder (active low: 0 = segment ON)
    // Segment mapping: seg[6:0] = {g, f, e, d, c, b, a}
    reg [6:0] seg_reg;
    
    always @(*) begin
        if (digit_select == 2'b11) begin
            seg_reg = 7'b1111111; // Blank leftmost digit
        end else begin
            case (hex_digit)
                4'h0: seg_reg = 7'b1000000;  // 0
                4'h1: seg_reg = 7'b1111001;  // 1
                4'h2: seg_reg = 7'b0100100;  // 2
                4'h3: seg_reg = 7'b0110000;  // 3
                4'h4: seg_reg = 7'b0011001;  // 4
                4'h5: seg_reg = 7'b0010010;  // 5
                4'h6: seg_reg = 7'b0000010;  // 6
                4'h7: seg_reg = 7'b1111000;  // 7
                4'h8: seg_reg = 7'b0000000;  // 8
                4'h9: seg_reg = 7'b0010000;  // 9
                4'hA: seg_reg = 7'b0001000;  // A
                4'hB: seg_reg = 7'b0000011;  // b
                4'hC: seg_reg = 7'b1000110;  // C
                4'hD: seg_reg = 7'b0100001;  // d
                4'hE: seg_reg = 7'b0000110;  // E
                4'hF: seg_reg = 7'b0001110;  // F
                default: seg_reg = 7'b1111111;
            endcase
        end
    end
    assign seg = seg_reg;
    
endmodule
