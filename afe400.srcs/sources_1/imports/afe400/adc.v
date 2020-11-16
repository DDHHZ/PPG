module adc (
	div_clk,
	rst_n,
	flash,
	adc_rx_data,
	adc_tx_data,
	adc_rd_en,
	adc_wr_en,
	spi_done,
	adc_rdy,
	//adc_read_over,
	conver,
	data_part,
	//
	brt_adj_en,
	diag_en,
	led2,
	led1,
	aled1,
	aled2
	);
	input div_clk;
	input	rst_n;
	input [7:0]adc_rx_data;
	input spi_done;
	input adc_rdy;
	input flash;
	input brt_adj_en;
	input diag_en;
	input [1:0]data_part;
	output reg adc_rd_en;
	output reg adc_wr_en;
	//output reg adc_read_over;
	output reg [7:0]adc_tx_data;
	output reg conver;
	reg	[7:0]adc_adder_data;
	
	output reg	[23:0]led1;
	output reg	[23:0]led2;
	output reg	[23:0]aled1;
	output reg	[23:0]aled2;
	
parameter	adder_data = 2'b00;
parameter	h_data = 2'b01;
parameter	m_data = 2'b10;
parameter	l_data = 2'b11;
	
	
//adc  模块工作信号
always @ (posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		conver <= 1'b0;
	else if (brt_adj_en || diag_en)
		conver <= 1'b0;
	else if (adc_rdy )
		conver <= 1'b1;
	else if (adc_tx_data == 8'h2e)
		conver <= 1'b0;
	end
	
	//当前进行哪个转换数据寄存器的读取,读转换数据的地址
always @ (posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		adc_tx_data <= 8'h2a;//LED2VAL:2A  ALED2VAL:2B  LED1VAL:2C  ALED1VAL:2D	
	else if (brt_adj_en || diag_en)
		adc_tx_data <= 8'h2a;
	else if (adc_rdy)
		adc_tx_data <= 8'h2a;
	else if(data_part == l_data && spi_done == 1'b1 && conver == 1'b1)
		adc_tx_data <= adc_tx_data + 1'b1;
	end
		
always @ (posedge div_clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
			led1 <= 24'b0;
			led2 <= 24'b0;
			aled1 <= 24'b0;
			aled2 <=24'b0;
			end
		else if (brt_adj_en || diag_en)
			begin
			led1 <= led1;
			led2 <= led2;
			aled1 <= aled1;
			aled2 <= aled2;
		end
		else if (spi_done)
			begin
			case({adc_tx_data[3:0],data_part})
				6'b1010_01:led2[23:16] <= adc_rx_data;
				6'b1010_10:led2[15:8]  <= adc_rx_data;
				6'b1010_11:led2[7:0]   <= adc_rx_data;
				6'b1011_01:aled2[23:16] <= adc_rx_data;
				6'b1011_10:aled2[15:8]  <= adc_rx_data;
				6'b1011_11:aled2[7:0]   <= adc_rx_data;
				6'b1100_01:led1[23:16] <= adc_rx_data;
				6'b1100_10:led1[15:8]  <= adc_rx_data;
				6'b1100_11:led1[7:0]   <= adc_rx_data;
				6'b1101_01:aled1[23:16] <= adc_rx_data;
				6'b1101_10:aled1[15:8]  <= adc_rx_data;
				6'b1101_11:aled1[7:0]   <= adc_rx_data;
				default:begin
					led1 <= led1;
					led2 <= led2;
					aled1 <= aled1;
					aled2 <= aled2;
				end
			endcase
			end
	end
				
				
			
//adc当前次读取数据结束信号		
/*always@ (posedge div_clk or negedge rst_n)
	begin
	if (!rst_n)
		begin
			adc_read_over <= 1'b0;
		end
	else if (adc_tx_data == 8'h2e)
		begin
			adc_read_over <= 1'b1;
		end
	else 
		begin
			adc_read_over <= 1'b0;
		end
	end*/
//读写信号的赋值
always @ (posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		begin
		adc_wr_en <= 1'b0;
		adc_rd_en <= 1'b0;
		end
	else if (brt_adj_en || diag_en)
		begin
		adc_wr_en <= 1'b0;
		adc_rd_en <= 1'b0;
		end
	else if (data_part == adder_data)
		begin
		if (flash)
			begin
			adc_wr_en <= 1'b1;
			adc_rd_en <= 1'b0;
			end
		else if(spi_done)
			begin
			adc_wr_en <= 1'b0;
			adc_rd_en <= 1'b0;
			end
		else 
			begin
			adc_wr_en <= 1'b1;
			adc_rd_en <= 1'b0;
			end
		end
	else begin
		if (flash)
			begin
			adc_wr_en <= 1'b0;
			adc_rd_en <= 1'b1;
			end
		else if(spi_done)
			begin
			adc_wr_en <= 1'b0;
			adc_rd_en <= 1'b0;
			end
		else 
			begin
			adc_wr_en <= 1'b0;
			adc_rd_en <= 1'b1;
			end
		end
	end
endmodule