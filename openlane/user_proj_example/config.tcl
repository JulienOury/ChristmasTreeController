# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_proj_example

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_proj_example.v \
	$script_dir/../../verilog/rtl/wishbone_1mst_to_4slv.v \
	$script_dir/../../verilog/rtl/prescaler.v \
	$script_dir/../../verilog/rtl/simple_fifo.v \
	$script_dir/../../verilog/rtl/nec_ir_receiver.v \
	$script_dir/../../verilog/rtl/pseudorandom.v \
	$script_dir/../../verilog/rtl/step_motor_controller.v \
	$script_dir/../../verilog/rtl/string_led_controller.v \
	$script_dir/../../verilog/rtl/generic_sram_1rw1r_8x1024.v"

set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT)   "wb_clk_i"
set ::env(CLOCK_NET)    "nec_ir_receiver.clk"
set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1250 1250"

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY)  0.30

set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"

## Internal Macros
### Macro PDN Connections
set ::env(FP_PDN_MACRO_HOOKS) "\
	i_string_led_controller.i_memory.skywater.sram vccd1 vssd1"

### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro.cfg

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/verilog/sky130_sram_1kbyte_1rw1r_8x1024_8.v"

set ::env(EXTRA_LEFS) "\
	$::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_8x1024_8.lef"

set ::env(EXTRA_GDS_FILES) "\
	$::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_8x1024_8.gds"
	
set ::env(EXTRA_LIBS) "\
    $::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/lib/sky130_sram_1kbyte_1rw1r_8x1024_8_TT_1p8V_25C.lib"

# Maximum layer used for routing is metal 4.
# This is because this macro will be inserted in a top level (user_project_wrapper) 
# where the PDN is planned on metal 5. So, to avoid having shorts between routes
# in this macro and the top level metal 5 stripes, we have to restrict routes to metal4.  
# 
#set ::env(GLB_RT_MAXLAYER) 5
set ::env(RT_MAX_LAYER) {met4}

# You can draw more power domains if you need to 
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(DIODE_INSERTION_STRATEGY) 4 
# If you're going to use multiple power domains, then disable cvc run.
set ::env(RUN_CVC) 1
