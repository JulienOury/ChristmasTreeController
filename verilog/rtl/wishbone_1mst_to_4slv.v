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

module wishbone_1mst_to_4slv #(
  parameter [31:0] ADDR_S0 = 32'h30000000 , // Base address of Wishbone SLV 0
  parameter [31:0] MASK_S0 = 32'hFFFF0000 , // Mask address of Wishbone SLV 0
  parameter [31:0] ADDR_S1 = 32'h30010000 , // Base address of Wishbone SLV 1
  parameter [31:0] MASK_S1 = 32'hFFFF0000 , // Mask address of Wishbone SLV 1
  parameter [31:0] ADDR_S2 = 32'h30020000 , // Base address of Wishbone SLV 2
  parameter [31:0] MASK_S2 = 32'hFFFF0000 , // Mask address of Wishbone SLV 2
  parameter [31:0] ADDR_S3 = 32'h30030000 , // Base address of Wishbone SLV 3
  parameter [31:0] MASK_S3 = 32'hFFFF0000   // Mask address of Wishbone SLV 3
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
  input  wire           wbs_s3_ack_i   // Wishbone SLV 3 acknowlegement

);

  wire [3:0] selected;

  assign selected[0] = ((wbs_m_adr_i & MASK_S0) == (ADDR_S0 & MASK_S0)) ? 1'b1 : 1'b0;
  assign selected[1] = ((wbs_m_adr_i & MASK_S1) == (ADDR_S1 & MASK_S1)) ? 1'b1 : 1'b0;
  assign selected[2] = ((wbs_m_adr_i & MASK_S2) == (ADDR_S2 & MASK_S2)) ? 1'b1 : 1'b0;
  assign selected[3] = ((wbs_m_adr_i & MASK_S3) == (ADDR_S3 & MASK_S3)) ? 1'b1 : 1'b0;

  assign wbs_s0_cyc_o = (selected[0] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s1_cyc_o = (selected[1] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s2_cyc_o = (selected[2] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  assign wbs_s3_cyc_o = (selected[3] == 1'b1) ? wbs_m_cyc_i : 1'b0;
  
  assign wbs_s0_stb_o = (selected[0] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s1_stb_o = (selected[1] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s2_stb_o = (selected[2] == 1'b1) ? wbs_m_stb_i : 1'b0;
  assign wbs_s3_stb_o = (selected[3] == 1'b1) ? wbs_m_stb_i : 1'b0;
  
  assign wbs_s0_adr_o = wbs_m_adr_i;
  assign wbs_s1_adr_o = wbs_m_adr_i;
  assign wbs_s2_adr_o = wbs_m_adr_i;
  assign wbs_s3_adr_o = wbs_m_adr_i;
  
  assign wbs_s0_we_o = wbs_m_we_i;
  assign wbs_s1_we_o = wbs_m_we_i;
  assign wbs_s2_we_o = wbs_m_we_i;
  assign wbs_s3_we_o = wbs_m_we_i;
  
  assign wbs_s0_dat_o = wbs_m_dat_i;
  assign wbs_s1_dat_o = wbs_m_dat_i;
  assign wbs_s2_dat_o = wbs_m_dat_i;
  assign wbs_s3_dat_o = wbs_m_dat_i;
  
  assign wbs_s0_sel_o = wbs_m_sel_i;
  assign wbs_s1_sel_o = wbs_m_sel_i;
  assign wbs_s2_sel_o = wbs_m_sel_i;
  assign wbs_s3_sel_o = wbs_m_sel_i;

  always @(*) begin
      case (selected)
      4'b1000 : begin
        wbs_m_dat_o  <= wbs_s3_dat_i;
        wbs_m_ack_o  <= wbs_s3_ack_i;
      end
      4'b0100 : begin
        wbs_m_dat_o  <= wbs_s2_dat_i;
        wbs_m_ack_o  <= wbs_s2_ack_i;
      end
      4'b0010 : begin
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