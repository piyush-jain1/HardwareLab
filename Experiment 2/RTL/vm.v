//Group 9
//Mukul Verma 150101038
//Piyush Jain 150101046
//Saswata De 150101058
//Shubhanshu Verma 150101073


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:31:38 02/23/2017 
// Design Name: 
// Module Name:    vm 
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
module mod1(
	input [7:0] a,//input for storing the 8 bit number
	input clk,//clock
	output [7:0] bwire//output wire to display the 8 bit number
   );
	reg [7:0] b=0;
	assign bwire=b;//assign the output in b
	integer status;
	always
		status=a;//assign status as the output
	integer lim=1000000000,count=1,mycounter=0,n,arr[0:9],sum=0,sumss=0,l1,i,looper,value;//lim is used for the frequency of the board
	always @(posedge clk) begin
		mycounter=mycounter+1;//increase the counter till 10s
		if(mycounter==lim*count) begin
			if(count==1) begin//after 10s
				n=status;//store the number of integers in n
				b<=status;//display the entered number
				count=count+1;
			end
			else if(count<n+2) begin//get the n integers in a gap of 10s each
				b<=status;//show the result in the LED
				arr[count-2]=status;
				sum=sum+status;//calculate the sum of the integers in the loop itself
				sumss=sumss+status*status;//calulate the sum of squares of each number in the loop itself
				count=count+1;
			end
			else if(count==n+2) begin
				if(status==0) begin// if the entered number is 0
					b<=sum;// display the sum of the n numbers
				end
				else if(status==1) begin// if the entered number is 1
					b<=sum/n;// display the average of the n numbers
				end
				else if(status==2) begin//if the entered number is 2
					b<=sumss;//show the sum of square of the numbers
				end
				else begin// if the entered number is 3 or any other number
					l1=sumss/n-(sum/n)*(sum/n);//store the sum of standard deviation in l1
					for(looper=0;looper<50;looper=looper+1) begin//cacaulate the root of l1
						if(looper*looper<l1 || looper*looper==l1) begin
							value=looper;
						end
					end
					b<=value;//show the output which is the standard deviation
				end
			end
		end
	end
endmodule
