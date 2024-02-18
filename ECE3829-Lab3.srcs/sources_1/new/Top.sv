`timescale 1ns / 1ps

module Top(
    input wire CLK100,
    output wire [6:0] sevenSegmentSegments,
    output wire sevenSegmentDecimal,
    output wire [3:0] sevenSegmentAnodes,
    output wire JA1, JA4,
    input wire JA3, buttonCenter
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
    wire [7:0] light_sensor_val;
    LightSensor #('d100) LightSensor(
        .CLK10(CLK10),
        .reset_n(reset_n),
        .SDATA(JA3),
        .SCLK(JA4),
        .CS_N(JA1),
        .read_val(light_sensor_val)
    );

    //Seven Segment Display (last 2 digits of WPI ID on left, light sensor value on right)
    wire [3:0] [3:0] digitValues = '{4'd8, 4'd7, 
        light_sensor_val[7:4], light_sensor_val[3:0]};
    SevenSegmentDisplay SevenSegmentDisplay(
        .CLK10(CLK10),
        .reset_n(reset_n),
        .digitValues(digitValues),
        .segments(sevenSegmentSegments),
        .decimal(sevenSegmentDecimal),
        .anodes(sevenSegmentAnodes)
    );
endmodule