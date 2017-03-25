`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:03:52 03/20/2017 
// Design Name: 
// Module Name:    AlarmClock 
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
module AlarmClock(clk_1,ncr,Adj_Min,Adj_Hour,AHour,AMinute);
	input clk_1,ncr,Adj_Min,Adj_Hour;		//set��ʾ�������ӣ�switch��ʾ��������
	output[7:0] AHour,AMinute;
	
		
	supply1 Vdd;
	supply0 Gnd;
	
//**************��***********************
counter6 M1(clk_1,ncr,MinH_En,AMinute[7:4]);
counter10 M2(clk_1,ncr,MinL_En,AMinute[3:0]);

//**************ʱ***********************
counter24 H(clk_1,ncr,Hour_En,AHour[7:4],AHour[3:0]);

assign MinL_En = Adj_Min?Vdd:Gnd;
assign MinH_En = Adj_Min?(AMinute[3:0]==4'd9):Gnd;
assign Hour_En = Adj_Hour?Vdd:Gnd;

endmodule
