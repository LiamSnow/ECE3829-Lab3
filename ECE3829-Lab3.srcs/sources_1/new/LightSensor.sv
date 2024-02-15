`timescale 1ns / 1ps

//Captures values from ADC081S021 light sensor
module LightSensor#(parameter [21:0] SAMPLE_RATE_HZ = 1)(
    input wire CLK10, reset_n,
    input wire SDATA,
    output wire SCLK,
    output reg CS_N,
    output reg [7:0] read_val
    );

    reg serial_clk = 'b0;
    reg isReading = 'b0;
    enum reg[1:0] {READ_LEAD_0, READ_DATA, READ_TRAIL_0, READ_END} read_state;
    reg [7:0] read_temp_val = 'b0;
    reg [4:0] read_seq_ptr = 'b0;
    
    assign CS_N = ~isReading;
    assign SCLK = CS_N ? 'b1 : serial_clk;
    
    //CS# Triggering & Sample Clock
    reg [20:0] sample_trig_counter = 'b0;
    localparam [21:0] SAMPLE_CLK_END = 2_500_000 / SAMPLE_RATE_HZ - 1; //2.5MHz -> XHz
    always_ff @(negedge serial_clk) begin
        if (~reset_n) begin
            isReading <= 'b0;
            read_seq_ptr <= 'b0;
            sample_trig_counter <= 'b0;
        end
        else begin
            //trigger read at 1hz
            if (sample_trig_counter == SAMPLE_CLK_END) begin
                sample_trig_counter <= 0;
                
                if (~isReading) begin
                    isReading <= 'b1;
                    read_seq_ptr <= 'b0;
                end
            end else begin
                sample_trig_counter <= sample_trig_counter + 1;
            end

            //end read
            if (isReading && read_state == READ_END) begin
                isReading <= 'b0;
                read_val <= read_temp_val;
            end
        end
    end

    //Read Logic
    always_ff @(posedge serial_clk) begin
        if (isReading) begin
            if (read_state == READ_DATA) begin
                read_temp_val['d7 - (read_seq_ptr - 'd4)] <= SDATA;
            end
            read_seq_ptr <= read_seq_ptr + 'b1;
        end
    end

    //State Logic
    always_comb begin
        if (read_seq_ptr < 'd4) read_state = READ_LEAD_0;
        else if (read_seq_ptr < 'd12) read_state = READ_DATA;
        else if (read_seq_ptr < 'd16) read_state = READ_TRAIL_0; //extra clock tick according to spec/diagram
        else read_state = READ_END;
    end

    //Generate a 2.5MHz "Slow Clock" (ADC081S021 requires 1-4MHz)
    reg [1:0] serial_clk_counter = 'b0;
    always_ff @(posedge CLK10) begin
        if (~reset_n) begin
            serial_clk <= 'b0;
            serial_clk_counter <= 'b0;
        end
        else begin
            serial_clk_counter <= serial_clk_counter + 'b1;
            if (serial_clk_counter == 3) begin
                serial_clk <= ~serial_clk;
            end
        end
    end
endmodule