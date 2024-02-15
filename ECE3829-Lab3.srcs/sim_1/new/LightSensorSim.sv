`timescale 1ns / 1ps

module LightSensorSim();

    reg CLK10 = 0; //10MHz
    always #50 CLK10 = ~CLK10;

    wire SCLK, CS_N;
    wire [7:0] read_val;
    
    reg serial_clk = 'b0, SDATA = 'b0;

    LightSensor #('d100_000) uut(
        .CLK10(CLK10),
        .reset_n(1'b1),
        .SDATA(SDATA),
        .SCLK(SCLK),
        .CS_N(CS_N),
        .read_val(read_val)
    );

    always_ff @(negedge serial_clk) begin
        SDATA <= ~SDATA;
    end 

    //Generate a 2.5MHz "Slow Clock" (ADC081S021 requires 1-4MHz)
    reg [1:0] serial_clk_counter = 'b0;
    always_ff @(posedge CLK10) begin
        serial_clk_counter <= serial_clk_counter + 'b1;
        if (serial_clk_counter == 3) begin
            serial_clk <= ~serial_clk;
        end
    end

endmodule
