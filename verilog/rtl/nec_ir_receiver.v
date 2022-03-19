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
module nec_ir_receiver #(
  parameter NB_STAGES =  2     , // Number of metastability filter stages
  parameter PSIZE     = 32     , // Size of prescaler counter(bits)
  parameter DSIZE     = 32     , // Size of delay counter (bits)
  parameter ASIZE     =  5       // FIFO size (FIFO_size=(2**ASIZE)-1)
)(

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

  input  wire        ir_in     ,

  output wire        irq         // Interrupt

);

  wire [PSIZE-1:0] multiplier      ;
  wire [PSIZE-1:0] divider         ;
  wire             tick8           ;
  wire             ir_meta_f       ;
  wire             ir_meta         ;
  wire             value           ;
  wire             new_sample      ;
  wire [DSIZE-1:0] reload_offset   ;
  wire [DSIZE-1:0] delay_mask      ;
  wire             event_new       ;
  wire             event_type      ;
  wire [DSIZE-1:0] event_delay     ;
  wire             event_timeout   ;
  wire             receiver_en     ;
  wire             repeat_en       ;
  wire             polarity        ;
  wire [7:0]       frame_addr      ;
  wire [7:0]       frame_data      ;
  wire             frame_repeat    ;
  wire             frame_write     ;
  wire             frame_full_n    ;
  wire [16:0]      fifo_wdata      ;
  wire [16:0]      fifo_rdata      ;
  wire             frame_read      ;
  wire             frame_available ;

  prescaler #(
    .BITS(PSIZE)
  ) i_prescaler (
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .clear_n    (receiver_en),
    .multiplier (multiplier ),
    .divider    (divider    ),
    .tick       (tick8      )
  );

  metastability_filter #(
    .NB_STAGES(NB_STAGES)
  ) i_metastability_filter (
    .rst_n      (rst_n    ),
    .clk        (clk      ),
    .i_raw      (ir_in    ),
    .o_filtered (ir_meta_f)
  );

  // Invert polarity if needed
  assign ir_meta = (polarity==0) ? ir_meta_f : ~ir_meta_f;

  pulse_filter i_pulse_filter (
    .rst_n   (rst_n      ),
    .clk     (clk        ),
    .clear_n (receiver_en),
    .i_value (ir_meta    ),
    .i_valid (tick8      ),
    .o_value (value      ),
    .o_valid (new_sample )
  );

  event_catcher #(
    .DBITS(DSIZE)
  ) i_event_catcher (
    .rst_n         (rst_n        ),
    .clk           (clk          ),
    .clear_n       (receiver_en  ),
    .reload_offset (reload_offset),
    .i_value       (value        ),
    .i_valid       (new_sample   ),
    .event_new     (event_new    ),
    .event_type    (event_type   ),
    .event_delay   (event_delay  ),
    .event_timeout (event_timeout)
  );

  frame_decoder #(
    .DBITS(DSIZE)
  ) i_frame_decoder (
    .rst_n         (rst_n        ),
    .clk           (clk          ),

    .receiver_en   (receiver_en  ),
    .repeat_en     (repeat_en    ),
    .delay_mask    (delay_mask   ),

    // Input event interface
    .event_new     (event_new    ),
    .event_type    (event_type   ),
    .event_delay   (event_delay  ),
    .event_timeout (event_timeout),

    // Output frame interface
    .frame_addr    (frame_addr   ),
    .frame_data    (frame_data   ),
    .frame_repeat  (frame_repeat ),
    .frame_write   (frame_write  )
  );

  assign       fifo_wdata = {frame_repeat, frame_addr, frame_data};

  simple_fifo #(
    .ASIZE(ASIZE),
    .DSIZE(17)
  ) i_fifo (
    .rst_n   (rst_n          ),
    .clk     (clk            ),
    .clear_n (receiver_en    ),
    .wr_data (fifo_wdata     ),
    .wr_valid(frame_write    ),
    .wr_ready(frame_full_n   ),
    .rd_data (fifo_rdata     ),
    .rd_valid(frame_available),
    .rd_ready(frame_read     )
  );

  nec_ir_receiver_registers #(
    .PSIZE(PSIZE),
    .DSIZE(DSIZE)
  ) i_nec_ir_receiver_registers (
    .rst_n   (rst_n),
    .clk     (clk  ),

   // Configuration
    .receiver_en     (receiver_en  ),
    .repeat_en       (repeat_en    ),
    .polarity        (polarity     ),
    .multiplier      (multiplier   ),
    .divider         (divider      ),
    .reload_offset   (reload_offset),
    .delay_mask      (delay_mask   ),

    // Wishbone bus
    .wbs_cyc_i       (wbs_cyc_i),
    .wbs_stb_i       (wbs_stb_i),
    .wbs_adr_i       (wbs_adr_i),
    .wbs_we_i        (wbs_we_i ),
    .wbs_dat_i       (wbs_dat_i),
    .wbs_sel_i       (wbs_sel_i),
    .wbs_dat_o       (wbs_dat_o),
    .wbs_ack_o       (wbs_ack_o),

    // Input frame interface
    .frame_new       (frame_write     ),
    .frame_full_n    (frame_full_n    ),
    .frame_available (frame_available ),
    .frame_addr      (fifo_rdata[15:8]),
    .frame_data      (fifo_rdata[7:0] ),
    .frame_repeat    (fifo_rdata[16]  ),
    .frame_read      (frame_read      ),

    // Interrupt
    .irq             (irq)

  );

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Metastability filter
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module metastability_filter #(
  parameter NB_STAGES = 2
)(
  input  wire  rst_n      , // Asynchronous reset (active low)
  input  wire  clk        , // Clock (rising edge)

  input  wire  i_raw      , // Raw input
  output wire  o_filtered   // Filtered output
);

  reg [NB_STAGES-1:0]  meta_i;
  integer    i;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      meta_i <= 1'b0;
    end else begin

      meta_i[0] = i_raw;

      for (i = 0; i < (NB_STAGES-1); i = i + 1) begin
        meta_i[i+1] <= meta_i[i];
      end

    end
  end
  assign o_filtered = meta_i[NB_STAGES-1];

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Pulse filter
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module pulse_filter (
  input  wire  rst_n      , // Asynchronous reset (active low)
  input  wire  clk        , // Clock (rising edge)
  input  wire  clear_n  , // Synchronous reset (active low)

  input  wire  i_value    , // Input value
  input  wire  i_valid    , // Input valid strobe

  output wire  o_value    , // Output value
  output reg   o_valid      // Output valid strobe
);

  reg [2:0]  filter_reg;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      filter_reg <= 1'b0;
      o_valid    <= 1'b0;
    end else begin
      if (clear_n == 1'b0) begin
          filter_reg <= 1'b0;
          o_valid    <= 1'b0;
      end else begin
        if (i_valid == 1'b1) begin
          filter_reg[2] <= i_value;
          filter_reg[1] <= filter_reg[2];
          filter_reg[0] <= filter_reg[1];
          o_valid       <= 1'b1;
        end else begin
          o_valid       <= 1'b0;
        end
      end
    end
  end

  assign o_value = (filter_reg[0] & filter_reg[1]) |
                   (filter_reg[1] & filter_reg[2]) |
                   (filter_reg[2] & filter_reg[0]) ;
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Event catcher
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module event_catcher #(
  parameter DBITS = 32 // Number of bits of delay counter
)(
  input  wire             rst_n         , // Asynchronous reset (active low)
  input  wire             clk           , // Clock (rising edge)
  input  wire             clear_n       , // Synchronous reset (active low)
  input  wire [DBITS-1:0] reload_offset , // Delay counter reload offset

  input  wire             i_value       , // Input value
  input  wire             i_valid       , // Input valid strobe

  output reg              event_new     ,
  output reg              event_type    ,
  output reg  [DBITS-1:0] event_delay   ,
  output reg              event_timeout
);

  wire detect_event;
  wire [DBITS-1:0] next_cnt;
  wire full_cnt;

  reg last_value;
  reg [DBITS-1:0] cnt;

  assign detect_event = (i_value != last_value);
  assign next_cnt     = cnt + 1'b1;
  assign full_cnt     = (cnt == {DBITS{1'b1}});

  // Event catcher
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      last_value    <= 1'b0;
      cnt           <= {DBITS{1'b1}};
      event_new     <= 1'b0;
      event_type    <= 1'b0;
      event_delay   <= {DBITS{1'b0}};
      event_timeout <= 1'b0;
    end else begin

    if (clear_n == 1'b0) begin
        last_value    <= 1'b0;
        cnt           <= {DBITS{1'b1}};
        event_new     <= 1'b0;
        event_type    <= 1'b0;
        event_delay   <= {DBITS{1'b0}};
        event_timeout <= 1'b0;
    end else begin

        if (i_valid == 1'b1) begin

          //event detect
          last_value <= i_value;

          //counter update
          if (detect_event == 1'b1) begin
            cnt <= reload_offset;
          end else if (!full_cnt) begin
            cnt <= next_cnt;
          end
        end

        //report event
        if ((i_valid == 1'b1) && (detect_event == 1'b1)) begin
          event_new     <= 1'b1;
          event_type    <= i_value; // 1: rising_edge, 0: falling_edge
          event_delay   <= next_cnt;
          event_timeout <= full_cnt;
        end else begin
          event_new     <= 1'b0;
        end

    end

    end
  end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Frame decoder
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module frame_decoder #(
  parameter DBITS = 32 // Number of bits of delay counter
)(
  input  wire  rst_n                    , // Asynchronous reset (active low)
  input  wire  clk                      , // Clock (rising edge)

  input  wire             receiver_en   , // Receiver enable
  input  wire             repeat_en     , // Repeat enable
  input  wire [DBITS-1:0] delay_mask    , // Mask delay

  // Input event interface
  input  wire             event_new     , // New event strobe
  input  wire             event_type    , // Type of event (0:rising, 1:falling)
  input  wire [DBITS-1:0] event_delay   , // Delay from last event
  input  wire             event_timeout , // Timeout flag

  // Output frame interface
  output reg  [7:0]       frame_addr    , // Frame address
  output reg  [7:0]       frame_data    , // Frame data
  output reg              frame_repeat  , // Frame repeat flag
  output reg              frame_write     // Frame write strobe
);

  localparam
    idle_state        = 3'b000,
    start_state       = 3'b001,
    data_prefix_state = 3'b010,
    data_latch_state  = 3'b011,
    stop_state        = 3'b100,
    idle_a_state      = 3'b101,
    idle_b_state      = 3'b110,
    idle_c_state      = 3'b111;

  reg [2:0] frame_state_reg ;
  wire is_valid_start_a     ;
  wire is_valid_start_b     ;
  wire is_valid_repeat      ;
  wire is_valid_bit_prefix  ;
  wire is_valid_bit_zero    ;
  wire is_valid_bit_one     ;
  wire is_valid_bit         ;
  wire is_valid_stop        ;
  wire is_valid_addr        ;
  wire is_valid_data        ;

  reg [31:0] frame_shift    ;
  reg        initial_timeout;

  assign is_valid_start_a    = ((event_timeout == 1'b0) && (event_type == 1'b0) && ((event_delay & delay_mask) == 128)); // 9.00ms pulse to 1'b1
  assign is_valid_start_b    = ((event_timeout == 1'b0) && (event_type == 1'b1) && ((event_delay & delay_mask) ==  64)); // 4.50ms pulse to 1'b0
  assign is_valid_repeat     = ((event_timeout == 1'b0) && (event_type == 1'b1) && ((event_delay & delay_mask) ==  32) && (initial_timeout == 0)); // 2.25ms pulse to 1'b0
  assign is_valid_bit_prefix = ((event_timeout == 1'b0) && (event_type == 1'b0) && ((event_delay & delay_mask) ==   8));
  assign is_valid_bit_zero   = ((event_timeout == 1'b0) && (event_type == 1'b1) && ((event_delay & delay_mask) ==   8));
  assign is_valid_bit_one    = ((event_timeout == 1'b0) && (event_type == 1'b1) && ((event_delay & delay_mask) ==  24));
  assign is_valid_bit        = (is_valid_bit_zero || is_valid_bit_one);
  assign is_valid_stop       = ((event_timeout == 1'b0) && (event_type == 1'b0) && ((event_delay & delay_mask) ==   8));
  assign is_valid_addr       = ((frame_shift[7:0] == ~frame_shift[15:8]));
  assign is_valid_data       = ((frame_shift[23:16] == ~frame_shift[31:24]));

  // Frame decoder
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      frame_state_reg  <= idle_state;
      frame_shift      <= 32'h80000000;
      frame_repeat     <= 1'b0;
      frame_write      <= 1'b0;
      frame_addr       <= 8'h00;
      frame_data       <= 8'h00;
    end else begin

      if (receiver_en == 1'b0) begin
        frame_state_reg <= idle_state;
        initial_timeout <= 1'b1;
        frame_shift     <= 32'h80000000;
        frame_repeat    <= 1'b0;
      end else begin
        if (event_new == 1'b1) begin
          case(frame_state_reg)
            idle_state,
            idle_a_state,
            idle_b_state,
            idle_c_state:
              if(is_valid_start_a) begin
                frame_state_reg <= start_state;
              end
            start_state:
              if (is_valid_start_b) begin
                frame_state_reg <= data_prefix_state;
              end else if (repeat_en && is_valid_repeat) begin
                frame_state_reg <= stop_state;
              end else begin
                frame_state_reg <= idle_state;
              end
            data_prefix_state:
              if (is_valid_bit_prefix) begin
                frame_state_reg <= data_latch_state;
              end else begin
                frame_state_reg <= idle_state;
              end
            data_latch_state:
              if (is_valid_bit) begin
                if (frame_shift[0] == 1'b1) begin
                  frame_state_reg <= stop_state;
                end else begin
                  frame_state_reg <= data_prefix_state;
                end
              end else begin
                frame_state_reg <= idle_state;
              end
            stop_state:
              frame_state_reg <= idle_state;
            default:
              frame_state_reg <= idle_state;
            endcase

          if ((frame_state_reg == idle_state) && (event_timeout == 1'b1)) begin
            initial_timeout <= 1'b1;
          end else if ((frame_state_reg == stop_state) && is_valid_stop && is_valid_addr && is_valid_data && (frame_repeat == 0)) begin
            initial_timeout <= 1'b0;
          end

          if ((frame_state_reg == start_state) && is_valid_start_b) begin
            frame_shift <= 32'h80000000;
          end else if (frame_state_reg == data_latch_state) begin
            if (is_valid_bit_zero) begin
              frame_shift <= {1'b0, frame_shift[31:1]};
            end else begin
              frame_shift <= {1'b1, frame_shift[31:1]};
            end
          end

          if (frame_state_reg == start_state) begin
            if (repeat_en && is_valid_repeat) begin
              frame_repeat <= 1'b1;
            end else begin
              frame_repeat <= 1'b0;
            end
          end

        end

        if ((receiver_en == 1'b1) && (event_new == 1'b1) && (frame_state_reg == stop_state) && is_valid_stop && is_valid_addr && is_valid_data) begin
          frame_write <= 1'b1;
          frame_addr  <= frame_shift[7:0];
          frame_data  <= frame_shift[23:16];
        end else begin
          frame_write <= 1'b0;
        end
      end
    end
  end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Registers
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module nec_ir_receiver_registers #(
  parameter PSIZE = 32 , // Size of prescaler counter(bits)
  parameter DSIZE = 32   // Size of delay counter (bits)
)(

  input                   rst_n           , // Asynchronous reset (active low)
  input                   clk             , // Clock (rising edge)

  // Configuration
  output reg              receiver_en     , // Receiver enable
  output reg              repeat_en       , // Repeat enable
  output reg              polarity        , // Polarity (value of idle state)
  output reg  [PSIZE-1:0] multiplier      , // frequency multiplier
  output reg  [PSIZE-1:0] divider         , // frequency divider
  output reg  [DSIZE-1:0] reload_offset   , // Delay counter reload offset
  output reg  [DSIZE-1:0] delay_mask      , // Mask delay

  // Wishbone bus
  input  wire             wbs_cyc_i       , // Wishbone strobe/request
  input  wire             wbs_stb_i       , // Wishbone strobe/request
  input  wire [31:0]      wbs_adr_i       , // Wishbone address
  input  wire             wbs_we_i        , // Wishbone write (1:write, 0:read)
  input  wire [31:0]      wbs_dat_i       , // Wishbone data output
  input  wire [ 3:0]      wbs_sel_i       , // Wishbone byte enable
  output reg  [31:0]      wbs_dat_o       , // Wishbone data input
  output wire             wbs_ack_o       , // Wishbone acknowlegement

  // Input frame interface
  input  wire             frame_new       , // New frame received
  input  wire             frame_full_n    , // New frame lost (FIFO full)
  input  wire             frame_available , // Frame write strobe
  input  wire [7:0]       frame_addr      , // Frame address
  input  wire [7:0]       frame_data      , // Frame data
  input  wire             frame_repeat    , // Frame repeat flag
  output reg              frame_read      , // Frame write strobe

  // Interrupt
  output reg              irq               // Interrupt

 );

  localparam
    cmd_reg_addr        = 2'b00,
    multiplier_reg_addr = 2'b01,
    divider_reg_addr    = 2'b10,
    status_reg_addr     = 2'b11;

  wire        valid;
  wire        rstrb;
  wire [31:0] wstrb;
  wire [1:0]  addr;

  reg  [1:0]  tolerance;
  reg         frame_lost;
  reg         ready;
  reg         irq_en;

  integer i = 0;

  assign valid     = wbs_cyc_i && wbs_stb_i;
  assign wstrb     = {{8{wbs_sel_i[3]}}, {8{wbs_sel_i[2]}}, {8{wbs_sel_i[1]}}, {8{wbs_sel_i[0]}}} & {32{wbs_we_i}};
  assign rstrb     = ~wbs_we_i;
  assign addr      = wbs_adr_i[3:2];
  assign wbs_ack_o = ready;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      ready       <= 1'b0;
      wbs_dat_o   <= 32'h00000000;
      tolerance   <= 2'b01;
      multiplier  <= {PSIZE{1'b0}};
      divider     <= {PSIZE{1'b0}};
      receiver_en <= 1'b0;
      repeat_en   <= 1'b0;
      irq_en      <= 1'b0;
      polarity    <= 1'b0;
      frame_lost  <= 1'b0;
      frame_read  <= 1'b0;
      irq         <= 1'b0;
    end else begin

      if (valid && !ready) begin

        //Write
        case (addr)
          cmd_reg_addr : begin
            wbs_dat_o[31] <= receiver_en  ; if (wstrb[31]) receiver_en <= wbs_dat_i[31];
            wbs_dat_o[30] <= repeat_en    ; if (wstrb[30]) repeat_en   <= wbs_dat_i[30];
            wbs_dat_o[29] <= irq_en       ; if (wstrb[29]) irq_en      <= wbs_dat_i[29];
            wbs_dat_o[28] <= polarity     ; if (wstrb[28]) polarity    <= wbs_dat_i[28];
            wbs_dat_o[27] <= tolerance[1] ; if (wstrb[27]) tolerance[1]<= wbs_dat_i[27];
            wbs_dat_o[26] <= tolerance[0] ; if (wstrb[26]) tolerance[0]<= wbs_dat_i[26];
            wbs_dat_o[25:0] <= 26'b0;
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
          status_reg_addr : begin

            if (frame_available == 1'b1) begin
              wbs_dat_o[31]    <= 1'b1;
              wbs_dat_o[30]    <= frame_repeat;
              wbs_dat_o[29]    <= frame_lost;
              wbs_dat_o[28:16] <= 13'b0;
              wbs_dat_o[15:8]  <= frame_addr;
              wbs_dat_o[7:0]   <= frame_data;
            end else begin
              wbs_dat_o[31:0]  <= 31'b0;
            end
          end
        endcase

        ready <= 1'b1;
      end else begin
        ready <= 1'b0;
      end

      if ((frame_new == 1'b1) && (frame_full_n == 1'b0)) begin
        frame_lost <= 1'b1;
      end else if (valid && !ready && rstrb && (addr == status_reg_addr)) begin
        frame_lost <= 1'b0;
      end

      if (valid && !ready && rstrb && (addr == status_reg_addr)) begin
        frame_read <= 1'b1;
      end else begin
        frame_read <= 1'b0;
      end

      if ((irq_en == 1'b1) && (frame_new == 1'b1)) begin
        irq <= 1'b1;
      end else begin
        irq <= 1'b0;
      end

    end
  end

  always @(*) begin
    case (tolerance)
      2'b00 : begin
        reload_offset <= {{(DSIZE-3){1'b0}}, 3'b001};
        delay_mask    <= {{(DSIZE-3){1'b1}}, 3'b110};
      end
      2'b01 : begin
        reload_offset <= {{(DSIZE-3){1'b0}}, 3'b010};
        delay_mask    <= {{(DSIZE-3){1'b1}}, 3'b100};
      end
      default : begin
        reload_offset <= {{(DSIZE-3){1'b0}}, 3'b100};
        delay_mask    <= {{(DSIZE-3){1'b1}}, 3'b000};
      end
    endcase
  end

endmodule
