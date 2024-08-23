
class driver #(
  parameter int ADDR_W,
  parameter int DATA_W
);

  int DBG_LEVEL = 0;

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
    vmem_if.address <= tr.addr;
    vmem_if.read    <= 1;
    do
      @(posedge vmem_if.clk);
    while(vmem_if.waitrequest);
    vmem_if.read <= 0;
    while(!vmem_if.readdatavalid)
      @(posedge vmem_if.clk);
    tr.rddata = vmem_if.readdata;
    if(DBG_LEVEL > 0)
      $display("[read] addr - %0d. data - %h",tr.addr,tr.rddata);
  endtask

  task write(amm_transaction tr);
    vmem_if.address   <= tr.addr;
    vmem_if.writedata <= tr.wrdata;
    vmem_if.write     <= 1;
    do
      @(posedge vmem_if.clk);
    while(vmem_if.waitrequest);
    vmem_if.write     <= 0;
    if(DBG_LEVEL > 0)
      $display("[write] addr - %0d. data - %h",tr.addr,tr.wrdata);
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

