class i2c_rst extends uvm_sequence;
  `uvm_object_utils(i2c_rst)
  function new(string name ="i2c_rst");
    super.new(name);
  endfunction
  
  task body();
    seq_item item1;
    item1=new();
    start_item(item1);
    item1.randomize() with {rst==1;};
    finish_item(item1);
  endtask
endclass

class i2c_write extends uvm_sequence;
  `uvm_object_utils(i2c_write)
  function new(string name ="i2c_write");
    super.new(name);
  endfunction
  
  task body();
    seq_item item2;
    item2=new();
    start_item(item2);
    item2.randomize() with {rst==0; rw==0; addr==7'h32;};
    finish_item(item2);
  endtask
endclass


class i2c_read extends uvm_sequence;
  `uvm_object_utils(i2c_read)
  function new(string name ="i2c_read");
    super.new(name);
  endfunction
  
  task body();
    seq_item item3;
    item3=new();
    start_item(item3);
    item3.randomize() with {rst==0; rw==1; addr==7'h32; datain==0;};
    finish_item(item3);
  endtask
endclass
