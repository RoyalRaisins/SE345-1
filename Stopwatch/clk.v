`timescale 1ns/1ns
module clk(clk);
output clk;
reg clk;
initial
begin
clk = 0;
end

always #10 clk = ~clk;
endmodule