class driver_cbs_scb extends driver_cbs;

  scoreboard scb;

  function new(scoreboard scb);
    this.scb = scb;
  endfunction

  function void post_write(amm_transaction tr);
    scb.put_write_transaction(tr);
  endfunction

  function void post_read(amm_transaction tr);
    scb.check_read_transaction(tr);
  endfunction

endclass

class environment #(
  parameter int ADDR_W,
  parameter int DATA_W
);

  virtual avalon_mm_if #(ADDR_W,DATA_W) vmem_if;

  mailbox #(amm_transaction) gen2drv_mbx;
  mailbox #(amm_transaction) drv2gen_mbx;

  generator               gen;
  driver #(ADDR_W,DATA_W) drv;
  scoreboard              scb;

  function new(
    virtual avalon_mm_if #(ADDR_W,DATA_W) vmem_if
  );
    this.vmem_if    = vmem_if;
  endfunction

  function void build();
    gen2drv_mbx = new();
    drv2gen_mbx = new();

    gen = new(gen2drv_mbx,drv2gen_mbx);
    drv = new(gen2drv_mbx,drv2gen_mbx,vmem_if);
    gen.blueprint.ADDR_W = ADDR_W;
    gen.blueprint.DATA_W = DATA_W;

    scb = new();
    begin
      driver_cbs_scb drv_cb = new(scb);
      drv.cbs.push_back(drv_cb);
    end
  endfunction

  task reset();
    vmem_if.read  <= 1'b0;
    vmem_if.write <= 1'b0;
  endtask

  task run();
    fork
      gen.run();
      drv.run();
    join_any
    disable fork;
  endtask

  function void wrap_up();
  endfunction

endclass

