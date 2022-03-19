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
module inferred_sram_1rw1r #(
  parameter ASIZE  = 32          , // Size of address bus (bits)
  parameter DSIZE  = 32            // Size of data bus (bits)
)(
  input  wire             clk    , // Clock (rising edge)

  // Port 0 (R/W)
  input  wire             cs0_n  , // Chip select (active low)
  input  wire             we0_n  , // Write enable (active low)
  input  wire [ASIZE-1:0] addr0  , // Adress bus
  input  wire [DSIZE-1:0] wdata0 , // Data bus (write)
  output reg  [DSIZE-1:0] rdata0 , // Data bus (read)

  // Port 1 (R/W)
  input  wire             cs1_n  , // Chip select (active low)
  input  wire [ASIZE-1:0] addr1  , // Adress bus
  output reg  [DSIZE-1:0] rdata1   // Data bus (read)
);

  reg              r_cs0_n ;
  reg              r_we0_n ;
  reg  [ASIZE-1:0] r_addr0 ;
  reg  [DSIZE-1:0] r_wdata0;
  reg              r_cs1_n ;
  reg  [ASIZE-1:0] r_addr1 ;
  reg  [DSIZE-1:0] memory[(2**ASIZE)-1:0];

  // Registers inputs
  always @(posedge clk) begin
    r_cs0_n  <= cs0_n ;
    r_we0_n  <= we0_n ;
    r_addr0  <= addr0 ;
    r_wdata0 <= wdata0;
    r_cs1_n  <= cs1_n ;
    r_addr1  <= addr1 ;
  end

  // Port 0 : Write operation
  always @(posedge clk) begin
    if (!r_cs0_n && !r_we0_n) begin
      memory[r_addr0] <= r_wdata0;
    end
  end

  // Port 0 : Read operation
  always @(posedge clk) begin
    if (!r_cs0_n && r_we0_n) begin
      rdata0 <= memory[r_addr0];
    end
  end

  // Port 1 : Read operation
  always @(posedge clk) begin
    if (!r_cs1_n) begin
      rdata1 <= memory[r_addr1];
    end
  end

endmodule