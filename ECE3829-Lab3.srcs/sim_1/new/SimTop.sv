`timescale 1ns / 1ps

module SimTop();
    reg CLK10 = 0; //10MHz
    always #50 CLK10 = ~CLK10;

    wire SCLK, CS_N, SDATA; //pass-thru

    //Simulate this file and make sure after sequence, write_val == read_val
    reg [7:0] write_val = 8'b00001111; //value that LightSensorSim will return
    wire [7:0] read_val; //value that LightSensor has read
    
    LightSensor #('d100_000) uut(
        .CLK10(CLK10),
        .reset_n(1'b1),
        .SDATA(SDATA),
        .SCLK(SCLK),
        .CS_N(CS_N),
        .read_val(read_val)
    );

    LightSensorSim uut_sim(
        .SCLK(SCLK),
        .CS_N(CS_N),
        .SDATA(SDATA),
        .output_value(write_val)
    );
endmodule