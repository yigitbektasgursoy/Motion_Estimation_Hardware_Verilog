module MotionEstimationTop
	#(parameter DATA_WIDTH = 8,
	            SW_MEMORY_DEPTH = 961,
				RB_MEMORY_DEPTH = 256,
                MAX_DATA_WIDTH = 16,
				PE_COUNT = 16
    )				
	(
	
	//GLOBAL SIGNALS BEGIN
	input in_clk,
	input in_rst,
	//GLOBAL SIGNALS END
	
	input me_enable,
	
	//SEARCH WINDOW MEMORY BEGIN
	input in_sw_write_en,
	input [$clog2(SW_MEMORY_DEPTH)-1:0] in_sw_write_addr,
	input [DATA_WIDTH-1:0] in_sw_write_data,
	//SEARCH WINDOW MEMORY END
	
	//REFERENCE BLOCK MEMORY BEGIN
	input in_rb_write_en,
	input [$clog2(RB_MEMORY_DEPTH)-1:0] in_rb_write_addr,
	input [DATA_WIDTH-1:0] in_rb_write_data,
	//REFERENCE BLOCK MEMORY END
	
	//COMPARATOR BEGIN
	output [MAX_DATA_WIDTH-1:0] out_min_SAD,
	output out_DONE
	//COMPARATOR END
	
	);
	
	//SEARCH WINDOW MEMORY WIRES BEGIN
	wire [$clog2(SW_MEMORY_DEPTH)-1:0] out_sw_read_addr1, out_sw_read_addr2;
	wire [DATA_WIDTH-1:0] out_sw_read_data1, out_sw_read_data2;
	//SEARCH WINDOW MEMORY WIRES END
	
	//REFERENCE BLOCK MEMORY WIRES BEGIN
	wire [$clog2(RB_MEMORY_DEPTH)-1:0] in_rb_read_addr;
	wire [DATA_WIDTH-1:0] out_rb_read_data;
	//REFERENCE BLOCK MEMORY WIRES END
	

	//CONTROL UNIT WIRES BEGIN
	wire [PE_COUNT-1:0] out_cu_sw_mux, out_cu_pe_ena;
	//CONTROL UNIT WIRES END
	
	SearchWindowMemory SearchWindowMemory(in_clk, in_sw_write_en, in_sw_write_addr, out_sw_read_addr1, out_sw_read_addr2, in_sw_write_data, out_sw_read_data1, out_sw_read_data2);
	ReferenceBlockMemory ReferenceBlockMemory(in_clk, in_rb_write_en, in_rb_write_addr, in_rb_read_addr, in_rb_write_data, out_rb_read_data);
	ControlUnit ControlUnit(in_clk, in_rst, me_enable, out_cu_sw_mux, out_cu_pe_ena, in_rb_read_addr, out_sw_read_addr1, out_sw_read_addr2);
	Datapath Datapath(in_clk, in_rst, out_cu_sw_mux, out_cu_pe_ena, out_sw_read_data1, out_sw_read_data2, out_rb_read_data, out_min_SAD, out_DONE);

endmodule