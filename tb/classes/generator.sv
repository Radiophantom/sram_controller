
class generator;

  amm_transaction blueprint;

  mailbox #(amm_transaction) req_port;
  mailbox #(amm_transaction) resp_port;

  function new(
    mailbox #(amm_transaction) req_port,
    mailbox #(amm_transaction) resp_port
  );
    this.req_port   = req_port;
    this.resp_port  = resp_port;
    blueprint = new();
  endfunction

  int transaction_amount = 0;

  virtual task run();
    amm_transaction req_tr;
    repeat(transaction_amount)
    begin
      `SV_RAND_CHECK(blueprint.randomize());
      req_tr = blueprint.copy();
      req_port.put(req_tr);
      resp_port.get(req_tr);
    end
  endtask

endclass

