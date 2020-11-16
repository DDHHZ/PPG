module brt_adj(
	div_clk,
	rst_n,
	flash,
	brt_tx_data,
	brt_rd_en,
	brt_wr_en,
	brt_adj_en,
	spi_done,
	led_add1,
	led_add2,
	led_sub1,
	led_sub2,
	data_part,
	brt_flag//reset data_part
	);
	input div_clk;
	input	rst_n;
	input spi_done;
	input led_add1;
	input led_add2;
	input led_sub1;
	input led_sub2;
	input flash;
	input [1:0]data_part;
	output reg brt_rd_en;
	output reg brt_wr_en;
	output reg [7:0]brt_tx_data;
	output reg brt_adj_en;
	output wire brt_flag;
	
	reg [7:0]led_value1;
	reg [7:0]led_value2;
	reg [15:0] adj_count;
	reg [1:0] part_count;
	
	parameter	adder_data = 2'b00;
	parameter	h_data = 2'b01;
	parameter	m_data = 2'b10;
	parameter	l_data = 2'b11;
	
//控制亮度调节速度
always @ (posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		adj_count <= 15'b0; 
	else if (adj_count == 16'd39999)
		adj_count <= 15'b0;
	else 
		adj_count <= adj_count + 1'b1;
	end
	
//亮度调节使能以及亮度值的调节
always @ (posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
	begin
		brt_adj_en <= 1'b0;
		led_value1 <= 8'h14;
		led_value2 <= 8'h14;
	end
	else if (adj_count == 15'b0 &&(led_add1 || led_add2 || led_sub1 ||led_sub2))
		begin
		brt_adj_en <= 1'b1;
		if(led_add1 && led_value1 !=  8'b1111_1111)
			led_value1 <= led_value1 + 1'b1;
		else if(led_add2 && led_value2 !=  8'b1111_1111)
			led_value2 <= led_value2 + 1'b1;
		else if(led_sub1 && led_value1 !=  8'b0)
			led_value1 <= led_value1 - 1'b1;
		else if(led_sub2 && led_value2 !=  8'b0)
			led_value2 <= led_value2 - 1'b1;
		end	
	else if (part_count == 2'b11)
		brt_adj_en <= 1'b0;
	end
assign brt_flag = (adj_count == 15'b0) ? 1'b1:1'b0;
always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		part_count <= 2'b0;
	else if (!brt_adj_en)
		part_count <= 2'b0;
	else if (data_part == l_data && spi_done == 1'b1 && brt_adj_en == 1'b1)
		part_count <= part_count + 1'b1;
	end
	
always @ (posedge div_clk or negedge rst_n)
	begin
	if (!rst_n)
	brt_tx_data <= 8'b0;
	else if (brt_adj_en)
		begin
		case({part_count,data_part})
			4'b00_00:brt_tx_data <= 8'b0;//control1 adder 
			4'b00_01:brt_tx_data <= 8'b0;//
			4'b00_10:brt_tx_data <= 8'b0;
			4'b00_11:brt_tx_data <= 8'b0;//SPI_READ  --   0
			4'b01_00:brt_tx_data <= 8'h22;//将相应的值写入寄存器 LED_Control_Register
			4'b01_01:brt_tx_data <= 8'b0;
			4'b01_10:brt_tx_data <= led_value1;//LED1 
			4'b01_11:brt_tx_data <= led_value2;//LED2
			4'b10_00:brt_tx_data <= 8'b0;//control1 adder 
			4'b10_01:brt_tx_data <= 8'b0;//
			4'b10_10:brt_tx_data <= 8'b0;
			4'b10_11:brt_tx_data <= 8'b000_0001;//SPI_READ  --   1
			default:brt_tx_data <= brt_tx_data;
		endcase
		end
	end			

always @ (posedge div_clk or negedge rst_n)
	begin
	if (!rst_n)
		begin
		brt_wr_en <= 1'b0;
		brt_rd_en <= 1'b0;
		end
	else begin
		brt_rd_en <= 1'b0;
		if (part_count == 2'b11)
			brt_wr_en <= 1'b0;
		else if (flash)
			brt_wr_en <= 1'b1;
		else if(spi_done)
			brt_wr_en <= 1'b0;
		else 
			brt_wr_en <= 1'b1;	
		end
	end
endmodule
