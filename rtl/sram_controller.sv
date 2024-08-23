
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

logic wen;
logic oen;
logic data_en;

//synthesis translate_off
initial
begin
  wen     = 1'b1;
  oen     = 1'b1;
  data_en = 1'b0;
end
//synthesis translate_on

assign wen_o = wen;
assign oen_o = oen;
assign data_en_o = data_en;

logic readdatavalid;

always_ff @(posedge clk_i,posedge rst_i)
  if(rst_i)
    readdatavalid <= 1'b0;
  else
    readdatavalid <= mem_if.read;

assign mem_if.readdata    = '1;
assign mem_if.waitrequest = 1'b0;

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
