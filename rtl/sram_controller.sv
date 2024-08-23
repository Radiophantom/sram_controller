
module sram_controller #(
  parameter int CLK_PERIOD, // ns
  parameter int ADDR_W,
  parameter int DATA_W
)(
  input                 rst_i,
  input                 clk_i,

  // Avalon-MM interface
  input   [ADDR_W-1:0]  amm_address_i,
  input                 amm_read_i,
  input                 amm_write_i,
  input   [DATA_W-1:0]  amm_writedata_i,
  output                amm_readdatavalid_o,
  output  [DATA_W-1:0]  amm_readdata_o,
  output                amm_waitrequest_o,

  // SRAM interface
  output                wen_o,
  output                oen_o,
  output  [ADDR_W-1:0]  addr_o,

  output                data_en_o,
  output  [DATA_W-1:0]  data_o,
  input   [DATA_W-1:0]  data_i
);

import sram_timings_pkg::*;

//synthesis translate_off
initial
begin
  wen_o     = 1'b1;
  oen_o     = 1'b1;
  data_en_o = 1'b0;
end
//synthesis translate_on

endmodule

/*

sram_controller #(
  .CLK_PERIOD         ( ),
  .ADDR_W             ( ),
  .DATA_W             ( )
) sram_controller_inst (
  .rst_i              ( ),
  .clk_i              ( ),

  .amm_address_i      ( ),
  .amm_read_i         ( ),
  .amm_write_i        ( ),
  .amm_writedata_i    ( ),
  .amm_readdatavalid_o( ),
  .amm_readdata_o     ( ),
  .amm_waitrequest_o  ( ),

  .wen_o              ( ),
  .oen_o              ( ),
  .addr_o             ( ),

  .data_en_o          ( ),
  .data_o             ( ),
  .data_i             ( )
);

*/
