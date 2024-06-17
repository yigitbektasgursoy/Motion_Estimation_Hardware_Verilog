`timescale 1ns / 1ps

module ControlUnit
    #(parameter DATA_WIDTH = 8,
				SW_MEMORY_DEPTH = 961,
				RB_MEMORY_DEPTH = 256,
				PE_COUNT = 16,
				CU_COUNTER_WIDTH = 13
	)
	(
	input in_clk,
	input in_rst,
	input in_cu_ena, // Control unit enable signal
	
	//DATAPATH INTERFACE BEGIN
	output reg [PE_COUNT-1:0] out_sw_mux, // Output to switch mux
	output reg [PE_COUNT-1:0] out_pe_ena, // Output to PE enable
	//DATAPATH INTERFACE END
	
	//REFERENCE BLOCK INTERFACE BEGIN
	output reg [$clog2(RB_MEMORY_DEPTH)-1:0] out_rb_read_addr, // Reference block read address
	//REFERENCE BLOCK INTERFACE END
	
	//SEARCH WINDOW INTERFACE BEGIN
	output reg [$clog2(SW_MEMORY_DEPTH)-1:0] out_sw_read_addr1, // Search window read address 1
	output reg [$clog2(SW_MEMORY_DEPTH)-1:0] out_sw_read_addr2 // Search window read address 2
	//SEARCH WINDOW INTERFACE END
	
	);
	
	// INTERNAL REGISTERS BEGIN
	reg [CU_COUNTER_WIDTH-1:0] cu_counter; // Control unit counter
	reg port2_triggered;                   // Flag for triggering port 2
	reg [4:0] rb_row_index;                // Reference block row index
	reg [3:0] new_frame_control;           // New frame control signal
	// INTERNAL REGISTERS END
	
	// COUNTER FOR THE CONTROL UNIT BEGIN
	always @(posedge in_clk or posedge in_rst)begin
		if(in_rst)begin
			cu_counter <= 0;
		end
		else begin
			if(in_cu_ena)begin
				cu_counter <= cu_counter + 1;
			end
		end
	end
	// COUNTER FOR THE CONTROL UNIT END
	
	//REFERENCE BLOCK READ ADDRES POINTER BEGIN
	always @(posedge in_clk or posedge in_rst)begin
		if(in_rst)begin
			out_rb_read_addr <= 0;
			rb_row_index <= 1;
		end
		else begin
			if(in_cu_ena)begin
				if(out_rb_read_addr == RB_MEMORY_DEPTH)begin // Check if address reaches max depth
					out_rb_read_addr <= 0;
				end
				else begin
					if((cu_counter+1)%16 != 0 || cu_counter == 0)begin
						out_rb_read_addr <= out_rb_read_addr + 16;
					end
					else begin
						if(rb_row_index == 15)begin
							rb_row_index <= 0;
							out_rb_read_addr <= rb_row_index;
						end
						else if((cu_counter+1) % 16 == 0 && cu_counter != 0)begin
							rb_row_index <= rb_row_index + 1;
							out_rb_read_addr <= rb_row_index;
						end
					end
				end

			end	
		end
	end
	//REFERENCE BLOCK READ ADDRES POINTER END
	
	
	// SEARCH WINDOW ADDRESS 1 CONTROL BEGIN	
	always @(posedge in_clk or posedge in_rst)begin
		if(in_rst)begin
			out_sw_read_addr1 <= 0;
			port2_triggered <= 0;
			new_frame_control <= 0;
		end
		else begin
			if(in_cu_ena)begin
				if (cu_counter % 256 == 254 && cu_counter > 253) begin // New frame control
					new_frame_control <= new_frame_control + 1;
					out_sw_read_addr1 <= out_sw_read_addr1 + 31;		
				end
				else if(cu_counter % 256 == 255 && cu_counter > 254)begin
					out_sw_read_addr1 <= new_frame_control;
				end
				else if (cu_counter % 16 == 15) begin
					out_sw_read_addr1 <= new_frame_control + rb_row_index; // Starting address of the new row
				end 
				else begin
					out_sw_read_addr1 <= out_sw_read_addr1 + 31; // 31 increments on the same row
				end
				
				// Trigger port 2 after 13 clock cycles to enable reading from the second search window
				if(cu_counter == 13)begin
				    port2_triggered <= 1'b1; 
				end
			end	
		end
	end
	// SEARCH WINDOW ADDRESS 1 CONTROL END
	
	// SEARCH WINDOW READ ADDRESS 2 CONTROL BEGIN
	always @(posedge in_clk or posedge in_rst)begin
		if(in_rst)begin
			out_sw_read_addr2 <= 0;
		end
		else begin
			if(port2_triggered)begin
				// Offset address 2 if port 2 is triggered and within valid range (0-14)
				if((cu_counter+2)%16 == 0) begin
					out_sw_read_addr2 <= out_sw_read_addr1 + 31; 
				end
				// Otherwise, use the same address as out_sw_read_addr1
				else begin
					out_sw_read_addr2 <= out_sw_read_addr2 + 31;
				end
			end
	   end
	end
	// SEARCH WINDOW READ ADDRESS 2 CONTROL END
	
	
	// PE ENABLE SCHEDULE BEGIN
	always @(posedge in_clk or posedge in_rst)begin
		if(in_rst)begin
			out_pe_ena <= 16'b0;
		end
		else begin
			if(in_cu_ena)begin
                out_pe_ena <= (out_pe_ena << 1) + 1;
            end
		end
	end
	// PE ENABLE SCHEDULE END
	


    always @(posedge in_clk or posedge in_rst) begin
        if (in_rst) begin
            out_sw_mux <= 16'b0;
        end else begin
            if (in_cu_ena) begin
                // PE0 SWMUX SCHEDULE BEGIN
                out_sw_mux[0] <= 1'b1;
                // PE0 SWMUX SCHEDULE END
                
                // PE1 SWMUX SCHEDULE BEGIN
                if(cu_counter % 16 == 0) begin
                    out_sw_mux[1] <= 1'b0;    
                end else begin
                    out_sw_mux[1] <= 1'b1;
                end
                // PE1 SWMUX SCHEDULE END
                
                // PE2 SWMUX SCHEDULE BEGIN
                if(cu_counter    % 16 == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter+1) % 16 == 0) 
				begin
                    out_sw_mux[2] <= 1'b0;    
                end 
				else begin
                    out_sw_mux[2] <= 1'b1;
                end
                // PE2 SWMUX SCHEDULE END
                
                // PE3 SWMUX SCHEDULE BEGIN
                if(cu_counter    % 16 == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter-2) % 16 == 0 || (cu_counter+1) % 16 == 0) 
				begin
                    out_sw_mux[3] <= 1'b0;    
                end 
				else begin
                    out_sw_mux[3] <= 1'b1;
                end
                // PE3 SWMUX SCHEDULE END
                
                // PE4 SWMUX SCHEDULE BEGIN
                if(cu_counter    % 16 == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter-2) % 16 == 0 || (cu_counter-3) % 16 == 0 || 
				  (cu_counter+1) % 16 == 0) 
				begin
                    out_sw_mux[4] <= 1'b0;    
                end else begin
                    out_sw_mux[4] <= 1'b1;
                end
                // PE4 SWMUX SCHEDULE END
                
                // PE5 SWMUX SCHEDULE BEGIN
                if(cu_counter    % 16 == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter-2) % 16 == 0 || (cu_counter-3) % 16 == 0 || 
				  (cu_counter+1) % 16 == 0 || (cu_counter-4) % 16 == 0) 
				begin
                    out_sw_mux[5] <= 1'b0;    
                end 
				else begin
                    out_sw_mux[5] <= 1'b1;
                end
                // PE5 SWMUX SCHEDULE END
                
                // PE6 SWMUX SCHEDULE BEGIN
                if(cu_counter    % 16 == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter-2) % 16 == 0 || (cu_counter-3) % 16 == 0 || 
				  (cu_counter+1) % 16 == 0 || (cu_counter-4) % 16 == 0 || 
				  (cu_counter-5) % 16 == 0) 
				begin
                    out_sw_mux[6] <= 1'b0;    
                end else begin
                    out_sw_mux[6] <= 1'b1;
                end
                // PE6 SWMUX SCHEDULE END
                
                // PE7 SWMUX SCHEDULE BEGIN
                if(cu_counter    % 16 == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter-2) % 16 == 0 || (cu_counter-3) % 16 == 0 || 
				  (cu_counter+1) % 16 == 0 || (cu_counter-4) % 16 == 0 || 
				  (cu_counter-5) % 16 == 0 || (cu_counter-6) % 16 == 0) 
				begin
                    out_sw_mux[7] <= 1'b0;    
                end else begin
                    out_sw_mux[7] <= 1'b1;
                end
                // PE7 SWMUX SCHEDULE END
                
                // PE8 SWMUX SCHEDULE BEGIN
                if(cu_counter % 16    == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter-2) % 16 == 0 || (cu_counter-3) % 16 == 0 || 
				  (cu_counter+1) % 16 == 0 || (cu_counter-4) % 16 == 0 || 
				  (cu_counter-5) % 16 == 0 || (cu_counter-6) % 16 == 0 || 
				  (cu_counter-7) % 16 == 0) 
				begin
                    out_sw_mux[8] <= 1'b0;    
                end 
				else begin
                    out_sw_mux[8] <= 1'b1;
                end
                // PE8 SWMUX SCHEDULE END
                
                // PE9 SWMUX SCHEDULE BEGIN
                if(cu_counter    % 16 == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter-2) % 16 == 0 || (cu_counter-3) % 16 == 0 || 
				  (cu_counter+1) % 16 == 0 || (cu_counter-4) % 16 == 0 || 
				  (cu_counter-5) % 16 == 0 || (cu_counter-6) % 16 == 0 || 
				  (cu_counter-7) % 16 == 0 || (cu_counter-8) % 16 == 0) 
				begin
                    out_sw_mux[9] <= 1'b0;    
                end 
				else begin
                    out_sw_mux[9] <= 1'b1;
                end
                // PE9 SWMUX SCHEDULE END
                
                // PE10 SWMUX SCHEDULE BEGIN
                if(cu_counter    % 16 == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter-2) % 16 == 0 || (cu_counter-3) % 16 == 0 || 
				  (cu_counter+1) % 16 == 0 || (cu_counter-4) % 16 == 0 || 
				  (cu_counter-5) % 16 == 0 || (cu_counter-6) % 16 == 0 || 
				  (cu_counter-7) % 16 == 0 || (cu_counter-8) % 16 == 0 || 
				  (cu_counter-9) % 16 == 0) 
				begin
                    out_sw_mux[10] <= 1'b0;    
                end 
				else begin
                    out_sw_mux[10] <= 1'b1;
                end
                // PE10 SWMUX SCHEDULE END
                
                // PE11 SWMUX SCHEDULE BEGIN
                if(cu_counter    % 16 == 0 || (cu_counter-1) % 16 == 0 || 
				  (cu_counter-2) % 16 == 0 || (cu_counter-3) % 16 == 0 || 
				  (cu_counter+1) % 16 == 0 || (cu_counter-4) % 16 == 0 || 
				  (cu_counter-5) % 16 == 0 || (cu_counter-6) % 16 == 0 || 
				  (cu_counter-7) % 16 == 0 || (cu_counter-8) % 16 == 0 || 
				  (cu_counter-9) % 16 == 0 || (cu_counter-10) % 16 == 0) 
				begin
                    out_sw_mux[11] <= 1'b0;    
                end else begin
                    out_sw_mux[11] <= 1'b1;
                end
                // PE11 SWMUX SCHEDULE END
                
                // PE12 SWMUX SCHEDULE BEGIN
                if(cu_counter     % 16  == 0 || (cu_counter-1)  % 16  == 0 || 
				  (cu_counter-2)  % 16  == 0 || (cu_counter-3)  % 16  == 0 || 
				  (cu_counter+1)  % 16  == 0 || (cu_counter-4)  % 16  == 0 || 
				  (cu_counter-5)  % 16  == 0 || (cu_counter-6)  % 16  == 0 || 
				  (cu_counter-7)  % 16  == 0 || (cu_counter-8)  % 16  == 0 || 
				  (cu_counter-9)  % 16  == 0 || (cu_counter-10) % 16  == 0 || 
				  (cu_counter-11) % 16 == 0) 
				begin
                    out_sw_mux[12] <= 1'b0;    
                end 
				else begin
                    out_sw_mux[12] <= 1'b1;
                end
                // PE12 SWMUX SCHEDULE END
                
                // PE13 SWMUX SCHEDULE BEGIN
                if(cu_counter     % 16  == 0 || (cu_counter-1)   % 16 == 0 || 
				  (cu_counter-2)  % 16  == 0 || (cu_counter-3)   % 16 == 0 || 
				  (cu_counter+1)  % 16  == 0 || (cu_counter-4)   % 16 == 0 || 
				  (cu_counter-5)  % 16  == 0 || (cu_counter-6)   % 16 == 0 || 
				  (cu_counter-7)  % 16  == 0 || (cu_counter-8)   % 16 == 0 || 
				  (cu_counter-9)  % 16  == 0 || (cu_counter-10)  % 16 == 0 || 
				  (cu_counter-11) % 16  == 0 || (cu_counter-12) % 16 == 0) 
				begin
                    out_sw_mux[13] <= 1'b0;    
                end 
				else begin
                    out_sw_mux[13] <= 1'b1;
                end
                // PE13 SWMUX SCHEDULE END
                
                // PE14 SWMUX SCHEDULE BEGIN
                if(cu_counter     % 16 == 0  || (cu_counter-1)  % 16 == 0 || 
				  (cu_counter-2)  % 16 == 0  || (cu_counter-3)  % 16 == 0 || 
				  (cu_counter+1)  % 16 == 0  || (cu_counter-4)  % 16 == 0 || 
				  (cu_counter-5)  % 16 == 0  || (cu_counter-6)  % 16 == 0 || 
				  (cu_counter-7)  % 16 == 0  || (cu_counter-8)  % 16 == 0 || 
				  (cu_counter-9)  % 16 == 0  || (cu_counter-10) % 16 == 0 || 
				  (cu_counter-11) % 16 == 0  || (cu_counter-12) % 16 == 0 || 
				  (cu_counter-13) % 16 == 0) 
				begin
                    out_sw_mux[14] <= 1'b0;    
                end else begin
                    out_sw_mux[14] <= 1'b1;
                end
                // PE14 SWMUX SCHEDULE END
                
                // PE15 SWMUX SCHEDULE BEGIN
                if(cu_counter     % 16 == 0 || (cu_counter-1)  % 16 == 0 || 
				  (cu_counter-2)  % 16 == 0 || (cu_counter-3)  % 16 == 0 || 
				  (cu_counter+1)  % 16 == 0 || (cu_counter-4)  % 16 == 0 || 
				  (cu_counter-5)  % 16 == 0 || (cu_counter-6)  % 16 == 0 || 
				  (cu_counter-7)  % 16 == 0 || (cu_counter-8)  % 16 == 0 || 
				  (cu_counter-9)  % 16 == 0 || (cu_counter-10) % 16 == 0 || 
				  (cu_counter-11) % 16 == 0 || (cu_counter-12) % 16 == 0 || 
				  (cu_counter-13) % 16 == 0 || (cu_counter-14) % 16 == 0) 
				begin
                    out_sw_mux[15] <= 1'b0;
                end 
				else begin
                    out_sw_mux[15] <= 1'b1;
                end
                // PE15 SWMUX SCHEDULE END
            end    
        end
    end
endmodule
