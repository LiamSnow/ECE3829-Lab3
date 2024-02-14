`timescale 1ns / 1ps

module Top(
    input wire CLK100,
    input wire buttonCenter,
    output wire [6:0] sevenSegmentSegments,
    output wire sevenSegmentDecimal,
    output wire [3:0] sevenSegmentAnodes
    );

    //10MHz Clock Gen
    wire CLK10, reset_n;
    clk_wiz_0 clk_wiz_0(
        .clk_in1(CLK100),
        .clk_out1(CLK10),
        .reset(buttonCenter),
        .locked(reset_n)
    );

    //Light Sensor
    LightSensor LightSensor(
        
    );

    //Seven Segment Display
    /*
    • Display the light sensor value on the 2 right most displays (display C and D).
    • Display the last two digits of your WPI ID on displays A and B.
    */
    wire [3:0] [3:0] digitValues = '{4'd9, 4'd8, 4'd8, 4'd7};
    SevenSegmentDisplay SevenSegmentDisplay(
        .CLK10(CLK10),
        .reset_n(reset_n),
        .digitValues(digitValues),
        .segments(sevenSegmentSegments),
        .decimal(sevenSegmentDecimal),
        .anodes(sevenSegmentAnodes)
    );
endmodule