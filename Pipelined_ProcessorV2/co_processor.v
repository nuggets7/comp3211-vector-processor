// written by Hugh Donaldson (z5683554)

// The coprocessor uses three instructions depending on the OPCODE:
// Add two vectors, scale a vector, or clip a vector with a K value.
//
// RA and RB are 32 bits.
// Each vector element is 8 bits, meaning 32 / 8 = 4 elements per vector.
//
// element 1: [31:24]
// element 2: [23:16]
// element 3: [15:8]
// element 4: [7:0]
//
// If values exceed 8 bits, the values are saturated to 255.


module co_processor (
    // 2 bit OPCODE signal (Highest 2 bits of 6 bit OPCODE)
    input [1:0] OPCODE,

    // Inputs
    input [31:0] RA,
    input [31:0] RB,
    input [31:0] K,

    // Outputs
    output [31:0] RD
);

    // Defintitons for each OPCODE signal
    localparam CO_ADD = 2'b01;
    localparam CO_SCALE = 2'b10;
    localparam CO_CLIP = 2'b11;

    // Saturation value 2^8 or 256
    localparam Saturation_Value = 8'b11111111;

    wire [7:0] k_value;
    assign k_value = K[7:0];

    wire [7:0] RA_vector [0:3];
    wire [7:0] RB_vector [0:3];

    reg [7:0] RD_vector [0:3];

    assign RA_vector[0] = RA[31:24];
    assign RA_vector[1] = RA[23:16];
    assign RA_vector[2] = RA[15:8];
    assign RA_vector[3] = RA[7:0];

    assign RB_vector[0] = RB[31:24];
    assign RB_vector[1] = RB[23:16];
    assign RB_vector[2] = RB[15:8];
    assign RB_vector[3] = RB[7:0];

    reg [8:0] add_result [0:3];
    reg [15:0] scale_result [0:3];

    integer i;


    always @(*) begin

        // Set all values to 0 (Default Value)
        for (i = 0; i < 4; i = i + 1) begin
            RD_vector[i] = 8'b0;
            add_result[i] = 9'b0;
            scale_result[i] = 16'b0;
        end

        // Add instruction
        if (OPCODE == CO_ADD) begin

            for (i = 0; i < 4; i = i + 1) begin
                add_result[i] = RA_vector[i] + RB_vector[i];

                // Saturation logic
                if (add_result[i] > Saturation_Value) begin
                    RD_vector[i] = Saturation_Value;
                end else begin
                    RD_vector[i] = add_result[i][7:0];
                end
            end

        // Scale instruction
        end else if (OPCODE == CO_SCALE) begin

            for (i = 0; i < 4; i = i + 1) begin
                scale_result[i] = RA_vector[i] * k_value;

                // Saturation logic
                if (scale_result[i] > Saturation_Value) begin
                    RD_vector[i] = Saturation_Value;
                end else begin
                    RD_vector[i] = scale_result[i][7:0];
                end
            end

        // Clip instruction
        end else if (OPCODE == CO_CLIP) begin

            for (i = 0; i < 4; i = i + 1) begin
                // If the vector's element is greater then the K value saturate the value to the K value, if not keep value the same
                if (RA_vector[i] >= k_value) begin
                    RD_vector[i] = k_value;
                end else begin
                    RD_vector[i] = RA_vector[i];
                end
            end

        end

    end

    // Reassemble each element of the vector back into RD 32 bit signal
    assign RD = {RD_vector[0], RD_vector[1], RD_vector[2], RD_vector[3]};

endmodule
