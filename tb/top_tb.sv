`timescale 1 ns / 1 ns

module top_tb;

logic [17:0]  sram_address;
logic [15:0]  sram_data;
logic         sram_ce1_n;
logic         sram_ce2;
logic         sram_wen;
logic         sram_oen;
logic         sram_bhen;
logic         sram_blen;
logic         sram_data_en;
logic [15:0]  sram_data_i;
logic [15:0]  sram_data_o;
wire  [15:0]  sram_data_w;

//------------------------------------------------------------------------------
// Start-up reset and clock generation
//------------------------------------------------------------------------------

parameter int CLK_T = 10;

bit clk;
bit rst;

initial
begin
  rst <= 1;
  #(10*CLK_T);
  fork
    forever
      #(CLK_T/2) clk = !clk;
  join_none
  repeat(10)
    @(posedge clk);
  rst <= 0;
end

avalon_mm_if #(18,16) mem_if (clk);

//------------------------------------------------------------------------------
// Test
//------------------------------------------------------------------------------

import tb_pkg::*;

environment #(18,16) env;

initial
begin

  env = new(mem_if);

  @(negedge rst);

  env.build();
  env.gen.transaction_amount = 100;
  //env.drv.DBG_LEVEL = 1;
  env.run();
  env.wrap_up();

  $display("Simulation finished!");
  $stop();
end

//------------------------------------------------------------------------------
// DUT instance
//------------------------------------------------------------------------------

sram_controller #(
  .CLK_PERIOD         ( CLK_T             ),
  .ADDR_W             ( 18                ),
  .DATA_W             ( 16                )
) DUT (
  .rst_i              ( rst               ),
  .clk_i              ( clk               ),

  .mem_if             ( mem_if            ),

  .wen_o              ( sram_wen          ),
  .oen_o              ( sram_oen          ),
  .addr_o             ( sram_address      ),

  .data_en_o          ( sram_data_en      ),
  .data_o             ( sram_data_o       ),
  .data_i             ( sram_data_i       )
);
//------------------------------------------------------------------------------
// SRAM instance
//------------------------------------------------------------------------------

assign sram_ce1_n = 1'b0;
assign sram_ce2   = 1'b1;
assign sram_bhen  = 1'b0;
assign sram_blen  = 1'b0;

mobl_256Kx16 #(
  .TimingInfo ( 1             )
) sram_model (
  .CE1_b      ( sram_ce1_n    ),
  .CE2        ( sram_ce2      ),

  .WE_b       ( sram_wen      ),
  .OE_b       ( sram_oen      ),
  .BHE_b      ( sram_bhen     ),
  .BLE_b      ( sram_blen     ),
  .A          ( sram_address  ),
  .DQ         ( sram_data_w   )
);

assign sram_data_w = sram_data_en ? sram_data_o : 'Z;
assign sram_data_i = sram_data_w;

endmodule

