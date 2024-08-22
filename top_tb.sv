`timescale 1 ns / 1 ns

module top_tb;

mobl_256Kx16 #(
  .ADDR_BITS    ( 18      ),
  .DATA_BITS    ( 16      ),
  .depth        ( 262144  ),

  .TimingInfo   ( 1       ),
  .TimingChecks ( 1       )
) DUT (
//mobl_256Kx16 DUT (
  .CE1_b ( 1'b0 ),
  .CE2   ( 1'b1 ),

  .WE_b  ( 1'b1 ),
  .OE_b  ( 1'b0 ),
  .BHE_b ( 1'b0 ),
  .BLE_b ( 1'b0 ),
  .A     ( '1   ),
  .DQ    (      )
);

initial
begin
  #10000;
  $display("Simulation finished!");
  $stop();
end

endmodule

