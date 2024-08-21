`timescale	1ns/1ns
//核对----y
module		pwd(
	input		sclk,
	input		s_rst_n,
	
	//control ov5640 power
	output	wire	ov5640_pwdn,
	output	wire	ov5640_rst_n,
	
	// sccb begin flag
	output	reg	ov5640_sccb_begin
);

localparam		DELAY_6MS	=	30_0000;
localparam		DELAY_2MS	=	10_0000;
localparam		DELAY_21MS	=	105_0000;

reg	[18:0]	cnt_6ms;
reg	[16:0]	cnt_2ms;
reg	[20:0]	cnt_21ms;

always @(posedge sclk or negedge s_rst_n) begin
	if(s_rst_n == 1'b0)
		cnt_6ms <= 'd0;
	else if(ov5640_pwdn == 1'b1)
		cnt_6ms <= cnt_6ms + 1'b1;
end

always @(posedge sclk or negedge s_rst_n) begin
	if(s_rst_n == 1'b0)
		cnt_2ms <= 'd0;
	else if(ov5640_pwdn == 1'b0 && ov5640_rst_n == 1'b0)
		cnt_2ms <= cnt_2ms + 1'b1;
end

always @(posedge sclk or negedge s_rst_n) begin
	if(s_rst_n == 1'b0)
		cnt_21ms <= 'd0;
	else if(ov5640_sccb_begin == 1'b1)
		cnt_21ms <= 'd0;
	else if(ov5640_rst_n == 1'b1 && ov5640_pwdn == 1'b0)
		cnt_21ms <= cnt_21ms + 1'b1;
end

always @(posedge sclk or negedge s_rst_n) begin
	if(s_rst_n == 1'b0)
		ov5640_sccb_begin <= 'd0;
	else if(cnt_21ms == DELAY_21MS)
		ov5640_sccb_begin <= 1'b1;
end

assign		ov5640_pwdn = (cnt_6ms >= DELAY_6MS)? 1'b0 : 1'b1;
assign		ov5640_rst_n = (cnt_2ms >= DELAY_2MS)? 1'b1 : 1'b0;  //给ov5640复位
//assign		ov5640_sccb_begin = (cnt_21ms >= DELAY_21MS)? 1'b1 : 1'b0; //给sccb可以通信

endmodule