//data:2019/10/25 11:28
//This module is used to divide out clk from afe4400(4M) 
module clk_gen (
clk,
div_clk,
rst_n
);
input clk;								//afe4400 clk
input rst_n;
output reg div_clk;							//spi clk
/*parameter div_length = 4;			//div register length
parameter div_cof = 4'd9;			//div coffient
reg [div_length-1:0] div_count;	//div register
always @(posedge clk or negedge rst_n)
	begin
	if (!rst_n)
		div_count <= 4'b0;
	else if (div_count == div_cof)
		div_count <= 4'b0;
	else 
		div_count <= div_count +1'b1;
	end*/

always @(posedge clk or negedge rst_n)
	begin
	if (!rst_n)
		div_clk <= 1'b0;
	else //if(div_count == div_cof)
		div_clk <= ~div_clk;
	end
endmodule
