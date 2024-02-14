`timescale 1ns / 1ps

module TestBench();
    reg CLK1 = 0; //1MHz
    always #500 CLK1 = ~CLK1;

    reg CS_N = 1;
    reg [7:0] input_value;
    wire SDATA;

    reg [14:0] actual_value;
    wire [14:0] expected_value = {3'b0, input_value, 4'b0};

    LightSensor uut(
        .SCLK(CLK1),
        .CS_N(CS_N),
        .SDATA(SDATA),
        .output_value(input_value)
    );

    initial begin
        #2000;
        readValue(8'b1001_0110);
        #2000;
        readValue(8'b1100_0011);
        #2000;
        readValue(8'b0110_1111);
        #2000;
        readValue(8'b1010_0101);
        #2000;
        $finish;
    end

    task readValue(reg [7:0] val);
        input_value = val;
        @(negedge CLK1);
        CS_N = 0;

        repeat (15) begin
            @(negedge CLK1);
            actual_value = {actual_value[13:0], SDATA};
        end

        CS_N = 1;

        if (actual_value == expected_value) begin
            $display("Pass: Time = %0t, Value = %b", $realtime, actual_value);
        end else begin
            $display("Fail: Time = %0t, Expected = %b, Actual = %b", $realtime, expected_value, actual_value);
        end
    endtask
endmodule