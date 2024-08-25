
interface avalon_mm_if #(
  parameter int ADDR_W,
  parameter int DATA_W
)(
  input clk
);

localparam int BE_W = (DATA_W/8);

logic [ADDR_W-1:0]  address;
logic               read;
logic [BE_W-1:0]    byteenable;
logic               write;
logic [DATA_W-1:0]  writedata;
logic               readdatavalid;
logic [DATA_W-1:0]  readdata;
logic               waitrequest;

clocking cb @(posedge clk);
  input   readdatavalid,
          readdata,
          waitrequest;
  output  address,
          read,
          byteenable,
          write,
          writedata;
endclocking

endinterface

