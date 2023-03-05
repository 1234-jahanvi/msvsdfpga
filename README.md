# msvsdfpga

## TASK-1: Generating an RTL supporting 10k LUT count using OpenFPGA

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

## References:
- [https://openfpga.readthedocs.io/en/master/manual/fpga_verilog/fabric_netlist/#top-level-netlists](https://openfpga.readthedocs.io/en/master/manual/fpga_verilog/fabric_netlist/#top-level-netlists)
- [https://openfpga.readthedocs.io/en/master/tutorials/design_flow/generate_fabric/#run-openfpga-task](https://openfpga.readthedocs.io/en/master/tutorials/design_flow/generate_fabric/#run-openfpga-task)
- [https://github.com/nandithaec/fpga_workshop_collaterals](https://github.com/nandithaec/fpga_workshop_collaterals)
