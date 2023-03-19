`timescale 1ns/1ps
module testbench;
 reg flick;
 reg reset;
 reg clk;
 wire [15:0] led_out;

 bound_flasher a0(.clock(clk), .reset(reset), .led_out(led_out), .flick(flick));
 
 always #5 clk = ~clk; //freq = 1GHz
 
 initial begin

 //Put code here
 clk = 0;
  reset = 0;
  flick = 1;
  #6 flick = 0;
  #500 flick = 1;
  #10 flick = 0;
  #148 flick = 1;
  #10 flick = 0;
  #200 flick = 1;
  #10 flick = 0;
  #1500 $finish;
  //end code
 end
initial begin
  $recordfile ("waves");
  $recordvars ("depth=0", testbench);
end


endmodule
