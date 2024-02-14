`timescale 1ns / 1ps

module SevenSegmentDisplay(
    input wire CLK10, reset_n,
    input wire [3:0] [3:0] digitValues,
    output reg [6:0] segments,
    output wire decimal,
    output wire [3:0] anodes
    );

    reg [1:0] currentDigit = 0;
    wire [3:0] currentDigitValue = digitValues[currentDigit];

    reg [15:0] slowClockCounter = 0;

    always_ff @(posedge CLK10) begin
        if (~reset_n) begin
            slowClockCounter <= 0;
            currentDigit <= 0;
        end
        else begin
            if (slowClockCounter[15]) begin
                slowClockCounter <= 0;
                currentDigit <= currentDigit + 1;
            end
            else slowClockCounter <= slowClockCounter + 1;
        end
    end
    
    assign decimal = 0;
    assign anodes = reset_n ? ~(4'b1 << currentDigit) : 4'b1111; //inverted "1-hot encoding"

    always_comb begin
        case (currentDigitValue)
            4'h0: segments = 7'b1000000; // 0
            4'h1: segments = 7'b1111001; // 1
            4'h2: segments = 7'b0100100; // 2
            4'h3: segments = 7'b0110000; // 3
            4'h4: segments = 7'b0011001; // 4
            4'h5: segments = 7'b0010010; // 5
            4'h6: segments = 7'b0000010; // 6
            4'h7: segments = 7'b1111000; // 7
            4'h8: segments = 7'b0000000; // 8
            4'h9: segments = 7'b0010000; // 9
            4'hA: segments = 7'b0001000; // A
            4'hB: segments = 7'b0000011; // b
            4'hC: segments = 7'b1000110; // C
            4'hD: segments = 7'b0100001; // d
            4'hE: segments = 7'b0000110; // E
            4'hF: segments = 7'b0001110; // F
            default: segments = 7'b1111111;
        endcase
    end
endmodule