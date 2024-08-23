`timescale 1 ns / 1 ns

module top_tb;

//------------------------------------------------------------------------------
logic [17:0]  amm_address;
logic         amm_read;
logic         amm_write;
logic [15:0]  amm_writedata;
logic         amm_readdatavalid;
logic [15:0]  amm_readdata;
logic         amm_waitrequest;
//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
// Tasks
//------------------------------------------------------------------------------

int DBG_LVL = 0;

task automatic avalon_mm_read(
  input   bit [17:0]  addr,
  output  bit [15:0]  data
);
  amm_address <= addr;
  amm_read    <= 1;
  do
    @(posedge clk);
  while(amm_waitrequest);
  amm_read <= 0;
  while(!amm_readdatavalid)
    @(posedge clk);
  data = amm_readdata;
  if(DBG_LVL > 0)
    $display("[read] addr - %0d. data - %h",addr,data);
endtask
        
task automatic avalon_mm_write(
  input   bit [17:0]  addr,
          bit [15:0]  data
);
  amm_address   <= addr;
  amm_writedata <= data;
  amm_write     <= 1;
  do
    @(posedge clk);
  while(amm_waitrequest);
  amm_write     <= 0;
  if(DBG_LVL > 0)
    $display("[write] addr - %0d. data - %h",addr,data);
endtask

//task automatic read(
//  input   bit [17:0]  addr,
//          int         words,
//  output  bit [15:0]  data [$]
//);
//  repeat(words)
//  begin
//    bit [15:0] dword;
//    read_word(addr++,dword);
//    data.push_back(dword);
//  end
//endtask
//
//task automatic write(
//  input   bit [17:0]  addr,
//          bit [15:0]  data [$]
//);
//  repeat(data.size())
//    write_word(addr++,data.pop_front());
//endtask

//------------------------------------------------------------------------------
// Test
//------------------------------------------------------------------------------

initial
begin

  DBG_LVL = 1;

  @(negedge rst);

  #10000;
  //begin
  //  bit [15:0] wr_data [$];
  //  repeat(16)
  //    wr_data.push_back($urandom_range(2**16-1,0));
  //  write(0,wr_data);
  //end
  //begin
  //  bit [15:0] rd_data [$];
  //  read(0,16,rd_data);
  //end

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

  .amm_address_i      ( amm_address       ),
  .amm_read_i         ( amm_read          ),
  .amm_write_i        ( amm_write         ),
  .amm_writedata_i    ( amm_writedata     ),
  .amm_readdatavalid_o( amm_readdatavalid ),
  .amm_readdata_o     ( amm_readdata      ),
  .amm_waitrequest_o  ( amm_waitrequest   ),

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

