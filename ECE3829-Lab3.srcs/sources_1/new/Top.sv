`timescale 1ns / 1ps

module Top(
    input wire CLK100, //100MHz clock
    output wire [6:0] sevenSegmentSegments, //seven segment display ports
    output wire sevenSegmentDecimal,
    output wire [3:0] sevenSegmentAnodes,
    output wire JA1, JA4, //PMOD ports for light sensor
    input wire JA3,
    input wire buttonCenter //button for reset
    );

    //10MHz Clock Gen
    wire CLK10, reset_n;
    clk_wiz_0 clk_wiz_0(
        .clk_in1(CLK100),
        .clk_out1(CLK10),
        .reset(buttonCenter), //center button triggers clock wiz reset, triggering a global reset
        .locked(reset_n)
    );

    //Light Sensor
    wire [7:0] light_sensor_val;
    LightSensor #(1/*1Hz sample rate*/) LightSensor(
        .CLK10(CLK10),
        .reset_n(reset_n),
        .SDATA(JA3),
        .SCLK(JA4),
        .CS_N(JA1),
        .read_val(light_sensor_val)
    );

    //Seven Segment Display
    wire [3:0] [3:0] digitValues = '{4'd8, 4'd7, //2 digits of WPI ID (left)
        light_sensor_val[7:4], light_sensor_val[3:0]}; //light sensor value (right)
    SevenSegmentDisplay SevenSegmentDisplay(
        .CLK10(CLK10),
        .reset_n(reset_n),
        .digitValues(digitValues),
        .segments(sevenSegmentSegments),
        .decimal(sevenSegmentDecimal),
        .anodes(sevenSegmentAnodes)
    );
endmodule