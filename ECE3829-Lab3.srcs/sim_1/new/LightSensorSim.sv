`timescale 1ns / 1ps

module LightSensorSim(
    input wire SCLK /*1-4MHz*/, CS_N,
    output tri SDATA,
    input wire [7:0] output_value
    );

    reg inSeq = 0;
    reg [14:0] word;
    assign SDATA = inSeq ? word[14] : 1'bz;

    always_ff @(posedge SCLK) begin
        if (CS_N) begin
            inSeq <= 1'b0;
        end
        else begin
            if (~inSeq) begin
                word <= {3'b0, output_value, 4'b0};
                inSeq <= 1'b1;
            end
            else begin
                word <= word << 1;
            end
        end
    end
endmodule
