`timescale 1ns / 1ps

module LightSensorSim();

    reg CLK10 = 0; //10MHz
    always #50 CLK10 = ~CLK10;

    wire SCLK, CS_N;
    wire [7:0] read_val;

    LightSensor #('d100_000) uut(
        .CLK10(CLK10),
        .reset_n(1'b1),
        .SDATA(1'b0),
        .SCLK(SCLK),
        .CS_N(CS_N),
        .read_val(read_val)
    );

endmodule
