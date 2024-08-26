
module sram_controller #(
  parameter int CLK_PERIOD, // ns
  parameter int ADDR_W,
  parameter int DATA_W
)(
  input                 rst_i,
  input                 clk_i,

  // Avalon-MM interface
  avalon_mm_if          mem_if,

  // SRAM interface
  output                wen_o,
  output                oen_o,
  output  [ADDR_W-1:0]  addr_o,

  output                data_en_o,
  output  [DATA_W-1:0]  data_o,
  input   [DATA_W-1:0]  data_i
);

import sram_timings_pkg::*;

//------------------------------------------------------------------------------
// Timing calculations
//------------------------------------------------------------------------------

localparam int TRC_TICKS   = (TRC  +CLK_PERIOD-1)/CLK_PERIOD;
localparam int TAA_TICKS   = (TAA  +CLK_PERIOD-1)/CLK_PERIOD;
localparam int TOHA_TICKS  = (TOHA +CLK_PERIOD-1)/CLK_PERIOD;
localparam int TDOE_TICKS  = (TDOE +CLK_PERIOD-1)/CLK_PERIOD;
localparam int TLZOE_TICKS = (TLZOE+CLK_PERIOD-1)/CLK_PERIOD;
localparam int THZOE_TICKS = (THZOE+CLK_PERIOD-1)/CLK_PERIOD;

localparam int TWC_TICKS   = (TWC  +CLK_PERIOD-1)/CLK_PERIOD;
localparam int TAW_TICKS   = (TAW  +CLK_PERIOD-1)/CLK_PERIOD;
localparam int THA_TICKS   = (THA  +CLK_PERIOD-1)/CLK_PERIOD;
localparam int TSA_TICKS   = (TSA  +CLK_PERIOD-1)/CLK_PERIOD;
localparam int TPWE_TICKS  = (TPWE +CLK_PERIOD-1)/CLK_PERIOD;
localparam int TSD_TICKS   = (TSD  +CLK_PERIOD-1)/CLK_PERIOD;
localparam int THD_TICKS   = (THD  +CLK_PERIOD-1)/CLK_PERIOD;
localparam int THZWE_TICKS = (THZWE+CLK_PERIOD-1)/CLK_PERIOD;
localparam int TLZWE_TICKS = (TLZWE+CLK_PERIOD-1)/CLK_PERIOD;

localparam int MAX_TICKS    = (TRC_TICKS > TWC_TICKS) ? TRC_TICKS : TWC_TICKS;
localparam int MAX_TICKS_W  = $clog2(MAX_TICKS);

//------------------------------------------------------------------------------
// Counter
//------------------------------------------------------------------------------

typedef enum {
  IDLE_S,
  RD_ADDR_S,
  RD_DATA_S,
  RD_HIGH_Z_S,
  WR_DATA_S,
  WR_PULSE_S,
  WR_HIGH_Z_S
} state_t;

state_t state, next_state;

logic [MAX_TICKS_W-1:0] tick_cnt;

always_ff @(posedge clk_i)
  if(state == IDLE_S)
    tick_cnt <= '0;
  else
    tick_cnt <= tick_cnt + 1'b1;

//------------------------------------------------------------------------------
// FSM
//------------------------------------------------------------------------------

always_ff @(posedge clk_i,posedge rst_i)
  if(rst_i)
    state <= IDLE_S;
  else
    state <= next_state;

always_comb
begin
  next_state = state;
  case(state)
    IDLE_S:
    begin
      if(mem_if.read)
        next_state = RD_ADDR_S;
      if(mem_if.write)
        next_state = WR_DATA_S;
    end
    RD_ADDR_S:
      if(tick_cnt >= TAA_TICKS-1)
        next_state = RD_DATA_S;
    RD_DATA_S:
      next_state = RD_HIGH_Z_S;
    RD_HIGH_Z_S:
      if(tick_cnt >= TAA_TICKS+THZOE_TICKS-1)
        next_state = IDLE_S;
    WR_DATA_S:
      if(tick_cnt >= TSD_TICKS-1)
        if(tick_cnt >= TPWE_TICKS-1)
          next_state = WR_HIGH_Z_S;
        else
          next_state = WR_PULSE_S;
    WR_PULSE_S:
      if(tick_cnt >= TPWE_TICKS-1)
        next_state = WR_HIGH_Z_S;
    WR_HIGH_Z_S:
      if(tick_cnt >= TPWE_TICKS+TLZWE_TICKS-1)
        next_state = IDLE_S;
    default:
      next_state = IDLE_S;
  endcase
end

//------------------------------------------------------------------------------
// Bus control signals
//------------------------------------------------------------------------------

logic              wen;
logic              oen;
logic              data_en;

always_ff @(posedge clk_i,posedge rst_i)
  if(rst_i)
  begin
    wen     <= 1'b1;
    oen     <= 1'b1;
    data_en <= 1'b0;
  end
  else
  begin
    case(state)
      IDLE_S:
      begin
        wen     <= mem_if.read;
        oen     <= mem_if.write;
        data_en <= mem_if.write;
      end
      RD_DATA_S:
      begin
        oen <= 1'b1;
      end
      WR_PULSE_S:
      begin
        data_en <= (tick_cnt <  TPWE_TICKS-1);
        wen     <= (tick_cnt >= TPWE_TICKS-1);
      end
      WR_HIGH_Z_S:
      begin
        data_en <= 1'b0;
      end
    endcase
  end

//------------------------------------------------------------------------------
// Bus addr/data signals
//------------------------------------------------------------------------------

logic [ADDR_W-1:0] addr;
logic [DATA_W-1:0] wr_data;

always_ff @(posedge clk_i)
  if(state == IDLE_S)
  begin
    addr    <= mem_if.address;
    wr_data <= mem_if.writedata;
  end

//------------------------------------------------------------------------------
// Avalon-MM signals
//------------------------------------------------------------------------------

logic               waitrequest;
logic               readdatavalid;
logic [DATA_W-1:0]  rd_data;

always_ff @(posedge clk_i,posedge rst_i)
  if(rst_i)
    readdatavalid <= 1'b0;
  else
    readdatavalid <= (state == RD_DATA_S);

always_ff @(posedge clk_i)
  if(state == RD_DATA_S)
    rd_data <= data_i;

always_ff @(posedge clk_i,posedge rst_i)
  if(rst_i)
    waitrequest <= 1'b0;
  else
    if(state == IDLE_S)
      waitrequest <= mem_if.read || mem_if.write;
    else
      if(state == RD_HIGH_Z_S)
        waitrequest <= (tick_cnt < TRC_TICKS+THZOE_TICKS-1);
      else
        if(state == WR_HIGH_Z_S)
          waitrequest <= (tick_cnt < TPWE_TICKS+TLZWE_TICKS-1);

//------------------------------------------------------------------------------
// Output assignments
//------------------------------------------------------------------------------

assign addr_o     = addr;
assign wen_o      = wen;
assign oen_o      = oen;
assign data_en_o  = data_en;
assign data_o     = wr_data;

assign mem_if.readdatavalid   = readdatavalid;
assign mem_if.readdata        = rd_data;
assign mem_if.waitrequest     = waitrequest;

endmodule

/*

sram_controller #(
  .CLK_PERIOD         ( ),
  .ADDR_W             ( ),
  .DATA_W             ( )
) sram_controller_inst (
  .rst_i              ( ),
  .clk_i              ( ),

  .mem_if             ( ),

  .wen_o              ( ),
  .oen_o              ( ),
  .addr_o             ( ),

  .data_en_o          ( ),
  .data_o             ( ),
  .data_i             ( )
);

*/
