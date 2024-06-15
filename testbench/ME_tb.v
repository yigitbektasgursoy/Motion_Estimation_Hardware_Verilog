`timescale 1ns / 1ps

module ME_tb();
	//PARAMETER BEGIN
	parameter DATA_WIDTH = 8,
	          SW_MEMORY_DEPTH = 961,
	          RB_MEMORY_DEPTH = 256,
	          MAX_DATA_WIDTH = 16,
	          PE_COUNT = 16;
	//PARAMETER END
	
    // GLOBAL SIGNALS BEGIN
    reg in_clk;    // Clock signal
    reg in_rst;    // Reset signal
    // GLOBAL SIGNALS END
    
    reg me_enable;  // Motion estimation enable signal
    
    // SEARCH WINDOW MEMORY BEGIN
    reg in_sw_write_en;      // Search window write enable
    reg [$clog2(SW_MEMORY_DEPTH)-1:0] in_sw_write_addr;  // Search window write address
    reg [DATA_WIDTH-1:0] in_sw_write_data; // Search window write data
    // SEARCH WINDOW MEMORY END
    
    // REFERENCE BLOCK MEMORY BEGIN
    reg in_rb_write_en;      // Reference block write enable
    reg [$clog2(RB_MEMORY_DEPTH)-1:0] in_rb_write_addr;  // Reference block write address
    reg [DATA_WIDTH-1:0] in_rb_write_data; // Reference block write data
    // REFERENCE BLOCK MEMORY END
    
    // COMPARATOR BEGIN
    wire [MAX_DATA_WIDTH-1:0] out_min_SAD; // Output minimum SAD value
    wire out_DONE;
    // COMPARATOR END
    
    //TEST BENCH INTERFACE BEGIN
    integer srchwindow_outputs, refblock_outputs; // File handlers
    integer scan_search_file, scan_reference_file; // File scan results
    integer CLK = 10; // Clock period
    integer global_counter, process_counter; // Performance analysis and schedule counters
    reg [19:0] min_SAD_hw, min_SAD_sw [0:0]; // SAD values for comparison
	reg read_DONE = 0;
    //TEST BENCH INTERFACE END
    
    // Instantiate the MotionEstimationTop module
    MotionEstimationTop DUT (
        in_clk, in_rst, me_enable, 
        in_sw_write_en, in_sw_write_addr, in_sw_write_data, 
        in_rb_write_en, in_rb_write_addr, in_rb_write_data,
        out_min_SAD,
        out_DONE
    );
    
    // Clock generation
    always #(CLK/2) in_clk = ~in_clk;
    
    // Global counter logic
    always @(posedge in_clk or posedge in_rst) begin
        if (in_rst) begin
            global_counter <= 0;
        end 
        else begin
            global_counter <= global_counter + 1;
        end
        
        if(in_rst)begin
            process_counter <= 0;
        end
        else begin
            if(me_enable)begin
                process_counter <= process_counter + 1;
            end
        end
    end
    
    // Initial block for reset and memory initialization
    initial begin
        #(50*CLK)
        in_clk = 0;
        in_rst = 1;
        me_enable = 0;
        
        in_sw_write_en = 1;
        in_sw_write_addr = 0;
        
        in_rb_write_en = 1;
        in_rb_write_addr = 0;
        #CLK
        in_rst = 0;
    end
     
    // Load search window memory from file
    initial begin 
        #(100*CLK)  
        srchwindow_outputs = $fopen("SearchWindowMemory_hw.txt", "r");
        if (srchwindow_outputs == 0) begin
            $display("SearchWindowMemory_hw.txt is not found");
            $finish;
        end
        
        while (!$feof(srchwindow_outputs)) begin
            scan_search_file = $fscanf(srchwindow_outputs, "%b\n", in_sw_write_data);
            #(CLK);
            in_sw_write_addr = in_sw_write_addr + 1;
        end
        in_sw_write_en = 0;
		read_DONE = 1;
    end
    
    // Load reference block memory from file
    initial begin
        #(100*CLK)   
        refblock_outputs = $fopen("ReferenceBlock_hw.txt", "r");
        if (refblock_outputs == 0) begin
            $display("ReferenceBlock_hw.txt is not found");
            $finish;
        end
        
        while (!$feof(refblock_outputs)) begin
            scan_reference_file = $fscanf(refblock_outputs, "%b\n", in_rb_write_data);
            #(CLK);
            in_rb_write_addr = in_rb_write_addr + 1;
        end
        in_rb_write_en = 0;
    end
    
    // Enable motion estimation and compare results
    initial begin
        wait(read_DONE);
		#(CLK*2);
        me_enable = 1;
        
        wait(out_DONE);
        me_enable = 0;
        
        // Begin comparison of software and hardware results
        $readmemh("min_SAD.txt", min_SAD_sw);
        min_SAD_hw = out_min_SAD;
        
        if (min_SAD_sw[0] == min_SAD_hw) begin
            // If the minimum SAD values match, display success message
            $display("**** SUCCESS: Minimum SAD values match **** Software Result: %0h | Hardware Result: %0h **** ", min_SAD_sw[0], min_SAD_hw);
            $display("**** Calculating min SAD took %0d clock cycles ****", process_counter);        
        end 
        else begin
            // If the minimum SAD values do not match, display failure message
            $display("**** FAILURE: Minimum SAD values do not match **** Software Result: %0h | Hardware Result: %0h ****", min_SAD_sw[0], min_SAD_hw);
        end
        // End comparison of software and hardware results        
        #(CLK);
        $stop;
    end

endmodule