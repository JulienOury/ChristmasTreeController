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

module wishbone_1mst_to_8slv #(
  parameter [31:0] ADDR_S0 = 32'h00000000 , // Base address of Wishbone SLV 0
  parameter [31:0] MASK_S0 = 32'hFFFFFFFF , // Mask address of Wishbone SLV 0
  parameter [31:0] ADDR_S1 = 32'h00000000 , // Base address of Wishbone SLV 1
  parameter [31:0] MASK_S1 = 32'hFFFFFFFF , // Mask address of Wishbone SLV 1
  parameter [31:0] ADDR_S2 = 32'h00000000 , // Base address of Wishbone SLV 2
  parameter [31:0] MASK_S2 = 32'hFFFFFFFF , // Mask address of Wishbone SLV 2
  parameter [31:0] ADDR_S3 = 32'h00000000 , // Base address of Wishbone SLV 3
  parameter [31:0] MASK_S3 = 32'hFFFFFFFF , // Mask address of Wishbone SLV 3
  parameter [31:0] ADDR_S4 = 32'h00000000 , // Base address of Wishbone SLV 4
  parameter [31:0] MASK_S4 = 32'hFFFFFFFF , // Mask address of Wishbone SLV 4
  parameter [31:0] ADDR_S5 = 32'h00000000 , // Base address of Wishbone SLV 5
  parameter [31:0] MASK_S5 = 32'hFFFFFFFF , // Mask address of Wishbone SLV 5
  parameter [31:0] ADDR_S6 = 32'h00000000 , // Base address of Wishbone SLV 6
  parameter [31:0] MASK_S6 = 32'hFFFFFFFF , // Mask address of Wishbone SLV 6
  parameter [31:0] ADDR_S7 = 32'h00000000 , // Base address of Wishbone SLV 7
  parameter [31:0] MASK_S7 = 32'hFFFFFFFF   // Mask address of Wishbone SLV 7
)(
  
  // Wishbone MST interface
  input  wire           wbs_m_cyc_i  , // Wishbone MST strobe/request
  input  wire           wbs_m_stb_i  , // Wishbone MST strobe/request
  input  wire [31:0]    wbs_m_adr_i  , // Wishbone MST address
  input  wire           wbs_m_we_i   , // Wishbone MST write (1:write, 0:read)
  input  wire [31:0]    wbs_m_dat_i  , // Wishbone MST data output
  input  wire [3:0]     wbs_m_sel_i  , // Wishbone MST byte enable
  output reg  [31:0]    wbs_m_dat_o  , // Wishbone MST data input
  output reg            wbs_m_ack_o  , // Wishbone MST acknowlegement

  // Wishbone SLV 0 interface
  output wire           wbs_s0_cyc_o , // Wishbone SLV 0 strobe/request
  output wire           wbs_s0_stb_o , // Wishbone SLV 0 strobe/request
  output wire [31:0]    wbs_s0_adr_o , // Wishbone SLV 0 address
  output wire           wbs_s0_we_o  , // Wishbone SLV 0 write (1:write, 0:read)
  output wire [31:0]    wbs_s0_dat_o , // Wishbone SLV 0 data output
  output wire [3:0]     wbs_s0_sel_o , // Wishbone SLV 0 byte enable
  input  wire [31:0]    wbs_s0_dat_i , // Wishbone SLV 0 data input
  input  wire           wbs_s0_ack_i , // Wishbone SLV 0 acknowlegement

  // Wishbone SLV 1 interface
  output wire           wbs_s1_cyc_o , // Wishbone SLV 1 strobe/request
  output wire           wbs_s1_stb_o , // Wishbone SLV 1 strobe/request
  output wire [31:0]    wbs_s1_adr_o , // Wishbone SLV 1 address
  output wire           wbs_s1_we_o  , // Wishbone SLV 1 write (1:write, 0:read)
  output wire [31:0]    wbs_s1_dat_o , // Wishbone SLV 1 data output
  output wire [3:0]     wbs_s1_sel_o , // Wishbone SLV 1 byte enable
  input  wire [31:0]    wbs_s1_dat_i , // Wishbone SLV 1 data input
  input  wire           wbs_s1_ack_i , // Wishbone SLV 1 acknowlegement

  // Wishbone SLV 2 interface
  output wire           wbs_s2_cyc_o , // Wishbone SLV 2 strobe/request
  output wire           wbs_s2_stb_o , // Wishbone SLV 2 strobe/request
  output wire [31:0]    wbs_s2_adr_o , // Wishbone SLV 2 address
  output wire           wbs_s2_we_o  , // Wishbone SLV 2 write (1:write, 0:read)
  output wire [31:0]    wbs_s2_dat_o , // Wishbone SLV 2 data output
  output wire [3:0]     wbs_s2_sel_o , // Wishbone SLV 2 byte enable
  input  wire [31:0]    wbs_s2_dat_i , // Wishbone SLV 2 data input
  input  wire           wbs_s2_ack_i , // Wishbone SLV 2 acknowlegement

  // Wishbone SLV 3 interface
  output wire           wbs_s3_cyc_o , // Wishbone SLV 3 strobe/request
  output wire           wbs_s3_stb_o , // Wishbone SLV 3 strobe/request
  output wire [31:0]    wbs_s3_adr_o , // Wishbone SLV 3 address
  output wire           wbs_s3_we_o  , // Wishbone SLV 3 write (1:write, 0:read)
  output wire [31:0]    wbs_s3_dat_o , // Wishbone SLV 3 data output
  output wire [3:0]     wbs_s3_sel_o , // Wishbone SLV 3 byte enable
  input  wire [31:0]    wbs_s3_dat_i , // Wishbone SLV 3 data input
  input  wire           wbs_s3_ack_i , // Wishbone SLV 3 acknowlegement

  // Wishbone SLV 4 interface
  output wire           wbs_s4_cyc_o , // Wishbone SLV 4 strobe/request
  output wire           wbs_s4_stb_o , // Wishbone SLV 4 strobe/request
  output wire [31:0]    wbs_s4_adr_o , // Wishbone SLV 4 address
  output wire           wbs_s4_we_o  , // Wishbone SLV 4 write (1:write, 0:read)
  output wire [31:0]    wbs_s4_dat_o , // Wishbone SLV 4 data output
  output wire [3:0]     wbs_s4_sel_o , // Wishbone SLV 4 byte enable
  input  wire [31:0]    wbs_s4_dat_i , // Wishbone SLV 4 data input
  input  wire           wbs_s4_ack_i , // Wishbone SLV 4 acknowlegement

  // Wishbone SLV 5 interface
  output wire           wbs_s5_cyc_o , // Wishbone SLV 5 strobe/request
  output wire           wbs_s5_stb_o , // Wishbone SLV 5 strobe/request
  output wire [31:0]    wbs_s5_adr_o , // Wishbone SLV 5 address
  output wire           wbs_s5_we_o  , // Wishbone SLV 5 write (1:write, 0:read)
  output wire [31:0]    wbs_s5_dat_o , // Wishbone SLV 5 data output
  output wire [3:0]     wbs_s5_sel_o , // Wishbone SLV 5 byte enable
  input  wire [31:0]    wbs_s5_dat_i , // Wishbone SLV 5 data input
  input  wire           wbs_s5_ack_i , // Wishbone SLV 5 acknowlegement

  // Wishbone SLV 6 interface
  output wire           wbs_s6_cyc_o , // Wishbone SLV 6 strobe/request
  output wire           wbs_s6_stb_o , // Wishbone SLV 6 strobe/request
  output wire [31:0]    wbs_s6_adr_o , // Wishbone SLV 6 address
  output wire           wbs_s6_we_o  , // Wishbone SLV 6 write (1:write, 0:read)
  output wire [31:0]    wbs_s6_dat_o , // Wishbone SLV 6 data output
  output wire [3:0]     wbs_s6_sel_o , // Wishbone SLV 6 byte enable
  input  wire [31:0]    wbs_s6_dat_i , // Wishbone SLV 6 data input
  input  wire           wbs_s6_ack_i , // Wishbone SLV 6 acknowlegement

  // Wishbone SLV 7 interface
  output wire           wbs_s7_cyc_o , // Wishbone SLV 7 strobe/request
  output wire           wbs_s7_stb_o , // Wishbone SLV 7 strobe/request
  output wire [31:0]    wbs_s7_adr_o , // Wishbone SLV 7 address
  output wire           wbs_s7_we_o  , // Wishbone SLV 7 write (1:write, 0:read)
  output wire [31:0]    wbs_s7_dat_o , // Wishbone SLV 7 data output
  output wire [3:0]     wbs_s7_sel_o , // Wishbone SLV 7 byte enable
  input  wire [31:0]    wbs_s7_dat_i , // Wishbone SLV 7 data input
  input  wire           wbs_s7_ack_i   // Wishbone SLV 7 acknowlegement

);

  wire [7:0] selected;

  assign selected[0] = ((wbs_m_adr_i & MASK_S0) == (ADDR_S0 & MASK_S0)) ? 1'b1 : 1'b0;
  assign selected[1] = ((wbs_m_adr_i & MASK_S1) == (ADDR_S1 & MASK_S1)) ? 1'b1 : 1'b0;
  assign selected[2] = ((wbs_m_adr_i & MASK_S2) == (ADDR_S2 & MASK_S2)) ? 1'b1 : 1'b0;
  assign selected[3] = ((wbs_m_adr_i & MASK_S3) == (ADDR_S3 & MASK_S3)) ? 1'b1 : 1'b0;
  assign selected[4] = ((wbs_m_adr_i & MASK_S4) == (ADDR_S4 & MASK_S4)) ? 1'b1 : 1'b0;
  assign selected[5] = ((wbs_m_adr_i & MASK_S5) == (ADDR_S5 & MASK_S5)) ? 1'b1 : 1'b0;
  assign selected[6] = ((wbs_m_adr_i & MASK_S6) == (ADDR_S6 & MASK_S6)) ? 1'b1 : 1'b0;
  assign selected[7] = ((wbs_m_adr_i & MASK_S7) == (ADDR_S7 & MASK_S7)) ? 1'b1 : 1'b0;

  assign wbs_s0_cyc_o = (selected[0] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s1_cyc_o = (selected[1] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s2_cyc_o = (selected[2] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s3_cyc_o = (selected[3] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s4_cyc_o = (selected[4] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s5_cyc_o = (selected[5] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s6_cyc_o = (selected[6] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s7_cyc_o = (selected[7] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  
  assign wbs_s0_stb_o = (selected[0] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s1_stb_o = (selected[1] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s2_stb_o = (selected[2] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s3_stb_o = (selected[3] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s4_stb_o = (selected[4] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s5_stb_o = (selected[5] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s6_stb_o = (selected[6] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s7_stb_o = (selected[7] == 1'b1) ? wbs_m_stb_i : 1'b0;
  
  assign wbs_s0_adr_o = wbs_m_adr_i;
  assign wbs_s1_adr_o = wbs_m_adr_i;
  assign wbs_s2_adr_o = wbs_m_adr_i;
  assign wbs_s3_adr_o = wbs_m_adr_i;
  assign wbs_s4_adr_o = wbs_m_adr_i;
  assign wbs_s5_adr_o = wbs_m_adr_i;
  assign wbs_s6_adr_o = wbs_m_adr_i;
  assign wbs_s7_adr_o = wbs_m_adr_i;
  
  assign wbs_s0_we_o = wbs_m_we_i;
  assign wbs_s1_we_o = wbs_m_we_i;
  assign wbs_s2_we_o = wbs_m_we_i;
  assign wbs_s3_we_o = wbs_m_we_i;
  assign wbs_s4_we_o = wbs_m_we_i;
  assign wbs_s5_we_o = wbs_m_we_i;
  assign wbs_s6_we_o = wbs_m_we_i;
  assign wbs_s7_we_o = wbs_m_we_i;
  
  assign wbs_s0_dat_o = wbs_m_dat_i;
  assign wbs_s1_dat_o = wbs_m_dat_i;
  assign wbs_s2_dat_o = wbs_m_dat_i;
  assign wbs_s3_dat_o = wbs_m_dat_i;
  assign wbs_s4_dat_o = wbs_m_dat_i;
  assign wbs_s5_dat_o = wbs_m_dat_i;
  assign wbs_s6_dat_o = wbs_m_dat_i;
  assign wbs_s7_dat_o = wbs_m_dat_i;
  
  assign wbs_s0_sel_o = wbs_m_sel_i;
  assign wbs_s1_sel_o = wbs_m_sel_i;
  assign wbs_s2_sel_o = wbs_m_sel_i;
  assign wbs_s3_sel_o = wbs_m_sel_i;
  assign wbs_s4_sel_o = wbs_m_sel_i;
  assign wbs_s5_sel_o = wbs_m_sel_i;
  assign wbs_s6_sel_o = wbs_m_sel_i;
  assign wbs_s7_sel_o = wbs_m_sel_i;

  always @(*) begin
      case (selected)
      8'b10000000 : begin
        wbs_m_dat_o  <= wbs_s7_dat_i;
        wbs_m_ack_o  <= wbs_s7_ack_i;
      end
      8'b01000000 : begin
        wbs_m_dat_o  <= wbs_s6_dat_i;
        wbs_m_ack_o  <= wbs_s6_ack_i;
      end
      8'b00100000 : begin
        wbs_m_dat_o  <= wbs_s5_dat_i;
        wbs_m_ack_o  <= wbs_s5_ack_i;
      end
      8'b00010000 : begin
        wbs_m_dat_o  <= wbs_s4_dat_i;
        wbs_m_ack_o  <= wbs_s4_ack_i;
      end
      8'b00001000 : begin
        wbs_m_dat_o  <= wbs_s3_dat_i;
        wbs_m_ack_o  <= wbs_s3_ack_i;
      end
      8'b00000100 : begin
        wbs_m_dat_o  <= wbs_s2_dat_i;
        wbs_m_ack_o  <= wbs_s2_ack_i;
      end
      8'b00000010 : begin
        wbs_m_dat_o  <= wbs_s1_dat_i;
        wbs_m_ack_o  <= wbs_s1_ack_i;
      end
      default : begin
        wbs_m_dat_o  <= wbs_s0_dat_i;
        wbs_m_ack_o  <= wbs_s0_ack_i;
      end
    endcase
  end

endmodule