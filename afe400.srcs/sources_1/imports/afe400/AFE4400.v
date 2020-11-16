module AFE4400 (
	clk,
//	clk_50,
	rst_n,
	//swc,
//	data_rec,
	//clk_40,
	alm,    //信号采集时发送数据警告

	//uart
//	nrst,
	uart_txd,
	
	//采集板a信号
	//afe_pdnz_fpga_a,
	adc_rdy_a,	
	spiste_a,
	spisimo_a,
	spisomi_a,
	sclk_a,
	//pd_alm_a,
	//led_alm_a,
	afe4400_rst_n_a,
	afe_pdnz_a,
	diag_end_a,
	//pd_alm_fpga_a,
	//led_alm_fpga_a,
	/*
	//采集板b信号
	afe_pdnz_fpga_b,
	adc_rdy_b,	
	spiste_b,
	spisimo_b,
	spisomi_b,
	sclk_b,
	pd_alm_b,
	led_alm_b,
	afe4400_rst_n_b,
	afe_pdnz_b,
	diag_end_b,
	pd_alm_fpga_b,
	led_alm_fpga_b,
	*/
	//brt_adj  和 diag
	diag_start,
	led_add1,
	led_add2,
	led_sub1,
	led_sub2,
	
	dataReady,
	dataReady_a
	//dataReady_b
	
);
input clk;    				//afe4400 4M  clock  采集板1时钟 最为程序主时钟
//input clk_50;
//input nrst;       		//串口复位信号
output uart_txd;  		//串口发送端	
input	rst_n;		 		//FPGA发送复位信号，作为两个采集板共用复位信号	
input	led_add1;			//FPGA输入LED1加亮度
input	led_add2;			//FPGA输入LED2加亮度
input	led_sub1;			//FPGA输入LED1减亮度
input	led_sub2;			//FPGA输入LED2减亮度
input diag_start;  		//FPAG输入开始诊断
//input swc;					//选择端口，选择哪个采集板进行诊断和亮度调节操作
wire data_rec;			//发送数据前8位标志位 显示或者显示并记录
assign data_rec = 1'b1;
//input afe_pdnz_fpga_a;	//FPGA输入power down信号
input adc_rdy_a;  		//ADC conversion data ready signal
//input pd_alm_a;			// photodiode diagnose signal
//input led_alm_a; 			// led diagnose signal
input diag_end_a; 		//diagnose finished signal
input spisomi_a; 			//slave output master input
output spisimo_a; 		//slave input master output
output spiste_a;			//spi enable
output sclk_a;  			//spi clk
output afe_pdnz_a;
//output pd_alm_fpga_a;	
//output led_alm_fpga_a;
output afe4400_rst_n_a;

/*
input afe_pdnz_fpga_b;
input adc_rdy_b;  			//ADC conversion data ready signal
input pd_alm_b;				// photodiode diagnose signal
input led_alm_b; 			// led diagnose signal
input diag_end_b; 			//diagnose finished signal
input spisomi_b; 			//slave output master input
output spisimo_b; 			//slave input master output
output spiste_b;				//spi enable
output sclk_b;  				//spi clk
output afe_pdnz_b;
output pd_alm_fpga_b;	
output led_alm_fpga_b;
output afe4400_rst_n_b;
*/

wire div_clk;
wire afe_rdover_a;

wire afe_rdover_b;
wire uart_rdover;
output reg dataReady;
output reg dataReady_a;
//output reg dataReady_b;
output reg alm;

reg [47:0] tx_data;

wire signed [23:0] led2_afe_spi_a;
wire signed [23:0] led1_afe_spi_a;
wire signed [23:0] aled1_afe_spi_a;
wire signed [23:0] aled2_afe_spi_a;
wire signed [23:0] led2_a;
wire signed [23:0] led1_a;
wire diag_start_a;
wire led_add1_a;
wire led_add2_a;
wire led_sub1_a;
wire led_sub2_a;
wire conver_a;
reg adc_rdy_temp_a;
reg [4:0] count_a;

/*
wire signed [23:0] 	led2_afe_spi_b;
wire signed [23:0] 	led1_afe_spi_b;
wire signed [23:0]	aled1_afe_spi_b;
wire signed [23:0]	aled2_afe_spi_b;
wire signed [23:0]	led2_b;
wire signed [23:0]	led1_b;

wire diag_start_b;
wire led_add1_b;
wire led_add2_b;
wire led_sub1_b;
wire led_sub2_b;

wire conver_b;
reg adc_rdy_temp_b;
reg [4:0] count_b;
*/

//output clk_40;
//output clk_100;

//a采集板
assign afe_pdnz_a = rst_n;
assign afe4400_rst_n_a = rst_n;
//assign pd_alm_fpga_a = pd_alm_a;
//assign led_alm_fpga_a = led_alm_a;
assign led2_a = led2_afe_spi_a - aled2_afe_spi_a;
assign led1_a = led1_afe_spi_a - aled1_afe_spi_a;
assign led_add1_a = 1'b1 ? led_add1 : 1'b1;
assign led_add2_a = 1'b1 ? led_add2 : 1'b1;
assign led_sub1_a = 1'b1 ? led_sub1 : 1'b1;
assign led_sub2_a = 1'b1 ? led_sub2 : 1'b1;
assign diag_start_a = 1'b1 ? diag_start : 1'b0;
/*
//b采集板
assign pd_alm_fpga_b = pd_alm_b;
assign led_alm_fpga_b = led_alm_b;
assign afe_pdnz_b = afe_pdnz_fpga_b;
assign afe4400_rst_n_b = rst_n;
assign led2_b = led2_afe_spi_b - aled2_afe_spi_b;
assign led1_b = led1_afe_spi_b - aled1_afe_spi_b;
assign led_add1_b = swc ? 1'b1 : led_add1;
assign led_add2_b = swc ? 1'b1 : led_add2;
assign led_sub1_b = swc ? 1'b1 : led_sub1;
assign led_sub2_b = swc ? 1'b1 : led_sub2;
assign diag_start_b = swc ? 1'b0 : diag_start;
*/


