# msvsdfpga

## TASK-1: Generating an RTL supporting 1000+ LUT count using OpenFPGA

OpenFPGA provides push-button scripts for users to run design flows. Users can customize their flow-run by crafting a task configuration file.

### Prepare the task configuration file

In the task configuration file, you can specify the XML-based architecture files that describe the architecture of the FPGA fabric.
Also, you can specify the openfpga shell script to be executed. Here, we are using an example script (example_script.openfpga) which is golden reference to generate Verilog netlists and their testbenches. 

To enable the ability write the Verilog netlist for FPGA fabric after completion of the OpenFPGA flow, we add the below line the script (example_script.openfpga):

```
write_fabric_verilog --file ${OPENFPGA_VERILOG_OUTPUT_DIR}/SRC --explicit_port_mapping --include_timing --print_user_defined_template --verbose
```

Now, below is the task.conf file in the yosys_vpr_template where we specify the architecture file and the design (rs_decoder.v).

```
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# Configuration file for running experiments
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# timeout_each_job : FPGA Task script splits fpga flow into multiple jobs
# Each job execute fpga_flow script on combination of architecture & benchmark
# timeout_each_job is timeout for each job
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

[GENERAL]
run_engine=openfpga_shell
power_tech_file = ${PATH:OPENFPGA_PATH}/openfpga_flow/tech/PTM_45nm/45nm.xml
power_analysis = true
spice_output=false
verilog_output=true
timeout_each_job = 20*60
fpga_flow=yosys_vpr

[OpenFPGA_SHELL]
openfpga_shell_template=${PATH:OPENFPGA_PATH}/OpenFPGA/openfpga_flow/tasks/template_tasks/yosys_vpr_template/example_script.openfpga
openfpga_arch_file=${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_arch/k6_frac_N10_40nm_openfpga.xml
openfpga_sim_setting_file=${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_simulation_settings/fixed_sim_openfpga.xml

[ARCHITECTURES]
arch0=${PATH:OPENFPGA_PATH}/openfpga_flow/vpr_arch/k6_frac_N10_40nm.xml

[BENCHMARKS]
bench0=${PATH:OPENFPGA_PATH}/openfpga_flow/benchmarks/quicklogic_tests/rs_decoder/rtl/rs_decoder.v

[SYNTHESIS_PARAM]
bench0_top = rs_decoder_top

[SCRIPT_PARAM_MIN_ROUTE_CHAN_WIDTH]
end_flow_with_test=
# vpr_fpga_verilog_formal_verification_top_netlist=

```

### Run OpenFPGA Task

After finalizing your configuration file, you can run the task by calling the python script with the given path to task configuration file:

```
python3 openfpga_flow/scripts/run_fpga_task.py openfpga_flow/tasks/template_tasks/yosys_vpr_template
```
Verilog netlists are generated in the following directory:

```
{OPENFPGA_PATH}/openfpga_flow/tasks/template_tasks/yosys_vpr_template/latest/k6_frac_N10_40nm/rs_decoder_top/MIN_ROUTE_CHAN_WIDTH
```

Below is the final fabric netlists generated in the above path:

