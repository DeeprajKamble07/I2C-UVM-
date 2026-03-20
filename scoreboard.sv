class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  uvm_analysis_imp #(seq_item, scoreboard) scb_port;
  
  bit [7:0] mem;
  bit [7:0] dout;
  
  function new(string name="scoreboard",uvm_component parent);
    super.new(name,parent);
    scb_port=new("scb_port",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  function void write(seq_item item);
    if(item.rst)
      begin
        mem=0;
        `uvm_info("SCB","system reset detection",UVM_NONE);
      end
    
    else if(item.rw==0)
      begin
        if(item.addr==7'h32)
          begin
            mem=item.datain;
            `uvm_info("SCB",$sformatf("WRITE: data %0h written into mem",item.datain),UVM_NONE);
          end
        else
          begin
            `uvm_error("SCB","WRITE: addr didnt match the slave addr");
          end
      end
    
    else if(item.rw==1)
      begin
        if(item.addr==7'h32)
          begin
            dout=mem;
            `uvm_info("SCB",$sformatf("dout %0h read from mem",dout),UVM_NONE);
            if(dout==item.dataout)
              begin
                `uvm_info("SCB PASS",$sformatf("datain=%0h dataout=%0h",item.datain,item.dataout),UVM_NONE);
              end
            else
              begin
                `uvm_error("SCB FAIL",$sformatf("datain=%0h dataout=%0h",item.datain,item.dataout));
              end
          end
        else
          begin
            `uvm_error("SCB","READ addr didnt match the slave addr");
          end
      end
  endfunction
endclass

        
    
