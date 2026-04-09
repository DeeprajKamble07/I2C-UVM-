class coverage extends uvm_subscriber#(seq_item);
  `uvm_component_utils(coverage)
  seq_item item;
  
  covergroup cg1;
    cp_rst: coverpoint item.rst{bins rst_0= {0};
                                bins rst_1={1};}
    
    cp_rw: coverpoint item.rw{bins read={1};
                              bins write={0};}
    
    cp_start: coverpoint item.start{bins start_0={0};
                                    bins start_1={1};}
    
    cp_addr: coverpoint item.addr{bins low_addr={[0:31]};
                                  bins high_addr={[31:63]};}
    
    cp_rst_x_cp_addr: cross cp_rst, cp_addr;
    cp_rw_x_cp_addr: cross cp_rw, cp_addr;
    cp_rw_x_cp_start: cross cp_rw, cp_start;
    
  endgroup
  
  function new(string name="coverage", uvm_component parent);
    super.new(name, parent);
    cg1=new();
  endfunction
  
  function void write(seq_item t);
    item= t;
    cg1.sample();
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", $sformatf("Total Coverage= %.2f%%",cg1.get_coverage()),UVM_NONE);
  endfunction
endclass
