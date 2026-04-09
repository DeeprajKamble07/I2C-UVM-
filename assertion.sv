module i2c_assertion(input clk,rst,rw,start, scl, sda,
                     input [6:0] addr,
                     input [7:0] datain);
  
  

  property p1;
    @(posedge clk)
    $fell(rst) |-> ##[1:5] scl;
  endproperty
    
  assert property(p1)
      else
        `uvm_error("ASSERT","scl not released high after rst");
      
  property p2;
    @(posedge clk)
    $fell(rst) |-> ##[1:5] sda;
  endproperty
    
    assert property(p2)
      else
        `uvm_error("ASSERT","sda not released high after rst");
      
  property p3;
    @(posedge clk) disable iff(rst)
    (start && !rst) |-> (addr==7'h32);
  endproperty
      
      assert property(p3)
        else 
          `uvm_error("ASSERT","transfer started with wrong slave addr");
          
endmodule
