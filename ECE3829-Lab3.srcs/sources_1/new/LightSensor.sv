`timescale 1ns / 1ps

//Captures values from ADC081S021 light sensor
module LightSensor#(parameter [21:0] SAMPLE_RATE_HZ = 1)(
    input wire CLK10, reset_n,
    input wire SDATA,
    output wire SCLK,
    output reg CS_N,
    output reg [7:0] read_val
    );

    reg serial_clk = 0; //internal 2.5MHz clock signal
    reg isReading = 0; //whether we are reading (or idle)
    enum reg[1:0] {READ_LEAD_0, READ_DATA, READ_TRAIL_0, READ_END} read_state; //where we are in read sequence
    reg [7:0] read_temp_val = 0; //value we are currently reading (but not ready yet)
    reg [4:0] read_seq_ptr = 0; //bit pos we are in for read sequence
    
    assign CS_N = ~isReading; //dropped on negative edge of SCLK/serial_clk
    assign SCLK = CS_N ? 1 : serial_clk; //stops SCLK when idle

    //CS# Triggering & Sample Clock
    reg [21:0] sample_trig_counter = 0;
    localparam [21:0] SAMPLE_CLK_END = 2_500_000 / SAMPLE_RATE_HZ - 1; //2.5MHz -> XHz
    always_ff @(negedge serial_clk) begin
        if (~reset_n) begin
            isReading <= 0;
            sample_trig_counter <= 0;
        end
        else begin
            //trigger read at specified sample rate (hz)
            if (sample_trig_counter == SAMPLE_CLK_END) begin
                sample_trig_counter <= 0;
                isReading <= 1;
            end else begin
                sample_trig_counter <= sample_trig_counter + 1;
            end

            //end read + transfer new reading
            if (isReading && read_state == READ_END) begin
                isReading <= 0;
                read_val <= read_temp_val;
            end
        end
    end

    //Read Logic
    always_ff @(posedge serial_clk) begin
        if (isReading) begin
            if (read_state == READ_DATA) begin
                read_temp_val[7 - (read_seq_ptr - 4)] <= SDATA; //read in value MSB first
            end
            read_seq_ptr <= read_seq_ptr + 1; //move through read sequence
        end
        else read_seq_ptr <= 0; //reset when not reading (also during ~reset_n)
    end

    //State Logic
    always_comb begin
        if (read_seq_ptr < 4) read_state = READ_LEAD_0;
        else if (read_seq_ptr < 12) read_state = READ_DATA;
        else if (read_seq_ptr < 16) read_state = READ_TRAIL_0; //extra clock tick according to spec/diagram
        else read_state = READ_END;
    end

    //Generate a 2.5MHz "Slow Clock" (ADC081S021 requires 1-4MHz)
    reg [1:0] serial_clk_counter = 0; //divides 10MHz by 4
    always_ff @(posedge CLK10) begin
        if (~reset_n) begin
            serial_clk <= 0;
            serial_clk_counter <= 0;
        end
        else begin
            serial_clk_counter <= serial_clk_counter + 1; //overflow automatically happens
            if (serial_clk_counter == 3) begin
                serial_clk <= ~serial_clk;
            end
        end
    end
endmodule