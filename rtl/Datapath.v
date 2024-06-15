`timescale 1ns / 1ps

module Datapath
	#(parameter DATA_WIDTH = 8, 
	            PE_COUNT = 16,		
				MAX_DATA_WIDTH = 16
	)
	(
    input in_clk,
	input in_rst,
	input [PE_COUNT-1:0]in_sw_mux, in_pe_ena,
	input [DATA_WIDTH-1:0]in_sw_data1, in_sw_data2, in_rb_data,
	output [MAX_DATA_WIDTH-1:0]out_final_min_SAD,
	output out_DONE
	); 
	wire [MAX_DATA_WIDTH-1:0] PE0_out_SDA, PE1_out_SDA, PE2_out_SDA, PE3_out_SDA, PE4_out_SDA, PE5_out_SDA, PE6_out_SDA, PE7_out_SDA, 
	            PE8_out_SDA, PE9_out_SDA, PE10_out_SDA, PE11_out_SDA, PE12_out_SDA, PE13_out_SDA, PE14_out_SDA, PE15_out_SDA;
				
	wire [DATA_WIDTH-1:0] PE0_out_rb_mem, PE1_out_rb_mem, PE2_out_rb_mem, PE3_out_rb_mem, PE4_out_rb_mem, PE5_out_rb_mem, PE6_out_rb_mem, PE7_out_rb_mem, 
	            PE8_out_rb_mem, PE9_out_rb_mem, PE10_out_rb_mem, PE11_out_rb_mem, PE12_out_rb_mem, PE13_out_rb_mem, PE14_out_rb_mem;
				
	wire [PE_COUNT-1:0] SAD_valid;
	
	wire out_SAD_valid_masked;
	
	wire [MAX_DATA_WIDTH-1:0] out_min_SAD;
				
	ProcessingElements PE0(in_clk, in_rst,  in_sw_mux[0],  in_pe_ena[0],  in_sw_data1, in_sw_data2, in_rb_data,      PE0_out_SDA,  SAD_valid[0],  PE0_out_rb_mem);
	ProcessingElements PE1(in_clk, in_rst,  in_sw_mux[1],  in_pe_ena[1],  in_sw_data1, in_sw_data2, PE0_out_rb_mem,  PE1_out_SDA,  SAD_valid[1],  PE1_out_rb_mem);
	ProcessingElements PE2(in_clk, in_rst,  in_sw_mux[2],  in_pe_ena[2],  in_sw_data1, in_sw_data2, PE1_out_rb_mem,  PE2_out_SDA,  SAD_valid[2],  PE2_out_rb_mem);
	ProcessingElements PE3(in_clk, in_rst,  in_sw_mux[3],  in_pe_ena[3],  in_sw_data1, in_sw_data2, PE2_out_rb_mem,  PE3_out_SDA,  SAD_valid[3],  PE3_out_rb_mem);
	ProcessingElements PE4(in_clk, in_rst,  in_sw_mux[4],  in_pe_ena[4],  in_sw_data1, in_sw_data2, PE3_out_rb_mem,  PE4_out_SDA,  SAD_valid[4],  PE4_out_rb_mem);
	ProcessingElements PE5(in_clk, in_rst,  in_sw_mux[5],  in_pe_ena[5],  in_sw_data1, in_sw_data2, PE4_out_rb_mem,  PE5_out_SDA,  SAD_valid[5],  PE5_out_rb_mem);
	ProcessingElements PE6(in_clk, in_rst,  in_sw_mux[6],  in_pe_ena[6],  in_sw_data1, in_sw_data2, PE5_out_rb_mem,  PE6_out_SDA,  SAD_valid[6],  PE6_out_rb_mem);
	ProcessingElements PE7(in_clk, in_rst,  in_sw_mux[7],  in_pe_ena[7],  in_sw_data1, in_sw_data2, PE6_out_rb_mem,  PE7_out_SDA,  SAD_valid[7],  PE7_out_rb_mem);
	ProcessingElements PE8(in_clk, in_rst,  in_sw_mux[8],  in_pe_ena[8],  in_sw_data1, in_sw_data2, PE7_out_rb_mem,  PE8_out_SDA,  SAD_valid[8],  PE8_out_rb_mem);
	ProcessingElements PE9(in_clk, in_rst,  in_sw_mux[9],  in_pe_ena[9],  in_sw_data1, in_sw_data2, PE8_out_rb_mem,  PE9_out_SDA,  SAD_valid[9],  PE9_out_rb_mem);
	ProcessingElements PE10(in_clk, in_rst, in_sw_mux[10], in_pe_ena[10], in_sw_data1, in_sw_data2, PE9_out_rb_mem,  PE10_out_SDA, SAD_valid[10], PE10_out_rb_mem);
	ProcessingElements PE11(in_clk, in_rst, in_sw_mux[11], in_pe_ena[11], in_sw_data1, in_sw_data2, PE10_out_rb_mem, PE11_out_SDA, SAD_valid[11], PE11_out_rb_mem);
	ProcessingElements PE12(in_clk, in_rst, in_sw_mux[12], in_pe_ena[12], in_sw_data1, in_sw_data2, PE11_out_rb_mem, PE12_out_SDA, SAD_valid[12], PE12_out_rb_mem);
	ProcessingElements PE13(in_clk, in_rst, in_sw_mux[13], in_pe_ena[13], in_sw_data1, in_sw_data2, PE12_out_rb_mem, PE13_out_SDA, SAD_valid[13], PE13_out_rb_mem);
	ProcessingElements PE14(in_clk, in_rst, in_sw_mux[14], in_pe_ena[14], in_sw_data1, in_sw_data2, PE13_out_rb_mem, PE14_out_SDA, SAD_valid[14], PE14_out_rb_mem);
	ProcessingElements PE15(in_clk, in_rst, in_sw_mux[15], in_pe_ena[15], in_sw_data1, in_sw_data2, PE14_out_rb_mem, PE15_out_SDA, SAD_valid[15], );
	
	InstantMinComp InstantMinComp(PE0_out_SDA, PE1_out_SDA, PE2_out_SDA, 
	                              PE3_out_SDA, PE4_out_SDA, PE5_out_SDA, 
	                              PE6_out_SDA, PE7_out_SDA, PE8_out_SDA, 
	                              PE9_out_SDA, PE10_out_SDA, PE11_out_SDA, 
	                              PE12_out_SDA, PE13_out_SDA, PE14_out_SDA, 
	                              PE15_out_SDA, SAD_valid, out_SAD_valid_masked, out_min_SAD);
	                      
	MinTrackerComp MinTrackerComp(in_clk, in_rst, out_min_SAD, out_SAD_valid_masked, out_final_min_SAD, out_DONE);
	
endmodule  