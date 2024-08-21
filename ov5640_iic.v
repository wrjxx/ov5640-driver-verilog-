`timescale	1ns/1ns

//已验证    11 

module		ov5640_iic(

	input		sclk,

	input		s_rst_n,

		

	//data input

	input		[31:0]	w_data,

	input		start,

	output		reg		[7:0]	riic_data,

	output		reg				busy,

	

	//iic

	output		reg		iic_clk,

	inout				iic_sda



);



reg		[31:0]		w_data_reg;

reg		[5:0]		cfg_cnt;

reg					iic_sda_reg;

reg					flag_ack;

reg		[3:0]		delay_cnt;

reg					done;



wire				dir;



//保存需要发送的数据--y

always @(posedge sclk or negedge s_rst_n) begin

	if(s_rst_n == 1'b0)

		w_data_reg <= 'd0;

	else if(start == 1'b1)

		w_data_reg <= w_data;

end



//iic时钟--y

always @(posedge sclk or negedge s_rst_n) begin

	if(s_rst_n == 1'b0)

		iic_clk <=  1'b1;

	else if(start == 1'b1)

		iic_clk <= 1'b0;

	else if(cfg_cnt == 'd28 && dir ==1'b1 && delay_cnt <='d3)

		iic_clk		<= 1'b1;

	else if(busy == 1'b1)

		iic_clk <= ~iic_clk;

	else iic_clk <=  1'b1;

end



//主机一次任务，代表主机忙--y

always @(negedge sclk or negedge s_rst_n) begin

	if(s_rst_n == 1'b0)

		busy <= 1'b0;

	else if(start == 1'b1)

		busy <= 1'b1;

	else if(done == 1'b1)

		busy <= 1'b0;

end



//发送比特计数--y

always @(negedge sclk or negedge s_rst_n) begin

	if(s_rst_n == 1'b0)

		cfg_cnt <= 'd0;

	else if((cfg_cnt >= 'd47 && dir == 1'b1) || (cfg_cnt >= 'd37 && dir == 1'b0))

		cfg_cnt <= 'd0;

	else if(cfg_cnt == 'd28 && delay_cnt <= 'd4 && dir == 1'b1)

		cfg_cnt <= 'd28;

	else if(busy == 1'b1 && iic_clk ==1'b0)

		cfg_cnt <= cfg_cnt + 1'b1;

end



//读出数据---y

always @(negedge sclk or negedge s_rst_n) begin

	if(s_rst_n == 1'b0)

		riic_data <= 'd0;

	else if(iic_clk == 1'b1 && cfg_cnt >= 'd38 && flag_ack ==1'b1)

		riic_data	<= {riic_data[6:0],iic_sda};

end



//一次读写任务结束-----y

always @(negedge sclk or negedge s_rst_n) begin

	if(s_rst_n == 1'b0)

		done <= 1'b0;

	else if(dir == 1'b1 && cfg_cnt == 'd46 && iic_clk == 1'b1)

		done	<= 	1'b1;

	else if(dir == 1'b0 && cfg_cnt == 'd36 && iic_clk == 1'b1)

		done	<= 	1'b1;

	else done	<= 	1'b0;

end



//产生停起信号 ---------y

always @(posedge sclk or negedge s_rst_n) begin

	if(s_rst_n == 1'b0)

		delay_cnt <= 'd0; 	

	else if(dir == 1'b1 && cfg_cnt == 'd28)

		delay_cnt <= delay_cnt + 1'b1; 

	else 

		delay_cnt <= 'd0;

end	



//写1；读0    flag区分输出和高阻态-----y

always @(*) begin

	if(dir == 1'b1 && (cfg_cnt =='d9 || cfg_cnt =='d18 ||cfg_cnt =='d27 ||(cfg_cnt >='d37 &&cfg_cnt <='d45)))

		flag_ack		<=1'b1;  //接受

	else if(dir == 1'b0 && (cfg_cnt =='d9 || cfg_cnt =='d18 ||cfg_cnt =='d27 ||cfg_cnt =='d36))

		flag_ack		<=1'b1;  

	else	flag_ack		<=1'b0;

end

		

//输出数据------------y

always @(*) begin

	if(dir == 1'b1)		//读

		case(cfg_cnt)

			0:

				if(busy == 1'b1)

					iic_sda_reg = 1'b0;

				else	iic_sda_reg = 1'b1;

			//ID Address

			1:		iic_sda_reg = w_data_reg[31];

			2:		iic_sda_reg = w_data_reg[30];

			3:		iic_sda_reg = w_data_reg[29];

			4:		iic_sda_reg = w_data_reg[28];

			5:		iic_sda_reg = w_data_reg[27];

			6:		iic_sda_reg = w_data_reg[26];

			7:		iic_sda_reg = w_data_reg[25];

			8:		iic_sda_reg = 1'b0;  //写地址

			

			//Address High	Byte

			10:		iic_sda_reg = w_data_reg[23];

			11:		iic_sda_reg = w_data_reg[22];

			12:		iic_sda_reg = w_data_reg[21];

			13:		iic_sda_reg = w_data_reg[20];

			14:		iic_sda_reg = w_data_reg[19];			

			15:		iic_sda_reg = w_data_reg[18];

			16:		iic_sda_reg = w_data_reg[17];

			17:		iic_sda_reg = w_data_reg[16];

			

			//Address	Low	Byte

			19:		iic_sda_reg = w_data_reg[15];

			20:		iic_sda_reg = w_data_reg[14];

			21:		iic_sda_reg = w_data_reg[13];

			22:		iic_sda_reg = w_data_reg[12];

			23:		iic_sda_reg = w_data_reg[11];

			24:		iic_sda_reg = w_data_reg[10];			

			25:		iic_sda_reg = w_data_reg[9];

			26:		iic_sda_reg = w_data_reg[8];

			

			//STOP & START

			28:

					if(delay_cnt <= 'd1 || delay_cnt >= 'd4)

						iic_sda_reg =		1'b0;

					else

						iic_sda_reg =		1'b1;

						

			//ID		Address

			29:		iic_sda_reg = w_data_reg[31];

			30:		iic_sda_reg = w_data_reg[30];

			31:		iic_sda_reg = w_data_reg[29];

			32:		iic_sda_reg = w_data_reg[28];

			33:		iic_sda_reg = w_data_reg[27];

			34:		iic_sda_reg = w_data_reg[26];			

			35:		iic_sda_reg = w_data_reg[25];

			36:		iic_sda_reg = w_data_reg[24]; //读数据

			

			47:		iic_sda_reg = 1'b0;

			default:iic_sda_reg = 1'b1;		

		endcase

	else		//写

		case(cfg_cnt)

			0:

				if(busy == 1'b1)

					iic_sda_reg = 1'b0;

				else	iic_sda_reg = 1'b1;

			//ID Address

			1:		iic_sda_reg = w_data_reg[31];

			2:		iic_sda_reg = w_data_reg[30];

			3:		iic_sda_reg = w_data_reg[29];

			4:		iic_sda_reg = w_data_reg[28];

			5:		iic_sda_reg = w_data_reg[27];

			6:		iic_sda_reg = w_data_reg[26];

			7:		iic_sda_reg = w_data_reg[25];

			8:		iic_sda_reg = 1'b0;  //写地址

			

			//Address High	Byte

			10:		iic_sda_reg = w_data_reg[23];

			11:		iic_sda_reg = w_data_reg[22];

			12:		iic_sda_reg = w_data_reg[21];

			13:		iic_sda_reg = w_data_reg[20];

			14:		iic_sda_reg = w_data_reg[19];			

			15:		iic_sda_reg = w_data_reg[18];

			16:		iic_sda_reg = w_data_reg[17];

			17:		iic_sda_reg = w_data_reg[16];

			

			//Address	Low	Byte

			19:		iic_sda_reg = w_data_reg[15];

			20:		iic_sda_reg = w_data_reg[14];

			21:		iic_sda_reg = w_data_reg[13];

			22:		iic_sda_reg = w_data_reg[12];

			23:		iic_sda_reg = w_data_reg[11];

			24:		iic_sda_reg = w_data_reg[10];			

			25:		iic_sda_reg = w_data_reg[9];

			26:		iic_sda_reg = w_data_reg[8];

			

			//STOP & START

			28:		iic_sda_reg = w_data_reg[7];

			29:		iic_sda_reg = w_data_reg[6];

			30:		iic_sda_reg = w_data_reg[5];

			31:		iic_sda_reg = w_data_reg[4];

			32:		iic_sda_reg = w_data_reg[3];

			33:		iic_sda_reg = w_data_reg[2];

			34:		iic_sda_reg = w_data_reg[1];			

			35:		iic_sda_reg = w_data_reg[0];

			

			37:		iic_sda_reg = 1'b0;

			default:iic_sda_reg = 1'b1;		

		endcase

	

	

	

	

end

	

//输入输出数据接口	 ---y

assign		iic_sda		=	(flag_ack == 1'b1)	?1'bz:iic_sda_reg;

//写0；读1    读：先写入要读的地址，再读     写：先写入要写的地址，再写

assign		dir			=	w_data_reg[24];  //y







endmodule