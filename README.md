# msvsdfpga

## TASK-1: Generating an RTL supporting 10k LUT count using OpenFPGA

OpenFPGA provides push-button scripts for users to run design flows. Users can customize their flow-run by crafting a task configuration file.

### Prepare the task configuration file

In the task configuration file, you can specify the XML-based architecture files that describe the architecture of the FPGA fabric.
Also, you can specify the openfpga shell script to be executed. Here, we are using an example script (vtr_benchmark_example_script.openfpga) which is golden reference to generate Verilog netlists using VTR-benchmarks. 

To enable the ability write the Verilog netlist for FPGA fabric after completion of the OpenFPGA flow, we add the below line the script (vtr_benchmark_example_script.openfpga):

```
write_fabric_verilog --file ${OPENFPGA_VERILOG_OUTPUT_DIR}/SRC --explicit_port_mapping --include_timing --print_user_defined_template --verbose
```

Now, below is the task.conf file in the vtr_benchmarks where we specify the architecture file and the design (stereovision0.v).

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
power_analysis = false
spice_output=false
verilog_output=true
timeout_each_job = 20*60
fpga_flow=yosys_vpr

[OpenFPGA_SHELL]
openfpga_shell_template=${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_shell_scripts/vtr_benchmark_example_script.openfpga
openfpga_arch_file=${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_arch/k6_frac_N10_adder_chain_dpram8K_dsp36_40nm_openfpga.xml
openfpga_sim_setting_file=${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_simulation_settings/fixed_sim_openfpga.xml
# VPR parameters
# Use a fixed routing channel width to save runtime
vpr_route_chan_width=300
openfpga_vpr_pack_stats_file=vpr_pack_block_usage.txt

[ARCHITECTURES]
arch0=${PATH:OPENFPGA_PATH}/openfpga_flow/vpr_arch/k6_frac_N10_tileable_adder_chain_dpram8K_dsp36_40nm.xml

[BENCHMARKS]
# Official benchmarks from VTR benchmark release
bench0=${PATH:OPENFPGA_PATH}/openfpga_flow/benchmarks/vtr_benchmark/stereovision0.v

[SYNTHESIS_PARAM]
# Yosys script parameters
bench_yosys_cell_sim_verilog_common=${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_yosys_techlib/k6_frac_N10_tileable_adder_chain_dpram8K_dsp36_40nm_cell_sim.v
bench_yosys_bram_map_rules_common=${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_yosys_techlib/k6_frac_N10_tileable_adder_chain_dpram8K_dsp36_40nm_bram.txt
bench_yosys_bram_map_verilog_common=${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_yosys_techlib/k6_frac_N10_tileable_adder_chain_dpram8K_dsp36_40nm_bram_map.v
bench_yosys_dsp_map_verilog_common=${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_yosys_techlib/k6_frac_N10_tileable_adder_chain_dpram8K_dsp36_40nm_dsp_map.v
bench_yosys_dsp_map_parameters_common=-D DSP_A_MAXWIDTH=36 -D DSP_B_MAXWIDTH=36 -D DSP_A_MINWIDTH=2 -D DSP_B_MINWIDTH=2 -D DSP_NAME=mult_36x36
bench_read_verilog_options_common = -nolatches
bench_yosys_common=${PATH:OPENFPGA_PATH}/openfpga_flow/misc/ys_tmpl_yosys_vpr_bram_dsp_flow.ys
# Benchmark ch_intrinsics
bench0_top = sv_chip0_hierarchy_no_mem

[SCRIPT_PARAM_MIN_ROUTE_CHAN_WIDTH]
# end_flow_with_test=
# vpr_fpga_verilog_formal_verification_top_netlist=

```

### Run OpenFPGA Task

After finalizing your configuration file, you can run the task by calling the python script with the given path to task configuration file:

```
python3 openfpga_flow/scripts/run_fpga_task.py openfpga_flow/tasks/benchmark_sweep/vtr_benchmarks
```
Verilog netlists are generated in the following directory:

```
{OPENFPGA_PATH}/openfpga_flow/tasks/benchmark_sweep/vtr_benchmarks/latest/k6_frac_N10_tileable_adder_chain_dpram8K_dsp36_40nm/sv_chip0_hierarchy_no_mem/MIN_ROUTE_CHAN_WIDTH/SRC
```

Below is the final fabric netlists generated in the above path:

![k2](https://user-images.githubusercontent.com/56501917/220191537-0163cb1b-9fd4-46ee-a5e5-fb0f587d722d.png)

And below is the hierarchy of the verilog netlists modelling our FPGA fabric:

![k3](https://user-images.githubusercontent.com/56501917/220191622-3ccefcf0-59de-467c-85c1-4433cd362789.png)



### Checking the LUT-count

Let's jump into the the directory with all the log files:

```
{OPENFPGA_PATH}/openfpga_flow/tasks/benchmark_sweep/vtr_benchmarks/latest/k6_frac_N10_tileable_adder_chain_dpram8K_dsp36_40nm/sv_chip0_hierarchy_no_mem/MIN_ROUTE_CHAN_WIDTH
```
Here; we can see the Circuit-Statistics in the openfpgashell.log

![k1](https://user-images.githubusercontent.com/56501917/220191249-a364e5dd-8425-43cb-9b54-89f0e1bd140a.png)


## References:
- [https://github.com/kunalg123/sky130CircuitDesignWorkshop](https://openfpga.readthedocs.io/en/master/manual/fpga_verilog/fabric_netlist/#top-level-netlists)
- [https://www.vsdiat.com/](https://openfpga.readthedocs.io/en/master/tutorials/design_flow/generate_fabric/#run-openfpga-task)
- [https://github.com/VrushabhDamle/sky130CircuitDesignWorkshop](https://github.com/nandithaec/fpga_workshop_collaterals)
