`timescale 1ns / 1ps
module ProcessingElements
    #(parameter DATA_WIDTH = 8,
              MAX_DATA_WIDTH = 16,
              PE_COUNTER_WIDTH = 8
    )
    ( 
        input in_clk,
        input in_rst,
        input in_sw_mux, // Choose Search Window Data for processing
        input in_pe_ena, // Processing Elements Enable
        input [DATA_WIDTH-1:0] in_sw_data1, in_sw_data2, in_rb_data, // Search Window Data and Reference Block Data

        output reg [MAX_DATA_WIDTH-1:0] out_SAD, // Sum Absolute Difference - SAD gets maximum 16 bits
        output reg out_SAD_valid, // When SAD processing is done, then set valid signal to 1
        output reg [DATA_WIDTH-1:0] out_rb_mem // Pass data to other PE || PE0 => PE1, PE1 => PE2, PE2 => PE3
    );

    reg [DATA_WIDTH-1:0] registered_rb_data, registered_sw_data, registered_SAD;
    reg [MAX_DATA_WIDTH-1:0] registered_accumulate_in, registered_accumulate_out;
    reg [PE_COUNTER_WIDTH-1:0] pe_counter;

    always @(*) begin
        registered_rb_data = 0;
        registered_sw_data = 0;
        // 2x1 MUX BEGIN
        if (in_pe_ena) begin
            registered_rb_data = in_rb_data;
            if (in_sw_mux) begin
                registered_sw_data = in_sw_data1;
            end else begin
                registered_sw_data = in_sw_data2;
            end
        end
        // 2X1 MUX END
    end

    // SENDING RB DATA TO OTHER PE BEGIN
    always @(posedge in_clk or posedge in_rst) begin
        if (in_rst) begin
            out_rb_mem <= 0;
        end else begin
            out_rb_mem <= in_rb_data; // Pass the reference block data to the next PE
        end
    end
    // SENDING RB DATA TO OTHER PE END

    // SUM ABSOLUTE DIFFERENCE AND ACCUMULATE BEGIN
    always @(posedge in_clk or posedge in_rst) begin
        if (in_rst) begin
            registered_accumulate_in <= 0;
        end else begin
            if (in_pe_ena) begin
                registered_accumulate_in <= registered_accumulate_out; // Store previous accumulated value
            end
        end
    end

    always @(*) begin
        // Calculate absolute difference between reference block data and selected search window data
        if (registered_rb_data >= registered_sw_data) begin
            registered_SAD = registered_rb_data - registered_sw_data;
        end else begin
            registered_SAD = registered_sw_data - registered_rb_data;
        end

        // Accumulate the SAD values over multiple cycles
        if (pe_counter == 0) begin
            if (registered_rb_data >= registered_sw_data) begin
                registered_accumulate_out = registered_rb_data - registered_sw_data;
            end else begin
                registered_accumulate_out = registered_sw_data - registered_rb_data;
            end
        end else begin
            registered_accumulate_out = registered_SAD + registered_accumulate_in;
        end
    end
    // SUM ABSOLUTE DIFFERENCE AND ACCUMULATE END

    // pe_counter BEGIN
    always @(posedge in_clk or posedge in_rst) begin
        if (in_rst) begin
            out_SAD <= 0;
            out_SAD_valid <= 0;
            pe_counter <= 0;
        end else begin
            if (in_pe_ena) begin
                pe_counter <= pe_counter + 1'b1;
                if (pe_counter == 255) begin
                    out_SAD <= registered_accumulate_out;
                    out_SAD_valid <= 1;
                end else begin
                    out_SAD_valid <= 1'b0;
                end
            end
        end
    end
    // pe_counter END

endmodule
