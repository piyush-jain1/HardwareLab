//Group 9
//Mukul Vema 150101038
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
	input clk,// clock
	output [7:0] bwire//output to show the result
   );
	reg [7:0] b=0;
	assign bwire=b;// assign b as output bwire
	integer status;
	always
		status=a;//assign status as the input a
	integer lim=1000000000,count=1,mycounter=0,n,arr[0:9],sum=0,sumss=0,l1,i,looper=0,value=0;//lim is for thr frequency of the board
	always @(posedge clk) begin
		
		mycounter=mycounter+1;
		
		if(mycounter==lim*count) begin//start after 10 seconds
			if(count==1) begin
				n=status;//read the number N to store the N integers
				b<=status;//show the output in LED
				count=count+1;
			end
			else if(count<n+2) begin// input the N integers and show the ressult in LED with a gap og 10s
				b<=status;
				arr[count-2]=status;
				count=count+1;
			end
			else if(count==n+2) begin//if status(enterd number via switches)==0, show the sum of the N numbers
				if(status==0) begin
					sum=0;
					for(i=0;i<10&&i<n;i=i+1) begin//calculating the sum of the N numbers
						sum=sum+arr[i];
					end
					b<=sum;//output the result in the LED
				end
				else if(status==1) begin//if entered number is 1, show the average of the N numbers
					sum=0;
					for(i=0;i<10&&i<n;i=i+1) begin
						sum=sum+arr[i];
					end
					b<=sum/n;//output the result in the LED
				end
				else if(status==2) begin// if the entered number is 2, show the sum of the squares
					sumss=0;
					for(i=0;i<10&&i<n;i=i+1) begin
						sumss=sumss+arr[i]*arr[i];
					end
					b<=sumss;//output the result in the LED
				end
				else begin
					sum=0;
					sumss=0;
					for(i=0;i<10&&i<n;i=i+1) begin// if the entered number is 3(or any other number), show the standard deviation 
						sum=sum+arr[i];
						sumss=sumss+arr[i]*arr[i];
					end
					l1=sumss/n-(sum/n)*(sum/n);//store the square of standard deviation in l1
					for(looper=0;looper<50;looper=looper+1) begin//calculating the square root of l1 
						if(looper*looper<l1 || looper*looper==l1) begin
							value=looper;
						end
					end
					b<=value;//output the result in the LED
				end
			end
		end
	end
endmodule
