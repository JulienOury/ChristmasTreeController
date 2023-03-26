////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2022 , Julien OURY                       
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Created by Julien OURY <julien.oury@outlook.fr>
//
////////////////////////////////////////////////////////////////////////////

module user_proj_example(

`ifdef USE_POWER_PINS
    inout  wire vccd1,  // User area 1 1.8V supply
    inout  wire vssd1,  // User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input  wire         wb_clk_i,
    input  wire         wb_rst_i,
    input  wire         wbs_stb_i,
    input  wire         wbs_cyc_i,
    input  wire         wbs_we_i,
    input  wire [3:0]   wbs_sel_i,
    input  wire [31:0]  wbs_dat_i,
    input  wire [31:0]  wbs_adr_i,
    output wire         wbs_ack_o,
    output wire [31:0]  wbs_dat_o,

    // Logic Analyzer Signals
    input  wire [127:0] la_data_in,
    output wire [127:0] la_data_out,
    input  wire [127:0] la_oenb,

    // IOs
    input  wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output wire [2:0] irq
);

  wire rst_n;
  
  // Wishbone SLV 0 interface
  wire           wbs_s0_cyc_o ;
  wire           wbs_s0_stb_o ;
  wire [31:0]    wbs_s0_adr_o ;
  wire           wbs_s0_we_o  ;
  wire [31:0]    wbs_s0_dat_o ;
  wire [3:0]     wbs_s0_sel_o ;
  wire [31:0]    wbs_s0_dat_i ;
  wire           wbs_s0_ack_i ;
  
  // Wishbone SLV 1 interface
  wire           wbs_s1_cyc_o ;
  wire           wbs_s1_stb_o ;
  wire [31:0]    wbs_s1_adr_o ;
  wire           wbs_s1_we_o  ;
  wire [31:0]    wbs_s1_dat_o ;
  wire [3:0]     wbs_s1_sel_o ;
  wire [31:0]    wbs_s1_dat_i ;
  wire           wbs_s1_ack_i ;
  
  // Wishbone SLV 2 interface
  wire           wbs_s2_cyc_o ;
  wire           wbs_s2_stb_o ;
  wire [31:0]    wbs_s2_adr_o ;
  wire           wbs_s2_we_o  ;
  wire [31:0]    wbs_s2_dat_o ;
  wire [3:0]     wbs_s2_sel_o ;
  wire [31:0]    wbs_s2_dat_i ;
  wire           wbs_s2_ack_i ;
  
  
  // Wishbone SLV 3 interface
  wire           wbs_s3_cyc_o ;
  wire           wbs_s3_stb_o ;
  wire [31:0]    wbs_s3_adr_o ;
  wire           wbs_s3_we_o  ;
  wire [31:0]    wbs_s3_dat_o ;
  wire [3:0]     wbs_s3_sel_o ;
  wire [31:0]    wbs_s3_dat_i ;
  wire           wbs_s3_ack_i ;
  
  // IO
  assign io_out[37]    =       1'b0  ;
  assign io_out[31: 0] = {(32){1'b0}};

  assign io_oeb[37]    =       1'b1  ;
  assign io_oeb[36]    =       1'b0  ; // String LED outputs
  assign io_oeb[35:32] = {( 4){1'b0}}; // MOTOR outputs
  assign io_oeb[31: 0] = {(32){1'b1}};
  
  // LA
  assign la_data_out = {(128){1'b0}};
  
  assign irq[2] = 1'b0;
  
  assign rst_n = ~wb_rst_i;
  
  wishbone_1mst_to_4slv #(
    .ADDR_S0(32'h30000000), // Base address of Wishbone SLV 0
    .MASK_S0(32'hFFFF0000), // Mask address of Wishbone SLV 0
    .ADDR_S1(32'h30010000), // Base address of Wishbone SLV 1
    .MASK_S1(32'hFFFF0000), // Mask address of Wishbone SLV 1
    .ADDR_S2(32'h30020000), // Base address of Wishbone SLV 2
    .MASK_S2(32'hFFFF0000), // Mask address of Wishbone SLV 2
    .ADDR_S3(32'h30030000), // Base address of Wishbone SLV 3
    .MASK_S3(32'hFFFF0000)  // Mask address of Wishbone SLV 3
  ) i_wishbone_1mst_to_4slv (
  
    // Wishbone MST interface
    .wbs_m_cyc_i(wbs_cyc_i),
    .wbs_m_stb_i(wbs_stb_i),
    .wbs_m_adr_i(wbs_adr_i),
    .wbs_m_we_i (wbs_we_i ),
    .wbs_m_dat_i(wbs_dat_i),
    .wbs_m_sel_i(wbs_sel_i),
    .wbs_m_dat_o(wbs_dat_o),
    .wbs_m_ack_o(wbs_ack_o),
  
    // Wishbone SLV 0 interface
    .wbs_s0_cyc_o(wbs_s0_cyc_o),
    .wbs_s0_stb_o(wbs_s0_stb_o),
    .wbs_s0_adr_o(wbs_s0_adr_o),
    .wbs_s0_we_o (wbs_s0_we_o ),
    .wbs_s0_dat_o(wbs_s0_dat_o),
    .wbs_s0_sel_o(wbs_s0_sel_o),
    .wbs_s0_dat_i(wbs_s0_dat_i),
    .wbs_s0_ack_i(wbs_s0_ack_i),
  
    // Wishbone SLV 1 interface
    .wbs_s1_cyc_o(wbs_s1_cyc_o),
    .wbs_s1_stb_o(wbs_s1_stb_o),
    .wbs_s1_adr_o(wbs_s1_adr_o),
    .wbs_s1_we_o (wbs_s1_we_o ),
    .wbs_s1_dat_o(wbs_s1_dat_o),
    .wbs_s1_sel_o(wbs_s1_sel_o),
    .wbs_s1_dat_i(wbs_s1_dat_i),
    .wbs_s1_ack_i(wbs_s1_ack_i),
  
    // Wishbone SLV 2 interface
    .wbs_s2_cyc_o(wbs_s2_cyc_o),
    .wbs_s2_stb_o(wbs_s2_stb_o),
    .wbs_s2_adr_o(wbs_s2_adr_o),
    .wbs_s2_we_o (wbs_s2_we_o ),
    .wbs_s2_dat_o(wbs_s2_dat_o),
    .wbs_s2_sel_o(wbs_s2_sel_o),
    .wbs_s2_dat_i(wbs_s2_dat_i),
    .wbs_s2_ack_i(wbs_s2_ack_i),
  
    // Wishbone SLV 3 interface
    .wbs_s3_cyc_o(wbs_s3_cyc_o),
    .wbs_s3_stb_o(wbs_s3_stb_o),
    .wbs_s3_adr_o(wbs_s3_adr_o),
    .wbs_s3_we_o (wbs_s3_we_o ),
    .wbs_s3_dat_o(wbs_s3_dat_o),
    .wbs_s3_sel_o(wbs_s3_sel_o),
    .wbs_s3_dat_i(wbs_s3_dat_i),
    .wbs_s3_ack_i(wbs_s3_ack_i)
  );
  
  nec_ir_receiver #(
    .NB_STAGES (10),
    .PSIZE     (20),
    .DSIZE     (11),
    .ASIZE     ( 4)
  ) i_nec_ir_receiver (
    .rst_n    (rst_n       ),
    .clk      (wb_clk_i    ),
    .wbs_cyc_i(wbs_s0_cyc_o),
    .wbs_stb_i(wbs_s0_stb_o),
    .wbs_adr_i(wbs_s0_adr_o),
    .wbs_we_i (wbs_s0_we_o ),
    .wbs_dat_i(wbs_s0_dat_o),
    .wbs_sel_i(wbs_s0_sel_o),
    .wbs_dat_o(wbs_s0_dat_i),
    .wbs_ack_o(wbs_s0_ack_i),
    .ir_in    (io_in[37]   ),
    .irq      (irq[0]      )
  );
  
  pseudorandom i_pseudorandom (
    .rst_n     (rst_n       ),
    .clk       (wb_clk_i    ),

    // Wishbone bus
    .wbs_cyc_i (wbs_s1_cyc_o),
    .wbs_stb_i (wbs_s1_stb_o),
    .wbs_adr_i (wbs_s1_adr_o),
    .wbs_we_i  (wbs_s1_we_o ),
    .wbs_dat_i (wbs_s1_dat_o),
    .wbs_sel_i (wbs_s1_sel_o),
    .wbs_dat_o (wbs_s1_dat_i),
    .wbs_ack_o (wbs_s1_ack_i) 
  );
  
  step_motor_controller #(
    .PSIZE(20),
    .DSIZE(20)
  ) i_step_motor_controller (
  
    .rst_n     (rst_n       ),
    .clk       (wb_clk_i    ),
  
    // Wishbone bus
    .wbs_cyc_i (wbs_s2_cyc_o),
    .wbs_stb_i (wbs_s2_stb_o),
    .wbs_adr_i (wbs_s2_adr_o),
    .wbs_we_i  (wbs_s2_we_o ),
    .wbs_dat_i (wbs_s2_dat_o),
    .wbs_sel_i (wbs_s2_sel_o),
    .wbs_dat_o (wbs_s2_dat_i),
    .wbs_ack_o (wbs_s2_ack_i),
  
    // Motor outputs
    .motor_a1  (io_out[35]),
    .motor_a2  (io_out[34]),
    .motor_b1  (io_out[33]),
    .motor_b2  (io_out[32])
  );
  
  string_led_controller #(
    .TECHNO( 0),
    .ASIZE ( 6),
    .PSIZE (20)
  ) i_string_led_controller (
`ifdef USE_POWER_PINS
	.vccd1     (vccd1       ),
	.vssd1     (vssd1       ),
`endif
    .rst_n     (rst_n       ),
    .clk       (wb_clk_i    ),
    .wbs_cyc_i (wbs_s3_cyc_o),
    .wbs_stb_i (wbs_s3_stb_o),
    .wbs_adr_i (wbs_s3_adr_o),
    .wbs_we_i  (wbs_s3_we_o ),
    .wbs_dat_i (wbs_s3_dat_o),
    .wbs_sel_i (wbs_s3_sel_o),
    .wbs_dat_o (wbs_s3_dat_i),
    .wbs_ack_o (wbs_s3_ack_i),
    .irq       (irq[1]      ),
    .sout      (io_out[36]  )
  );

endmodule
