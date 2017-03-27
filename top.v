`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:59:50 03/15/2017 
// Design Name: 
// Module Name:    top 
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
//	manual comments:
//	����������ʱ��ʹ��˳��:��������ǰ 1.��setAL 2.��Adj_Min,Adj_Hour ������Ϻ�:	1.�ر�Adj_Min,Adj_Hour 2.�ر�setAL
//							  ����ʱ��ʱ 1.setAL�ر�״̬ 2.2.��Adj_Min,Adj_Hour
//	Լ��ʱ:	���а�������Ҫ�ò��뿪�� �����Լ��:gfedcba = Hex[6:0] Led�ߵ�λ��Ӧ˳�򲻱�
//
//////////////////////////////////////////////////////////////////////////////////
module top(clk_50,ncr,en,setAL,SwitchAL,Switch12,Adj_Min,Adj_Hour,Show,AN0,AN1,AN2,AN3,Led,Alarm,Clock_Led);  //���ź�ͨ��LED��ʾ������������

	input clk_50,ncr,en;						//ncr==0ʱ��Ч��en == 1ʱ��Ч
	input Adj_Min,Adj_Hour;					//=1ʱ��Ч
	input setAL,SwitchAL;					//���ӵ������뿪�� setAL == 1ʱ��������,SwitchAL == 1ʱ������������==0ʱ�رշ���
	input Switch12;
	
	output AN0,AN1,AN2,AN3;					//����ܵ�Ƭѡ�ź�
	output wire[6:0] Show;					//����ܵ�����ź�
	output wire[7:0] Led;					//LED������ź�
	output Alarm;								//���ӵ�����ź�
	output Clock_Led;							//���㱨ʱ�ź�
	

	supply1 Vdd;       					//��Դ
	supply0 Gnd;		 					//��

	wire[6:0] Hex0,Hex1,Hex2,Hex3;
	wire[7:0] Hour,Minute,Second;			//ʱ���ź�
	wire[7:0] AHour,AMinute;				//�����ź�
	wire[7:0] Show_Minute,Show_Hour;    //������ź�
	wire[7:0] Show_Hour12,Show_Hour24;  //12��24���Ƶ�Сʱ�ź�
	wire MinL_En,MinH_En,Hour_En;			//ʱ��ʹ���ź�
	wire AL_Adj_Min,AL_Adj_Hour;			//����ʹ���ź�
	
	wire clk_1;
	reg Clock_Led_En;     					//���㱨ʱʹ���ź�
	reg Clock_Led_Temp1;
	reg[5:0]Clock_Led_Cnt;					//���㱨ʱ�ƴ��ź�
	wire Clock_Led_Temp;						//���㱨ʱ ʱ�ź� 
	
//----------------------------------------------��Ƶ--------------------------------------------------
Divider50MHz U0(.clk_50M(clk_50),
					 .ncr(ncr),
					 .clk_1(clk_1));	 
//----------------------------------------------����-------------------------------------------------
//*************************��*******************************
counter6 S1(clk_1,ncr,en,Second[7:4]);
counter10 S2(clk_1,ncr,en,Second[3:0]);

//*************************��*******************************
counter6 M1(clk_1,ncr,MinH_En,Minute[7:4]);
counter10 M2(clk_1,ncr,MinL_En,Minute[3:0]);

//*************************ʱ*******************************
counter24 H(clk_1,ncr,Hour_En,Hour[7:4],Hour[3:0]);	

assign MinL_En = ((!setAL)&&Adj_Min)?Vdd:(Second==8'b0101_1001);
assign MinH_En = ((!setAL)&&Adj_Min)?(Minute[3:0]==4'd9):((Minute[3:0]==4'd9)&&(Second==8'b0101_1001));

assign Hour_En = ((!setAL)&&Adj_Hour)?Vdd:((Minute==8'b0101_1001)&&(Second==8'b0101_1001));
//----------------------------------------------���㱨ʱ-------------------------------------------------
//����Hour_En�ź����ж��Ƿ�������,Show_Hour�����ж���Clock_Led_Cnt�Ƿ���ͬ����ʾ���Ĵ���
always@(Show_Hour[5:4])
begin
	case(Show_Hour[5:4])
		2'b00:Clock_Led_Temp1 = 5'd0;
		2'b01:Clock_Led_Temp1 = 5'd10;
		2'b10:Clock_Led_Temp1 = 5'd20;
		default:Clock_Led_Temp1 = 5'd0;
	endcase
end

assign Clock_Led_Temp = Clock_Led_Temp1 + Show_Hour[3:0] + Clock_Led_Temp1 + Show_Hour[3:0];

always@(posedge clk_1)
begin
	if((!Adj_Min)&&(!Adj_Hour)&&(Hour_En))
		begin Clock_Led_En <= 1;Clock_Led_Cnt <= 6'd0;end
	else if(Clock_Led_Temp == Clock_Led_Cnt)
		begin Clock_Led_En <= 0;Clock_Led_Cnt <= 6'd0;end
	else
		begin Clock_Led_En <= Clock_Led_En;Clock_Led_Cnt <= Clock_Led_Cnt + 1'b1;end
end

assign Clock_Led = Clock_Led_En?Second[0]:Gnd;



//----------------------------------------------����-----------------------------------------------------
//--------------�ж�����setAL---------------
assign AL_Adj_Min = setAL && Adj_Min;	
assign AL_Adj_Hour =	setAL && Adj_Hour;		
AlarmClock AL1(clk_1,ncr,AL_Adj_Min,AL_Adj_Hour,AHour,AMinute);

assign Alarm = SwitchAL?((AHour == Hour)&&(AMinute == Minute)):Gnd;

//*****************�������ʾ**************
assign Show_Minute = setAL?AMinute:Minute;
assign Show_Hour24 = setAL?AHour:Hour;

//*****************��������****************
Seg7_Lut MinL(Show_Minute[3:0],Hex0);
Seg7_Lut MinH(Show_Minute[7:4],Hex1);

//----------------12��24֮��ת��-------------
Trans24To12 T12(Show_Hour24,ncr,Show_Hour12);

assign  Show_Hour= Switch12?Show_Hour12:Show_Hour24;
//*****************ʱ������******************
Seg7_Lut HouL(Show_Hour[3:0],Hex2);
Seg7_Lut HouH(Show_Hour[7:4],Hex3);

Show_Seg7 S3(Hex0,Hex1,Hex2,Hex3,clk_50,ncr,Show,AN0,AN1,AN2,AN3);

assign Led = Second;

endmodule