![kunal_netlists](https://user-images.githubusercontent.com/56501917/222959020-71151ff0-6928-409d-b525-dd03beba8c4c.png)

And below is the hierarchy of the verilog netlists modelling our FPGA fabric:

![k3](https://user-images.githubusercontent.com/56501917/220191622-3ccefcf0-59de-467c-85c1-4433cd362789.png)



### Checking the LUT-count

Let's jump into the the directory with all the log files:

```
{OPENFPGA_PATH}/openfpga_flow/tasks/template_tasks/yosys_vpr_template/latest/k6_frac_N10_40nm/rs_decoder_top/MIN_ROUTE_CHAN_WIDTH
```
Here; we can see the Circuit-Statistics in the openfpgashell.log

![kunal_stats](https://user-images.githubusercontent.com/56501917/222959057-79b068ca-026b-468c-aa40-e7ceb8691b5f.png)

## Testbench and Simulation:

In the example_script.openfpga, we had to included the command which automatically generates the testbench for our design as an FPGA fabric. The command:

```
write_full_testbench --file ./SRC --reference_benchmark_file_path ${REFERENCE_VERILOG_TESTBENCH} --include_signal_init --bitstream fabric_bitstream.bit 
```
This generates rs_decoder_top_autocheck_top_tb.v which we can now simulate in Vivado.

The following changes were made for a successful simulation:

1. Change ```default_nettype none``` to ```default_nettype wire``` in all the files in the SRC folder

2. In the rs_decoder_top_autocheck_top_tb.v, the reference benchmark instanciation should be changed as follows because we need to match the number of signals in the top module of the design (rs_decoder_top) with that of this instanciated module.

```
wire [4:0] x_input;
wire [4:0] k_input;
wire [4:0] error_benchmark;
assign x_input = {x_4__shared_input, x_3__shared_input, x_2__shared_input, x_1__shared_input, x_0__shared_input};
assign k_input = {k_4__shared_input, k_3__shared_input, k_2__shared_input, k_1__shared_input, k_0__shared_input};
assign error_benchmark = {error_4__benchmark, error_3__benchmark, error_2__benchmark, error_1__benchmark, error_0__benchmark};

	rs_decoder_top REF_DUT(
		x_input,
		error_benchmark,
		with_error_benchmark,
		enable_shared_input,
		valid_benchmark,
		k_input,
		clk,
		clrn_shared_input
	);
```

3. Since $deposit was throwing an error: Undefined System Task, we change all the $deposit statements as assign statements along with removing the initial block around that statements.

For example, earlier it was:

```
// ------ BEGIN driver initialization -----
initial begin
  $deposit(FPGA_DUT.grid_clb_1__1_.logical_tile_clb_mode_clb__0.logical_tile_clb_mode_default__fle_0.logical_tile_clb_mode_default__fle_mode_physical__fabric_0.logical_tile_clb_mode_default__fle_mode_physical__fabric_mode_default__frac_logic_0.logical_tile_clb_mode_default__fle_mode_physical__fabric_mode_default__frac_logic_mode_default__frac_lut6_0.frac_lut6_0_.frac_lut6_mux_0_.mux_l1_in_0_.TGATE_0_.in, $random % 2 ? 1'b1 : 1'b0);
end	
// ------ END driver initialization -----
```

This got changed to:

```
// ------ BEGIN driver initialization -----
	
		assign FPGA_DUT.grid_clb_1__1_.logical_tile_clb_mode_clb__0.logical_tile_clb_mode_default__fle_0.logical_tile_clb_mode_default__fle_mode_physical__fabric_0.logical_tile_clb_mode_default__fle_mode_physical__fabric_mode_default__frac_logic_0.logical_tile_clb_mode_default__fle_mode_physical__fabric_mode_default__frac_logic_mode_default__frac_lut6_0.frac_lut6_0_.frac_lut6_mux_0_.mux_l1_in_0_.TGATE_0_.in= $random % 2 ? 1'b1 : 1'b0;
	
// ------ END driver initialization -----
```


### Simulation screenshot:

![kunal_ss](https://user-images.githubusercontent.com/56501917/222982755-32df4797-d899-4797-aef8-d2dae7188f73.png)



## References:
- [https://openfpga.readthedocs.io/en/master/manual/fpga_verilog/fabric_netlist/#top-level-netlists](https://openfpga.readthedocs.io/en/master/manual/fpga_verilog/fabric_netlist/#top-level-netlists)
- [https://openfpga.readthedocs.io/en/master/tutorials/design_flow/generate_fabric/#run-openfpga-task](https://openfpga.readthedocs.io/en/master/tutorials/design_flow/generate_fabric/#run-openfpga-task)
- [https://github.com/nandithaec/fpga_workshop_collaterals](https://github.com/nandithaec/fpga_workshop_collaterals)
