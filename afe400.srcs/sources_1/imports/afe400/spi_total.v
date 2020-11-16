module spi_total(
	div_clk,
	rst_n,
	//adc_read_over,
	adc_rdy,
	sclk,
	spiste,
	spisimo,
	spisomi,
	conver,
	//brt_adj
	led_add1,
	led_add2,
	led_sub1,
	led_sub2,
	
	//diag
	diag_start,
	diag_end,
	led2,
	led1,
	aled1,
	aled2,
	afe_rdover
	);
input div_clk;
input rst_n;
input adc_rdy;
input spisomi;
input	led_add1;
input	led_add2;
input	led_sub1;
input led_sub2;
input diag_start;
input diag_end;
output sclk;
output spiste;
output spisimo;
output [23:0]led2;
output [23:0]led1;
output [23:0]aled1;
output [23:0]aled2;
output reg afe_rdover;
output conver;
//output adc_read_over;
reg [1:0]data_part;
reg flash;
//
reg conver_temp1,conver_temp2;

wire spi_done;
wire rd_en;
wire wr_en;
wire adc_rd_en;
wire adc_wr_en;
wire ini_rd_en;
wire ini_wr_en;
wire brt_rd_en;
wire brt_wr_en;
wire diag_rd_en;
wire diag_wr_en;
wire ini_over;

wire brt_adj_en;
wire diag_en;
wire [7:0]ini_tx_data;
wire [7:0]adc_tx_data;
wire [7:0]adc_rx_data;
wire [7:0]brt_tx_data;
wire [7:0]diag_tx_data;
wire [7:0]diag_rx_data;
wire [7:0]tx_data;
wire [7:0]rx_data;
wire brt_flag;
wire diag_start_pos;
wire stage_rst;



wire flag;
assign rd_en = ~ini_over ? ini_rd_en : brt_adj_en ? brt_rd_en : diag_en ? diag_rd_en : conver ? adc_rd_en :1'b0; 
assign wr_en = ~ini_over ? ini_wr_en : brt_adj_en ? brt_wr_en : diag_en ? diag_wr_en : conver ? adc_wr_en :1'b0;
assign tx_data = ~ini_over ? ini_tx_data : brt_adj_en ? brt_tx_data : diag_en ? diag_tx_data : conver ? adc_tx_data :8'b0;
assign adc_rx_data = (~brt_adj_en && ~diag_en && conver) ? rx_data: 8'b0;
assign diag_rx_data = diag_en ? rx_data: 8'b0;


assign flag = ~ini_over || conver || diag_en || brt_adj_en; 
assign stage_rst = (brt_flag &&(led_add1 || led_add2 || led_sub1 ||led_sub2)) || diag_start_pos;

spi u1(.spi_done(spi_done),
		 .spisomi(spisomi),
		 .sclk(sclk),
		 .spisimo(spisimo),
		 .spiste(spiste),
		 .wr_en(wr_en),
		 .rd_en(rd_en),
		 .tx_data(tx_data),
		 .rx_data(rx_data),
		 .div_clk(div_clk),
		 .rst_n(rst_n),
		 .stage_rst(stage_rst),
		 .flag(flag)
		 );
ini	u2(
	.div_clk(div_clk),
	.rst_n(rst_n),
	.ini_tx_data(ini_tx_data),
	.ini_wr_en(ini_wr_en),
	.ini_rd_en(ini_rd_en),
	.spi_done(spi_done),
	.flash(flash),
	.ini_over(ini_over),
	.data_part(data_part)
	);
	
adc	u3 (
	.div_clk(div_clk),
	.rst_n(rst_n),
	.flash(flash),
	.adc_rx_data(adc_rx_data),
	.adc_tx_data(adc_tx_data),
	.adc_rd_en(adc_rd_en),
	.adc_wr_en(adc_wr_en),
	.spi_done(spi_done),
	.adc_rdy(adc_rdy),
	//.adc_read_over(adc_read_over),
	.conver(conver),
	.data_part(data_part),
	.brt_adj_en(brt_adj_en),
	.diag_en(diag_en),
	.led2(led2),
	.led1(led1),
	.aled1(aled1),
	.aled2(aled2)
	);
	
brt_adj	u4(
	.div_clk(div_clk),
	.rst_n(rst_n),
	.flash(flash),
	.brt_tx_data(brt_tx_data),
	.brt_rd_en(brt_rd_en),
	.brt_wr_en(brt_wr_en),
	.brt_adj_en(brt_adj_en),
	.spi_done(spi_done),
	.led_add1(led_add1),
	.led_add2(led_add2),
	.led_sub1(led_sub1),
	.led_sub2(led_sub2),
	.data_part(data_part),
	.brt_flag(brt_flag)
);

diag	u5(
	.div_clk(div_clk),
	.rst_n(rst_n),
	.flash(flash),
	.diag_rx_data(diag_rx_data),
	.diag_tx_data(diag_tx_data),
	.diag_rd_en(diag_rd_en),
	.diag_wr_en(diag_wr_en),
	.diag_en(diag_en),
	.spi_done(spi_done),
	.diag_start(diag_start),
	.diag_end(diag_end),
	.data_part(data_part),
	.diag_start_pos(diag_start_pos)
);
//指出每一次8位完成进入下一个8位的阶段  一共4个阶段
always @(posedge div_clk or negedge rst_n)
	begin
	if (!rst_n)
		begin
		data_part <= 2'b00;
		flash <= 1'b0;
		end
	else if (brt_flag &&(led_add1 || led_add2 || led_sub1 ||led_sub2))
		data_part <= 2'b00;
	else if (diag_start_pos)
		data_part <= 2'b00;
	else if (spi_done)
		begin
		data_part <= data_part +1'b1;
		flash <= 1'b1;
		end
	else
		flash <= 1'b0;
	end
	
	//采集conver下降沿，表示此时已从AFE获取数据完毕，可发送到PC端
always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		begin
		conver_temp1 <= 1'b0;
		conver_temp2 <= 1'b0;
		end
	else
		begin
			conver_temp1 <= conver;
			conver_temp2 <= conver_temp1;
		end
	end

always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		afe_rdover <= 1'b0;
	else
		afe_rdover = ~conver_temp1&conver_temp2;
	end
endmodule

