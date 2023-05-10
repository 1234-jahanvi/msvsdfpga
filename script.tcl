#Cd to ....../counter_design_database_45nm/synthesis
#Launch Genus using the command: genus -legacy_ui 

#Start typing in the commands from rc_script.tcl one at a time 
#Or To source the whole script file, source <filename.tcl>

#Step1: Set library paths
#rm designs/*
set_attr init_lib_search_path /home/jahanvi1/Documents/jahanvi/scl_pdk_v2/stdlib/fs120/liberty/lib_flow_ff/
set_attr init_hdl_search_path /home/jahanvi1/genus_flow_2/SRC/
set_attr library tsl18fs120_scl_ff.lib 

# Set the path to the directory containing the main Verilog files


read_hdl {./SRC/fpga_defines.v ./SRC/fabric_netlists.v ./SRC/fpga_top.v}


#Step 3: Elaborate/connect all modules
elaborate fpga_top
# elaborate looks for undefined modules in the directories specified through the -libpath option

gui_show 
#Check schematic by clicking on + --> Close --> Hide GUI (do not hit exit)
#Step 4: Read constraints
#read_sdc /home/jahanvi1/genus_flow_2/SDC/*.sdc
#This is part of sdc: create_clock -name clk -period 2 -waveform {0 1} [get_ports "clk"] --> 2--> ns
#Slack is in ps


#Step 4: Synthesise the  design to generic gates and set the effort level
set_attr syn_generic_effort high
syn_generic

#gui_show
#suspend - to stop here and observe the results


#syn_map: Maps  the  design  to  the  cells  described in the supplied technology library and performs logic optimization.
syn_map

#Step 5: Report results before optimisation
report_power > power.txt
#gui_show
report_gates 
#suspend

#Step 6: Optimise and run synthesis- key step
#Performs  gate  level  optimization to improve timing on critical paths
set_attr syn_opt_effort high

#Step 7: Report results after optimisation
report_gates 
report_power > power.txt

#Step 8 Check design for timing errors
check_design > design_check.txt
#suspend

#Step 9: Write out synthesised netlist and constraints- important output
write_hdl > hdl_synthesis.v
write_sdc > ./reports/area_opt/counter_sdc.sdc  

#Step 10: Report final results
report_gates 
report_area > area.txt
report_power > power.txt
report_timing > timing.txt
#suspend  --> Change constraints --clock, redo read_hdc, syn_generic, syn_map, syn_opt and report_timing --> to check slack.


#write_hdl > counter_netlist.v
#write_sdc > counter_sdc.sdc  

#suspend
#write_template -simple -outfile simple_template.txt
#write_template -power -outfile template_power.tcl
#write_template -area -outfile template_area.tcl
#write_template -full -outfile template_full.tcl
#write_template -retime -outfile template_retime.tcl

#Hit quit to exit Genus. Do not do Ctrl+C, you will be holding up licenses
