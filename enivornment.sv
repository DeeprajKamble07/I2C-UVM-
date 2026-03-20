class enivornment extends uvm_env;
  `uvm_component_utils(enivornment)
  agent agen;
  scoreboard scb;
  
  function new(string name="enivornment", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agen=agent::type_id::create("agen",this);
    scb=scoreboard::type_id::create("scb",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agen.mon.monitor_port.connect(scb.scb_port);
  endfunction
endclass
