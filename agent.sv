class agent extends uvm_agent;
  `uvm_component_utils(agent)
  driver drv;
  monitor mon;
  sequencer sqnr;
  
  function new(string name="agent",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv=driver::type_id::create("drv",this);
    mon=monitor::type_id::create("mon",this);
    sqnr=sequencer::type_id::create("sqnr",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqnr.seq_item_export);
  endfunction
  
endclass
