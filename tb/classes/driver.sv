
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
      @vmem_if.cbm;
    vmem_if.cbm.address <= tr.addr;
    vmem_if.cbm.read    <= 1;
    do
      @vmem_if.cbm;
    while(vmem_if.cbm.waitrequest);
    vmem_if.cbm.read <= 0;
    while(!vmem_if.cbm.readdatavalid)
      @vmem_if.cbm;
    tr.rddata = vmem_if.cbm.readdata;
    foreach(cbs[i])
      cbs[i].post_read(tr);
    if(DBG_LEVEL > 0)
      $display("@%t [read] addr - %0d. data - %h",$time(),tr.addr,tr.rddata);
  endtask

  task write(amm_transaction tr);
    repeat(tr.gap)
      @vmem_if.cbm;
    vmem_if.cbm.address   <= tr.addr;
    vmem_if.cbm.writedata <= tr.wrdata;
    vmem_if.cbm.write     <= 1;
    do
      @vmem_if.cbm;
    while(vmem_if.cbm.waitrequest);
    vmem_if.cbm.write     <= 0;
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

