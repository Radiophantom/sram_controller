`timescale 1 ns / 1 ns

module top_tb;

wire  [17:0]  sram_address;
wire  [15:0]  sram_data;
wire          sram_ce1_n;
wire          sram_ce2;
wire          sram_wen;
wire          sram_oen;
wire          sram_bhen;
wire          sram_blen;

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

//------------------------------------------------------------------------------
// Test
//------------------------------------------------------------------------------

initial
begin
  #10000;
  $display("Simulation finished!");
  $stop();
end

//------------------------------------------------------------------------------
// SRAM instance
//------------------------------------------------------------------------------

mobl_256Kx16 #(
  .TimingInfo   ( 1             ),
  .TimingChecks ( 1             )
) DUT (
  .CE1_b        ( sram_ce1_n    ),
  .CE2          ( sram_ce2      ),

  .WE_b         ( sram_wen      ),
  .OE_b         ( sram_oen      ),
  .BHE_b        ( sram_bhen     ),
  .BLE_b        ( sram_blen     ),
  .A            ( sram_address  ),
  .DQ           ( sram_data     )
);

endmodule

