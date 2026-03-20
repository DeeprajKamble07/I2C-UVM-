interface intf(input logic clk);
  logic rst, rw, start;
  logic [6:0] addr;
  logic [7:0] datain;
  logic [7:0] dataout;
  wire scl;
  wire sda;
endinterface
