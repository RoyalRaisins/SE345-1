`timescale 1ns/1ns
module stopwatch_top;

reg clk;
initial clk=0;
always #10 clk=~clk;

stopwatch_01 sw(clk,1,1,1,hex0,hex1,hex2,hex3,hex4,hex5,led0,led1,led2,led3);
endmodule