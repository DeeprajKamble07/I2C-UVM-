class test extends uvm_test;
  `uvm_component_utils(test)
  enivornment env;
  i2c_rst seq1;
  i2c_write seq2;
  i2c_read seq3;
  
  function new(string name="test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=enivornment::type_id::create("env",this);
    seq1=i2c_rst::type_id::create("seq1");
    seq2=i2c_write::type_id::create("seq2");
    seq3=i2c_read::type_id::create("seq3");
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    seq1.start(env.agen.sqnr);
    #200;
    seq2.start(env.agen.sqnr);
    #200;
    seq3.start(env.agen.sqnr);
    #500;
    phase.drop_objection(this);
  endtask
endclass
