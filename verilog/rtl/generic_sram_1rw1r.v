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
module generic_sram_1rw1r #(
  parameter TECHNO = 1           , // TECHNO RAM (0:inferred, 1:SkyWater)
  parameter ASIZE  = 32          , // Size of address bus (bits)
  parameter DSIZE  = 32            // Size of data bus (bits)
)(
`ifdef USE_POWER_PINS
  inout  wire             vccd1  , // User area 1 1.8V supply
  inout  wire             vssd1  , // User area 1 digital ground
`endif
  input  wire             clk    , // Clock (rising edge)

  // Port 0 (R/W)
  input  wire             cs0_n  , // Chip select (active low)
  input  wire             we0_n  , // Write enable (active low)
  input  wire [ASIZE-1:0] addr0  , // Adress bus
  input  wire [DSIZE-1:0] wdata0 , // Data bus (write)
  output wire [DSIZE-1:0] rdata0 , // Data bus (read)

  // Port 1 (R/W)
  input  wire             cs1_n  , // Chip select (active low)
  input  wire [ASIZE-1:0] addr1  , // Adress bus
  output wire [DSIZE-1:0] rdata1   // Data bus (read)
);

generate
  case (TECHNO)
    0 : begin : inferred
      inferred_sram_1rw1r #(
        .ASIZE (ASIZE ),
        .DSIZE (DSIZE )
      ) sram (
        .clk   (clk   ),
        .cs0_n (cs0_n ),
        .we0_n (we0_n ),
        .addr0 (addr0 ),
        .wdata0(wdata0),
        .rdata0(rdata0),
        .cs1_n (cs1_n ),
        .addr1 (addr1 ),
        .rdata1(rdata1)
      );
    end
    1 : begin : skywater
      if (ASIZE == 10) begin
        sky130_sram_1kbyte_1rw1r_8x1024_8 sram (
        `ifdef USE_POWER_PINS
          .vccd1(vccd1),
          .vssd1(vssd1),
        `endif
          .clk0  (clk   ),
          .csb0  (cs0_n ),
          .web0  (we0_n ),
          .wmask0(1'b1  ),
          .addr0 (addr0 ),
          .din0  (wdata0),
          .dout0 (rdata0),
          .clk1  (clk   ),
          .csb1  (cs1_n ),
          .addr1 (addr1 ),
          .dout1 (rdata1)
        );
      end
    end
  endcase
endgenerate


endmodule