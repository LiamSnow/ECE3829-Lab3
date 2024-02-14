`timescale 1ns / 1ps

//Captures values from ADC081S021 light sensor
module LightSensor#(parameter SAMPLE_RATE = 1)(
    input wire CLK10, reset_n, SDATA,
    output wire SCLK, CS_N,
    output wire [7:0] reading
    );

    typedef enum {INIT, WAIT, READ} states_t;
    states_t state;
    reg slow_clock;

    assign SCLK = ~slow_clock;
    
    always_ff @(posedge slow_clock) begin
        
    end
    

    //Capture values @ 1hz, use a state machine


    //Generate a 2.5MHz "Slow Clock" (ADC081S021 requires 1-4MHz)
    reg [1:0] slow_clock_counter = 'b0;
    always_ff @(posedge CLK10) begin
        if (~reset_n) begin
            slow_clock <= 'b0;
            slow_clock_counter <= 'b0;
        end
        else begin
            slow_clock_counter <= slow_clock_counter + 'd1;
            if (slow_clock_counter == 3) begin
                slow_clock <= ~slow_clock;
            end
        end
    end
endmodule