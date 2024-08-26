
class generator_ext extends generator;

  bit [31:0] mem_indx [$];

  function new(
    mailbox #(amm_transaction) req_port,
    mailbox #(amm_transaction) resp_port
  );
    super.new(req_port,resp_port);
  endfunction

  task run();
    amm_transaction req_tr;
    repeat(transaction_amount)
    begin
      if(mem_indx.size() == 0)
        `SV_RAND_CHECK(blueprint.randomize() with {op == WRITE;});
      else
        `SV_RAND_CHECK(blueprint.randomize() with {(op == READ) -> addr inside {mem_indx};solve op before addr;});
      req_tr = blueprint.copy();
      req_port.put(req_tr);
      resp_port.get(req_tr);
      if(req_tr.op == WRITE)
      begin
        if(mem_indx.find_index with (item == req_tr.addr) == '{})
          mem_indx.push_back(req_tr.addr);
      end
    end
  endtask

endclass