//扩宽adc_rdy信号，以便2M时钟能够采到
always@(posedge clk or negedge rst_n)
	begin
	if (!rst_n)
		count_a <= 5'b0;
	else if (count_a == 5'd3)
		count_a <= 5'b0;
	else if (count_a >= 5'b1)
		count_a <= count_a + 1'b1;
	else if (adc_rdy_a)
		count_a <= 5'b1;
	end
always@(posedge clk or negedge rst_n)
	begin
	if (!rst_n)
		adc_rdy_temp_a <= 1'b0;
	else if (count_a == 5'b0)
		adc_rdy_temp_a <= 1'b0;
	else 
		adc_rdy_temp_a <= 1'b1;
	end
/*	
always@(posedge clk or negedge rst_n)
	begin
	if (!rst_n)
		count_b <= 5'b0;
	else if (count_b == 5'd3)
		count_b <= 5'b0;
	else if (count_b >= 5'b1)
		count_b <= count_b + 1'b1;
	else if (adc_rdy_b)
		count_b <= 5'b1;
	end
	
always@(posedge clk or negedge rst_n)
	begin
	if (!rst_n)
		adc_rdy_temp_b <= 1'b0;
	else if (count_b == 5'b0)
		adc_rdy_temp_b <= 1'b0;
	else 
		adc_rdy_temp_b <= 1'b1;
	end

pll		i5(
	.areset(~rst_n),
	.inclk0(clk_50),
	.c0(clk_40)//,
//	.c1(clk_100)
	);
*/	
clk_gen	i0(
	.clk(clk),
	.div_clk(div_clk),
	.rst_n(rst_n)
);

spi_total	i1( 
	.div_clk(div_clk),
	.rst_n(rst_n),
	//adc_read_over,
	.adc_rdy(adc_rdy_temp_a),
	.sclk(sclk_a),
	.spiste(spiste_a),
	.spisimo(spisimo_a),
	.spisomi(spisomi_a),
	.conver(conver_a),
	
	//brt_adj
	.led_add1(~led_add1_a),
	.led_add2(~led_add2_a),
	.led_sub1(~led_sub1_a),
	.led_sub2(~led_sub2_a),
	
	//diag
	.diag_start(diag_start_a),
	.diag_end(diag_end_a),
	.led2(led2_afe_spi_a),
	.led1(led1_afe_spi_a),
	.aled2(aled2_afe_spi_a),
	.aled1(aled1_afe_spi_a),
	.afe_rdover(afe_rdover_a)
);
/*
spi_total	i2( 
	.div_clk(div_clk),
	.rst_n(rst_n),
	//adc_read_over,
	.adc_rdy(adc_rdy_temp_b),
	.sclk(sclk_b),
	.spiste(spiste_b),
	.spisimo(spisimo_b),
	.spisomi(spisomi_b),
	
	//brt_adj
	.led_add1(~led_add1_b),
	.led_add2(~led_add2_b),
	.led_sub1(~led_sub1_b),
	.led_sub2(~led_sub2_b),
	
	//diag
	.diag_start(diag_start_b),
	.diag_end(diag_end_b),
	.led2(led2_afe_spi_b),
	.led1(led1_afe_spi_b),
	.aled2(aled2_afe_spi_b),
	.aled1(aled1_afe_spi_b),
	.afe_rdover(afe_rdover_b)
);
*/

uart 		i3(
	.nrst(rst_n),
	.sysClk(div_clk),
	.dataReady(dataReady),
	.indata(tx_data),
	.rdover(uart_rdover),
	.uartTxd(uart_txd),
	.data_rec(data_rec)
	);
	
	
//uart 交互信号	
always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		dataReady_a <= 1'b0;
	else 
	begin
		if(uart_rdover)
			dataReady_a <= 1'b0;
		else if(afe_rdover_a)
			dataReady_a <= 1'b1;
	end
end
/*
always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		dataReady_b <= 1'b0;
	else 
	begin
		if(uart_rdover)
			dataReady_b <= 1'b0;
		else if(afe_rdover_b)
			dataReady_b <= 1'b1;
	end
end
*/
always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		dataReady <= 1'b0;
	else 
	begin
		if(uart_rdover)
			dataReady <= 1'b0;
		else if(dataReady_a /*&& dataReady_b*/)
			dataReady <= 1'b1;
	end
end

always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		tx_data <= 47'b0;
	else 
		tx_data <= {{3{led2_a[21]}},led2_a[20:0],{3{led1_a[21]}},led1_a[20:0]};
						/*{3{led2_b[21]}},led2_b[20:0],{3{led1_b[21]}},led1_b[20:0]*/
	end
	
	
	
//发送串口信号在采集信号时的警告信号
always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		alm <= 1'b0;
	else if (dataReady)
		begin
		if (conver_a == 1'b1 /*|| conver_b == 1'b1*/)
			alm <= 1'b1;
		else 
			alm <= 1'b0;
		end
	else
		alm <= alm;
	end
	
endmodule
