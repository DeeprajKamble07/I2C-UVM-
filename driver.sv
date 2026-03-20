
// half_period = sys_clk / (i2c_clk * 2) = 50_000_000 / 200_000 = 250 cycles
  // Full I2C transaction: START + 8 addr bits + ACK + 8 data bits + ACK + STOP
  // Each bit takes 2 half-periods (one low, one high) = 500 cycles per bit
  // Total bits: ~20 transitions + overhead -> 250 * 2 * 22 = 11000 cycles, use 15000 to be safe
  
class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)
  virtual intf vif;
  seq_item item;
  
  localparam transaction_cycles=15000;
  
  function new(string name ="driver", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item=seq_item::type_id::create("item");
    if(!uvm_config_db #(virtual intf)::get(this,"","vif",vif))
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
    seq_item_port.get_next_item(item);
    
    if(item.rst)
      begin
        vif.rst<=1;
        vif.start<=0;
        vif.addr<=0;
        vif.datain<=0;
        vif.rw<=0;
        repeat(4) @(posedge vif.clk);
        vif.rst=0;
        @(posedge vif.clk);
      end
    
      
    else if(!item.rst && !item.rw)
      begin
        vif.rst<=0;
        vif.addr<=item.addr;
        vif.datain<=item.datain;
        vif.rw<=0;
        @(posedge vif.clk);
        vif.start<=1;
        @(posedge vif.clk);
        vif.start<=0;
        repeat(transaction_cycles) @(posedge vif.clk);
      end
      
    
    else if(!item.rst && item.rw)
      begin
        vif.rst<=0;
        vif.addr<=item.addr;
        vif.rw<=1;
        @(posedge vif.clk);
        vif.start<=1;
        @(posedge vif.clk);
        vif.start<=0;
        repeat(transaction_cycles) @(posedge vif.clk);  
      end
      
      seq_item_port.item_done();
    end
  endtask
endclass
