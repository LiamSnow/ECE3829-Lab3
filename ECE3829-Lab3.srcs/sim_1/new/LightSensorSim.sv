`timescale 1ns / 1ps

module LightSensorSim(
    input wire SCLK /*1-4MHz*/, CS_N,
    output tri SDATA,
    input wire [7:0] output_value
    );

    reg inSeq = 0; //whether we are in a write sequence
    reg [14:0] word; //all bits that will be shifted out serially over SDATA
    assign SDATA = inSeq ? word[14] : 1'bz; //put SDATA in tri-state when not in sequence

    always_ff @(negedge SCLK) begin
        //Stop Sequence when CS# Pulled Up
        if (CS_N) begin
            inSeq <= 0;
        end
        else begin
            //Start Sequence
            if (~inSeq) begin
                //leading zeros + data + trailing zeros
                word <= {3'b0, output_value, 4'b0};
                inSeq <= 1;
            end

            //In Sequence
            else begin
                //shift out word
                word <= word << 1;
            end
        end
    end
endmodule
