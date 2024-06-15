create_clock -name sysclk -period 32 -waveform {0 16} [get_ports in_clk]
#set_property dont_touch true [get_cells ControlUnit];
#set_property dont_touch true [get_cells Datapath];
#set_property dont_touch true [get_cells MotionEstimationTop];   
#set_property dont_touch true [get_nets <net_name>]; 