## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
 
# Switches

#set_property PACKAGE_PIN V17 [get_ports {sw[0]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
#set_property PACKAGE_PIN V16 [get_ports {sw[1]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
#set_property PACKAGE_PIN W16 [get_ports {sw[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
#set_property PACKAGE_PIN W17 [get_ports {sw[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
#set_property PACKAGE_PIN W15 [get_ports {sw[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
#set_property PACKAGE_PIN V15 [get_ports {sw[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
#set_property PACKAGE_PIN W14 [get_ports {sw[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
#set_property PACKAGE_PIN W13 [get_ports {sw[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
#set_property PACKAGE_PIN V2 [get_ports {sw[8]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
#set_property PACKAGE_PIN T3 [get_ports {sw[9]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
#set_property PACKAGE_PIN T2 [get_ports {sw[10]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
#set_property PACKAGE_PIN R3 [get_ports {sw[11]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
#set_property PACKAGE_PIN W2 [get_ports {sw[12]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
#set_property PACKAGE_PIN U1 [get_ports {sw[13]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
#set_property PACKAGE_PIN T1 [get_ports {sw[14]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
set_property PACKAGE_PIN R2 [get_ports {gen_data}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gen_data}]
 

# LEDs

#set_property PACKAGE_PIN U16 [get_ports {LED[0]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
#set_property PACKAGE_PIN E19 [get_ports {LED[1]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
#set_property PACKAGE_PIN U19 [get_ports {LED[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
#set_property PACKAGE_PIN V19 [get_ports {LED[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
#set_property PACKAGE_PIN W18 [get_ports {LED[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
#set_property PACKAGE_PIN U15 [get_ports {LED[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
#set_property PACKAGE_PIN U14 [get_ports {LED[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
#set_property PACKAGE_PIN V14 [get_ports {LED[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
#set_property PACKAGE_PIN V13 [get_ports {LED[8]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
#set_property PACKAGE_PIN V3 [get_ports {LED[9]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
#set_property PACKAGE_PIN W3 [get_ports {LED[10]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
#set_property PACKAGE_PIN U3 [get_ports {LED[11]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
#set_property PACKAGE_PIN P3 [get_ports {LED[12]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
set_property PACKAGE_PIN N3 [get_ports {sync}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sync}]
set_property PACKAGE_PIN P1 [get_ports {lock}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {lock}]
#set_property PACKAGE_PIN L1 [get_ports {LED[15]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]
	
	
#7 digitment display
set_property PACKAGE_PIN W7 [get_ports {digit[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[0]}]
set_property PACKAGE_PIN W6 [get_ports {digit[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[1]}]
set_property PACKAGE_PIN U8 [get_ports {digit[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[2]}]
set_property PACKAGE_PIN V8 [get_ports {digit[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[3]}]
set_property PACKAGE_PIN U5 [get_ports {digit[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[4]}]
set_property PACKAGE_PIN V5 [get_ports {digit[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[5]}]
set_property PACKAGE_PIN U7 [get_ports {digit[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[6]}]

#set_property PACKAGE_PIN V7 [get_ports dp]							
	#set_property IOSTANDARD LVCMOS33 [get_ports dp]

set_property PACKAGE_PIN U2 [get_ports {anode_en[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode_en[0]}]
set_property PACKAGE_PIN U4 [get_ports {anode_en[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode_en[1]}]
set_property PACKAGE_PIN V4 [get_ports {anode_en[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode_en[2]}]
set_property PACKAGE_PIN W4 [get_ports {anode_en[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode_en[3]}]


##Buttons
#BtnC
set_property PACKAGE_PIN U18 [get_ports reset]						
	set_property IOSTANDARD LVCMOS33 [get_ports reset]
#BtnU
set_property PACKAGE_PIN T18 [get_ports gen_error]						
	set_property IOSTANDARD LVCMOS33 [get_ports gen_error]
#BtnL
#set_property PACKAGE_PIN W19 [get_ports clk_btn]						
	#set_property IOSTANDARD LVCMOS33 [get_ports clk_btn]
#set_property PACKAGE_PIN T17 [get_ports btnR]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnR]
#set_property PACKAGE_PIN U17 [get_ports btnD]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnD]
 


##Pmod Header JA

##Sch name = JA1
#set_property PACKAGE_PIN J1 [get_ports {JA[0]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[0]}]
##Sch name = JA2
#set_property PACKAGE_PIN L2 [get_ports {JA[1]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[1]}]
##Sch name = JA3
#set_property PACKAGE_PIN J2 [get_ports {JA[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[2]}]
##Sch name = JA4
#set_property PACKAGE_PIN G2 [get_ports {JA[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[3]}]
##Sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {JA[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[4]}]
##Sch name = JA8
#set_property PACKAGE_PIN K2 [get_ports {JA[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[5]}]
##Sch name = JA9
#set_property PACKAGE_PIN H2 [get_ports {JA[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[6]}]
##Sch name = JA10
#set_property PACKAGE_PIN G3 [get_ports {JA[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[7]}]



##Pmod Header JB
##Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {bits_in[0]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {bits_in[0]}]
##Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports {bits_in[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {bits_in[1]}]
##Sch name = JB3
#set_property PACKAGE_PIN B15 [get_ports {fifo_out}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {fifo_out}]
##Sch name = JB4
#set_property PACKAGE_PIN B16 [get_ports {fifo_valid}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {fifo_valid}]
##Sch name = JB7
set_property PACKAGE_PIN A15 [get_ports {valid_data_in}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {valid_data_in}]	
##Sch name = JB8
set_property PACKAGE_PIN A17 [get_ports {word_start_in}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {word_start_in}]
##Sch name = JB9
#set_property PACKAGE_PIN C15 [get_ports {JB[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[6]}]
##Sch name = JB10 
#set_property PACKAGE_PIN C16 [get_ports {JB[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[7]}]
 


##Pmod Header JC

##Sch name = JC1
set_property PACKAGE_PIN K17 [get_ports {bits_out[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {bits_out[0]}]
##Sch name = JC2
set_property PACKAGE_PIN M18 [get_ports {bits_out[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {bits_out[1]}]
##Sch name = JC3
#set_property PACKAGE_PIN N17 [get_ports {JC[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[2]}]
##Sch name = JC4
#set_property PACKAGE_PIN P18 [get_ports {JC[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]
##Sch name = JC7
set_property PACKAGE_PIN L17 [get_ports {valid_data_out}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {valid_data_out}]
##Sch name = JC8
set_property PACKAGE_PIN M19 [get_ports {word_start_out}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {word_start_out}]
##Sch name = JC9
#set_property PACKAGE_PIN P17 [get_ports {JC[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[6]}]
##Sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports {JC[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]



