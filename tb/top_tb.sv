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

task automatic read_word(
  input   bit [17:0]  addr,
  output  bit [15:0]  data
);
  sram_address  = addr;
  sram_oen      = 1'b0;
  #50;
  data          = sram_data_w;
  sram_oen      = 1'b1;
  #50;
  if(DBG_LVL > 0)
    $display("[read] addr - %0d. data - %h",addr,data);
endtask
        
task automatic write_word(
  input   bit [17:0]  addr,
          bit [15:0]  data
);
  if(DBG_LVL > 0)
    $display("[write] addr - %0d. data - %h",addr,data);
  sram_address  = addr;
  #50;
  sram_wen      = 1'b0;
  sram_data     = data;
  #50;
  sram_wen      = 1'b1;
  #50;
  sram_data     = 'Z;
endtask

task automatic read(
  input   bit [17:0]  addr,
          int         words,
  output  bit [15:0]  data [$]
);
  repeat(words)
  begin
    bit [15:0] dword;
    read_word(addr++,dword);
    data.push_back(dword);
  end
endtask

task automatic write(
  input   bit [17:0]  addr,
          bit [15:0]  data [$]
);
  repeat(data.size())
    write_word(addr++,data.pop_front());
endtask

//------------------------------------------------------------------------------
// Test
//------------------------------------------------------------------------------

initial
begin

  // Init signals
  sram_ce1_n    = 1'b0;
  sram_ce2      = 1'b1;
  sram_wen      = 1'b1;
  sram_oen      = 1'b1;
  sram_bhen     = 1'b0;
  sram_blen     = 1'b0;
  sram_address  = 'X;
  sram_data     = 'Z;

  @(negedge rst);

  #100;

  DBG_LVL = 1;

  begin
    bit [15:0] wr_data [$];
    repeat(16)
      wr_data.push_back($urandom_range(2**16-1,0));
    write(0,wr_data);
  end
  begin
    bit [15:0] rd_data [$];
    read(0,16,rd_data);
  end

  $display("Simulation finished!");
  $stop();
end

//------------------------------------------------------------------------------
// SRAM instance
//------------------------------------------------------------------------------

mobl_256Kx16 #(
  .TimingInfo   ( 1             )
) DUT (
  .CE1_b        ( sram_ce1_n    ),
  .CE2          ( sram_ce2      ),

  .WE_b         ( sram_wen      ),
  .OE_b         ( sram_oen      ),
  .BHE_b        ( sram_bhen     ),
  .BLE_b        ( sram_blen     ),
  .A            ( sram_address  ),
  .DQ           ( sram_data_w   )
);

assign sram_data_w = sram_data;

endmodule

