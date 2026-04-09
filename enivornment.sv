class enivornment extends uvm_env;
  `uvm_component_utils(enivornment)
  agent agen;
  scoreboard scb;
  coverage cov;
  
  function new(string name="enivornment", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agen=agent::type_id::create("agen",this);
    scb=scoreboard::type_id::create("scb",this);
    cov=coverage::type_id::create("cov",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agen.mon.monitor_port.connect(scb.scb_port);
    agen.mon.monitor_port.connect(cov.analysis_export);
  endfunction
endclass
