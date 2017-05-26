`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:24:56 01/18/2017 
// Design Name: 
// Module Name:    counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module counter(count,enable,clk,reset);
	output [3:0]count;
   reg [3:0] count;
	input enable,clk,reset;
	reg clocking;
	wire clk_ibufg;
	wire clk_int;
	reg[26:0] slow_count=27'b000000000000000000000000000;
	initial count = 4'b0;
   IBUFG clk_ibufg_inst(.I(clk), .O(clk_ibufg));
	BUFG clk_bufg_inst (.I(clk_ibufg), .O(clk_int));
   always @(posedge clk_int)
	begin
		if(slow_count == 27'b111111111111111111111111111)
      begin
			clocking =~ clocking;
			slow_count <= 0;
		end
		else
			slow_count <= slow_count+1;
	
		if (reset)
			count <= 4'b0;
		else if(enable) 
			count <= count + 1;
	end

endmodule
