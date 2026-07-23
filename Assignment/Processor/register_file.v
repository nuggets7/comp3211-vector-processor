// written by Hugh Donaldson (z5683554)

// The register file holds 32 writable 32-bit registers that the CPU uses to complete instructions.

// RA, RB and RD are 5-bit signals that are connected to multiplexers to select registers for use. RA and RB signals will select their according register. For example RA = 5'b00010 or 2 in decimal, will select 2 on the 32 to 1 multiplexer outputing the data of register 2 which is a 32 bit signal. RA and RB travel out of the register file and traverse into the ALU where instructions such as RA + RB can be executed. The output will be equal to RD so RD = RA + RB for example. On the register file RD selects the register we want to write the data too. The data of RD_Data will travel into the RD register and store the according data. 

module register_file (
    // clock
    input clk,

    // 1'b signals for writing to registers and clearing registers
    input write_enable,
    input reset,

    // inputs to registers
    input [4:0] RA,
    input [4:0] RB,
    input [4:0] RD,

    // input RD data
    input [31:0] RD_Data,

    // output data
    output [31:0] RA_Out,
    output [31:0] RB_Out

);

    // 32 registers of 32 bit widths
    reg [31:0] registers [0:31];

    integer i;

    always @(negedge clk) begin
        // traverse all 32 registers and reset their values to 0
        if (reset) begin
            for (i = 0; i < 32 ; i = i + 1) begin
                registers[i] = 32'b0;
            end
        end else if (write_enable) begin
            // write to register RD using the data coming in from RD.
            registers[RD] <= RD_Data;
        end
            // zero registers remains at a constant 0
            registers[0] <= 16'b0;
        end

    // ouput RA and RB data
    assign RA_Out = registers[RA];
    assign RB_Out = registers[RB];


endmodule
