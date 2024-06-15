`timescale 1ns / 1ps

module ReferenceBlockMemory
	#(parameter DATA_WIDTH = 8, MEMORY_DEPTH = 256)
	
	(
    input in_clk,
    input in_write_en,
    input [$clog2(MEMORY_DEPTH)-1:0] in_write_addr, in_read_addr,
    input [DATA_WIDTH-1:0] in_write_data,
    output reg [DATA_WIDTH-1:0] out_read_data
	);
    
    reg [DATA_WIDTH-1:0]RefMemBlock[0:MEMORY_DEPTH-1];
    
    always @(posedge in_clk)begin
        if(in_write_en)begin
            RefMemBlock[in_write_addr] <= in_write_data;
        end
       else begin
           out_read_data <= RefMemBlock[in_read_addr];
       end
    end

endmodule