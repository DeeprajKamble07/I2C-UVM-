class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item)
  
  function new(string name="seq_item");
    super.new(name);
  endfunction
  
  rand logic rst, rw, start;
  rand logic [6:0] addr;
  rand logic [7:0] datain;
  logic scl,sda;
  logic [7:0] dataout;
endclass
