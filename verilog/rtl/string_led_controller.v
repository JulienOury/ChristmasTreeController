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

module string_led_controller #(
  parameter TECHNO =  1        , // TECHNO RAM (0:inferred, 1:SkyWater)
  parameter PSIZE  = 32          // Size of prescaler counter(bits)
)(
`ifdef USE_POWER_PINS
  inout  wire        vccd1     , // User area 1 1.8V supply
  inout  wire        vssd1     , // User area 1 digital ground
`endif

  input  wire        rst_n     , // Asynchronous reset (active low)
  input  wire        clk       , // Clock (rising edge)

  // Wishbone bus
  input  wire        wbs_cyc_i , // Wishbone strobe/request
  input  wire        wbs_stb_i , // Wishbone strobe/request
  input  wire [31:0] wbs_adr_i , // Wishbone address
  input  wire        wbs_we_i  , // Wishbone write (1:write, 0:read)
  input  wire [31:0] wbs_dat_i , // Wishbone data output
  input  wire [3:0]  wbs_sel_i , // Wishbone byte enable
  output wire [31:0] wbs_dat_o , // Wishbone data input
  output wire        wbs_ack_o , // Wishbone acknowlegement

  // Interrupt
  output wire        irq       , // Interrupt

  // Output serial
  output wire        sout        // Serial out

);

  wire             controller_en   ;
  wire [PSIZE-1:0] multiplier      ;
  wire [PSIZE-1:0] divider         ;
  wire             tick            ;
  wire             valid           ;
  wire             polarity        ;
  wire             bit_value       ;
  wire             ready           ;
  wire [9:0]       w_first         ;
  wire [9:0]       w_last          ;
  wire             start           ;
  wire             progress        ;

  wire             cs0_n           ;
  wire             we0_n           ;
  wire [9:0]       addr0           ;
  wire [7:0]       wdata0          ;
  wire [7:0]       rdata0          ;
  wire             cs1_n           ;
  wire [9:0]       addr1           ;
  wire [7:0]       rdata1          ;
  
  

  prescaler #(
    .BITS(PSIZE)
  ) i_prescaler (
    .rst_n      (rst_n         ),
    .clk        (clk           ),
    .clear_n    (controller_en ),
    .multiplier (multiplier    ),
    .divider    (divider       ),
    .tick       (tick          )
  );
  
  bit_generator i_bit_generator (
    .rst_n      (rst_n         ),
    .clk        (clk           ),
    .clear_n    (controller_en ),
    .tick       (tick          ),
    .polarity   (polarity      ),
    .bit_value  (bit_value     ),
    .valid      (valid         ),
    .ready      (ready         ),
    .sout       (sout          )
  );
  
  string_led_sequencer i_sequencer(
    .rst_n      (rst_n         ),
    .clk        (clk           ),
    .clear_n    (controller_en ),
    
    // Configuration/management
    .w_first    (w_first       ),
    .w_last     (w_last        ),
    .start      (start         ),
    .progress   (progress      ),
    
    // Memory port   
    .cs_n       (cs1_n         ),
    .addr       (addr1         ),
    .rdata      (rdata1        ),
    
    // Outut data
    .bit_value  (bit_value     ),
    .valid      (valid         ),
    .ready      (ready         )
  );
  
  generic_sram_1rw1r_8x1024 #(
    .TECHNO(TECHNO)
  ) i_memory (
  `ifdef USE_POWER_PINS
    .vccd1    (vccd1 ),
    .vssd1    (vssd1 ),
  `endif
    .clk      (clk   ),
  
    // Port 0 (R/W)   
    .cs0_n    (cs0_n ),
    .we0_n    (we0_n ),
    .addr0    (addr0 ),
    .wdata0   (wdata0),
    .rdata0   (rdata0),
  
    // Port 1 (R/W)   
    .cs1_n    (cs1_n ),
    .addr1    (addr1 ),
    .rdata1   (rdata1)
  );

  string_led_registers #(
    .PSIZE(PSIZE)
  ) i_registers (
    .rst_n           (rst_n        ),
    .clk             (clk          ),
    .controller_en   (controller_en),
    .multiplier      (multiplier   ),
    .divider         (divider      ),
    .polarity        (polarity     ),
    .w_first         (w_first      ),
    .w_last          (w_last       ),
    .start           (start        ),
    .progress        (progress     ),
    .wbs_cyc_i       (wbs_cyc_i    ),
    .wbs_stb_i       (wbs_stb_i    ),
    .wbs_adr_i       (wbs_adr_i    ),
    .wbs_we_i        (wbs_we_i     ),
    .wbs_dat_i       (wbs_dat_i    ),
    .wbs_sel_i       (wbs_sel_i    ),
    .wbs_dat_o       (wbs_dat_o    ),
    .wbs_ack_o       (wbs_ack_o    ),
    .irq             (irq          ),
    .cs_n            (cs0_n        ),
    .we_n            (we0_n        ),
    .addr            (addr0        ),
    .wdata           (wdata0       ),
    .rdata           (rdata0       )
  );

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Bit generator
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module bit_generator (
  input  wire  rst_n      , // Asynchronous reset (active low)
  input  wire  clk        , // Clock (rising edge)
  input  wire  clear_n    , // Synchronous reset (active low)
  input  wire  tick       , // 50ms tick input

  input  wire  polarity   , // Polarity of output signal
  
  input  wire  bit_value  , // Bit value
  input  wire  valid      , // Valid bit value (active high)
  output reg   ready      , // Serial output
  
  output reg   sout         // Serial output
);

  localparam val_p  = 5'b11000; //24
  localparam val_1  = 5'b10000; //16
  localparam val_0  = 5'b01000; // 8

  reg [4:0]  count;
  reg        dbit ;
  reg        polar;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      count <= val_p;
      ready <= 1'b0;
      dbit  <= 1'b0;
      polar <= 1'b0;
      sout  <= 1'b0;
    end else begin
    
      if (clear_n == 1'b0) begin
        count <= val_p;
        ready <= 1'b0;
        dbit  <= 1'b0;
        polar <= 1'b0;
        sout  <= 1'b0;
      end else begin

        if (tick == 1'b1) begin
          if (count[4:3] == 2'b11) begin
            if (valid == 1'b1) begin
              count <= 5'b00000;
              dbit  <= bit_value;
              polar <= polarity;
            end
          end else begin
            count <= count + 1'b1;
          end
        end
        
        if ((tick == 1'b1) && (count[4:3] == 2'b11) && (valid == 1'b1)) begin
          ready <= 1'b1;
        end else begin
          ready <= 1'b0;
        end
        
        if (((dbit == 1'b0) && ((count[4] == 1'b1) || (count[3] == 1'b1))) ||
            ((dbit == 1'b1) &&  (count[4] == 1'b1)                       ) ) begin
          sout <= polar;
        end else begin
          sout <= ~polar;
        end
      end
    end
  end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// String LED sequencer
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module string_led_sequencer (
  input  wire       rst_n    , // Asynchronous reset (active low)
  input  wire       clk      , // Clock (rising edge)
  input  wire       clear_n  , // Synchronous reset (active low)
  
  // Configuration/management
  input  wire [9:0] w_first  , // First word index
  input  wire [9:0] w_last   , // Last word index
  input  wire       start    , // Start strobe (active high)
  output wire       progress , // Progress status
  
  // Memory port   
  output wire       cs_n     , // Chip select (active low)
  output reg  [9:0] addr     , // Adress bus
  input  wire [7:0] rdata    , // Data bus (read)
  
  // Outut data
  output reg        bit_value, // Bit value
  output reg        valid    , // Data valid (active high)
  input  wire       ready      // Data read (active high)

);

  localparam
    idle_state       = 4'b0000,
    ram_ctrl_state   = 4'b0001,
    ram_wait_state   = 4'b0010,
    ram_read_state   = 4'b0011,
    send_bit7_state  = 4'b0100,
    send_bit6_state  = 4'b0101,
    send_bit5_state  = 4'b0110,
    send_bit4_state  = 4'b0111,
    send_bit3_state  = 4'b1000,
    send_bit2_state  = 4'b1001,
    send_bit1_state  = 4'b1010,
    send_bit0_state  = 4'b1011,
    idle_a_state     = 4'b1100,
    idle_b_state     = 4'b1101,
    idle_c_state     = 4'b1110,
    idle_d_state     = 4'b1111;

  
  wire [9:0]  next_addr;
  reg  [9:0]  last_addr;
  reg  [7:0]  data;
  reg  [3:0]  state_reg;
  
  assign next_addr = addr + 1'b1;

  // Frame decoder
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      state_reg  <= idle_state;
      addr       <= 10'b0000000000;
      last_addr  <= 10'b0000000000;
      data       <= 8'b00000000;
    end else begin
    
      if (clear_n == 1'b0) begin
        state_reg  <= idle_state;
        addr       <= 10'b0000000000;
        last_addr  <= 10'b0000000000;
        data       <= 8'b00000000;
      end else begin
    
        case(state_reg)
          idle_state,
          idle_a_state,
          idle_b_state,
          idle_c_state,
          idle_d_state:
          begin
            if (start) begin
              state_reg <= ram_ctrl_state;
              addr      <= w_first;
              last_addr <= w_last;
            end
          end
          ram_ctrl_state: begin
            state_reg <= ram_wait_state;
          end
          ram_wait_state: begin
            state_reg <= ram_read_state;
          end
          ram_read_state: begin
            data      <= rdata;
            state_reg <= send_bit7_state;
          end
          send_bit7_state: begin
            if (ready) begin
              state_reg <= send_bit6_state;
            end
          end
          send_bit6_state: begin
            if (ready) begin
              state_reg <= send_bit5_state;
            end
          end
          send_bit5_state: begin
            if (ready) begin
              state_reg <= send_bit4_state;
            end
          end
          send_bit4_state: begin
            if (ready) begin
              state_reg <= send_bit3_state;
            end
          end
          send_bit3_state: begin
            if (ready) begin
              state_reg <= send_bit2_state;
            end
          end
          send_bit2_state: begin
            if (ready) begin
              state_reg <= send_bit1_state;
            end
          end
          send_bit1_state: begin
            if (ready) begin
              state_reg <= send_bit0_state;
            end
          end
          send_bit0_state: begin
            if (ready) begin
              if (addr != last_addr)  begin
                addr            <= next_addr;
                state_reg <= ram_ctrl_state;
              end else begin
                state_reg  <= idle_state;
              end
            end
          end
        endcase
      end
    end
  end
  
  always @(*) begin
    case (state_reg)
      send_bit7_state : begin
        bit_value <= data[7];
        valid     <= 1'b1;
      end
      send_bit6_state : begin
        bit_value <= data[6];
        valid     <= 1'b1;
      end
      send_bit5_state : begin
        bit_value <= data[5];
        valid     <= 1'b1;
      end
      send_bit4_state : begin
        bit_value <= data[4];
        valid     <= 1'b1;
      end
      send_bit3_state : begin
        bit_value <= data[3];
        valid     <= 1'b1;
      end
      send_bit2_state : begin
        bit_value <= data[2];
        valid     <= 1'b1;
      end
      send_bit1_state : begin
        bit_value <= data[1];
        valid     <= 1'b1;
      end
      send_bit0_state : begin
        bit_value <= data[0];
        valid     <= 1'b1;
      end
      default : begin
        bit_value <= 1'b0;
        valid     <= 1'b0;
      end
    endcase
  end
  
  assign cs_n     = (state_reg==ram_ctrl_state) ? 1'b0 : 1'b1;
  assign progress = (state_reg==    idle_state) ? 1'b0 : 1'b1;

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Registers
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module string_led_registers #(
  parameter PSIZE = 32                      // Size of prescaler counter(bits)
)(

  input                   rst_n           , // Asynchronous reset (active low)
  input                   clk             , // Clock (rising edge)

  // Configuration
  output reg              controller_en   , // Controller enable (active high)
  output reg  [PSIZE-1:0] multiplier      , // frequency multiplier
  output reg  [PSIZE-1:0] divider         , // frequency divider
  output reg              polarity        , // Polarity of output signal
  
  // Sequencer
  output reg  [9:0]       w_first         , // First word index
  output reg  [9:0]       w_last          , // Last word index
  output reg              start           , // Start strobe (active high)
  input  wire             progress        , // Progress status

  // Wishbone bus
  input  wire             wbs_cyc_i       , // Wishbone strobe/request
  input  wire             wbs_stb_i       , // Wishbone strobe/request
  input  wire [31:0]      wbs_adr_i       , // Wishbone address
  input  wire             wbs_we_i        , // Wishbone write (1:write, 0:read)
  input  wire [31:0]      wbs_dat_i       , // Wishbone data output
  input  wire [ 3:0]      wbs_sel_i       , // Wishbone byte enable
  output reg  [31:0]      wbs_dat_o       , // Wishbone data input
  output wire             wbs_ack_o       , // Wishbone acknowlegement

  // Interrupt
  output reg              irq             , // Interrupt
  
  // Memory  
  output reg              cs_n            , // Chip select (active low)
  output reg              we_n            , // Write enable (active low)
  output reg  [9:0]       addr            , // Adress bus
  output reg  [7:0]       wdata           , // Data bus (write)
  input  wire [7:0]       rdata             // Data bus (read)

 );

  localparam
    config_reg_addr     = 3'b00,
    multiplier_reg_addr = 3'b01,
    divider_reg_addr    = 3'b10,
    ctrl_reg_addr       = 3'b11;

  wire        valid;
  wire [31:0] wstrb;
  wire [1:0]  wbs_addr;

  reg         irq_en;
  reg         ready;
  reg  [1:0]  mstate;
  reg         last_progress;

  integer i = 0;

  assign valid     = wbs_cyc_i && wbs_stb_i;
  assign wstrb     = {{8{wbs_sel_i[3]}}, {8{wbs_sel_i[2]}}, {8{wbs_sel_i[1]}}, {8{wbs_sel_i[0]}}} & {32{wbs_we_i}};
  assign wbs_addr  = wbs_adr_i[3:2];
  assign wbs_ack_o = ready;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      cs_n          <= 1'b1;
      we_n          <= 1'b0;
      addr          <= 10'b0;
      wdata         <= 8'h00;
      mstate        <= 2'b00;
      ready         <= 1'b0;
      wbs_dat_o     <= 32'h00000000;
      controller_en <= 1'b0;
      irq_en        <= 1'b0;
      polarity      <= 1'b0;
      multiplier    <= {PSIZE{1'b0}};
      divider       <= {PSIZE{1'b0}};
      w_first       <= 10'b0;
      w_last        <= 10'b0;
      start         <= 1'b0;
      irq           <= 1'b0;
      last_progress <= 1'b0;
    end else begin

      if (valid && !ready) begin
        if (wbs_adr_i[12] == 1'b0) begin // Register access

          case (wbs_addr)
            config_reg_addr : begin
              wbs_dat_o[31]   <= controller_en; if (wstrb[31]) controller_en <= wbs_dat_i[31];
              wbs_dat_o[30]   <= irq_en       ; if (wstrb[30]) irq_en        <= wbs_dat_i[30];
              wbs_dat_o[29]   <= polarity     ; if (wstrb[29]) polarity      <= wbs_dat_i[29];
              wbs_dat_o[28:0] <= {(29){1'b0}};
            end
            multiplier_reg_addr : begin
              for (i = 0; i < 32; i = i + 1) begin
                if (i >= PSIZE) begin
                  wbs_dat_o[i] <= 1'b0 ;
                end else begin
                  wbs_dat_o[i] <= multiplier[i] ; if (wstrb[i]) multiplier[i] <= wbs_dat_i[i];
                end
              end
            end
            divider_reg_addr : begin
              for (i = 0; i < 32; i = i + 1) begin
                if (i >= PSIZE) begin
                  wbs_dat_o[i] <= 1'b0 ;
                end else begin
                  wbs_dat_o[i] <= divider[i] ; if (wstrb[i]) divider[i] <= wbs_dat_i[i];
                end
              end
            end
            ctrl_reg_addr : begin
              wbs_dat_o[30]    <= start;
              wbs_dat_o[29]    <= progress;
              wbs_dat_o[28:26] <= 3'b0;
              wbs_dat_o[25]    <= w_last[9]     ; if (wstrb[25]) w_last[9]  <= wbs_dat_i[25];
              wbs_dat_o[24]    <= w_last[8]     ; if (wstrb[24]) w_last[8]  <= wbs_dat_i[24];
              wbs_dat_o[23]    <= w_last[7]     ; if (wstrb[23]) w_last[7]  <= wbs_dat_i[23];
              wbs_dat_o[22]    <= w_last[6]     ; if (wstrb[22]) w_last[6]  <= wbs_dat_i[22];
              wbs_dat_o[21]    <= w_last[5]     ; if (wstrb[21]) w_last[5]  <= wbs_dat_i[21];
              wbs_dat_o[20]    <= w_last[4]     ; if (wstrb[20]) w_last[4]  <= wbs_dat_i[20];
              wbs_dat_o[19]    <= w_last[3]     ; if (wstrb[19]) w_last[3]  <= wbs_dat_i[19];
              wbs_dat_o[18]    <= w_last[2]     ; if (wstrb[18]) w_last[2]  <= wbs_dat_i[18];
              wbs_dat_o[17]    <= w_last[1]     ; if (wstrb[17]) w_last[1]  <= wbs_dat_i[17];
              wbs_dat_o[16]    <= w_last[0]     ; if (wstrb[16]) w_last[0]  <= wbs_dat_i[16];
              wbs_dat_o[15:10] <= 6'b0;
              wbs_dat_o[ 9]    <= w_first[9]    ; if (wstrb[ 9]) w_first[9] <= wbs_dat_i[ 9];
              wbs_dat_o[ 8]    <= w_first[8]    ; if (wstrb[ 8]) w_first[8] <= wbs_dat_i[ 8];
              wbs_dat_o[ 7]    <= w_first[7]    ; if (wstrb[ 7]) w_first[7] <= wbs_dat_i[ 7];
              wbs_dat_o[ 6]    <= w_first[6]    ; if (wstrb[ 6]) w_first[6] <= wbs_dat_i[ 6];
              wbs_dat_o[ 5]    <= w_first[5]    ; if (wstrb[ 5]) w_first[5] <= wbs_dat_i[ 5];
              wbs_dat_o[ 4]    <= w_first[4]    ; if (wstrb[ 4]) w_first[4] <= wbs_dat_i[ 4];
              wbs_dat_o[ 3]    <= w_first[3]    ; if (wstrb[ 3]) w_first[3] <= wbs_dat_i[ 3];
              wbs_dat_o[ 2]    <= w_first[2]    ; if (wstrb[ 2]) w_first[2] <= wbs_dat_i[ 2];
              wbs_dat_o[ 1]    <= w_first[1]    ; if (wstrb[ 1]) w_first[1] <= wbs_dat_i[ 1];
              wbs_dat_o[ 0]    <= w_first[0]    ; if (wstrb[ 0]) w_first[0] <= wbs_dat_i[ 0];
            end
          endcase
          
          cs_n      <= 1'b1;
          mstate    <= 2'b00;
          ready     <= 1'b1;
        
        end else begin // Memory access
        
          // Memory state
          mstate <= mstate + 1'b1;
          
          // Memory control
          if (mstate == 2'b00) begin
            cs_n      <= 1'b0;
            we_n      <= ~wbs_we_i;
            addr[9:0] <= wbs_adr_i[11:2];
            if (wbs_we_i && wbs_sel_i[0]) wdata[7:0] <= wbs_dat_i[7:0];
          end else begin
            cs_n      <= 1'b1;
          end
          
          // Memory ready
          if (mstate == 2'b11) begin
            ready     <= 1'b1;
          end else begin
            ready     <= 1'b0;
          end

        end
      end else begin
        cs_n      <= 1'b1;
        mstate    <= 2'b00;
        ready     <= 1'b0;
      end
      
      if (valid && !ready && (wbs_addr == ctrl_reg_addr) && wstrb[31]) begin
        start <= wbs_dat_i[31];
      end else begin
        start <= 1'b0;
      end
      
      if ((irq_en == 1'b1) && (last_progress == 1'b1) && (progress == 1'b0)) begin
        irq <= 1'b1;
      end else begin
        irq <= 1'b0;
      end
      
      last_progress <= progress;

    end
  end

endmodule