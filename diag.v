module diag (
	div_clk,
	rst_n,
	flash,
	diag_rx_data,
	diag_tx_data,
	diag_rd_en,
	diag_wr_en,
	diag_en,
	spi_done,
	diag_start,
	diag_end,
	data_part,
	diag_start_pos//data_part reset
);


input	div_clk;
input	rst_n;
input flash;
input spi_done;
input [7:0]diag_rx_data;
input diag_start;
input diag_end;
input [1:0]data_part;
output reg [7:0]diag_tx_data;
output reg diag_rd_en;
output reg diag_wr_en;
output reg diag_en;
output wire diag_start_pos;

reg diag_start_en;
reg diag_end_en;
reg diag_start_reg1;
reg diag_start_reg2;
reg [1:0]part_count;
reg [23:0]diag_reg;


parameter	adder_data = 2'b00;
parameter	h_data = 2'b01;
parameter	m_data = 2'b10;
parameter	l_data = 2'b11;
	
always @ (posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		begin
		diag_start_reg1 <= 1'b0;
		diag_start_reg2 <= 1'b0;
		end
	else 
		begin
		diag_start_reg1 <= diag_start;
		diag_start_reg2 <= diag_start_reg1;
		end
	end
	
assign diag_start_pos = diag_start_reg1 & ~diag_start_reg2;

always @ (posedge div_clk or negedge rst_n)
	begin
	if (!rst_n)
		diag_start_en <= 1'b0;
	else if (diag_start_pos) 
		diag_start_en <= 1'b1;
	else if (data_part == l_data && spi_done == 1'b1)
		diag_start_en <= 1'b0;
	end

always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		part_count <= 2'b0;
	else if (part_count == 2'b10)
		part_count <= 2'b0;
	else if (data_part == l_data && spi_done == 1'b1 )
		part_count <= part_count + 1'b1;
	end
	
always @ (posedge div_clk or negedge rst_n)
	begin
	if (!rst_n)
		diag_end_en <= 1'b0;
	else if (diag_end)
		diag_end_en <= 1'b1;
	else if (part_count == 2'b10)
		diag_end_en <= 1'b0;
	end
	
always @ (posedge div_clk or negedge rst_n)
	begin
	if (!rst_n)
		diag_en <= 1'b0;
	else if (diag_start_pos)
		diag_en <= 1'b1;
	else if (part_count == 2'b10)
		diag_en <= 1'b0;
	end
	
always @ (posedge div_clk or negedge rst_n)
	begin 
	if (!rst_n)
	begin
		diag_wr_en <= 1'b0;
		diag_rd_en <= 1'b0;
	end
	else if (diag_start_en)
		begin
		if (flash)
			diag_wr_en <= 1'b1;
		else if(spi_done)
			diag_wr_en <= 1'b0;
		else 
			diag_wr_en <= 1'b1;	
		end
	else if (diag_end_en && data_part == adder_data)
		begin
		if (flash)
			begin
			diag_wr_en <= 1'b1;
			diag_rd_en <= 1'b0;
			end
		else if(spi_done)
			begin
			diag_wr_en <= 1'b0;
			diag_rd_en <= 1'b0;
			end
		else 
			begin
			diag_wr_en <= 1'b1;
			diag_rd_en <= 1'b0;
			end
		end
	else if (diag_end_en)
		begin
		if (flash)
			begin
			diag_wr_en <= 1'b0;
			diag_rd_en <= 1'b1;
			end
		else if(spi_done)
			begin
			diag_wr_en <= 1'b0;
			diag_rd_en <= 1'b0;
			end
		else 
			begin
			diag_wr_en <= 1'b0;
			diag_rd_en <= 1'b1;
			end
		end
	else begin	
		diag_wr_en <= 1'b0;
		diag_rd_en <= 1'b0;
		end
	end

	
always @ (posedge div_clk or negedge rst_n)
	begin
	if (!rst_n)
		begin
		diag_tx_data <= 8'b0;
		diag_reg <= 24'b0;
		end
	else if (diag_start_en)
		begin
		case(data_part)
			adder_data: diag_tx_data <= 8'h00;
			h_data	:	diag_tx_data <= 8'h00;
			m_data	:	diag_tx_data <= 8'h00;
			l_data	:	diag_tx_data <= 8'b0000_0101;//SPI_READ -- 1   DIAG_REG --- 1
		endcase
		end
	else if (diag_end_en)
		begin
		case(data_part)
			adder_data: diag_tx_data <= 8'h30;
			h_data	:	diag_reg[23:16] <= diag_rx_data;
			m_data	:	diag_reg[15:8] <= diag_rx_data;
			l_data	:	diag_reg[7:0] <= diag_rx_data;
		endcase
		end
	end
endmodule
	
	