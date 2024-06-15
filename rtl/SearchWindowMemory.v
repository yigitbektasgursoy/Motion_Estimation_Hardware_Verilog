`timescale 1ns / 1ps

module SearchWindowMemory
	#(parameter DATA_WIDTH = 8, MEMORY_DEPTH = 961)
	(
    input in_clk,
    input in_write_en,
    input [$clog2(MEMORY_DEPTH)-1:0] in_write_addr, in_read_addr1, in_read_addr2,
    input [DATA_WIDTH-1:0] in_write_data,
    output reg [DATA_WIDTH-1:0] out_read_data1, out_read_data2
	);
    
    reg [DATA_WIDTH-1:0]SrchMemBlock[0:MEMORY_DEPTH-1];
    
    always @(posedge in_clk)begin
        if(in_write_en)begin
            SrchMemBlock[in_write_addr] <= in_write_data;
        end
       else begin
           out_read_data1 <= SrchMemBlock[in_read_addr1];
           out_read_data2 <= SrchMemBlock[in_read_addr2];
       end
    end
     
endmodule