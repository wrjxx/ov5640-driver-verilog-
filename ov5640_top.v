`timescale	1ns/1ns
//检测完  l 12
module		ov5640_top(
	input		sclk_50m,	//zynq provide
	//input		sclk_24m,	//zynq provide
	input		s_rst_n,  //sys reset
	
	//ov5640 input
	input		 	    ov5640_pclk,	
	input		 	    ov5640_href,	
	input		 	    ov5640_vsync,
	input		[7:0] 	ov5640_data,
		
	//zynq 
	output		wire 	ov5640_pwdn,	
	output		wire 	ov5640_rst_n,	
	//output		wire 	ov5640_xclk, //ov5640 interal crystal provide
	output		wire 	ov5640_scl, 
	inout				iic_sda

);

reg		[8:0]	div_cnt;
wire			div_clk;
wire			ov5640_sccb_begin;

//assign		ov5640_xclk =	sclk_24m;
assign		div_clk =	div_cnt[8];

always @(posedge sclk_50m or negedge s_rst_n) begin
	if(s_rst_n == 1'b0)
		div_cnt <= 'd0;
	else 
		div_cnt <= div_cnt + 1'b1;
end

pwd		pwd_inst(
	.sclk				(sclk_50m),  
	.s_rst_n            (s_rst_n),

	.ov5640_pwdn        (ov5640_pwdn),//输出 
	.ov5640_rst_n       (ov5640_rst_n),

	.ov5640_sccb_begin  (ov5640_sccb_begin)
);


//与ov用iic通信（配置）的模块，时钟不能超过100k
ov5640_cfg		ov5640_cfg_inst(
	.sclk		(div_clk),
	.s_rst_n    (s_rst_n & ov5640_sccb_begin),
			
	.iic_clk    (ov5640_scl),
	.iic_sda    (iic_sda)

);



endmodule