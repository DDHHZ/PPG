//data:2019/10/25 15:16
//This module is used for spi communication
module spi(
div_clk,
rst_n,
sclk,
spiste,
spisimo,
spisomi,
spi_done,
tx_data,
rx_data,
wr_en,
rd_en,
flag,
stage_rst
);
input flag;
input div_clk;
input rst_n;
input spisomi;
input wr_en;
input rd_en;
input stage_rst;
input [7:0]tx_data;
output reg spi_done;
output reg sclk;
output reg spisimo;
output reg spiste;
output reg [7:0] rx_data;
reg [3:0]spi_count;

always @(posedge div_clk or negedge rst_n)
	begin
	if(!rst_n)
		begin
		spi_count <= 4'b0;
		spi_done <= 1'b0;
		rx_data <= 8'b0;
		sclk <= 1'b0;
		spiste <= 1'b1;
		spisimo <= 1'b0;
		end
	else if (stage_rst)
		begin
		spi_count <= 4'b0;
		spi_done <= 1'b0;
		rx_data <= 8'b0;
		sclk <= 1'b0;
		spiste <= 1'b1;
		spisimo <= 1'b0;
		end
	else if (wr_en)
		begin
			spiste <= 1'b0;
			case(spi_count)
				4'd1,4'd3,4'd5,4'd7,
				4'd9,4'd11,4'd13:
					begin
						sclk <= 1'b1;
						spi_count <= spi_count + 1'b1;
						spi_done <= 1'b0;
					end
				4'd0:
					begin
						sclk <= 1'b0;
						spi_count <= spi_count +1'b1;
						spisimo <= tx_data[7];
						spi_done <= 1'b0;
					end
				4'd2:
					begin
						sclk <= 1'b0;
						spi_count <= spi_count +1'b1;
						spisimo <= tx_data[6];
						spi_done <= 1'b0;
					end
				4'd4:
					begin
						sclk <= 1'b0;
						spi_count <= spi_count +1'b1;
						spisimo <= tx_data[5];
						spi_done <= 1'b0;
					end
				4'd6:
					begin
						sclk <= 1'b0;
						spi_count <= spi_count +1'b1;
						spisimo <= tx_data[4];
						spi_done <= 1'b0;
					end
				4'd8:
					begin
						sclk <= 1'b0;
						spi_count <= spi_count +1'b1;
						spisimo <= tx_data[3];
						spi_done <= 1'b0;
					end
				4'd10:
					begin
						sclk <= 1'b0;
						spi_count <= spi_count +1'b1;
						spisimo <= tx_data[2];
						spi_done <= 1'b0;
					end
				4'd12:
					begin
						sclk <= 1'b0;
						spi_count <= spi_count +1'b1;
						spisimo <= tx_data[1];
						spi_done <= 1'b0;
					end
				4'd14:
					begin
						sclk <= 1'b0;
						spi_count <= spi_count +1'b1;
						spisimo <= tx_data[0];
						spi_done <= 1'b1;
					end
				4'd15:
					begin
						sclk <= 1'b1;
						spi_count <= spi_count +1'b1;
						spi_done <= 1'b0;
					end
			endcase
		end
	else if (rd_en)
		begin
		spiste <= 1'b0;
			case(spi_count)
				4'd0,4'd2,4'd4,4'd6,
				4'd8,4'd10,4'd12,4'd14:
					begin
						sclk <= 1'b0;
						spi_count <= spi_count + 1'b1;
						spi_done <= 1'b0;
					end
				4'd1:
					begin
						sclk <= 1'b1;
						spi_count <= spi_count +1'b1;
						rx_data[7] <= spisomi;
						spi_done <= 1'b0;
					end
				4'd3:
					begin
						sclk <= 1'b1;
						spi_count <= spi_count +1'b1;
						rx_data[6] <= spisomi;
						spi_done <= 1'b0;
					end
				4'd5:
					begin
						sclk <= 1'b1;
						spi_count <= spi_count +1'b1;
						rx_data[5] <= spisomi;
						spi_done <= 1'b0;
					end
				4'd7:
					begin
						sclk <= 1'b1;
						spi_count <= spi_count +1'b1;
						rx_data[4] <= spisomi;
						spi_done <= 1'b0;
					end
				4'd9:
					begin
						sclk <= 1'b1;
						spi_count <= spi_count +1'b1;
						rx_data[3] <= spisomi;
						spi_done <= 1'b0;
					end
				4'd11:
					begin
						sclk <= 1'b1;
						spi_count <= spi_count +1'b1;
						rx_data[2] <= spisomi;
						spi_done <= 1'b0;
					end
				4'd13:
					begin
						sclk <= 1'b1;
						spi_count <= spi_count +1'b1;
						rx_data[1] <= spisomi;
						spi_done <= 1'b0;
					end
				4'd15:
					begin
						sclk <= 1'b1;
						spi_count <= 4'b0;
						rx_data[0] <= spisomi;
						spi_done <= 1'b1;
					end
			endcase
		end				
	else if (flag)
		begin
			spi_count <= 4'b0;
			rx_data <= 8'b0;
			spi_done <= 1'b0;
			sclk <= 1'b0;
			spiste <= 1'b0;
			spisimo <= 1'b0;
		end
	else
		begin
		spi_count <= 4'b0;
			rx_data <= 8'b0;
			spi_done <= 1'b0;
			sclk <= 1'b0;
			spiste <= 1'b1;
			spisimo <= 1'b0;
		end	
	end	
endmodule 			