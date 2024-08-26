
class driver_cbs;
  virtual function void post_write(amm_transaction tr);
  endfunction
  virtual function void post_read(amm_transaction tr);
  endfunction
endclass

class driver #(
  parameter int ADDR_W,
  parameter int DATA_W
);

  int DBG_LEVEL = 0;

  driver_cbs cbs [$];

  virtual avalon_mm_if #(ADDR_W,DATA_W) vmem_if;

  mailbox #(amm_transaction) req_port;
  mailbox #(amm_transaction) resp_port;

  function new(
    mailbox #(amm_transaction) req_port,
    mailbox #(amm_transaction) resp_port,
    virtual avalon_mm_if #(ADDR_W,DATA_W) vmem_if
  );
    this.req_port   = req_port;
    this.resp_port  = resp_port;
    this.vmem_if    = vmem_if;
  endfunction

  task read(amm_transaction tr);
    repeat(tr.gap)
      @vmem_if.cb;
    vmem_if.cb.address <= tr.addr;
    vmem_if.cb.read    <= 1;
    do
      @vmem_if.cb;
    while(vmem_if.cb.waitrequest);
    vmem_if.cb.read <= 0;
    while(!vmem_if.cb.readdatavalid)
      @vmem_if.cb;
    tr.rddata = vmem_if.cb.readdata;
    foreach(cbs[i])
      cbs[i].post_read(tr);
    if(DBG_LEVEL > 0)
      $display("@%t [read] addr - %0d. data - %h",$time(),tr.addr,tr.rddata);
  endtask

  task write(amm_transaction tr);
    repeat(tr.gap)
      @vmem_if.cb;
    vmem_if.cb.address   <= tr.addr;
    vmem_if.cb.writedata <= tr.wrdata;
    vmem_if.cb.write     <= 1;
    do
      @vmem_if.cb;
    while(vmem_if.cb.waitrequest);
    vmem_if.cb.write     <= 0;
    foreach(cbs[i])
      cbs[i].post_write(tr);
    if(DBG_LEVEL > 0)
      $display("@%t: [write] addr - %0d. data - %h",$time(),tr.addr,tr.wrdata);
  endtask

  task run();
    amm_transaction req_tr;
    forever
    begin
      req_port.get(req_tr);
      if(req_tr.op == WRITE)
        write(req_tr);
      else
        read(req_tr);
      resp_port.put(req_tr);
    end
  endtask

endclass

