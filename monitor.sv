class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  virtual intf vif;
  seq_item item;
  uvm_analysis_port #(seq_item) monitor_port;
  
  // Must match the driver's wait — sample AFTER the transaction is done
  // Slightly less than driver so we capture the stable dataout value
  
  localparam sample_delay=14000;
  
  function new(string name ="monitor", uvm_component parent);
    super.new(name,parent);
    monitor_port=new("monitor_port",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item=seq_item::type_id::create("item");
    if(!uvm_config_db #(virtual intf)::get(this,"*","vif",vif))
      begin
        `uvm_error("DRV","failed to get vif from config db");
      end
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(posedge vif.clk iff (vif.start==1'b1));
        item=seq_item::type_id::create("item");
        item.rst=vif.rst;
        item.addr=vif.addr;
        item.datain=vif.datain;
        item.rw=vif.rw;
        item.start=vif.start;
      
      if(vif.rst)
        begin
          `uvm_info("MON", $sformatf("rst=%0b rw=%0d addr=%0h dataout=%0h",
                  item.rst, item.rw, item.addr, item.dataout), UVM_LOW);
        monitor_port.write(item);
        end
      else
        begin
          repeat(sample_delay) @(posedge vif.clk);
          item.dataout=vif.dataout;
          `uvm_info("MON", $sformatf("rst=%0b rw=%0d addr=%0h datain=%0h dataout=%0h",item.rst, item.rw, item.addr, item.datain, item.dataout), UVM_LOW);
          monitor_port.write(item);
        end
    end
  endtask
endclass
