module InstantMinComp
    #(parameter MAX_DATA_WIDTH = 16,
                PE_COUNT = 16
    )
    (
        input [MAX_DATA_WIDTH-1:0] in_SAD0, in_SAD1, in_SAD2, in_SAD3, in_SAD4, in_SAD5, in_SAD6, in_SAD7, in_SAD8, in_SAD9, in_SAD10, in_SAD11, in_SAD12, in_SAD13, in_SAD14, in_SAD15,
        input [PE_COUNT-1:0] SAD_valid, // ONLY USING MSB FOR VALID SIGNAL
        output out_SAD_valid_masked,
        output reg [MAX_DATA_WIDTH-1:0] out_min_SAD
    );

    reg [MAX_DATA_WIDTH-1:0] in_SAD[0:PE_COUNT-1];
    wire SAD_valid_masking;
    
    assign SAD_valid_masking = (SAD_valid[15] == 1'b1) ? 1'b1 : 1'b0;
    assign out_SAD_valid_masked = SAD_valid_masking;                            
    
    // 1D SAD ARRAY BEGIN 
    always @(*) begin // Populate the SAD array with input values
        in_SAD[0] = in_SAD0;
        in_SAD[1] = in_SAD1;
        in_SAD[2] = in_SAD2;
        in_SAD[3] = in_SAD3;
        in_SAD[4] = in_SAD4;
        in_SAD[5] = in_SAD5;
        in_SAD[6] = in_SAD6;
        in_SAD[7] = in_SAD7;
        in_SAD[8] = in_SAD8;
        in_SAD[9] = in_SAD9;
        in_SAD[10] = in_SAD10;
        in_SAD[11] = in_SAD11;
        in_SAD[12] = in_SAD12;
        in_SAD[13] = in_SAD13;
        in_SAD[14] = in_SAD14;
        in_SAD[15] = in_SAD15;
    end
    // 1D SAD ARRAY END
    
    // COMPARATOR ALGORITHM BEGIN
    integer i;
    always @(*) begin  // Initialize minimum SAD to the first value
        out_min_SAD = in_SAD[0]; 
        if (SAD_valid_masking) begin // Only proceed if the overall valid signal is set
            for (i = 1; i < 16; i = i + 1) begin
                if (out_min_SAD > in_SAD[i]) begin
                    out_min_SAD = in_SAD[i]; 
                end
            end
        end
    end
    // COMPARATOR ALGORITHM END
    
endmodule
