
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

assign oen_o = 1'b0;

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
  RD_WAIT_S,
  RD_HOLD_S,
  WR_SET_ADDR_S,
  WR_WAIT_S,
  WR_RELEASE_S
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
        next_state = RD_WAIT_S;
      if(mem_if.write)
        next_state = WR_WAIT_S;
    end
    RD_WAIT_S:
      if(tick_cnt == TRC_TICKS)
        next_state = RD_HOLD_S;
    RD_HOLD_S:
      if(tick_cnt == TRC_TICKS+THZOE_TICKS)
        next_state = IDLE_S;
    WR_WAIT_S:
      if(tick_cnt == TLZWE_TICKS+TSD_TICKS)
        next_state = WR_RELEASE_S;
    WR_RELEASE_S:
      if(tick_cnt == TWC_TICKS)
        next_state = IDLE_S;
    default:
      next_state = IDLE_S;
  endcase
end

logic [ADDR_W-1:0] addr;
logic              wen;
logic              data_en;
logic [DATA_W-1:0] wr_data;
logic [DATA_W-1:0] rd_data;

always_ff @(posedge clk_i,posedge rst_i)
  if(rst_i)
  begin
    wen     <= 1'b1;
    data_en <= 1'b0;
  end
  else
  begin
    case(state)
      IDLE_S:
      begin
        addr    <= mem_if.address;
        wen     <= mem_if.write ? 1'b0 : 1'b1;
        wr_data <= mem_if.writedata;
        data_en <= 1'b0;
      end
      RD_WAIT_S:
      begin
        if(tick_cnt == TRC_TICKS)
          rd_data <= data_i;
      end
      WR_WAIT_S:
      begin
        if(tick_cnt == TLZWE_TICKS)
        begin
          data_en <= 1'b1;
        end
        if(tick_cnt == TPWE_TICKS)
          wen <= 1'b1;
      end
      WR_RELEASE_S:
        data_en <= 1'b0;
    endcase
  end

logic readdatavalid;
logic waitrequest;

always_ff @(posedge clk_i,posedge rst_i)
  if(rst_i)
    readdatavalid <= 1'b0;
  else
    readdatavalid <= (state == RD_HOLD_S) && (tick_cnt == TRC_TICKS+THZOE_TICKS);

assign waitrequest = (state != IDLE_S);
//always_ff @(posedge clk_i,posedge rst_i)
//  if(rst_i)
//    waitrequest <= 1'b0;
//  else
//    waitrequest <= (state != IDLE_S);

assign addr_o     = addr;
assign wen_o      = wen;
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
