
class scoreboard;

  bit [31:0] ref_mem [*];

  function void put_write_transaction(amm_transaction tr);
    ref_mem[tr.addr] = tr.wrdata;
  endfunction

  function void check_read_transaction(amm_transaction tr);
    if(!ref_mem.exists(tr.addr))
    begin
      $display("[scoreboard] ERROR: Read from non-written address [0x%0h]!",tr.addr);
      $stop();
    end
    if(ref_mem[tr.addr] != tr.rddata)
    begin
      $display("[scoreboard] ERROR: Read invalid data!\nAddress: [0x%0h]. Written data: [0x%0h]. Read-out data: [0x%0h]",tr.addr,ref_mem[tr.addr],tr.rddata);
      $stop();
    end
  endfunction

endclass

