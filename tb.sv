// Code your testbench here
// or browse Examples

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "interface.sv"
`include "sequence_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "enivornment.sv"
`include "test.sv"
`include "assertion.sv"

module tb;
  logic clk;
  intf intff(clk);
  
  i2c_master dut1(.clk(intff.clk),.rst(intff.rst),.rw(intff.rw),.start(intff.start),.addr(intff.addr),.datain(intff.datain),.scl(intff.scl),.sda(intff.sda),.dataout(intff.dataout));
  
  i2c_slave #(.SLAVE_ADDR(7'h32)) dut2 (.scl(intff.scl),. sda(intff.sda));
  
  i2c_assertion dut3(.clk(intff.clk),.rst(intff.rst),.rw(intff.rw),.start(intff.start),.scl(intff.scl),.sda(intff.sda),.addr(intff.addr),.datain(intff.datain));
  
  initial begin
    clk=0;
    forever #5 clk=~clk;
  end
  
  initial begin
    uvm_config_db #(virtual intf)::set(null,"*","vif",intff);
  end
  
  initial begin
    run_test("test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end
endmodule



