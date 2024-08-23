
typedef enum {
  READ,
  WRITE
} op_t;

class amm_transaction;

  int ADDR_W = 0;
  int DATA_W = 0;

  rand op_t         op;
  rand bit [31:0]   addr;
  rand bit [31:0]   wrdata;
       bit [31:0]   rddata;

  constraint size_c {
    addr    < 2**this.ADDR_W;
    wrdata  < 2**this.DATA_W;
  }

  virtual function amm_transaction copy();
    copy = new();
    copy.op     = this.op;
    copy.addr   = this.addr;
    copy.wrdata = this.wrdata;
    copy.rddata = this.rddata;
    copy.ADDR_W = this.ADDR_W;
    copy.DATA_W = this.DATA_W;
  endfunction

  virtual function string convert2string();
    string s;
    s = {s,$sformatf("OP:   %s\n",op.name())};
    s = {s,$sformatf("ADDR: 0x%h\n",(this.addr & (2**this.ADDR_W-1)))};
    if(op == READ)
      s = {s,$sformatf("RDATA: 0x%h\n",(this.rddata & (2**this.DATA_W-1)))};
    else
      s = {s,$sformatf("WDATA: 0x%h\n",(this.wrdata & (2**this.DATA_W-1)))};
    return s;
  endfunction

endclass

