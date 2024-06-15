`timescale 1ns / 1ps

module MinTrackerComp
    #(parameter MAX_DATA_WIDTH = 16,
      parameter COUNTER_WIDTH = 9
    )    
    (
        input in_clk,
        input in_rst,
        input [MAX_DATA_WIDTH-1:0] in_min_SAD,
        input in_SAD_valid_masked,
        
        output reg [MAX_DATA_WIDTH-1:0] out_final_min_SAD,
        output reg out_DONE
    );
    
    reg [MAX_DATA_WIDTH-1:0] reg_min_SAD; // Register to store the current minimum SAD
    reg [COUNTER_WIDTH-1:0] SAD_valid_counter;
    
    always @(posedge in_clk or posedge in_rst) begin
        if (in_rst) begin
            reg_min_SAD <= 20'hFFFFF;   // Initialize with maximum possible value on reset
        end else begin
            // Process only when the SAD value is valid
            // On the first valid input, store the SAD value in reg_min_SAD.
            // On the second valid input, compare the stored value with the new input.
            // If the new input is smaller, update reg_min_SAD. 
            // Otherwise, the stored value in reg_min_SAD is the final minimum and output it.
            if (in_SAD_valid_masked) begin 
                if (reg_min_SAD >= in_min_SAD) begin
                    reg_min_SAD <= in_min_SAD;
                end
            end
        end
    end
    
    // PROCESS COUNTER BEGIN
    always @(posedge in_clk or posedge in_rst) begin
        if (in_rst) begin
            SAD_valid_counter <= 0;
            out_DONE <= 0;
            out_final_min_SAD <= 0;
        end else begin
            if (in_SAD_valid_masked) begin
                SAD_valid_counter <= SAD_valid_counter + 1'b1;
            end else if (SAD_valid_counter == 16) begin
                out_DONE <= 1'b1;
                out_final_min_SAD <= reg_min_SAD;
            end
        end
    end
    // PROCESS COUNTER END
    
endmodule
