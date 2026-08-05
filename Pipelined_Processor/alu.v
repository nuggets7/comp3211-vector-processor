module alu (
    input [31:0] A,
    input [31:0] B,
    input ADD_SEL, SUB_SEL, MULT_SEL, DIV_SEL, AND_SEL, OR_SEL,
    output reg [31:0] RESULT
);
    always @(*) begin
        if (ADD_SEL)
            RESULT = A + B;
        else if (SUB_SEL)
            RESULT = A - B;
        else if (MULT_SEL)
            RESULT = A * B; // 64 bit product that we truncate be4 returning
        else if (DIV_SEL) begin
            if (B == 32'b0)
                RESULT = 32'hFFFFFFFF; // divide by zero
            else
                RESULT = A / B;
        end else
            RESULT = 32'b0;
    end
endmodule