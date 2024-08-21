`timescale	1ns/1ns

module		tb;

	reg		sclk_50m;
	reg		s_rst_n;
	
	wire		ov5640_pwdn ;   
	wire		ov5640_rst_n   ;
	wire		ov5640_scl    ; 
	wire		iic_sda		;
		
initial begin
		sclk_50m	=	1;
		s_rst_n <= 0;
		#100
		s_rst_n <= 1;

end

always		#10 		sclk_50m	=	~sclk_50m;





ov5640_top		ov5640_top_inst(
	.sclk_50m       (sclk_50m),	//zynq provide
	.s_rst_n        (s_rst_n),  //sys reset

	.ov5640_pclk    (),	
	.ov5640_href    (),	
	.ov5640_vsync   (),
	.ov5640_data    (),

	.ov5640_pwdn    (ov5640_pwdn    ),	
	.ov5640_rst_n   (ov5640_rst_n   ),	
	.ov5640_scl     (ov5640_scl     ), 
	.iic_sda		(iic_sda		)

);


endmodule